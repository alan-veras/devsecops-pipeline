# devsecops-pipeline

> A deliberately attackable app, wrapped in a pipeline that kills every attack before production.
>
> **Status: `planning`** — see [docs/PLAN.md](docs/PLAN.md) (pt-BR working document)
[![license](https://img.shields.io/badge/license-CC%20BY--NC--SA%204.0-lightgrey)](LICENSE)

## The pitch

I planted 6 attacks in my own deploy. Every single one died before production:

| Attack planted | Gate | Result |
|---|---|---|
| AWS key committed | gitleaks | blocked |
| Dependency with known CVE | trivy | blocked |
| Security group open to 0.0.0.0/0 | checkov | blocked |
| SQL injection in handler | semgrep | blocked |
| Dockerfile as root + `:latest` | hadolint | blocked |
| Defenses off (control group) | — | all pass |

Every attack is a real branch, a real commit, a real red PR. The git history *is* the proof.

## Stack

FastAPI · Docker · Terraform (AWS) · GitHub Actions · EC2 + ECR
Auth via OIDC (no static keys) · State on S3 + DynamoDB lock

## Roadmap

- [ ] Phase 0 — Secure AWS account setup (MFA, IAM, budget alarm)
- [ ] Phase 1 — Scaffold + CI gates green
- [ ] Phase 2 — Attack branches with documented red PRs
- [ ] Phase 3 — Terraform infra + OIDC + real deploy
- [ ] Phase 4 — Docs (EN/PT-BR), threat model, LinkedIn post

Full plan: [docs/PLAN.md](docs/PLAN.md).

## License

CC BY-NC-SA 4.0 — share and adapt freely with attribution; non-commercial; derivatives under the same license. See [LICENSE](LICENSE).
