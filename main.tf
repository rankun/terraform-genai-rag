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
    "pubsub.googleapis.com",          # Pub/Sub (required for Eventarc transport)
  ]
}

# Generate a random ID
resource "random_id" "id" {
  byte_length = 4
}

# Document AI Processor
resource "google_document_ai_processor" "document_ai_ocr" {
  display_name = "Document AI OCR Processor"
  type         = var.document_ai_processor_type  # Use variable for processor type (OCR by default)
  location     = var.location                    # Use variable for location
}

# Enable API for Document AI
resource "google_project_service" "documentai" {
  service = "documentai.googleapis.com"
  project = var.project_id
}

# Vertex AI Featurestore for Vector Embeddings
resource "google_vertex_ai_featurestore" "featurestore" {
  display_name = var.vertex_ai_featurestore_name  # Use variable for Featurestore name
  region       = var.region                       # Use variable for region
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

# Pub/Sub topic for Eventarc
resource "google_pubsub_topic" "upload_topic" {
  name = var.eventarc_trigger_name
}

# Eventarc Trigger for Cloud Storage
resource "google_eventarc_trigger" "document_upload_trigger" {
  name     = var.eventarc_trigger_name
  location = var.region

  matching_criteria {
    attribute = "type"
    value     = "google.cloud.storage.object.v1.finalized"
  }

  matching_criteria {
    attribute = "bucket"
    value     = google_storage_bucket.staging_bucket.name
  }

  transport {
    pubsub {
      topic = google_pubsub_topic.upload_topic.id
    }
  }

  destination {
    cloud_function {
      uri = google_cloudfunctions_function.document_processor.https_trigger_url
    }
  }
}

# Cloud Function to process uploaded documents
resource "google_cloudfunctions_function" "document_processor" {
  name        = "document-processor"
  runtime     = "python310"
  entry_point = "process_document"
  region      = var.region

  source_archive_bucket = google_storage_bucket.staging_bucket.name
  source_archive_object = "function_source.zip"

  https_trigger {}

  environment_variables = {
    BUCKET_NAME  = google_storage_bucket.staging_bucket.name
    PROCESSOR_ID = google_document_ai_processor.document_ai_ocr.name
  }

  service_account_email = google_service_account.cloud_function_sa.email
  timeout               = 60
}

# Service account for Cloud Functions
resource "google_service_account" "cloud_function_sa" {
  account_id   = "cloud-function-service-account"
  display_name = "Cloud Function Service Account"
}

# IAM roles for Cloud Function service account
resource "google_project_iam_member" "cloud_function_iam" {
  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${google_service_account.cloud_function_sa.email}"
}
