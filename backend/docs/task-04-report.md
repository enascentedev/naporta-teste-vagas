# TASK-04 — Relatório de execução

## 1. Resultado

A suíte automatizada do backend foi criada e validada com PostgreSQL 16 real, banco
exclusivo recriado do zero, migrations versionadas, limpeza determinística e 64 testes:

- 19 unitários;
- 6 de integração;
- 39 end-to-end.

O workflow de CI foi criado, mas não foi executado remotamente porque esta tarefa proíbe
commit, push e abertura de pull request. Todos os comandos usados pelo workflow passaram
localmente no mesmo encadeamento.

## 2. Diagnóstico inicial

- O backend não possuía testes, Jest, Nest Testing, Supertest ou configuração de cobertura.
- Não existia `.github/workflows/`.
- `npm run lint` usava `--fix`, inadequado para CI.
- Todo o comportamento descrito no README era validado apenas manualmente.
- `ValidationPipe`, prefixo `/api`, CORS e Helmet estavam presos a `main.ts`, então um
  harness criado por Nest Testing não reproduziria a aplicação real.
- A listagem não tinha desempate para registros com o mesmo `createdAt`.
- O filtro aceitava `startDate > endDate` e retornava `200`.

A matriz completa e atualizada está em [test-matrix.md](./test-matrix.md).

## 3. Implementação

### Ferramental e ambiente

- Jest 29 + ts-jest + `@nestjs/testing` + Supertest.
- Configurações separadas para unitários, integração e E2E.
- `docker-compose.test.yml` com PostgreSQL 16 em `naporta_test`.
- `.env.test.example` somente com valores fictícios.
- Helper de limpeza que recusa bancos cujo nome não termine em `_test`.
- Factories de usuário e pedido independentes do seed.
- `app.setup.ts` compartilhado por produção e E2E.
- Scripts reproduzíveis para gerar o Prisma Client e aplicar migrations usando `.env.test`.

### Testes unitários

Cobrem:

- registro, hash/sanitização, duplicidade, login e falhas de credencial;
- decisão do guard global entre rota pública e JWT;
- delegação do `UsersService` ao Prisma;
- criação, constraint única, paginação, filtros combinados, busca, atualização e exclusão
  lógica do `OrdersService`;
- proteção do helper contra limpeza do banco de desenvolvimento.

### Integração

Cobrem com PostgreSQL real:

- criação e busca de usuário;
- índice único de e-mail;
- relação pedido/itens e precisão decimal;
- permanência física após exclusão lógica;
- filtros combinados;
- ordenação determinística em empate de `createdAt`.

### End-to-end

Cobrem via HTTP:

- registro/login, senha ausente das respostas e JWT;
- guard global, rotas públicas, token ausente/inválido/expirado;
- whitelist e rejeição de campos desconhecidos;
- criação e validação de pedidos/itens/preços/status/opcionais;
- paginação, limite máximo, ordenação, busca e itens;
- PATCH parcial, `{}` idempotente, status e recursos inexistentes/excluídos;
- exclusão lógica, persistência no banco, ocultação e segunda exclusão;
- número parcial, status, datas inclusivas, intervalo, filtros combinados e paginação.

## 4. Bugs comprovados e corrigidos

1. **Ordenação instável:** `findAll` usava apenas `createdAt DESC`. O teste unitário falhou
   demonstrando ausência de desempate; foi adicionado `id DESC`.
2. **Intervalo invertido aceito:** o E2E recebeu `200` para
   `startDate=2030-02-01&endDate=2030-01-01`. Foi adicionada validação cruzada no DTO,
   preservando a semântica inclusiva do dia final; a suíte passou após a correção.

## 5. Decisões

- Mocks são usados somente nos unitários; integração e E2E usam PostgreSQL real.
- O banco de teste não usa seed e é limpo entre cenários.
- `PATCH {}` mantém o comportamento observado: `200` sem alteração de dados.
- Não foram inventados papéis ou autorização por propriedade: o contrato existente é JWT
  obrigatório nas rotas de pedidos.
- Os scripts de banco usam `127.0.0.1` porque o schema engine do Prisma falhou ao resolver
  `localhost` no ambiente Windows/WSL, enquanto conexão IPv4 direta funcionou.
- Jest inicia com `--experimental-vm-modules` nas suítes com banco porque o client Prisma 7
  carrega o compilador WASM dinamicamente.

## 6. CI

`.github/workflows/backend-ci.yml` executa em pull requests e pushes para `main`:

1. checkout;
2. Node 22 com cache do lockfile do backend;
3. `npm ci`;
4. Prisma generate;
5. migrations em PostgreSQL 16 de teste;
6. lint sem escrita;
7. unitários;
8. integração;
9. E2E;
10. cobertura;
11. build.

O job usa apenas variáveis fictícias declaradas no próprio ambiente e falha quando qualquer
etapa falha.

## 7. Validações finais

| Comando                                                              | Resultado                                                               |
| -------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| `npm ci`                                                             | passou; 813 pacotes instalados pelo lockfile                            |
| `docker compose -f docker-compose.test.yml down -v` + `up -d --wait` | banco anterior removido e PostgreSQL novo saudável                      |
| `npm run test:db:prepare`                                            | Prisma Client gerado e 2 migrations aplicadas em banco vazio            |
| `npm test`                                                           | 19 testes, 5 suítes, passando                                           |
| `npm run test:unit`                                                  | 19 testes, 5 suítes, passando                                           |
| `npm run test:integration`                                           | 6 testes, 2 suítes, passando                                            |
| `npm run test:e2e`                                                   | 39 testes, 3 suítes, passando                                           |
| `npm run test:cov`                                                   | passando; 96% statements, 76,81% branches, 100% functions, 95,52% lines |
| `npm run lint:check`                                                 | passou sem escrita                                                      |
| `npm run build`                                                      | passou                                                                  |
| `npm audit --omit=dev --audit-level=high`                            | falhou: 9 vulnerabilidades transitivas (1 baixa, 5 moderadas, 3 altas)  |

## 8. Critérios de aceite

- Scripts `test`, `test:unit`, `test:e2e`, `test:cov`, `lint:check` e `build`: **atendidos**.
- PostgreSQL real, migrations, isolamento e limpeza determinística: **atendidos**.
- Autenticação, guard global, JWT e senha fora das respostas: **atendidos**.
- CRUD, validações, paginação, busca, exclusão lógica e filtros combinados: **atendidos**.
- Cobertura mínima de 75% nos services/regras: **atendida em todas as métricas globais**.
- README e comandos de teste/CI: **atendidos**.
- CI independente de arquivos locais: **atendido por configuração; execução remota depende
  do commit/push manual**.
- Nenhum segredo real: **atendido**.

## 9. Riscos restantes

1. `npm audit --omit=dev` reporta advisories transitivos nas cadeias já existentes de
   Nest/Prisma, incluindo `multer`, `fast-uri`, Hono e Valibot. Não foi executado
   `npm audit fix`, pois atualização de dependências é um hardening separado e exigiria
   revisão de compatibilidade.
2. O workflow ainda não tem execução no GitHub até que a pessoa revise, crie o commit e faça
   push.
3. A autorização continua sem papéis/propriedade, coerente com o escopo original.
4. O aviso experimental de VM Modules permanece enquanto Prisma 7/Jest 29 exigirem esse
   modo de carregamento.

## 10. Sugestões de commits manuais

```text
test(auth): cover registration and JWT authentication
test(orders): add service and validation coverage
test(e2e): validate order API with PostgreSQL
ci: run backend quality gates on pull requests
docs(testing): document automated test workflow
```

Nenhum commit, push ou pull request foi criado pelo agente.
