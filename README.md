Personal website infrastructure for [inhyup.com](https://inhyup.com), managed entirely with Terraform.

## Architecture

GitHub (push)
→ GitHub Actions  
├── Checkov (IaC security scan)  
├── Trivy (vulnerability scan)  
├── Terraform Plan (infrastructure validation)  
└── S3 Deploy (myweb repo only)  
→ CloudFront CDN (HTTPS)  
→ Route 53 (inhyup.com)

## Stack

| Layer           | Service               |
| --------------- | --------------------- |
| DNS             | AWS Route 53          |
| CDN + HTTPS     | AWS CloudFront        |
| SSL             | AWS ACM (auto-renew)  |
| Storage         | AWS S3                |
| IaC             | Terraform             |
| CI/CD Auth      | GitHub OIDC (keyless) |
| Security Scan   | Checkov               |
| Terraform State | S3 backend            |

## CI/CD Pipeline

Every push to `main` triggers 3 parallel jobs:

| Job                      | Tool      | Purpose                          |
| ------------------------ | --------- | -------------------------------- |
| Terraform Security Scan  | Checkov   | Detects IaC misconfigurations    |
| Trivy Vulnerability Scan | Trivy     | Detects HIGH/CRITICAL CVEs       |
| Terraform Plan           | Terraform | Validates infrastructure changes |

## Security highlights

- **Keyless authentication** — GitHub Actions uses OIDC to assume an IAM Role. No AWS access keys stored anywhere.
- **Checkov IaC scanning** — every push triggers automated security scanning of Terraform code. Intentional exceptions are documented with `#checkov:skip` comments explaining the rationale.
- **Trivy vulnerability scanning** — scans Terraform filesystem for HIGH and CRITICAL severity vulnerabilities on every push.
- **Terraform Plan validation** — automatically runs `terraform plan` on every push to catch infrastructure drift or misconfigurations before they reach production.
- **S3 public access blocked** — only CloudFront can access the S3 bucket via Origin Access Control (OAC).
- **Security response headers** — CloudFront enforces `X-Frame-Options`, `X-XSS-Protection`, `Strict-Transport-Security`, `Content-Type-Options`, and `Referrer-Policy`.
- **TLS 1.2+ enforced** — CloudFront configured with `TLSv1.2_2021` minimum protocol.
- **ACM auto-renewal** — SSL certificate managed and renewed automatically by AWS.
- **CloudFront access logging** — all CDN requests logged to a dedicated S3 bucket.

## Repository structure

myweb-infra/  
├── terraform/  
│ ├── versions.tf # Provider and backend config  
│ ├── variables.tf # Input variables  
│ ├── outputs.tf # Output values  
│ ├── iam_oidc.tf # GitHub OIDC provider and IAM role  
│ ├── s3_website.tf # S3 bucket for website hosting  
│ ├── acm.tf # SSL certificate (us-east-1)  
│ ├── cloudfront.tf # CloudFront distribution  
│ ├── cloudfront_security.tf # Security headers policy + access log bucket  
│ └── route53.tf # DNS records  
└── .github/  
└── workflows/  
└── security-scan.yml # Checkov + Trivy + Terraform Plan

## Certifications

- AWS Certified Solutions Architect – Associate
- HashiCorp Certified: Terraform Associate
