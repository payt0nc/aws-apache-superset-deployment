resource "aws_sqs_queue" "superset_job_queue" {
  name                      = "superset-job-queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 3600
  receive_wait_time_seconds = 1

  tags = {
    Service = "Superset"
    Managed = "Terraform"
  }
}
