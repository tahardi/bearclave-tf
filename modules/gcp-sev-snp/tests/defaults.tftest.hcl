run "configuration_validation" {
  command = plan

  variables {
    instance_name         = "test-sev-snp-instance"
    project_id            = "bearclave"
    zone                  = "us-central1-a"
    machine_type          = "n2d-standard-2"
    service_account_email = "test-sa@bearclave.iam.gserviceaccount.com"
    ssh_public_key        = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAA test@example.com"
    container_image       = "us-east1-docker.pkg.dev/bearclave/bearclave/hello-world:latest"
    labels                = {}
  }

  assert {
    condition     = google_compute_instance.bcl_sev_snp.name == var.instance_name
    error_message = "Instance name must match input variable"
  }

  assert {
    condition     = google_compute_instance.bcl_sev_snp.machine_type == var.machine_type
    error_message = "Machine type must match input variable"
  }

  assert {
    condition     = google_compute_instance.bcl_sev_snp.project == var.project_id
    error_message = "Project ID must match input variable"
  }

  assert {
    condition     = google_compute_instance.bcl_sev_snp.zone == var.zone
    error_message = "Zone must match input variable"
  }
}

run "security_settings" {
  command = plan

  variables {
    instance_name         = "test-sev-snp-instance"
    project_id            = "bearclave"
    zone                  = "us-central1-a"
    machine_type          = "n2d-standard-2"
    service_account_email = "test-sa@bearclave.iam.gserviceaccount.com"
    ssh_public_key        = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAA test@example.com"
    container_image       = "us-east1-docker.pkg.dev/bearclave/bearclave/hello-world:latest"
    labels                = {}
  }

  assert {
    condition     = google_compute_instance.bcl_sev_snp.confidential_instance_config[0].enable_confidential_compute == true
    error_message = "Confidential compute must be enabled"
  }

  assert {
    condition     = google_compute_instance.bcl_sev_snp.confidential_instance_config[0].confidential_instance_type == "SEV_SNP"
    error_message = "Confidential instance type must be SEV_SNP"
  }

  assert {
    condition     = google_compute_instance.bcl_sev_snp.shielded_instance_config[0].enable_secure_boot == true
    error_message = "Secure boot must be enabled"
  }

  assert {
    condition     = google_compute_instance.bcl_sev_snp.shielded_instance_config[0].enable_vtpm == true
    error_message = "vTPM must be enabled"
  }

  assert {
    condition     = google_compute_instance.bcl_sev_snp.shielded_instance_config[0].enable_integrity_monitoring == true
    error_message = "Integrity monitoring must be enabled"
  }

  assert {
    condition     = google_compute_instance.bcl_sev_snp.boot_disk[0].initialize_params[0].size >= 8
    error_message = "Boot disk size must be at least 8GB"
  }
}

run "labeling_strategy" {
  command = plan

  variables {
    instance_name         = "test-sev-snp-instance"
    project_id            = "bearclave"
    zone                  = "us-central1-a"
    machine_type          = "n2d-standard-2"
    service_account_email = "test-sa@bearclave.iam.gserviceaccount.com"
    ssh_public_key        = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAA test@example.com"
    container_image       = "us-east1-docker.pkg.dev/bearclave/bearclave/hello-world:latest"
    labels = {
      environment = "dev"
      owner       = "platform-team"
    }
  }

  assert {
    condition     = google_compute_instance.bcl_sev_snp.labels["tee-type"] == "sev-snp"
    error_message = "Instance must have tee-type label set to sev-snp"
  }

  assert {
    condition     = google_compute_instance.bcl_sev_snp.labels["environment"] == "dev"
    error_message = "Instance must inherit environment label"
  }

  assert {
    condition     = google_compute_instance.bcl_sev_snp.labels["owner"] == "platform-team"
    error_message = "Instance must inherit owner label"
  }
}

run "firewall_rules" {
  command = plan

  variables {
    instance_name         = "test-sev-snp-instance"
    project_id            = "bearclave"
    zone                  = "us-central1-a"
    machine_type          = "n2d-standard-2"
    service_account_email = "test-sa@bearclave.iam.gserviceaccount.com"
    ssh_public_key        = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAA test@example.com"
    container_image       = "us-east1-docker.pkg.dev/bearclave/bearclave/hello-world:latest"
    labels                = {}
  }

  # Verify SSH firewall rule
  assert {
    condition     = length([for allow in google_compute_firewall.ssh.allow : allow if allow.protocol == "tcp"]) > 0
    error_message = "SSH firewall rule must allow TCP"
  }

  assert {
    condition     = length([for allow in google_compute_firewall.ssh.allow : allow.ports if allow.protocol == "tcp" && contains(allow.ports, "22")]) > 0
    error_message = "SSH firewall rule must allow port 22"
  }

  assert {
    condition     = contains(google_compute_firewall.ssh.source_ranges, "0.0.0.0/0")
    error_message = "SSH firewall rule must allow traffic from anywhere"
  }

  # Verify HTTP firewall rule
  assert {
    condition     = length([for allow in google_compute_firewall.http.allow : allow.ports if contains(allow.ports, "80") && contains(allow.ports, "8080")]) > 0
    error_message = "HTTP firewall rule must allow ports 80 and 8080"
  }

  assert {
    condition     = contains(google_compute_firewall.http.source_ranges, "0.0.0.0/0")
    error_message = "HTTP firewall rule must allow traffic from anywhere"
  }

  # Verify HTTPS firewall rule
  assert {
    condition     = length([for allow in google_compute_firewall.https.allow : allow.ports if contains(allow.ports, "443") && contains(allow.ports, "8443")]) > 0
    error_message = "HTTPS firewall rule must allow ports 443 and 8443"
  }

  assert {
    condition     = contains(google_compute_firewall.https.source_ranges, "0.0.0.0/0")
    error_message = "HTTPS firewall rule must allow traffic from anywhere"
  }

  # Verify egress rule
  assert {
    condition     = google_compute_firewall.egress.direction == "EGRESS"
    error_message = "Egress rule must have direction set to EGRESS"
  }

  assert {
    condition     = length([for allow in google_compute_firewall.egress.allow : allow if allow.protocol == "all"]) > 0
    error_message = "Egress rule must allow all protocols"
  }

  assert {
    condition     = contains(google_compute_firewall.egress.destination_ranges, "0.0.0.0/0")
    error_message = "Egress rule must allow traffic to anywhere"
  }
}

run "service_account_configuration" {
  command = plan

  variables {
    instance_name         = "test-sev-snp-instance"
    project_id            = "bearclave"
    zone                  = "us-central1-a"
    machine_type          = "n2d-standard-2"
    service_account_email = "test-sa@bearclave.iam.gserviceaccount.com"
    ssh_public_key        = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAA test@example.com"
    container_image       = "us-east1-docker.pkg.dev/bearclave/bearclave/hello-world:latest"
    labels                = {}
  }

  assert {
    condition     = google_compute_instance.bcl_sev_snp.service_account[0].email == var.service_account_email
    error_message = "Service account email must match input variable"
  }
}
