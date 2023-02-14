resource "google_compute_network" "vpc_network" {
  project = "moonlit-caster-377620"
  name = "terraform-network"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "public" {
  project = "moonlit-caster-377620"
  name = "terraform-public"
  ip_cidr_range = "10.0.0.0/24"
  region = "europe-west3"
  network = google_compute_network.vpc_network.name
  depends_on = [google_compute_network.vpc_network]
}

resource "google_compute_subnetwork" "private" {
  project = "moonlit-caster-377620"
  name = "terraform-private"
  ip_cidr_range = "10.0.1.0/24"
  region = "europe-west3"
  network = google_compute_network.vpc_network.name
  depends_on = [google_compute_network.vpc_network]
}

resource "google_compute_router" "router" {
  project = "moonlit-caster-377620"
  region = "europe-west3"
  name = "router"
  network = google_compute_network.vpc_network.name
  bgp {
    asn = 64514
    advertise_mode = "CUSTOM"
  }
}

resource "google_compute_router_nat" "nat" {
  project = "moonlit-caster-377620"
  region = "europe-west3"
  name = "nat"
  router = google_compute_router.router.name
  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name = google_compute_subnetwork.private.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}