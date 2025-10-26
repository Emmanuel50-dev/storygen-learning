provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "run" {
  service = "run.googleapis.com"
}

resource "google_project_service" "artifactregistry" {
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "iam" {
  service = "iam.googleapis.com"
}

resource "google_project_service" "aiplatform" {
  service = "aiplatform.googleapis.com"
}

resource "google_artifact_registry_repository" "registry" {
  location      = var.region
  repository_id = "storygen"
  format        = "DOCKER"
}

resource "google_cloud_run_v2_service" "backend" {
  name     = "storygen-backend"
  location = var.region

  template {
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/storygen/backend:latest"
    }
  }
}

resource "google_cloud_run_v2_service" "frontend" {
  name     = "storygen-frontend"
  location = var.region

  template {
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/storygen/frontend:latest"
      env {
        name  = "NEXT_PUBLIC_BACKEND_URL"
        value = google_cloud_run_v2_service.backend.uri
      }
    }
  }
}

resource "google_storage_bucket" "generated-images-bucket" {
  name          = "${var.project_id}-storygen-images"
  location      = var.region
  storage_class = "STANDARD"
  uniform_bucket_level_access = true
}

resource "google_service_account" "backend_sa" {
  account_id   = "storygen-backend-sa"
  display_name = "StoryGen Backend Service Account"
}

resource "google_project_iam_member" "backend_sa_roles" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.backend_sa.email}"
}

resource "google_storage_bucket_iam_member" "backend_bucket_access" {
  bucket = google_storage_bucket.generated-images-bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.backend_sa.email}"
}

resource "google_cloud_run_service_iam_binding" "backend_invoke" {
  location = google_cloud_run_v2_service.backend.location
  service  = google_cloud_run_v2_service.backend.name
  role     = "roles/run.invoker"
  members = [
    "serviceAccount:${google_service_account.backend_sa.email}",
    "allUsers",
  ]
}