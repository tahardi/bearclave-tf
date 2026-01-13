locals {
  firewall_rules = "bcl-sev-snp"
  network        = "default"
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.15"
    }
  }
}

provider "google" {
  project = var.project_id
  zone    = var.zone
}

# Definition for our SEV-SNP enabled Compute instance
resource "google_compute_instance" "bcl_sev_snp" {
  name             = var.instance_name
  machine_type     = var.machine_type
  zone             = var.zone
  project          = var.project_id
  min_cpu_platform = "AMD Milan"

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  confidential_instance_config {
    enable_confidential_compute = true
    confidential_instance_type  = "SEV_SNP"
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  # Scheduling configuration
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "TERMINATE"
  }

  # (LOW): Instance disk encryption does not use a customer managed key.
  # trivy:ignore:AVD-GCP-0033
  boot_disk {
    initialize_params {
      # Choose a SEV_SNP_CAPABLE VM image to use
      image = "projects/cos-cloud/global/images/cos-stable-121-18867-294-76"
      size  = 16
    }
  }


  # Depends on how you use the module. You could just as easily pass a different
  # SSH key for every instance you create. Not worth enforcing via the module.
  #
  # (MEDIUM): Instance allows use of project-level SSH keys.
  # trivy:ignore:AVD-GCP-0030
  metadata = {
    enable-oslogin                = "TRUE"
    google-compute-default-scopes = "cloud-platform"
    google-logging-enabled        = "true"
    google-monitoring-enabled     = "true"
    ssh-keys                      = "root:${var.ssh_public_key}"
    user-data = base64encode(templatefile("${path.module}/setup.sh", {
      container_image = var.container_image
    }))
    gce-container-declaration = jsonencode({
      spec = {
        containers = [
          {
            image = var.container_image
            # Container needs privileged perms to access `/dev/sev-guest`
            securityContext = {
              privileged = true
            }
            # Add logging configuration
            stdout = true
            stderr = true
          }
        ]
      }
    })
  }

  # Specify the network to use. Our firewall rules should also be attached to
  # this network.
  network_interface {
    network = local.network


    # Maybe I'll look into Cloud IAP or some static IP solution one day, but for
    # now I need to access my TEE applications from my home network.
    #
    # (HIGH): Instance has a public IP allocated.
    # trivy:ignore:AVD-GCP-0031
    access_config {
      # We must explicitly create an access_config otherwise we will only
      # be assigned a private IP. By leaving it empty, GCP should automatically
      # assign us a public IP.
    }
  }

  # Attach the firewall_rules tag so that the instance inherits our firewall
  # rules defined below
  tags = [local.firewall_rules]

  # Labels
  labels = merge(
    {
      "tee-type" = "sev-snp"
    },
    var.labels
  )
  depends_on = []
}

# Allow ingress from anywhere on port 22 (typically used for SSH)
resource "google_compute_firewall" "ssh" {
  name          = "${var.instance_name}-allow-ssh"
  network       = local.network
  source_ranges = ["0.0.0.0/0"]
  target_tags   = [local.firewall_rules]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# Allow ingress from anywhere on ports 80 and 8080 (typically used for HTTP)
resource "google_compute_firewall" "http" {
  name          = "${var.instance_name}-allow-http"
  network       = local.network
  source_ranges = ["0.0.0.0/0"]
  target_tags   = [local.firewall_rules]

  allow {
    protocol = "tcp"
    ports    = ["80", "8080"]
  }
}

# Allow ingress from anywhere on ports 443 and 8443 (typically used for HTTPS)
resource "google_compute_firewall" "https" {
  name          = "${var.instance_name}-allow-https"
  network       = local.network
  source_ranges = ["0.0.0.0/0"]
  target_tags   = [local.firewall_rules]

  allow {
    protocol = "tcp"
    ports    = ["443", "8443"]
  }
}



# Allow all egress traffic (outbound)
#
# Might tighten down once I've finished testing and developing Bearclave.
#
# (CRITICAL): Firewall rule allows unrestricted egress to any IP address.
# trivy:ignore:AVD-GCP-0035
resource "google_compute_firewall" "egress" {
  name               = "${var.instance_name}-allow-egress"
  network            = local.network
  destination_ranges = ["0.0.0.0/0"]
  target_tags        = [local.firewall_rules]
  direction          = "EGRESS"

  allow {
    protocol = "all"
  }
}
