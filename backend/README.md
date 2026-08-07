# naPorta — API de Pedidos (Desafio Backend)

Web API REST para gestão de pedidos, construída para o [desafio backend da naPorta](./CHALLENGE.md).

## Stack e justificativas

| Tecnologia | Por quê |
|---|---|
| **NestJS** (Node.js + TypeScript) | Framework preferido pelo desafio; arquitetura modular, injeção de dependência e validação integrada |
| **PostgreSQL** | Banco relacional preferido pelo desafio; modelo de pedidos/itens é naturalmente relacional |
| **Prisma 7** | ORM sugerido pelo desafio; schema tipado, migrations versionadas e client type-safe (gerado em `src/generated`, com driver adapter `@prisma/adapter-pg` e configuração em `prisma.config.ts`) |
| **JWT (Bearer)** | Autenticação exigida pelo desafio, via Passport |
| **Docker** | Item bônus; sobe API + banco com um único comando |

## Funcionalidades

- ✅ Criar pedido
- ✅ Listar pedidos (com paginação)
- ✅ Filtrar pedidos por número, período (data inicial/final) e status
- ✅ Editar pedido
- ✅ Excluir pedido (exclusão lógica — o registro permanece no banco com `deletedAt`)
- ✅ Autenticação JWT (registro + login)
- ✅ Seed com usuário demo e 10 pedidos fictícios

## Como executar

### Opção 1 — Docker (recomendado)

Pré-requisitos: Docker + Docker Compose.

```bash
cd backend
docker compose up -d --build
```

Isso sobe o PostgreSQL, aplica as migrations, executa o seed e inicia a API em `http://localhost:3000/api`.

> Portas ocupadas? Sobrescreva com variáveis de ambiente: `API_PORT=3001 POSTGRES_PORT=5433 docker compose up -d --build`

### Opção 2 — Local

Pré-requisitos: Node.js 22+, PostgreSQL rodando.

```bash
cd backend
cp .env.example .env        # o .env.example já vem com valores funcionais para avaliação local; ajuste DATABASE_URL se necessário
npm install
npx prisma generate         # gera o Prisma Client em src/generated
npx prisma migrate deploy   # aplica as migrations
npm run seed                # popula o banco (regra 7 do desafio)
npm run start:dev           # API em http://localhost:3000/api
```

## Variáveis de ambiente

| Variável | Descrição | Padrão |
|---|---|---|
| `DATABASE_URL` | String de conexão do PostgreSQL | — |
| `JWT_SECRET` | Segredo para assinar os tokens JWT | — |
| `JWT_EXPIRES_IN` | Validade do token | `1d` |
| `PORT` | Porta da API | `3000` |

## Scripts

| Script | Descrição |
|---|---|
| `npm run start:dev` | Inicia em modo desenvolvimento (watch) |
| `npm run build` | Compila para `dist/` |
| `npm run start:prod` | Inicia a versão compilada |
| `npm run seed` | Popula o banco com dados fictícios |
| `npm run lint` | Roda o ESLint e aplica correções automáticas |
| `npm run lint:check` | Verifica ESLint sem modificar arquivos |
| `npm test` / `npm run test:unit` | Testes unitários de services e guard |
| `npm run test:integration` | Integração dos services com PostgreSQL real |
| `npm run test:e2e` | API completa via HTTP e PostgreSQL real |
| `npm run test:cov` | Unitários com cobertura mínima obrigatória de 75% |
| `npm run test:db:prepare` | Gera o Prisma Client e aplica migrations no banco de teste |
| `npx prisma migrate dev` | Cria/aplica migrations em desenvolvimento |
| `npx prisma studio` | Interface visual do banco |

## Testes automatizados

### Pré-requisitos e isolamento

- Node.js 22+;
- Docker + Docker Compose;
- porta `5434` livre para o PostgreSQL de teste.

O ambiente automatizado usa o banco exclusivo `naporta_test`; ele não usa o banco
`naporta` de desenvolvimento, não depende do seed e limpa os dados entre cenários. O helper
de limpeza recusa qualquer `DATABASE_URL` cujo nome de banco não termine em `_test`.

Prepare o ambiente local:

```bash
cd backend
cp .env.test.example .env.test
docker compose -f docker-compose.test.yml up -d --wait
npm ci
npm run test:db:prepare
```

No Windows desta máquina, onde o Docker roda dentro do WSL, prefixe os comandos Docker com
`wsl`, por exemplo: `wsl docker compose -f docker-compose.test.yml up -d --wait`.

As variáveis exclusivas de teste são:

| Variável         | Uso                           | Valor local documentado                                                            |
| ---------------- | ----------------------------- | ---------------------------------------------------------------------------------- |
| `DATABASE_URL`   | PostgreSQL isolado            | `postgresql://naporta_test:naporta_test@127.0.0.1:5434/naporta_test?schema=public` |
| `JWT_SECRET`     | Assinatura de tokens de teste | valor fictício de `.env.test.example`                                              |
| `JWT_EXPIRES_IN` | Expiração de tokens de teste  | `1h`                                                                               |

### Suítes e comandos

```bash
npm test                  # alias dos unitários
npm run test:unit         # services e guard, sem banco
npm run test:integration  # services + constraints/relações reais do PostgreSQL
npm run test:e2e          # AppModule + HTTP/Supertest + PostgreSQL real
npm run test:cov          # threshold de 75% nos services/regras
npm run lint:check        # nunca altera arquivos
npm run build
```

Unitários isolam apenas as fronteiras dos services. Integração e E2E nunca substituem o
PostgreSQL por mocks: aplicam as migrations versionadas e executam serialmente para manter
limpeza determinística. Para encerrar o banco local:

```bash
docker compose -f docker-compose.test.yml down -v
```

### Integração contínua

O workflow `.github/workflows/backend-ci.yml` roda em pull requests e em pushes para
`main`: instala pelo lockfile, sobe PostgreSQL 16, gera o Prisma Client, aplica migrations,
executa lint sem escrita, unitários, integração, E2E, cobertura e build. Qualquer etapa
falha o job; nenhum `.env` local ou segredo real é usado.

### Limitações conhecidas

- A autorização atual é o contrato do desafio: JWT válido em todas as rotas de pedidos;
  não existem papéis nem controle de propriedade por usuário.
- `PATCH /orders/:id` com `{}` é aceito como operação idempotente sem alteração e retorna
  `200`.
- Prisma 7 carrega o compilador WASM dinamicamente; por isso os scripts com banco iniciam o
  Jest com `--experimental-vm-modules` no Node 22.

## Autenticação

Todas as rotas de pedidos exigem o header `Authorization: Bearer <token>`.

**Usuário do seed:** `admin@naporta.com` / senha `naporta123`

```bash
# Obter token
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@naporta.com", "password": "naporta123"}'
# → { "access_token": "eyJhbGciOi..." }
```

## Rotas

### Auth

| Método | Rota | Auth | Descrição |
|---|---|---|---|
| `POST` | `/api/auth/register` | — | Cria um usuário |
| `POST` | `/api/auth/login` | — | Retorna o token JWT |

<details>
<summary><strong>POST /api/auth/register</strong></summary>

```json
// Request
{ "name": "Fulano", "email": "fulano@email.com", "password": "senha123" }

// Response 201
{ "id": "uuid", "name": "Fulano", "email": "fulano@email.com", "createdAt": "..." }
```
</details>

<details>
<summary><strong>POST /api/auth/login</strong></summary>

```json
// Request
{ "email": "admin@naporta.com", "password": "naporta123" }

// Response 200
{ "access_token": "eyJhbGciOi..." }
```
</details>

### Pedidos (requerem Bearer token)

| Método | Rota | Descrição |
|---|---|---|
| `POST` | `/api/orders` | Cria um pedido |
| `GET` | `/api/orders` | Lista pedidos (filtros + paginação) |
| `GET` | `/api/orders/:id` | Detalha um pedido |
| `PATCH` | `/api/orders/:id` | Edita um pedido (parcial) |
| `DELETE` | `/api/orders/:id` | Exclusão lógica (204) |

#### Filtros do `GET /api/orders`

| Query param | Descrição | Exemplo |
|---|---|---|
| `orderNumber` | Busca parcial pelo número | `?orderNumber=ORD-0001` |
| `startDate` | Data de criação inicial | `?startDate=2026-01-01` |
| `endDate` | Data de criação final (inclusiva) | `?endDate=2026-12-31` |
| `status` | `PENDING` \| `IN_TRANSIT` \| `DELIVERED` \| `CANCELLED` | `?status=PENDING` |
| `page` | Página (padrão 1) | `?page=2` |
| `limit` | Itens por página (padrão 10, máx 100) | `?limit=20` |

Os filtros são combináveis: `?status=PENDING&startDate=2026-06-01&endDate=2026-06-30`

<details>
<summary><strong>POST /api/orders</strong></summary>

```json
// Request (campos de contato, origem e coordenadas são opcionais)
{
  "orderNumber": "ORD-0011",
  "deliveryForecast": "2026-06-20T12:00:00.000Z",
  "customerName": "Maria da Silva",
  "customerDocument": "123.456.789-00",
  "customerEmail": "maria.silva@email.com",
  "customerPhone": "+55 21 99876-1001",
  "originAddress": "Depósito naPorta - Av. Brasil, 500 - São Cristóvão, Rio de Janeiro - RJ",
  "originLat": -22.8975,
  "originLng": -43.2245,
  "deliveryAddress": "Rua das Acácias, 120 - Rio de Janeiro - RJ",
  "deliveryLat": -22.8625,
  "deliveryLng": -43.252,
  "items": [
    { "description": "Smartphone", "price": 1199.9 }
  ]
}

// Response 201
{
  "id": "uuid",
  "orderNumber": "ORD-0011",
  "deliveryForecast": "2026-06-20T12:00:00.000Z",
  "customerName": "Maria da Silva",
  "customerDocument": "123.456.789-00",
  "customerEmail": "maria.silva@email.com",
  "customerPhone": "+55 21 99876-1001",
  "originAddress": "Depósito naPorta - Av. Brasil, 500 - São Cristóvão, Rio de Janeiro - RJ",
  "originLat": -22.8975,
  "originLng": -43.2245,
  "deliveryAddress": "Rua das Acácias, 120 - Rio de Janeiro - RJ",
  "deliveryLat": -22.8625,
  "deliveryLng": -43.252,
  "status": "PENDING",
  "items": [
    { "id": "uuid", "description": "Smartphone", "price": "1199.9", "orderId": "uuid" }
  ],
  "createdAt": "...",
  "updatedAt": "...",
  "deletedAt": null
}
```
</details>

<details>
<summary><strong>GET /api/orders</strong></summary>

```json
// Response 200
{
  "data": [ { "id": "uuid", "orderNumber": "ORD-0010", "items": [/* ... */] /* ... */ } ],
  "meta": { "total": 10, "page": 1, "limit": 10, "lastPage": 1 }
}
```
</details>

### Códigos de retorno

| Código | Quando |
|---|---|
| `200` | Leitura/edição/login com sucesso |
| `201` | Criação com sucesso |
| `204` | Exclusão com sucesso |
| `400` | Payload inválido (validação) |
| `401` | Token ausente/inválido ou credenciais incorretas |
| `404` | Pedido não encontrado (ou excluído logicamente) |
| `409` | Número de pedido ou e-mail já existente |

## Decisões de projeto

- **Exclusão lógica**: o `DELETE` apenas preenche `deletedAt`; todas as consultas filtram `deletedAt: null`.
- **Campo `status`**: não está na tabela de campos do enunciado, mas é exigido pelo filtro por status — modelado como enum (`PENDING`, `IN_TRANSIT`, `DELIVERED`, `CANCELLED`).
- **Campos para o app mobile**: `customerEmail`, `customerPhone`, `originAddress` e as coordenadas (`originLat/Lng`, `deliveryLat/Lng`) foram adicionados (todos opcionais) para atender o layout do [desafio mobile](../mobile/CHALLENGE.md), que exibe contato do cliente e o mapa com a rota de entrega.
- **Segurança**: senhas com hash bcrypt, `helmet` nos headers HTTP, `ValidationPipe` global com `whitelist` + `forbidNonWhitelisted` (rejeita campos não esperados), segredos somente via variáveis de ambiente, senha nunca retornada nas respostas.
- **Guard JWT global**: todas as rotas são protegidas por padrão; apenas `register`/`login` são públicas (decorator `@Public()`).
