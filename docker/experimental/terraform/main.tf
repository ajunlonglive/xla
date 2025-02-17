provider "google" {
  project = "tpu-pytorch"
}

resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "default" {
  name          = "${random_id.bucket_prefix.hex}-bucket-tfstate"
  force_destroy = false
  location      = "US"
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
}

terraform {
 backend "gcs" {
   bucket  = "426a09baf5992b6a-bucket-tfstate"
   prefix  = "terraform/state"
 }
}

resource "google_artifact_registry_repository" "torch-xla-python-repo" {
  location      = "us"
  repository_id = "torch-xla"
  description   = "PyTorch/XLA nightly packages"
  format        = "PYTHON"
}

resource "google_artifact_registry_repository" "torch-xla-docker-repo" {
  location      = "us"
  repository_id = "torch-xla-images"
  description   = "PyTorch/XLA nightly images"
  format        = "DOCKER"
}

module "nightly-py37-tpuvm" {
  source = "./modules/trigger"

  release = "nightly"
  python_version = "3.7"
  platform = "tpuvm"
  docker_build_args = [ "tpuvm=1" ]
}

module "nightly-py38-tpuvm" {
  source = "./modules/trigger"

  release = "nightly"
  python_version = "3.8"
  platform = "tpuvm"
  docker_build_args = [ "tpuvm=1" ]
}

module "nightly-py38-tpunode" {
  source = "./modules/trigger"

  release = "nightly"
  python_version = "3.8"
  platform = "tpunode"
  docker_build_args = [ "tpuvm=0" ]
}

module "nightly-py38-cuda112" {
  source = "./modules/trigger"

  release = "nightly"
  python_version = "3.8"
  platform = "cuda112"
  docker_build_args = [ "tpuvm=0,cuda=1"]
}
