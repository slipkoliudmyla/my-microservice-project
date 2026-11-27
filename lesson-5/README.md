# Lesson 5 — IaC (Terraform) на AWS

Terraform-структура, яка створює в AWS (регіон `us-west-2`):

- **S3-бакет + DynamoDB** — віддалене зберігання стейту з версіюванням і блокуванням;
- **VPC** — 3 публічні та 3 приватні підмережі, Internet Gateway, NAT Gateway, маршрутні таблиці;
- **ECR** — репозиторій для Docker-образів з автоматичним скануванням.

## Структура проєкту

```
lesson-5/
├── main.tf          # Провайдер AWS і підключення модулів
├── backend.tf       # Бекенд для стейтів (S3 + DynamoDB)
├── outputs.tf       # Загальні вихідні дані з усіх модулів
├── modules/
│   ├── s3-backend/  # S3-бакет і таблиця DynamoDB
│   │   ├── s3.tf
│   │   ├── dynamodb.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── vpc/         # Мережа
│   │   ├── vpc.tf
│   │   ├── routes.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── ecr/         # Репозиторій Docker-образів
│       ├── ecr.tf
│       ├── variables.tf
│       └── outputs.tf
└── README.md
```

## Модулі

### s3-backend
- `aws_s3_bucket` — бакет `slipko-terraform-state-lesson-5` для файлу `terraform.tfstate`;
- версіювання (`aws_s3_bucket_versioning`) — історія всіх версій стейту;
- шифрування AES256 і блокування публічного доступу;
- `aws_dynamodb_table` `terraform-locks` (ключ `LockID`) — не дає двом людям одночасно змінювати інфраструктуру.

Outputs: `s3_bucket_name`, `s3_bucket_url`, `dynamodb_table_name`.

### vpc
- VPC `10.0.0.0/16` з увімкненим DNS;
- 3 публічні підмережі (`10.0.1–3.0/24`) у зонах `us-west-2a/b/c`;
- 3 приватні підмережі (`10.0.4–6.0/24`);
- Internet Gateway — вихід в інтернет для публічних підмереж;
- NAT Gateway (з Elastic IP) у першій публічній підмережі — вихідний інтернет для приватних підмереж;
- дві маршрутні таблиці: публічна (`0.0.0.0/0` → IGW) і приватна (`0.0.0.0/0` → NAT).

Outputs: `vpc_id`, `public_subnets`, `private_subnets`, `internet_gateway_id`, `nat_gateway_id`.

### ecr
- `aws_ecr_repository` `lesson-5-ecr` з `scan_on_push = true`;
- `aws_ecr_repository_policy` — push/pull дозволено лише власному AWS-акаунту.

Output: `ecr_repository_url`.

## Як запустити

Потрібно: Terraform ≥ 1.5, AWS CLI з налаштованими обліковими даними (`aws configure`).

### Перший запуск (бакета для стейту ще немає)

1. У `backend.tf` закоментуйте блок `terraform { backend "s3" { ... } }`.
2. Створіть ресурси з локальним стейтом:
   ```bash
   cd lesson-5
   terraform init
   terraform plan
   terraform apply
   ```
3. Розкоментуйте `backend.tf` і перенесіть стейт у S3:
   ```bash
   terraform init -migrate-state
   ```

### Звичайна робота

```bash
terraform init      # завантажити провайдер і підключити бекенд
terraform plan      # подивитися, що буде змінено
terraform apply     # створити / оновити ресурси
terraform output    # показати URL бакета, ID VPC, URL ECR тощо
```

### Видалення ресурсів

```bash
terraform destroy
```

> ⚠️ NAT Gateway і Elastic IP платні — видаляйте ресурси після перевірки.
> `terraform destroy` видаляє і S3-бакет зі стейтом, і таблицю DynamoDB. Щоб потім запустити
> інфраструктуру знову: закоментуйте `backend.tf` → `terraform init -reconfigure` → `terraform apply` →
> розкоментуйте `backend.tf` → `terraform init -migrate-state`.
>
> Через увімкнене версіювання бакет може не видалитися, якщо в ньому лишилися версії файлів —
> тоді спершу очистіть його в консолі S3 (Empty), а потім повторіть `terraform destroy`.
