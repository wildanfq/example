resource "google_compute_instance" "vm_gitops" {
  name         = "server-demo"
  machine_type = "e2-micro"
  zone         = "asia-southeast2-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
}
