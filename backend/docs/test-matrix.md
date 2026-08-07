# TASK-04 — Plano e matriz de testes do backend naPorta

## 1. Estado e limite desta etapa

- **Branch:** `fix/task-04-testes-ci`, criada a partir de `main` (`673fdba`).
- **Etapa atual:** execução concluída e validada em 31/07/2026.
- **Implementação:** 19 testes unitários, 6 de integração e 39 E2E implementados.
- **Gate:** plano aprovado pelo usuário antes do início da implementação.

## 2. Diagnóstico verificado

Foram lidos o README da raiz, os READMEs de `backend` e `mobile`, os dois enunciados
(`backend/CHALLENGE.md` e `mobile/CHALLENGE.md`), a configuração do backend, o schema e
as duas migrations do Prisma, o seed e todo o código TypeScript fora do client gerado.

### 2.1 Inventário no diagnóstico inicial

| Camada          | Estado encontrado                                                                                                                              |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| Módulos         | `AppModule`, `AuthModule`, `UsersModule`, `OrdersModule` e `PrismaModule` global                                                               |
| Controllers     | `AuthController` (`register`, `login`) e `OrdersController` (criar, listar, buscar, atualizar e excluir)                                       |
| Services        | `AuthService`, `UsersService`, `OrdersService` e `PrismaService`                                                                               |
| Segurança       | `JwtAuthGuard` global via `APP_GUARD`; `@Public()` em registro/login; estratégia Bearer JWT; `ValidationPipe` apenas no bootstrap de `main.ts` |
| DTOs            | `RegisterDto`, `LoginDto`, `CreateOrderDto`, `OrderItemDto`, `UpdateOrderDto` e `FilterOrdersDto`                                              |
| Persistência    | PostgreSQL + Prisma 7; `User`, `Order` e `OrderItem`; enum `OrderStatus`; duas migrations; seed idempotente com um usuário e dez pedidos       |
| Exclusão lógica | `OrdersService.remove()` preenche `deletedAt`; consultas do service filtram `deletedAt: null`                                                  |
| Testes backend  | Inexistentes; não há Jest, `@nestjs/testing`, Supertest, configuração ou scripts de teste                                                      |
| CI              | `.github/workflows/` inexistente                                                                                                               |
| Lint            | `npm run lint` executa ESLint com `--fix` e, portanto, não pode ser usado no CI                                                                |
| Baseline        | A latência inicial foi ambiental. Na validação final, `npm run lint:check` e `npm run build` terminaram com sucesso e sem alterar arquivos     |

O backend era validado apenas manualmente. A frase do README raiz que afirmava validação
“de ponta a ponta” não apontava para uma suíte reproduzível e foi substituída por comandos
e resultados verificáveis.

### 2.2 Achados do diagnóstico e decisões finais

1. `PATCH /orders/:id` aceita DTO totalmente parcial; `{}` foi caracterizado como `200`
   idempotente sem alteração e documentado no README.
2. `startDate` e `endDate` eram validados isoladamente; o E2E comprovou que intervalo
   invertido retornava `200`, e o DTO agora devolve `400`.
3. A ordenação usava somente `createdAt DESC`; após falha unitária, recebeu `id DESC` como
   desempate determinístico.
4. A autorização existente não possui papéis nem propriedade de recurso. O contrato atual
   é apenas: rotas de pedidos exigem um JWT válido.
5. A duplicidade sequencial de e-mail retorna `409`; a constraint única do banco também foi
   comprovada por integração. Corrida concorrente não faz parte do contrato desta tarefa.
6. `ValidationPipe`, prefixo `/api`, CORS e Helmet foram extraídos para `app.setup.ts`,
   compartilhado por produção e E2E.

## 3. Decisões executadas

### 3.1 Pirâmide e arquivos

- **Unitários:** services e guard com doubles tipados apenas nas fronteiras (`PrismaService`,
  `UsersService`, `JwtService` e `Reflector`). Mocks não são usados como substitutos do
  PostgreSQL nos testes de integração/e2e.
- **Integração:** services reais contra PostgreSQL de teste, principalmente constraints,
  relações e exclusão lógica.
- **E2E:** `AppModule` completo, HTTP real via Supertest e PostgreSQL real migrado.
- **Factories/builders:** dados válidos por padrão e sobrescritas explícitas por cenário.
- **Cobertura:** mínimo global de 75% para services e regras exercitadas; não reduzir regras
  de lint nem excluir arquivos apenas para inflar o número.

Arquivos implementados:

```text
backend/
  docker-compose.test.yml
  .env.test.example
  jest.config.js
  test/
    jest-integration.json
    jest-e2e.json
    setup-env.ts
    helpers/test-database.ts
    factories/user.factory.ts
    factories/order.factory.ts
    integration/users.service.integration-spec.ts
    integration/orders.service.integration-spec.ts
    e2e/auth.e2e-spec.ts
    e2e/orders.e2e-spec.ts
    e2e/security.e2e-spec.ts
  src/
    app.setup.ts
    auth/auth.service.spec.ts
    auth/guards/jwt-auth.guard.spec.ts
    orders/orders.service.spec.ts
    users/users.service.spec.ts
```

`src/app.setup.ts` centraliza prefixo, pipes e middleware usados pelo bootstrap e pelo
harness e2e. Isso é uma refatoração de testabilidade sem mudar o contrato HTTP.

### 3.2 Banco isolado e limpeza

- Banco exclusivo `naporta_test`, em PostgreSQL 16, com porta local padrão `5434`.
- Credenciais fictícias apenas em `.env.test.example` e no ambiente do CI.
- `DATABASE_URL` de teste não aponta para o banco `naporta` de desenvolvimento.
- O helper de limpeza falha fechado se o nome do banco não terminar em `_test`.
- Migrations reais são aplicadas antes da suíte; nenhuma tabela é criada por `db push`.
- Limpeza por `TRUNCATE ... CASCADE` entre cenários e execução serial das suítes com banco.
- Factories geram identificadores únicos; nenhum teste depende do seed ou da ordem.

### 3.3 Scripts

Scripts implementados, preservando `lint` como autocorreção local:

```json
{
  "test": "jest --runInBand",
  "test:unit": "jest --runInBand",
  "test:integration": "node --experimental-vm-modules ./node_modules/jest/bin/jest.js --config test/jest-integration.json --runInBand",
  "test:e2e": "node --experimental-vm-modules ./node_modules/jest/bin/jest.js --config test/jest-e2e.json --runInBand",
  "test:cov": "jest --coverage --runInBand",
  "lint:check": "eslint \"src/**/*.ts\" \"test/**/*.ts\"",
  "build": "nest build"
}
```

Os seis scripts obrigatórios foram executados com esses contratos funcionais.

## 4. Matriz de testes

Todos os cenários abaixo estão como **Passando** após execução local registrada contra um
PostgreSQL de teste recriado do zero. O workflow repetirá os mesmos comandos no GitHub.

### 4.1 Autenticação e usuários

| Funcionalidade | Regra                                              | Tipo de teste    | Arquivo de teste                                                                  | Estado   | Observações                                       |
| -------------- | -------------------------------------------------- | ---------------- | --------------------------------------------------------------------------------- | -------- | ------------------------------------------------- |
| Registro       | Payload válido cria usuário e retorna `201`        | E2E              | `test/e2e/auth.e2e-spec.ts`                                                       | Passando | Confirmar persistência real                       |
| Registro       | E-mail duplicado retorna `409`                     | Unitário + E2E   | `src/auth/auth.service.spec.ts`; `test/e2e/auth.e2e-spec.ts`                      | Passando | Cobrir precheck e constraint real                 |
| Registro       | Senha é armazenada com hash e nunca retornada      | Integração + E2E | `test/integration/users.service.integration-spec.ts`; `test/e2e/auth.e2e-spec.ts` | Passando | Comparar hash com bcrypt sem expor valor          |
| Login          | Credenciais válidas retornam JWT em `access_token` | Unitário + E2E   | `src/auth/auth.service.spec.ts`; `test/e2e/auth.e2e-spec.ts`                      | Passando | Validar claims esperadas, sem fixar token literal |
| Login          | Senha incorreta retorna `401`                      | Unitário + E2E   | `src/auth/auth.service.spec.ts`; `test/e2e/auth.e2e-spec.ts`                      | Passando | Mensagem não distingue a causa                    |
| Login          | Usuário inexistente retorna `401`                  | Unitário + E2E   | `src/auth/auth.service.spec.ts`; `test/e2e/auth.e2e-spec.ts`                      | Passando | Mesma resposta da senha incorreta                 |
| Proteção       | Rota protegida sem token retorna `401`             | E2E              | `test/e2e/security.e2e-spec.ts`                                                   | Passando | Exercitar uma rota de pedidos                     |
| Proteção       | Token inválido/expirado retorna `401`              | E2E              | `test/e2e/security.e2e-spec.ts`                                                   | Passando | Não relaxar expiração                             |
| Rotas públicas | Apenas handlers com `@Public()` ignoram o guard    | Unitário + E2E   | `src/auth/guards/jwt-auth.guard.spec.ts`; `test/e2e/security.e2e-spec.ts`         | Passando | Registro/login públicos; pedidos protegidos       |

### 4.2 Criação de pedido

| Funcionalidade | Regra                                                     | Tipo de teste    | Arquivo de teste                                                                     | Estado   | Observações                             |
| -------------- | --------------------------------------------------------- | ---------------- | ------------------------------------------------------------------------------------ | -------- | --------------------------------------- |
| Criar pedido   | Payload obrigatório válido retorna `201` e persiste       | Unitário + E2E   | `src/orders/orders.service.spec.ts`; `test/e2e/orders.e2e-spec.ts`                   | Passando | Conferir item relacionado no PostgreSQL |
| Criar pedido   | Número duplicado retorna `409`                            | Unitário + E2E   | `src/orders/orders.service.spec.ts`; `test/e2e/orders.e2e-spec.ts`                   | Passando | Exercitar erro Prisma `P2002` real      |
| Itens          | Item válido preserva descrição e preço decimal            | Integração + E2E | `test/integration/orders.service.integration-spec.ts`; `test/e2e/orders.e2e-spec.ts` | Passando | Normalizar comparação de `Decimal`      |
| Itens          | Lista vazia ou descrição vazia retorna `400`              | E2E              | `test/e2e/orders.e2e-spec.ts`                                                        | Passando | `ArrayNotEmpty` e `IsNotEmpty`          |
| Itens          | Preço zero, negativo ou com mais de 2 casas retorna `400` | E2E              | `test/e2e/orders.e2e-spec.ts`                                                        | Passando | Cobrir `IsPositive` e precisão          |
| Validação      | Campo desconhecido retorna `400`                          | E2E              | `test/e2e/orders.e2e-spec.ts`                                                        | Passando | Prova de `forbidNonWhitelisted`         |
| Status         | Status fora do enum retorna `400`                         | E2E              | `test/e2e/orders.e2e-spec.ts`                                                        | Passando | Sem coerção silenciosa                  |
| Opcionais      | Contato/origem/coordenadas podem ser omitidos             | E2E              | `test/e2e/orders.e2e-spec.ts`                                                        | Passando | Status default deve ser `PENDING`       |

### 4.3 Listagem e busca

| Funcionalidade | Regra                                                       | Tipo de teste    | Arquivo de teste                                                                     | Estado   | Observações                                               |
| -------------- | ----------------------------------------------------------- | ---------------- | ------------------------------------------------------------------------------------ | -------- | --------------------------------------------------------- |
| Listar         | Paginação padrão é página 1, limite 10                      | Unitário + E2E   | `src/orders/orders.service.spec.ts`; `test/e2e/orders.e2e-spec.ts`                   | Passando | Conferir `meta` e quantidade                              |
| Listar         | Paginação customizada calcula `skip`, total e última página | Unitário + E2E   | `src/orders/orders.service.spec.ts`; `test/e2e/orders.e2e-spec.ts`                   | Passando | Dados independentes do seed                               |
| Listar         | Limite 100 é aceito e valor maior é `400`                   | E2E              | `test/e2e/orders.e2e-spec.ts`                                                        | Passando | Limite máximo explícito                                   |
| Listar         | Ordenação é decrescente por criação e determinística        | Integração + E2E | `test/integration/orders.service.integration-spec.ts`; `test/e2e/orders.e2e-spec.ts` | Passando | Adicionar desempate somente se o teste provar necessidade |
| Listar         | Pedidos com `deletedAt` não aparecem                        | Integração + E2E | `test/integration/orders.service.integration-spec.ts`; `test/e2e/orders.e2e-spec.ts` | Passando | Conferir também total da paginação                        |
| Buscar por ID  | Pedido ativo existente retorna `200`                        | E2E              | `test/e2e/orders.e2e-spec.ts`                                                        | Passando | Incluir itens                                             |
| Buscar por ID  | UUID inexistente retorna `404`                              | Unitário + E2E   | `src/orders/orders.service.spec.ts`; `test/e2e/orders.e2e-spec.ts`                   | Passando | UUID válido sem registro                                  |
| Buscar por ID  | Pedido excluído retorna `404`                               | E2E              | `test/e2e/orders.e2e-spec.ts`                                                        | Passando | Não vazar recurso apagado                                 |

### 4.4 Atualização

| Funcionalidade | Regra                                                   | Tipo de teste      | Arquivo de teste                                                                     | Estado   | Observações                                            |
| -------------- | ------------------------------------------------------- | ------------------ | ------------------------------------------------------------------------------------ | -------- | ------------------------------------------------------ |
| Atualizar      | PATCH parcial altera apenas campos enviados             | Unitário + E2E     | `src/orders/orders.service.spec.ts`; `test/e2e/orders.e2e-spec.ts`                   | Passando | Confirmar preservação dos demais                       |
| Atualizar      | Payload vazio tem comportamento explícito e documentado | Caracterização E2E | `test/e2e/orders.e2e-spec.ts`                                                        | Passando | Não decidir o status sem observar o comportamento real |
| Atualizar      | Campo desconhecido retorna `400`                        | E2E                | `test/e2e/orders.e2e-spec.ts`                                                        | Passando | Mesmo pipe da criação                                  |
| Atualizar      | Mudança válida de status retorna `200` e persiste       | Integração + E2E   | `test/integration/orders.service.integration-spec.ts`; `test/e2e/orders.e2e-spec.ts` | Passando | Conferir banco                                         |
| Atualizar      | Status inválido retorna `400`                           | E2E                | `test/e2e/orders.e2e-spec.ts`                                                        | Passando | Enum estrito                                           |
| Atualizar      | Pedido inexistente retorna `404`                        | Unitário + E2E     | `src/orders/orders.service.spec.ts`; `test/e2e/orders.e2e-spec.ts`                   | Passando | Não executar update após `findOne` falhar              |
| Atualizar      | Pedido excluído retorna `404` e permanece inalterado    | Integração + E2E   | `test/integration/orders.service.integration-spec.ts`; `test/e2e/orders.e2e-spec.ts` | Passando | Regra de exclusão lógica                               |

### 4.5 Exclusão lógica

| Funcionalidade | Regra                                           | Tipo de teste    | Arquivo de teste                                                                     | Estado   | Observações                          |
| -------------- | ----------------------------------------------- | ---------------- | ------------------------------------------------------------------------------------ | -------- | ------------------------------------ |
| Excluir        | Primeira exclusão retorna `204` sem corpo       | E2E              | `test/e2e/orders.e2e-spec.ts`                                                        | Passando | Contrato REST documentado            |
| Excluir        | `deletedAt` é preenchido                        | Integração + E2E | `test/integration/orders.service.integration-spec.ts`; `test/e2e/orders.e2e-spec.ts` | Passando | Inspeção direta pelo Prisma          |
| Excluir        | Registro e itens permanecem no banco            | Integração       | `test/integration/orders.service.integration-spec.ts`                                | Passando | Não confundir com delete físico      |
| Excluir        | Recurso some da lista, busca e filtros          | E2E              | `test/e2e/orders.e2e-spec.ts`                                                        | Passando | Conferir `meta.total`                |
| Excluir        | Segunda exclusão retorna `404` consistentemente | Unitário + E2E   | `src/orders/orders.service.spec.ts`; `test/e2e/orders.e2e-spec.ts`                   | Passando | Contrato atual derivado de `findOne` |

### 4.6 Filtros

| Funcionalidade | Regra                                              | Tipo de teste    | Arquivo de teste                                                                     | Estado   | Observações                                                    |
| -------------- | -------------------------------------------------- | ---------------- | ------------------------------------------------------------------------------------ | -------- | -------------------------------------------------------------- |
| Filtrar        | Número parcial e case-insensitive                  | Integração + E2E | `test/integration/orders.service.integration-spec.ts`; `test/e2e/orders.e2e-spec.ts` | Passando | Prisma `contains` + `insensitive`                              |
| Filtrar        | Status válido retorna apenas o enum solicitado     | E2E              | `test/e2e/orders.e2e-spec.ts`                                                        | Passando | Cobrir pelo menos dois status nos dados                        |
| Filtrar        | Data inicial é inclusiva                           | E2E              | `test/e2e/orders.e2e-spec.ts`                                                        | Passando | Controlar timestamps da factory                                |
| Filtrar        | Data final em formato de data inclui o dia inteiro | Unitário + E2E   | `src/orders/orders.service.spec.ts`; `test/e2e/orders.e2e-spec.ts`                   | Passando | Exercitar `toEndOfDay` indiretamente                           |
| Filtrar        | Intervalo válido aplica os dois limites            | E2E              | `test/e2e/orders.e2e-spec.ts`                                                        | Passando | Incluir registro dentro e fora                                 |
| Filtrar        | Número, status e datas combinam por AND            | Unitário + E2E   | `src/orders/orders.service.spec.ts`; `test/e2e/orders.e2e-spec.ts`                   | Passando | Critério de aceite explícito                                   |
| Filtrar        | Intervalo invertido retorna `400`                  | E2E              | `test/e2e/orders.e2e-spec.ts`                                                        | Passando | Provável bug atual; corrigir causa raiz após falha reproduzida |
| Filtrar        | Status inválido retorna `400`                      | E2E              | `test/e2e/orders.e2e-spec.ts`                                                        | Passando | Validação antes do service                                     |
| Filtrar        | Paginação mantém filtros e metadados corretos      | E2E              | `test/e2e/orders.e2e-spec.ts`                                                        | Passando | Total deve refletir o filtro                                   |

### 4.7 Segurança, persistência e infraestrutura

| Funcionalidade | Regra                                                               | Tipo de teste      | Arquivo de teste                                                          | Estado   | Observações                             |
| -------------- | ------------------------------------------------------------------- | ------------------ | ------------------------------------------------------------------------- | -------- | --------------------------------------- |
| Guard global   | `APP_GUARD` protege todas as rotas não públicas                     | Unitário + E2E     | `src/auth/guards/jwt-auth.guard.spec.ts`; `test/e2e/security.e2e-spec.ts` | Passando | Sem lista manual de rotas protegidas    |
| DTO global     | `whitelist` e `forbidNonWhitelisted` valem no harness e em produção | E2E                | `test/e2e/security.e2e-spec.ts`                                           | Passando | Depende de `app.setup.ts` compartilhado |
| Senha          | Nenhuma resposta de auth inclui `password`                          | E2E                | `test/e2e/auth.e2e-spec.ts`                                               | Passando | Registro, login e erros                 |
| JWT            | Todas as rotas de pedido exigem Bearer válido                       | E2E parametrizado  | `test/e2e/security.e2e-spec.ts`                                           | Passando | POST, GET coleção/ID, PATCH e DELETE    |
| Prisma         | Migrations criam schema esperado em banco vazio                     | Integração/CI      | `test/integration/orders.service.integration-spec.ts`; workflow           | Passando | Usar `migrate deploy`, não `db push`    |
| Isolamento     | Limpeza é determinística e recusa banco não-test                    | Integração         | `test/helpers/test-database.ts`                                           | Passando | Teste do guard de segurança do helper   |
| Independência  | Suítes não dependem do seed nem da ordem                            | Todas              | Todos os arquivos                                                         | Passando | Factories + limpeza por teste           |
| Lint CI        | `lint:check` não modifica arquivos                                  | Comando/CI         | `package.json`; workflow                                                  | Passando | Validar diff antes/depois               |
| Cobertura      | Services/regras atingem no mínimo 75%                               | Unitário/cobertura | `jest.config.js`                                                          | Passando | Threshold deve falhar abaixo do mínimo  |
| Build          | Nest compila após todas as mudanças                                 | Comando/CI         | workflow                                                                  | Passando | Validado após `npm ci`                  |

## 5. CI implementado

Criado `.github/workflows/backend-ci.yml` para `pull_request` e `push` na `main`, com
`defaults.run.working-directory: backend` e PostgreSQL 16 como service saudável.

Ordem obrigatória:

1. checkout;
2. Node 22 e cache do `backend/package-lock.json`;
3. `npm ci`;
4. `npx prisma generate`;
5. `npx prisma migrate deploy` no banco `naporta_test`;
6. `npm run lint:check`;
7. `npm run test:unit`;
8. `npm run test:integration`;
9. `npm run test:e2e`;
10. `npm run test:cov`;
11. `npm run build`.

O workflow usa somente valores de teste declarados no próprio job. Nenhum `.env` local,
seed de desenvolvimento ou segredo do repositório é necessário. Cada comando é uma etapa
separada e qualquer falha encerra o job com erro.

## 6. Fases executadas após aprovação

1. **Baseline e ambiente:** rediagnosticar a demora de build/lint, instalar dependências
   Jest/Nest/Supertest com lockfile, criar configs, banco de teste e helper fail-closed.
2. **Primeiro ciclo:** AuthService + guard + e2e mínimo de registro/login/proteção.
3. **Segundo ciclo:** OrdersService unitário, factories e integração real com Prisma.
4. **Terceiro ciclo:** e2e de criação, listagem, busca e atualização.
5. **Quarto ciclo:** exclusão lógica, filtros simples/combinados e casos inválidos.
6. **Hardening:** corrigir apenas bugs/testabilidade comprovados pelos testes (intervalo
   invertido, ordenação ou corrida de constraint, se reproduzidos).
7. **Automação:** scripts, threshold de cobertura e GitHub Actions.
8. **Documentação e validação limpa:** atualizar READMEs, recriar banco do zero, rodar todos
   os comandos, confirmar que lint não altera arquivos e revisar o diff.

Cada fase seguiu o loop da TASK-04: pequeno grupo de testes, execução, causa raiz,
correção, reexecução e suíte completa, sem ultrapassar oito ciclos.

## 7. Comandos de aceite executados

```bash
cd backend
npm ci
docker compose -f docker-compose.test.yml up -d --wait
npm run test:db:prepare
npm test
npm run test:unit
npm run test:integration
npm run test:e2e
npm run test:cov
npm run lint:check
npm run build
docker compose -f docker-compose.test.yml down -v
```

O banco foi removido, recriado do zero e recebeu as duas migrations pelo script
multiplataforma documentado.

## 8. Riscos e pontos para revisão

- E2E com PostgreSQL real é mais lento; as suítes de banco são seriais e o CI possui
  healthcheck explícito.
- `PATCH {}` foi caracterizado e documentado como `200` idempotente sem alteração.
- A regra `startDate <= endDate` foi adicionada após o E2E reproduzir o retorno incorreto
  `200` para intervalo invertido.
- Não foi criada autorização por papéis, pois ela não existe no produto nem no enunciado.
  A TASK-04 comprovou o limite real: JWT obrigatório para pedidos.
- `npm audit --omit=dev` ainda reporta 9 vulnerabilidades transitivas nas cadeias existentes
  de Nest/Prisma (1 baixa, 5 moderadas e 3 altas); atualização de dependências fica fora
  desta tarefa para não misturar hardening com a entrega de testes/CI.

## 9. Mensagens de commit sugeridas para criação manual futura

Nenhum commit foi criado pelo agente. Sugestões para revisão e criação manual:

```text
test(auth): cover registration and JWT authentication
test(orders): add service and validation coverage
test(e2e): validate order API with PostgreSQL
ci: run backend quality gates on pull requests
docs(testing): document automated test workflow
```
