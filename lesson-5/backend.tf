# Бекенд: стейт зберігається в S3, а DynamoDB блокує його від одночасних змін.
# ВАЖЛИВО: під час першого запуску (коли бакета ще немає) цей блок треба закоментувати,
# виконати terraform init + terraform apply, потім розкоментувати
# і виконати terraform init -migrate-state (див. README.md).
terraform {
  backend "s3" {
    bucket         = "slipko-terraform-state-lesson-5"
    key            = "lesson-5/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
