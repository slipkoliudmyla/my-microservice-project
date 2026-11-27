# Таблиця DynamoDB для блокування стейтів:
# поки хтось виконує terraform apply, інші не можуть одночасно змінювати стейт
resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST" # платимо лише за фактичні запити
  hash_key     = "LockID"          # саме цей ключ очікує Terraform

  attribute {
    name = "LockID"
    type = "S" # S = string (рядок)
  }

  tags = {
    Name        = "Terraform state locks"
    Environment = "lesson-5"
  }
}
