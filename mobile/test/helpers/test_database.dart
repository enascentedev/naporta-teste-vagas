import 'package:drift/native.dart';
import 'package:naporta_pedidos/data/local/app_database.dart';

/// Banco em memória para testes de repositório. O `package:sqlite3` 3.x usa
/// native assets, então o SQLite é compilado/baixado automaticamente pelo
/// `flutter test`, sem depender de DLLs no PATH.
AppDatabase createInMemoryDatabase() =>
    AppDatabase.withExecutor(NativeDatabase.memory());
