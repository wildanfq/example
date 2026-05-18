terraform {
  backend "gcs" {
    bucket = "belajar-gitops-tfstate-123"
    prefix = "terraform/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = "asia-southeast2"
}

variable "project_id" {
  type = string
}
