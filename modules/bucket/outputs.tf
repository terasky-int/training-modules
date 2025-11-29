output "bucket_name" {
  value = trimprefix(google_storage_bucket.bucket.url, "gs://")
}
