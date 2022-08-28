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


resource "aws_sqs_queue_policy" "superset_job_queue_policy" {
  queue_url = aws_sqs_queue.superset_job_queue.id
  policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "1",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.superset_instance.arn}"
      },
      "Action": "sqs:*",
      "Resource": "${aws_sqs_queue.superset_job_queue.id}"
    }
  ]
}
POLICY
}
