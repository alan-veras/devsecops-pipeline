# PLANO DE POST, `devsecops-pipeline`

> Repo em fase de planejamento (ver [EXECUTION-PLAN.md](EXECUTION-PLAN.md)). Este plano fica
> pronto ANTES da execução: define ângulo, matéria-prima auditável **esperada**, esqueleto,
> prompt de execução e análise adversarial do POST. Só gere o rascunho DEPOIS da Fase 4.
> **Estilo OBRIGATÓRIO:** anatomia de 7 blocos de [POST-STYLE.md](../../POST-STYLE.md)
>, o esqueleto da seção 4 já é uma instância dela (link só no primeiro comentário).
>
> **Posição na sequência do portfólio: 4º**, depois de redteam-lab → evals → conductor.

---

## 1. Objetivo & público

| | |
|---|---|
| Objetivo | Posicionar "defesa provada por evidência" como marca pessoal; converter para o repo |
| Público primário | Devs que fazem deploy com CI e nunca viram um gate bloquear um ataque real |
| Público secundário | AppSec/platform folks; hiring managers que valorizam DevSecOps prático |
| Ação desejada | Clonar, olhar os PRs vermelhos preservados e rodar o controle no-defenses |

## 2. Matéria-prima auditável (só cite quando existir, fonte no repo)

⚠️ Este repo ainda não foi construído. Cada claim abaixo depende de artefato gerado nas fases
do EXECUTION-PLAN. NÃO publique nada enquanto a fonte não existir.

| Claim possível | Fonte futura |
|---|---|
| 6 ataques plantados; todos bloqueados pelo gate certo | `docs/attacks.md` + PRs `attack/*` vermelhos (Fase 2) |
| Controle: defesas OFF → tudo passa | branch `demo/no-defenses` verde (Fase 2) |
| Deploy real na AWS respondendo /health | output do deploy.yml + curl (Fase 3) |
| Zero chave estática, OIDC | workflow + role IAM (Fase 3) |
| Custo pós-demo = R$0 (destroy + budget alarm $1) | console/budget (Fase 3) |

## 3. Ângulo & hooks (escolher 1, gerar variantes na execução)

- **A (tese não-dita, recomendado):** *plantei uma chave AWS fake no meu próprio código e esperei o pipeline matar ela, porque defesa que você nunca viu falhar é fé, não engenharia*
- **B (vazio de mercado):** *todo mundo tem pipeline CI; quase ninguém já VIU o gate bloquear um ataque de verdade*
- **C (pivô do deployei):** *"passou no CI" virou sinônimo de seguro, e é aí que mora o perigo*

Regra: o hook promete exatamente o que os PRs vermelhos entregam. Zero exagero.

## 4. Esqueleto do post, instância dos 7 blocos ([POST-STYLE.md](../../POST-STYLE.md))

| # | Bloco | Conteúdo deste repo |
|---|---|---|
| 1 | Origem conversacional + tese não-dita | comitei uma chave fake contra mim mesmo e esperei o pipeline matar ela; percebi que quase ninguém já VIU a própria defesa funcionar |
| 2 | Concessão ("Beleza.") | montar CI hoje é fácil: template pronto, action copiada, check verde |
| 3 | Pergunta-pivô | mas aquele check verde já pegou um ataque REAL? Ou você só acredita nele? |
| 4 | Exagero | se "passou no CI" significasse seguro, ninguém vazaria credencial no GitHub |
| 5 | Bullets-pergunta (3-5) | seu pipeline pega chave commitada? · dependência com CVE conhecida? · security group aberto pro mundo? · SQLi no handler? · Dockerfile rodando como root? (os resultados reais 6/6 bloqueados entram aqui dentro, como dado) |
| 6 | Aforismo espelhado | eu plantei 6 ataques no meu próprio deploy; todos morreram antes da produção |
| 7 | Pergunta aberta final | quando foi a última vez que o SEU pipeline bloqueou algo de verdade, ou ele só carimba verde? |

How-to-run (`make scan`, link pros PRs vermelhos), menção ao k8s-security-lab ("o deploy validado vira cluster endurecido") e o link vão no PRIMEIRO COMENTÁRIO.

## 5. Checklist de conversão LinkedIn

Aplicar o checklist integral de [POST-STYLE.md](../../POST-STYLE.md) + itens específicos:

- [ ] Todo número citado tem PR/run correspondente em `docs/attacks.md`
- [ ] Framing defensivo claro (ataques são branches próprias, nunca terceiros)
- [ ] Bloco 2 concede ("CI fácil") antes de virar a mesa
- [ ] Termina em interrogação

## 6. Prompt de execução (colar em sessão nova do opencode)

```
CONTEXTO: quero criar o post LinkedIn do repo devsecops-pipeline. Leia README(.pt-BR).md,
docs/attacks.md, .github/workflows/, docs/EXECUTION-PLAN.md e docs/POST-PLAN.md
(a especificação deste post).

TAREFAS:
1. Confirme que TODAS as fontes da seção 2 deste POST-PLAN existem (PRs, runs, attacks.md).
   Se alguma não existir, PARE e me diga qual falta, sem fonte não tem post.
2. Gere 3 variantes do post em pt-BR seguindo a ANATOMIA DE 7 BLOCOS de ../../POST-STYLE.md
   (a seção 4 deste plano é a instância concreta), variando o bloco 1 entre os hooks A/B/C
   da seção 3. Tom informal real, parágrafos curtos, SEM link no corpo, terminando em pergunta.
   Gere também o texto do PRIMEIRO COMENTÁRIO (link + como ver os PRs bloqueados + teaser).
3. Audite cada variante claim a claim contra a seção 2. Marque OK/NOK por claim.
4. Recomende a vencedora; salve tudo em docs/post-draft.md com o checklist §5 marcado.
5. Sugira 2 melhorias concretas na vencedora.

REGRAS: nada fora da matéria-prima §2; zero buzzword; link SOMENTE no primeiro comentário;
nunca inventar pessoa/diálogo real no bloco 1. NÃO publique nada, só gerar arquivos locais.
```

## 7. 🔴 Análise adversarial do POST

Rodar numa sessão nova depois do rascunho pronto. Não edita nada, só julga.

```
CONTEXTO: análise ADVERSARIAL do rascunho em docs/post-draft.md do repo devsecops-pipeline.
Leia o rascunho, README(.pt-BR).md, docs/attacks.md e docs/POST-PLAN.md.
Você é revisor hostil triplo: usuário cético de LinkedIn, DevSecOps sênior alérgico a hype,
hiring manager técnico de 45 segundos. NÃO edite nada.

EIXOS DE ATAQUE:
1. VERACIDADE: cada número/claim tem PR ou run real atrás? O controle no-defenses aparece?
2. GANCHO: linha 1 para o scroll? Entrega curiosidade sozinha?
3. CLAREZA EM 45s: dev que nunca tocou Terraform entende o valor (defesa provada > prometida)?
4. TOM: praticante mostrando trabalho ou vendedor de curso de DevSecOps?
5. FRAMING: óbvio que os ataques são branches próprias num lab? Ninguém lê como tutorial de invasão?
6. CONVERSÃO: primeiro comentário tem link + ação clara? Corpo termina em pergunta?
7. FORMATO: respira? Bullets renderizam? ≤1500 chars?

SAÍDA OBRIGATÓRIA: relatório markdown, achados P1/P2/P3 com evidência (linha do rascunho)
e correção de 1 linha. Veredito: "pronto para publicar: SIM/NÃO" + top 3 fixes.
Declare eixos limpos explicitamente.
```

## 8. Fluxo pós-análise & sequência

1. P1 → corrigir → re-rodar eixos afetados.
2. Veredito SIM → aplicar P2 → publicar (terça/quarta 8h-10h SP) → primeiro comentário imediato.
3. Sequência global: redteam-lab → evals → conductor → **este** → k8s-security-lab → poisoned-annotations.
