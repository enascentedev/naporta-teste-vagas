# Desafio naPorta — Backend + Mobile

Solução para os desafios de código da naPorta: uma API REST de gestão de pedidos e um app Flutter offline first que a consome.

| Projeto | Stack | Enunciado | Documentação |
|---|---|---|---|
| [`backend/`](./backend) | NestJS · PostgreSQL · Prisma · JWT · Docker | [CHALLENGE.md](./backend/CHALLENGE.md) | [README](./backend/README.md) |
| [`mobile/`](./mobile) | Flutter · MVVM · Drift (SQLite) · flutter_map/OSRM | [CHALLENGE.md](./mobile/CHALLENGE.md) | [README](./mobile/README.md) |

## Visão geral

- **Backend**: API REST com autenticação JWT (Bearer), CRUD de pedidos com filtros por número, período e status, exclusão lógica e seed com dados de demonstração. Sobe com um comando via Docker Compose.
- **Mobile**: app de acompanhamento de pedidos seguindo o layout do Figma — listagem com scroll infinito, detalhes do pedido e mapa com a rota de entrega. Offline first: a UI lê sempre do banco local (SQLite/Drift) e a API apenas sincroniza; sem rede, o app segue funcionando.

## Execução rápida

Pré-requisitos: Docker + Docker Compose e Flutter 3.x.

```bash
# 1. API + banco (http://localhost:3000/api, com migrations e seed automáticos)
cd backend
docker compose up -d --build

# 2. App Flutter (emulador Android, dispositivo físico ou web)
cd ../mobile
flutter pub get
dart run build_runner build
flutter run
```

Credenciais de demonstração: `admin@naporta.com` / `naporta123` (já pré-preenchidas na tela de login do app).

O passo a passo completo — incluindo execução sem Docker, no navegador e em dispositivo físico — está nos READMEs de cada projeto.

## Testes

- **Mobile**: `flutter test` — ViewModels, repositório offline first (banco em memória) e widgets.
- **Backend**: `npm test`, `npm run test:integration` e `npm run test:e2e` — services,
  autenticação/JWT, validações, filtros combinados, persistência e exclusão lógica em
  PostgreSQL real. O workflow `Backend CI` também executa lint sem autocorreção, cobertura
  e build em pull requests e na `main`.
