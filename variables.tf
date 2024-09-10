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

# --------------------------------------------------
# VARIABLES
# Set these before applying the configuration
# --------------------------------------------------

variable "project_id" {
  type        = string
  description = "Google Cloud Project ID"
}

variable "region" {
  type        = string
  description = "Google Cloud Region for resources"
  default     = "us-central1"
}

variable "location" {
  type        = string
  description = "Google Cloud location for Document AI"
  default     = "us"
}

variable "labels" {
  type        = map(string)
  description = "A map of labels to apply to contained resources."
  default     = { "genai-rag" = true }
}

variable "enable_apis" {
  type        = bool
  description = "Whether or not to enable underlying APIs in this solution."
  default     = true
}

variable "deletion_protection" {
  type        = bool
  description = "Whether or not to protect Cloud SQL resources from deletion when solution is modified or changed."
  default     = false
}

variable "frontend_container" {
  type        = string
  description = "The public Artifact Registry URI for the frontend container"
  default     = "us-docker.pkg.dev/google-samples/containers/jss/rag-frontend-service:v0.0.1"
}

variable "retrieval_container" {
  type        = string
  description = "The public Artifact Registry URI for the retrieval container"
  default     = "us-docker.pkg.dev/google-samples/containers/jss/rag-retrieval-service:v0.0.2"
}

# Vertex AI related variables
variable "vertex_ai_model_name" {
  type        = string
  description = "The name of the Vertex AI model to use for LLM tasks."
  default     = "vertex-ai-llm"
}

variable "vertex_ai_featurestore_name" {
  type        = string
  description = "The name of the Vertex AI Featurestore for vector embeddings."
  default     = "vector-embedding-featurestore"
}

# Document AI related variables
variable "document_ai_processor_type" {
  type        = string
  description = "The type of Document AI processor to use, e.g., OCR_PROCESSOR."
  default     = "OCR_PROCESSOR"
}

# Cloud SQL Variables
variable "cloud_sql_database_version" {
  type        = string
  description = "The version of the Cloud SQL database."
  default     = "POSTGRES_13"
}

variable "cloud_sql_tier" {
  type        = string
  description = "The machine tier for Cloud SQL instance."
  default     = "db-f1-micro"
}

# Eventarc Variables
variable "eventarc_trigger_name" {
  type        = string
  description = "The name for the Eventarc trigger for file uploads."
  default     = "document-upload-trigger"
}
