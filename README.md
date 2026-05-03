Personal website infrastructure for [inhyup.com](https://inhyup.com), managed entirely with Terraform.

## Architecture

GitHub (push)
→ GitHub Actions (OIDC keyless auth)
→ Checkov security scan
→ S3 deploy (myweb repo)
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

## Security highlights

- **Keyless authentication** — GitHub Actions uses OIDC to assume an IAM Role. No AWS access keys stored anywhere.
- **Checkov IaC scanning** — every push triggers automated security scanning of Terraform code.
- **S3 public access blocked** — only CloudFront can access the S3 bucket via Origin Access Control (OAC).
- **TLS 1.2+ enforced** — CloudFront configured with `TLSv1.2_2021` minimum protocol.
- **ACM auto-renewal** — SSL certificate managed and renewed automatically by AWS.

## Repository structure

myweb-infra/  
├── terraform/
│ ├── versions.tf # Provider and backend config  
│ ├── variables.tf # Input variables  
│ ├── outputs.tf # Output values  
│ ├── iam_oidc.tf # GitHub OIDC provider and IAM role  
│ ├── s3_website.tf # S3 bucket for website hosting  
│ ├── acm.tf # SSL certificate  
│ ├── cloudfront.tf # CloudFront distribution  
│ └── route53.tf # DNS records  
└── .github/  
└── workflows/  
└── security-scan.yml # Checkov automated scan

## Certifications

- AWS Certified Solutions Architect – Associate
- HashiCorp Certified: Terraform Associate
