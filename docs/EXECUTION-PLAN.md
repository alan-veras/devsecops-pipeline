# PLANO DE EXECUÇÃO DETALHADO, `devsecops-pipeline`

> Complemento operacional de [PLAN.md](PLAN.md): transforma as fases estratégicas em
> sessões executáveis, cada uma com um **prompt pronto para colar numa sessão nova do
> opencode** (toda sessão começa sem memória, os prompts são autocontidos de propósito).
>
> **Como usar:** uma fase por sessão. Cole o prompt → revise o aceite com o agente →
> marque a fase no roadmap do README e no §7 do PLAN.md → só então siga.
> **Regra de ouro:** evidência real > promessa. Todo número publicado precisa ser
> auditável (link de run, link de PR, output colado).

---

## Definition of Done transversal (conversão)

Aplica a todas as fases; auditado na Fase 4 e na análise adversarial:

- [ ] Tabela-âncora do README com resultados REAIS e links clicáveis para os runs/PRs
- [ ] Quickstart copiável que impressiona em ≤30s (`git clone` → algo visível)
- [ ] Seção "honest scope" (o que este repo NÃO cobre), franqueza é diferencial
- [ ] README EN + espelho PT-BR fiel
- [ ] Badges: CI, nº de ataques bloqueados, license
- [ ] Rascunho do post LinkedIn com gancho forte, zero buzzword vazio
- [ ] Repo pinável no perfil GitHub

---

## Fase 0, Conta AWS segura

| | |
|---|---|
| Objetivo | Conta AWS nova blindada ANTES de qualquer recurso |
| Pré-condição | Cartão disponível (exigência do free tier) |
| Entrega | MFA root ativo, IAM admin, root guardado, budget alarm $1, região fixada `us-east-1` |
| Aceite | Checklist marcado; alarme ativo no console |
| Tempo | ~30 min (sessão guiada, passos manuais) |

```
CONTEXTO: estou na Fase 0 do repo devsecops-pipeline (leia docs/PLAN.md seções 7 e 9).
Estou logado numa conta AWS NOVA pela primeira vez e você vai me guiar passo a passo,
um comando/passo por vez, esperando minha confirmação antes do próximo.

TAREFAS NESTA ORDEM EXATA:
1. Ativar MFA virtual no root (guie-me pelo console).
2. Criar usuário IAM "alan-admin" com permissão AdministratorAccess + MFA obrigatório
   + access key apenas se eu pedir CLI.
3. Criar budget alarm de US$1 com alerta por e-mail (Billing → Budgets).
4. Fixar região us-east-1 no console e me dar o comando `aws configure` correto.
5. Checklist final de segurança do root (senha forte, sem access keys do root, alternate contact).

REGRAS: nunca me peça para colar segredos no chat; quando envolver secret, diga onde salvar
(~/.aws/credentials ou password manager). Ao final, imprima um checklist markdown marcado
para eu colar no PLAN.md e confirme: "Fase 0 OK, pode prosseguir".
```

## Fase 1, Bootstrap do repo + Scaffold + CI verde

| | |
|---|---|
| Objetivo | A pasta vira repositório real no GitHub; estrutura completa do §3; CI com os 6 gates verde |
| Pré-condição | Nenhuma (não precisa de cloud) |
| Entrega | Repo criado, app FastAPI mínima, Dockerfile hardenado, ci.yml verde |
| Aceite | Run do Actions verde (link); pytest/hadolint/trivy/semgrep passando local |
| Tempo | 1 sessão |

```
CONTEXTO: repo devsecops-pipeline em /home/alanv/Trabalhos/Portfolio/devsecops-pipeline/.
Leia docs/PLAN.md inteiro (é a especificação) e README.md. Status: só existe README+PLAN.
Esta é a Fase 1: scaffold + CI verde. Nada de cloud ainda.

TAREFAS:
1. git init (branch main), primeiro commit organizado (README + docs/PLAN.md),
   depois crie o repo via `gh repo create alan-veras/devsecops-pipeline --source . --push`.
2. Crie a estrutura completa da seção 3 do PLAN.md: app/ (FastAPI GET /health + GET /items,
   tests/test_smoke.py), Dockerfile (python:3.12-alpine PINADO POR DIGEST, USER non-root),
   terraform/ (módulos network/registry/compute com placeholder documentado),
   scripts/bootstrap-state.sh, Makefile (up/down/scan/bootstrap), .gitignore.
   Confirme que o LICENSE (CC BY-NC-SA 4.0) já existente está commitado desde o primeiro commit.
3. .github/workflows/ci.yml com os 7 passos da seção 5 (gitleaks → semgrep → checkov →
   hadolint → docker build → trivy → pytest). TODAS as actions pinadas por SHA.
   Versões das ferramentas fixadas. Cache pip/docker configurado.
4. Rode localmente o que der: pytest, hadolint, trivy fs, semgrep --config p/python.
   Corrija até tudo passar.
5. Push, abra issue "Phase 1 checklist", marque feito, feche.

ACEITE: CI verde no GitHub Actions (me mostre o link do run). Commits em conventional commits.
NÃO avance para os ataques nesta sessão.
```

## Fase 2, As 6 branches de ataque

| | |
|---|---|
| Objetivo | Matriz §4 completa: 5 PRs reais vermelhos (um por ataque) + branch controle `demo/no-defenses` verde |
| Pré-condição | Fase 1 concluída |
| Entrega | Branches `attack/*` preservadas, PRs bloqueados, docs/attacks.md com links permanentes |
| Aceite | Cada PR falhou NO GATE CERTO (não noutro); controle verde; nenhum merge em main |
| Tempo | 1 sessão |

**Por que isso converte:** o produto do repo não é o app, são os PRs vermelhos. O histórico
do git É a prova; recrutador técnico clica no PR e vê o gate matando o ataque.

```
CONTEXTO: repo devsecops-pipeline, Fase 2. Leia docs/PLAN.md §4 (matriz de ataques) e §1
(tabela-âncora). O CI da Fase 1 já está verde. O produto desta fase SÃO OS PRs VERMELHOS, 
o histórico do git é a prova. Nada simulado.

PARA CADA ataque da matriz §4 (hardcoded-key, vuln-dep, open-sg, sqli, root-docker):
1. `git checkout -b attack/<nome>` a partir de main.
2. Plante o payload EXATO descrito na matriz (chave fake AKIA..., requests==2.28.0,
   ingress 0.0.0.0/0 porta 22, SQLi concatenado em /items?q=, Dockerfile root+:latest).
3. Commit descritivo ("plant: <ataque>"), push, `gh pr create` com corpo explicando
   qual gate DEVE pegar.
4. Espere o CI rodar, CONFIRME que falhou no gate certo (não noutro), capture o número/link
   do run. Se o PR ficar verde ou falhar no gate errado, corrija o payload ou o workflow
   até o bloqueio ser cirúrgico.
5. NÃO faça merge. Preserve o PR aberto ou fechado como "blocked", é evidência.

DEPOIS, o grupo de controle:
6. Crie a branch demo/no-defenses: edite ci.yml desativando todos os gates (jobs comentados
   com "# CONTROL GROUP: defenses off") e plante TODOS os payloads juntos (chave fake +
   dep CVE + SQLi + Dockerfile root). O CI deve ficar 100% VERDE, essa é a linha 6 da
   tabela-âncora ("defenses OFF → all pass").

FINALIZAÇÃO:
7. Atualize docs/attacks.md: uma entrada por ataque com branch → link do PR → gate que
   bloqueou → link permanente do run do Actions → correção demonstrada (diff curto).

ACEITE: 5 PRs vermelhos no gate CERTO + 1 controle verde; docs/attacks.md com os 6 links
reais; nenhuma branch attack/* mergeada em main. Me mostre a tabela final antes do commit.
```

## Fase 3, Infra Terraform + OIDC + deploy real

| | |
|---|---|
| Objetivo | `/health` respondendo da EC2; `make up`/`make down`; custo pós-demo = R$0 |
| Pré-condição | **Dura:** Fase 0 concluída |
| Entrega | Módulos TF, backend remoto S3+lock, OIDC role, deploy.yml com approval, deploy real + destroy |
| Aceite | curl /health da AWS; checkov verde sobre terraform/; destroy deixa conta em R$0 |
| Tempo | 1-2 sessões |

```
CONTEXTO: repo devsecops-pipeline, Fase 3. Leia docs/PLAN.md §5 (workflows), §6 (infra) e §9
(riscos). Fases 0-2 concluídas: conta AWS segura, CI verde, 6 PRs de ataque documentados.

TAREFAS EM ORDEM:
0. Verifique pré-reqs §8: terraform, awscli v2, tflint, gh auth, environment "production"
   criado no GitHub com required reviewer. Instale/guie o que faltar ANTES de seguir.
1. scripts/bootstrap-state.sh: bucket S3 versionado + DynamoDB lock (roda uma vez via CLI,
   fora do TF, dogfooding: o backend do TF nunca se gerencia por si mesmo).
2. OIDC primeiro (~15 min, chato mas é a narrativa): guie criação do OIDC provider + role IAM
   com trust policy do repo, permissão mínima viável. SEM chaves estáticas em nenhum segredo.
3. Módulos terraform/: network (VPC, 2 subnets, SG com 22 restrito AO MEU IP, pergunte antes),
   registry (ECR scan-on-push ON + tag immutability ON), compute (Launch Template t4g.micro +
   user-data: docker pull ECR → run na 8080). envs/dev amarra tudo; state remoto S3+lock.
4. checkov TEM que passar limpo sobre terraform/ (é gate do CI da Fase 1).
5. .github/workflows/deploy.yml: configure-aws-credentials OIDC → terraform fmt/validate/plan
   (plan vira artifact) → environment production com approval manual → apply → build+push ECR →
   smoke curl /health. Documente rollback (re-run com tag anterior da imagem).
6. Budget alarm CONFIRMADO ativo antes do primeiro apply. make up / make down orquestram tudo.
7. Ao final: terraform destroy + confirme pelo budget/console que não ficou recurso pendurado.

ACEITE: curl http://<endpoint>:8080/health responde da instância EC2; destroy deixa a conta em
R$0 (mostre o console/budget); checkov verde. Se qualquer passo ameaçar sair do free tier, PARE
e me consulte com estimativa antes de aplicar.
```

## Fase 4, Docs & Post

| | |
|---|---|
| Objetivo | Repo pinável + rascunho do post LinkedIn |
| Pré-condição | Fases 0-3 |
| Entrega | architecture.md, threat-model.md, attacks.md final, READMEs EN/PT-BR polidos, post |
| Aceite | Checklist §2 do PLAN.md 100%; números do README auditáveis nos links |
| Tempo | 1 sessão |

```
CONTEXTO: repo devsecops-pipeline, Fase 4 final. Leia PLAN.md §1-§2, docs/attacks.md (links reais
da Fase 2) e o histórico do repo.

TAREFAS:
1. docs/architecture.md: diagrama mermaid (dev → CI gates → ECR → EC2) + decisões em formato ADR
   curto (por que OIDC, por que t4g.micro, por que state remoto).
2. docs/threat-model.md: STRIDE-lite, 1 página, mapeando cada gate à ameaça que mitiga.
3. README.md EN polido para conversão: tabela-âncora com resultado REAL de cada ataque (links dos
   PRs vermelhos clicáveis), quickstart copiável ≤30s, badges (CI, attacks count), seção "honest
   scope" (o que NÃO cobre), stack list. README.pt-BR.md espelho fiel.
4. Rascunho post LinkedIn pt-BR: seguir **[docs/POST-PLAN.md](POST-PLAN.md)**, anatomia de
   7 blocos ([../../POST-STYLE.md](../../POST-STYLE.md)), matéria-prima auditável da seção 2,
   prompt pronto na seção 6 e análise adversarial do post na seção 7. Só gerar rascunho quando
   todas as fontes da seção 2 existirem (PRs vermelhos, controle verde, deploy real).
5. Atualize roadmap do README (checkboxes) e o checklist §2 do PLAN.md marcando tudo feito.

ACEITE: checklist §2 100%; números do README auditáveis nos links; post revisado com sugestão
de melhoria de hook se houver.
```

---

## 🔴 Análise adversarial, rodar ao final de TODAS as fases

Cole este prompt numa sessão nova quando o repo estiver completo. Ele NÃO corrige nada, 
produz o relatório que decide se o repo está pronto para virar post + ser pinado.

```
CONTEXTO: análise ADVERSARIAL do repo devsecops-pipeline. Leia README(.pt-BR).md, docs/,
.github/workflows/, app/, terraform/ e inspecione as branches attack/* (gh pr list --state all).
Você é TRÊS revisores hostis num só: engenheiro DevSecOps sênior, auditor de segurança, hiring
manager impaciente. Objetivo: achar TODO ponto onde o repo falha como prova de competência ou
peça de conversão. NÃO corrija nada, só analise.

EIXOS DE ATAQUE:
1. VERACIDADE: algum claim sem evidência real? Os 6 PRs existem e cada um falhou NO GATE CERTO
   (abra os runs)? O controle no-defenses está documentado? Números do README são auditáveis?
2. REPRODUTIBILIDADE: clonei, funciona do zero? Versões/pins corretos (actions por SHA)?
   Algum IP privado, ARN real ou segredo vazou em logs/tfstate/docs?
3. SEGURANÇA DO PRÓPRIO REPO: branches attack/* têm branch protection (merge acidental deixaria
   main vulnerável)? tfstate com dados sensíveis parou onde? O deploy.yml tem superfície de
   injection (pull_request_target, eval de input)?
4. PROFUNDIDADE TÉCNICA: o que um sênior apontaria como amador? Faltam SBOM/cosign/scorecards?
   Módulos TF mal fatiados? Gates com ordem errada (fail fast)?
5. FRANQUEZA: a seção "honest scope" admite o que não cobre, ou finge completude?
6. CONVERSÃO: 45 segundos de atenção, o valor fica óbvio? Quickstart funciona? O post teria
   engagement real ou é cringe/clickbait?

SAÍDA OBRIGATÓRIA: relatório markdown, cada achado com severidade (P1 = bloqueia publicação /
P2 = corrigir antes do post / P3 = nice-to-have), evidência exata (arquivo:linha ou URL) e
correção concreta de 1 linha. Feche com veredito: "pronto para pinar no perfil: SIM/NÃO" +
top 3 fixes por impacto. Se um eixo passar limpo, declare explicitamente "eixo X: sem achados"
(não invente problema).
```

### Fluxo pós-análise

1. P1 encontrados → corrigir → rodar análise de novo (só os eixos afetados).
2. Veredito SIM → aplicar correções P2 rápidas → gerar post definitivo → publicar → pin.
