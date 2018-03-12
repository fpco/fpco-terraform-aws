variable "aws_region" {
  description = "AWS partition where this is running. Unless running on GovCloud, leave as default"
  default     = "aws"
}

variable "name_prefix" {
  description = "Name to prefix to S3 bucket with CloudWatch logs"
}

variable "principals" {
  description = "List of principals’ ARNs"
  type        = "list"
}

variable "extra_tags" {
  description = "Tags to apply on S3 bucket. Name is automatically created, so no need to pass it."
  type        = "map"
  default     = {}
}
