# PLANO, Repo #1: `devsecops-pipeline`

> Destino: `/home/alanv/Trabalhos/Portfolio/devsecops-pipeline/`
> Status atual: **somente planejamento documentado**, nenhuma linha de implementação ainda.
> Decisões confirmadas pelo Alan: AWS real · EC2 + Docker · app-cobaia com gancho de cyber · EN + PT-BR · este é o repo prioritário.
> Execução fase a fase com prompts prontos: **[EXECUTION-PLAN.md](EXECUTION-PLAN.md)**

---

## 1. Conceito narrativo, "The Pipeline That Says No"

O produto do repo **não é o app**, são os ataques que o pipeline mata. Um app pequeno de propósito atacável, com 6 ataques plantados, onde cada gate bloqueia um deles, demonstrado via branches/PRs reais ficando vermelhos.

Tabela-âncora do README (mesmo formato dos headlines do llm-redteam-lab):

| Attack planted | Gate | Result |
|---|---|---|
| AWS key committed | gitleaks | blocked |
| Dependency with known CVE | trivy | blocked |
| Security group open to 0.0.0.0/0 | checkov | blocked |
| SQL injection in handler | semgrep | blocked |
| Dockerfile as root + `:latest` | hadolint | blocked |
| Defenses OFF (controle) |(nenhum)| all pass |

Post derivado pronto: *"Eu plantei 6 ataques no meu próprio deploy. Todos morreram antes da produção."*

## 2. Critérios de sucesso

- [ ] Os 6 gates rodando verdes no branch principal e bloqueando os PRs de ataque
- [ ] Deploy real na AWS (EC2 rodando a imagem do ECR) com `make up` / `make down`
- [ ] Custo pós-demo = R$0 (`terraform destroy` + budget alarm de $1)
- [ ] README EN + espelho PT-BR, diagrama de arquitetura, threat model 1 página
- [ ] Histórico git prova cada bloqueio (branches `attack/*` preservadas)
- [ ] Rascunho do post LinkedIn gerado junto

## 3. Estrutura final do repositório

```
devsecops-pipeline/
├── app/
│   ├── main.py                 # FastAPI mínima: GET /health + GET /items
│   ├── requirements.txt        # dependência vulnerável plantada na branch de ataque
│   ├── tests/test_smoke.py     # smoke test usado no deploy
│   └── Dockerfile              # python:3.12-alpine pinado por digest, USER non-root
├── terraform/
│   ├── modules/
│   │   ├── network/            # VPC, 2 subnets, SG (22 restrito ao IP; 8080 do ALB/direto)
│   │   ├── registry/           # ECR: scan-on-push ON, tag immutability ON
│   │   └── compute/            # Launch Template t4g.micro + user-data (docker pull ECR + run)
│   └── envs/dev/{main,variables,outputs}.tf
├── scripts/bootstrap-state.sh  # S3 backend versioned + DynamoDB lock
├── .github/workflows/
│   ├── ci.yml                  # gates: gitleaks → semgrep → checkov → hadolint → build → trivy
│   └── deploy.yml              # terraform plan → approval manual → apply → push ECR → smoke test
├── docs/
│   ├── architecture.md         # diagrama + decisões estilo ADR curto
│   ├── attacks.md              # writeup por ataque: payload, gate que pega, correção
│   └── threat-model.md         # STRIDE-lite, 1 página
├── Makefile                    # up / down / scan / bootstrap
├── README.md                   # EN
└── README.pt-BR.md             # espelho PT-BR
```

## 4. Matriz de ataques (branch → payload → gate → fix)

| # | Branch | Payload plantado | Gate que bloqueia | Correção demonstrada |
|---|--------|------------------|-------------------|----------------------|
| 1 | `attack/hardcoded-key` | `AWS_ACCESS_KEY=AKIA...` fake no código | gitleaks (secret scanning) | variável de ambiente + OIDC |
| 2 | `attack/vuln-dep` | `requests==2.28.0` (CVE conhecida) em requirements.txt | trivy fs scan | bump pinado |
| 3 | `attack/open-sg` | ingress `0.0.0.0/0` na porta 22 no Terraform | checkov (CKV_AWS_24) | CIDR restrito |
| 4 | `attack/sqli` | query concatenada em `/items?q=` | semgrep (python SQLi rule) | query parametrizada |
| 5 | `attack/root-docker` | Dockerfile sem USER + base `:latest` | hadolint (DL3002/DL3006) + trivy config | non-root + digest |
| 6 |(nenhum)| branch `demo/no-defenses` com todos gates desativados no CI | nenhum | tabela comparativa |

Regra: nada simulado. Cada ataque é commit real, PR real vermelho, link no `docs/attacks.md`. O histórico do git É a evidência.

## 5. Especificação dos workflows

### ci.yml (todo push/PR)
1. `gitleaks/gitleaks-action@v2`, secret scanning
2. `semgrep`, `p/python`, `p/sql-injection`, `p/default`
3. `checkov`, scan do diretório `terraform/`
4. `hadolint`, lint do(s) Dockerfile(s)
5. build da imagem docker (sem push)
6. `trivy image --exit-code 1 --severity CRITICAL,HIGH`
7. pytest smoke

Pins: actions por SHA, versões de ferramentas fixadas, cache de pip/docker.

### deploy.yml (main, manual approval)
1. configure-aws-credentials com **OIDC role** (sem chaves estáticas)
2. terraform fmt/validate/plan → artifact do plano
3. GitHub Environment `production` com required reviewer (Alan)
4. terraform apply → build+push ECR → SSH/user-data pull → curl /health
5. rollback documentado (re-run de versão anterior da imagem)

## 6. Infra AWS resumida

VPC simples (2 subnets públicas) → SG fechado → t4g.micro (free tier) rodando Docker com imagem do ECR (scan-on-push) → state S3 versionado + lock DynamoDB → budget alarm $1.

Custo estimado fora do free tier: < R$5/mês; após destroy: R$0.

## 7. Fases de execução (quando aprovadas)

| Fase | Entrega | Aceite | Estimo |
|---|---|---|---|
| **0. Conta AWS segura** | conta nova com MFA, usuário IAM admin (root guardado), budget alarm | login OK + alarme ativo | checklist guiado ~30 min |
| **1. Scaffold + Gates** | estrutura completa, app, Dockerfile, ci.yml verde | CI verde no GitHub | 1 sessão |
| **2. Ataques** | 6 branches attack/* com PRs vermelhos documentados | matriz §4 completa | 1 sessão |
| **3. Infra** | módulos TF + bootstrap + deploy.yml OIDC + deploy real | /health responde da AWS | 1-2 sessões |
| **4. Docs & Post** | READMEs EN/PT-BR, architecture.md, attacks.md, threat-model.md, rascunho post | repo pinado no perfil | 1 sessão |

Dependência dura: Fase 3 só começa após Fase 0 concluída. Fases 1-2 não precisam de cloud.

## 8. Checklist pré-requisitos locais (Fase 0 paralela)

- [ ] Instalar `terraform` (tfenv ou brew)
- [ ] Instalar `awscli v2` + `tflint`
- [ ] `gh auth login` ativo
- [ ] Criar environment `production` no repo (Settings → Environments → required reviewers)

## 9. Riscos / notas

- Free tier exige cartão na criação da conta → Fase 0 inclui alarme antes de qualquer recurso
- OIDC tem setup inicial chato (~15 min) mas elimina segredos estáticos, vale a narrativa
- Portas expostas: manter apenas 8080 público; SSH restrito ao IP doméstico (ou SSM Session Manager como stretch)
- O app é propositalmente vulnerável APENAS em branches attack/*; main sempre limpa

---
Próximo passo quando autorizado: executar Fase 0 + Fase 1, criando os arquivos no destino.
