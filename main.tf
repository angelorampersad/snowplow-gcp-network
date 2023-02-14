resource "google_compute_network" "vpc_network" {
  project = var.project_id
  name = "terraform-network"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "public" {
  project = var.project_id
  region = var.region
  name = "terraform-public"
  ip_cidr_range = "10.0.0.0/24"
  network = google_compute_network.vpc_network.name
  depends_on = [google_compute_network.vpc_network]
}

resource "google_compute_subnetwork" "private" {
  project = var.project_id
  region = var.region
  name = "terraform-private"
  ip_cidr_range = "10.0.1.0/24"
  network = google_compute_network.vpc_network.name
  depends_on = [google_compute_network.vpc_network]
}

resource "google_compute_router" "router" {
  project = var.project_id
  region = var.region
  name = "router"
  network = google_compute_network.vpc_network.name
  bgp {
    asn = 64514
    advertise_mode = "CUSTOM"
  }
}

resource "google_compute_router_nat" "nat" {
  project = var.project_id
  region = var.region
  name = "nat"
  router = google_compute_router.router.name
  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name = google_compute_subnetwork.private.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}