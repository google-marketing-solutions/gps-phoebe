# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

provider "google" {
  project = var.project_id
}

# Enable APIs
resource "google_project_service" "cloudresourcemanager" {
  disable_on_destroy = false
  service            = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "compute" {
  disable_on_destroy = false
  service            = "compute.googleapis.com"
}

resource "google_project_service" "containerregistry" {
  disable_on_destroy = false
  service            = "containerregistry.googleapis.com"
}

resource "google_project_service" "aiplatform" {
  disable_on_destroy = false
  service            = "aiplatform.googleapis.com"
}

resource "google_project_service" "cloudbuild" {
  disable_on_destroy = false
  service            = "cloudbuild.googleapis.com"
}

resource "google_project_service" "cloudfunctions" {
  disable_on_destroy = false
  service            = "cloudfunctions.googleapis.com"
}

resource "google_project_service" "artifactregistry" {
  disable_on_destroy = false
  service            = "artifactregistry.googleapis.com"
}

resource "google_project_service" "storage-component" {
  disable_on_destroy = false
  service            = "storage-component.googleapis.com"
}

resource "google_storage_bucket" "models-bucket" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "sample-file" {
 for_each = fileset("${path.module}", "model/**")
 name         = each.value
 source       = each.value
 content_type = "application/octet-stream"
 bucket       = google_storage_bucket.models-bucket.id
}

module "vertex-model-upload" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 3.1.2"

  platform = "linux"
  additional_components = ["beta"]

  create_cmd_entrypoint  = "gcloud"
  create_cmd_body        = "ai models upload --project=${var.project_id} --region=${var.region} --display-name='demo-model' --model-id='demo-model' --container-image-uri=${var.serving_container_image} --artifact-uri=gs://${var.bucket_name}/model"
  destroy_cmd_entrypoint = "gcloud"
  destroy_cmd_body       = "ai models delete demo-model --project=${var.project_id} --region=${var.region}"

  module_depends_on = [google_project_service.aiplatform]
}

resource "google_vertex_ai_endpoint" "demo-model-endpoint" {
  name         = "demo-model-endpoint"
  display_name = "demo-model-endpoint"
  location     = var.region
  region       = var.region

  depends_on = [module.vertex-model-upload]
}

module "vertex-model-deploy" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 3.1.2"

  platform = "linux"
  additional_components = ["beta"]

  create_cmd_entrypoint  = "gcloud"
  create_cmd_body        = "ai endpoints deploy-model demo-model-endpoint --project=${var.project_id} --region=${var.region} --display-name='demo-model' --model='demo-model'"
  destroy_cmd_entrypoint = "gcloud"
  destroy_cmd_body       = "ai endpoints undeploy-model demo-model-endpoint --project=${var.project_id} --region=${var.region} --deployed-model-id=$(gcloud ai models describe demo-model | grep deployedModelId | head -1 | sed -E \"s/^[^']+'([^']+)'/\\1/\")"

  module_depends_on = [google_vertex_ai_endpoint.demo-model-endpoint]
}