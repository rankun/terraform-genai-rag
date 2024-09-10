/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

module "project-services" {
  source                      = "terraform-google-modules/project-factory/google//modules/project_services"
  version                     = "15.0.1"
  disable_services_on_destroy = false

  project_id  = var.project_id
  enable_apis = var.enable_apis

  activate_apis = [
    "aiplatform.googleapis.com",      # Vertex AI
    "artifactregistry.googleapis.com",
    "cloudapis.googleapis.com",
    "cloudbuild.googleapis.com",
    "compute.googleapis.com",
    "config.googleapis.com",
    "iam.googleapis.com",
    "run.googleapis.com",             # Cloud Run
    "secretmanager.googleapis.com",
    "serviceusage.googleapis.com",
    "sqladmin.googleapis.com",        # Cloud SQL
    "storage-api.googleapis.com",
    "storage.googleapis.com",         # Cloud Storage
    "documentai.googleapis.com",      # Document AI
    "eventarc.googleapis.com",        # Eventarc
  ]
}

resource "random_id" "id" {
  byte_length = 4
}

# Document AI Processor
resource "google_document_ai_processor" "document_ai_ocr" {
  display_name = "Document AI OCR Processor"
  type         = "OCR_PROCESSOR"
  location     = "us"
}

# Enable API for Document AI
resource "google_project_service" "documentai" {
  service = "documentai.googleapis.com"
  project = var.project_id
}

# Vertex AI Featurestore for Vector Embeddings
resource "google_vertex_ai_featurestore" "featurestore" {
  display_name = "Vector Embeddings"
  region       = var.region
}

resource "google_vertex_ai_featurestore_entitytype" "entity_type" {
  featurestore = google_vertex_ai_featurestore.featurestore.name
  entitytype_id = "vector-embedding"
  description   = "Embeddings for processed documents"
}

# Enable Vertex AI Platform APIs
resource "google_project_service" "aiplatform" {
  service = "aiplatform.googleapis.com"
  project = var.project_id
}

# Enable Eventarc API
resource "google_project_service" "eventarc" {
  service = "eventarc.googleapis.com"
  project = var.project_id
}
