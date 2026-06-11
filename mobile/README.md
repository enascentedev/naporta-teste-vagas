# naPorta Pedidos — App Flutter (Desafio Mobile)

App **offline first** de acompanhamento de pedidos, construído para o [desafio mobile da naPorta](./CHALLENGE.md), seguindo o [layout do Figma](https://www.figma.com/proto/l51mqIkdtTX91K6lfnO8GH/Desafio-Mobile?type=design&node-id=47-2&t=H8x4BD7H4L4MMW58-0&scaling=scale-down&page-id=47%3A2&prev-org-id=external-teams) e consumindo a [API do desafio backend](../backend/README.md) deste mesmo repositório.

## Funcionalidades

- ✅ **Login** (JWT) — tela extra, criada no mesmo design system do protótipo, pois a API exige autenticação
- ✅ **Listagem de pedidos com scroll infinito** + pull-to-refresh
- ✅ **Detalhes do pedido** com dados do cliente e itens
- ✅ **Mapa com rota de entrega** (OpenStreetMap + rota real por ruas via OSRM — sem chave de API)
- ✅ **Offline first** com banco local **SQLite (Drift)**: a UI lê sempre do banco; a API só sincroniza
- ✅ Rota do mapa **cacheada localmente** (funciona offline após a 1ª visualização)
- ✅ Criação de pedido (botão "Novo pedido" do layout)
- ✅ Testes automatizados (ViewModels, repositório com banco em memória e widgets)

## Stack e decisões

| Tecnologia | Por quê |
|---|---|
| **Flutter** | Exigido pelo desafio |
| **MVVM + Provider/ChangeNotifier** | Item bônus; padrão de arquitetura da documentação oficial do Flutter |
| **Drift (SQLite)** | Banco local exigido pelo desafio (offline first); queries tipadas e reativas (streams) |
| **Dio** | Cliente HTTP com interceptor para o Bearer token (401 → volta ao login) |
| **flutter_map + OpenStreetMap** | Mapa sem chave de API — o avaliador roda o projeto sem configurar nada |
| **OSRM** | Rota real de carro entre origem e destino, gratuito e sem chave |
| **flutter_secure_storage** | Armazenamento seguro do JWT |

### Arquitetura (MVVM por feature)

```
lib/
  core/        # tema (design system do Figma), config, Result
  domain/      # modelos de domínio (Order, OrderItem)
  data/
    services/  # Dio (ApiClient), AuthApi, OrdersApi, RoutingService (OSRM)
    local/     # AppDatabase (Drift) — fonte única da verdade da UI
    repositories/  # AuthRepository, OrderRepository (offline first)
  ui/
    auth/ login/ orders/ order_details/ new_order/   # ViewModel + telas
```

**Offline first:** a UI observa streams do Drift. `OrderRepository.syncPage()` busca uma página da API e faz upsert no banco; se a rede falhar, o app segue com os dados locais e exibe um badge "Offline". O scroll infinito pagina localmente e sincroniza páginas remotas quando há conexão.

## Como executar

### 1. Suba a API (com Docker)

```bash
cd ../backend
docker compose up -d --build
```

A API sobe em `http://localhost:3000/api` com migrations aplicadas e seed (10 pedidos + usuário demo).
Portas ocupadas? `API_PORT=3001 POSTGRES_PORT=5433 docker compose up -d --build`

### 2. Rode o app

Pré-requisitos: Flutter 3.x e um emulador Android (ou dispositivo físico).

```bash
flutter pub get
dart run build_runner build   # gera o código do Drift
flutter run
```

O app aponta por padrão para `http://10.0.2.2:3000/api` (o `localhost` da máquina visto de dentro do **emulador Android**).

Para outros cenários, sobrescreva a URL:

```bash
# Dispositivo físico (use o IP da sua máquina na rede local)
flutter run --dart-define=API_BASE_URL=http://192.168.0.10:3000/api

# API em outra porta
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3001/api
```

### Alternativa: rodar no navegador (web)

Sem emulador/dispositivo à mão, o app também roda na web — o suporte ao Drift/SQLite vem dos assets `web/sqlite3.wasm` e `web/drift_worker.js` (já incluídos no repositório):

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3001/api
```

Ou compile e sirva a versão release:

```bash
flutter build web --release --dart-define=API_BASE_URL=http://localhost:3001/api
cd build/web && python3 -m http.server 8080   # abra http://localhost:8080
```

> Na web o banco local usa o SQLite em WASM (OPFS/IndexedDB), então o offline first funciona da mesma forma. O alvo principal do desafio continua sendo Android; a web é uma conveniência para avaliação rápida.

### 3. Login

| Campo | Valor |
|---|---|
| E-mail | `admin@naporta.com` |
| Senha | `naporta123` |

Os campos já vêm pré-preenchidos para facilitar a avaliação.

## Testes

```bash
flutter test
```

Cobrem: fluxos de login/logout/sessão expirada (`AuthViewModel`), paginação e estados offline (`OrdersViewModel`), sincronização/upsert/cache de rota com banco em memória (`OrderRepository`) e renderização da listagem (widget tests).

## Testando o offline first

1. Abra o app com a API no ar e navegue pela listagem e por alguns detalhes;
2. Derrube a API: `docker compose stop api`;
3. Feche e reabra o app: listagem, detalhes e mapas já visitados continuam funcionando — os dados vêm do SQLite local e a rota do cache (badge "Offline" aparece na listagem).
