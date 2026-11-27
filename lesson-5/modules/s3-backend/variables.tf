variable "bucket_name" {
  description = "Ім'я S3-бакета для стейтів (унікальне в усьому AWS)"
  type        = string
}

variable "table_name" {
  description = "Ім'я таблиці DynamoDB для блокування стейтів"
  type        = string
  default     = "terraform-locks"
}
