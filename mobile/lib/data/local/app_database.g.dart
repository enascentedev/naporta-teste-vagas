// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $OrderRowsTable extends OrderRows
    with TableInfo<$OrderRowsTable, OrderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderNumberMeta = const VerificationMeta(
    'orderNumber',
  );
  @override
  late final GeneratedColumn<String> orderNumber = GeneratedColumn<String>(
    'order_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deliveryForecastMeta = const VerificationMeta(
    'deliveryForecast',
  );
  @override
  late final GeneratedColumn<DateTime> deliveryForecast =
      GeneratedColumn<DateTime>(
        'delivery_forecast',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerDocumentMeta = const VerificationMeta(
    'customerDocument',
  );
  @override
  late final GeneratedColumn<String> customerDocument = GeneratedColumn<String>(
    'customer_document',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerEmailMeta = const VerificationMeta(
    'customerEmail',
  );
  @override
  late final GeneratedColumn<String> customerEmail = GeneratedColumn<String>(
    'customer_email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerPhoneMeta = const VerificationMeta(
    'customerPhone',
  );
  @override
  late final GeneratedColumn<String> customerPhone = GeneratedColumn<String>(
    'customer_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originAddressMeta = const VerificationMeta(
    'originAddress',
  );
  @override
  late final GeneratedColumn<String> originAddress = GeneratedColumn<String>(
    'origin_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originLatMeta = const VerificationMeta(
    'originLat',
  );
  @override
  late final GeneratedColumn<double> originLat = GeneratedColumn<double>(
    'origin_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originLngMeta = const VerificationMeta(
    'originLng',
  );
  @override
  late final GeneratedColumn<double> originLng = GeneratedColumn<double>(
    'origin_lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deliveryAddressMeta = const VerificationMeta(
    'deliveryAddress',
  );
  @override
  late final GeneratedColumn<String> deliveryAddress = GeneratedColumn<String>(
    'delivery_address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deliveryLatMeta = const VerificationMeta(
    'deliveryLat',
  );
  @override
  late final GeneratedColumn<double> deliveryLat = GeneratedColumn<double>(
    'delivery_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deliveryLngMeta = const VerificationMeta(
    'deliveryLng',
  );
  @override
  late final GeneratedColumn<double> deliveryLng = GeneratedColumn<double>(
    'delivery_lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemsJsonMeta = const VerificationMeta(
    'itemsJson',
  );
  @override
  late final GeneratedColumn<String> itemsJson = GeneratedColumn<String>(
    'items_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routeGeometryJsonMeta = const VerificationMeta(
    'routeGeometryJson',
  );
  @override
  late final GeneratedColumn<String> routeGeometryJson =
      GeneratedColumn<String>(
        'route_geometry_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    orderNumber,
    deliveryForecast,
    customerName,
    customerDocument,
    customerEmail,
    customerPhone,
    originAddress,
    originLat,
    originLng,
    deliveryAddress,
    deliveryLat,
    deliveryLng,
    status,
    createdAt,
    itemsJson,
    routeGeometryJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('order_number')) {
      context.handle(
        _orderNumberMeta,
        orderNumber.isAcceptableOrUnknown(
          data['order_number']!,
          _orderNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_orderNumberMeta);
    }
    if (data.containsKey('delivery_forecast')) {
      context.handle(
        _deliveryForecastMeta,
        deliveryForecast.isAcceptableOrUnknown(
          data['delivery_forecast']!,
          _deliveryForecastMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deliveryForecastMeta);
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('customer_document')) {
      context.handle(
        _customerDocumentMeta,
        customerDocument.isAcceptableOrUnknown(
          data['customer_document']!,
          _customerDocumentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerDocumentMeta);
    }
    if (data.containsKey('customer_email')) {
      context.handle(
        _customerEmailMeta,
        customerEmail.isAcceptableOrUnknown(
          data['customer_email']!,
          _customerEmailMeta,
        ),
      );
    }
    if (data.containsKey('customer_phone')) {
      context.handle(
        _customerPhoneMeta,
        customerPhone.isAcceptableOrUnknown(
          data['customer_phone']!,
          _customerPhoneMeta,
        ),
      );
    }
    if (data.containsKey('origin_address')) {
      context.handle(
        _originAddressMeta,
        originAddress.isAcceptableOrUnknown(
          data['origin_address']!,
          _originAddressMeta,
        ),
      );
    }
    if (data.containsKey('origin_lat')) {
      context.handle(
        _originLatMeta,
        originLat.isAcceptableOrUnknown(data['origin_lat']!, _originLatMeta),
      );
    }
    if (data.containsKey('origin_lng')) {
      context.handle(
        _originLngMeta,
        originLng.isAcceptableOrUnknown(data['origin_lng']!, _originLngMeta),
      );
    }
    if (data.containsKey('delivery_address')) {
      context.handle(
        _deliveryAddressMeta,
        deliveryAddress.isAcceptableOrUnknown(
          data['delivery_address']!,
          _deliveryAddressMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deliveryAddressMeta);
    }
    if (data.containsKey('delivery_lat')) {
      context.handle(
        _deliveryLatMeta,
        deliveryLat.isAcceptableOrUnknown(
          data['delivery_lat']!,
          _deliveryLatMeta,
        ),
      );
    }
    if (data.containsKey('delivery_lng')) {
      context.handle(
        _deliveryLngMeta,
        deliveryLng.isAcceptableOrUnknown(
          data['delivery_lng']!,
          _deliveryLngMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('items_json')) {
      context.handle(
        _itemsJsonMeta,
        itemsJson.isAcceptableOrUnknown(data['items_json']!, _itemsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_itemsJsonMeta);
    }
    if (data.containsKey('route_geometry_json')) {
      context.handle(
        _routeGeometryJsonMeta,
        routeGeometryJson.isAcceptableOrUnknown(
          data['route_geometry_json']!,
          _routeGeometryJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      orderNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_number'],
      )!,
      deliveryForecast: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}delivery_forecast'],
      )!,
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      )!,
      customerDocument: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_document'],
      )!,
      customerEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_email'],
      ),
      customerPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_phone'],
      ),
      originAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_address'],
      ),
      originLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}origin_lat'],
      ),
      originLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}origin_lng'],
      ),
      deliveryAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivery_address'],
      )!,
      deliveryLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}delivery_lat'],
      ),
      deliveryLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}delivery_lng'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      itemsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}items_json'],
      )!,
      routeGeometryJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_geometry_json'],
      ),
    );
  }

  @override
  $OrderRowsTable createAlias(String alias) {
    return $OrderRowsTable(attachedDatabase, alias);
  }
}

class OrderRow extends DataClass implements Insertable<OrderRow> {
  final String id;
  final String orderNumber;
  final DateTime deliveryForecast;
  final String customerName;
  final String customerDocument;
  final String? customerEmail;
  final String? customerPhone;
  final String? originAddress;
  final double? originLat;
  final double? originLng;
  final String deliveryAddress;
  final double? deliveryLat;
  final double? deliveryLng;
  final String status;
  final DateTime createdAt;
  final String itemsJson;
  final String? routeGeometryJson;
  const OrderRow({
    required this.id,
    required this.orderNumber,
    required this.deliveryForecast,
    required this.customerName,
    required this.customerDocument,
    this.customerEmail,
    this.customerPhone,
    this.originAddress,
    this.originLat,
    this.originLng,
    required this.deliveryAddress,
    this.deliveryLat,
    this.deliveryLng,
    required this.status,
    required this.createdAt,
    required this.itemsJson,
    this.routeGeometryJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['order_number'] = Variable<String>(orderNumber);
    map['delivery_forecast'] = Variable<DateTime>(deliveryForecast);
    map['customer_name'] = Variable<String>(customerName);
    map['customer_document'] = Variable<String>(customerDocument);
    if (!nullToAbsent || customerEmail != null) {
      map['customer_email'] = Variable<String>(customerEmail);
    }
    if (!nullToAbsent || customerPhone != null) {
      map['customer_phone'] = Variable<String>(customerPhone);
    }
    if (!nullToAbsent || originAddress != null) {
      map['origin_address'] = Variable<String>(originAddress);
    }
    if (!nullToAbsent || originLat != null) {
      map['origin_lat'] = Variable<double>(originLat);
    }
    if (!nullToAbsent || originLng != null) {
      map['origin_lng'] = Variable<double>(originLng);
    }
    map['delivery_address'] = Variable<String>(deliveryAddress);
    if (!nullToAbsent || deliveryLat != null) {
      map['delivery_lat'] = Variable<double>(deliveryLat);
    }
    if (!nullToAbsent || deliveryLng != null) {
      map['delivery_lng'] = Variable<double>(deliveryLng);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['items_json'] = Variable<String>(itemsJson);
    if (!nullToAbsent || routeGeometryJson != null) {
      map['route_geometry_json'] = Variable<String>(routeGeometryJson);
    }
    return map;
  }

  OrderRowsCompanion toCompanion(bool nullToAbsent) {
    return OrderRowsCompanion(
      id: Value(id),
      orderNumber: Value(orderNumber),
      deliveryForecast: Value(deliveryForecast),
      customerName: Value(customerName),
      customerDocument: Value(customerDocument),
      customerEmail: customerEmail == null && nullToAbsent
          ? const Value.absent()
          : Value(customerEmail),
      customerPhone: customerPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(customerPhone),
      originAddress: originAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(originAddress),
      originLat: originLat == null && nullToAbsent
          ? const Value.absent()
          : Value(originLat),
      originLng: originLng == null && nullToAbsent
          ? const Value.absent()
          : Value(originLng),
      deliveryAddress: Value(deliveryAddress),
      deliveryLat: deliveryLat == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryLat),
      deliveryLng: deliveryLng == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryLng),
      status: Value(status),
      createdAt: Value(createdAt),
      itemsJson: Value(itemsJson),
      routeGeometryJson: routeGeometryJson == null && nullToAbsent
          ? const Value.absent()
          : Value(routeGeometryJson),
    );
  }

  factory OrderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderRow(
      id: serializer.fromJson<String>(json['id']),
      orderNumber: serializer.fromJson<String>(json['orderNumber']),
      deliveryForecast: serializer.fromJson<DateTime>(json['deliveryForecast']),
      customerName: serializer.fromJson<String>(json['customerName']),
      customerDocument: serializer.fromJson<String>(json['customerDocument']),
      customerEmail: serializer.fromJson<String?>(json['customerEmail']),
      customerPhone: serializer.fromJson<String?>(json['customerPhone']),
      originAddress: serializer.fromJson<String?>(json['originAddress']),
      originLat: serializer.fromJson<double?>(json['originLat']),
      originLng: serializer.fromJson<double?>(json['originLng']),
      deliveryAddress: serializer.fromJson<String>(json['deliveryAddress']),
      deliveryLat: serializer.fromJson<double?>(json['deliveryLat']),
      deliveryLng: serializer.fromJson<double?>(json['deliveryLng']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      itemsJson: serializer.fromJson<String>(json['itemsJson']),
      routeGeometryJson: serializer.fromJson<String?>(
        json['routeGeometryJson'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'orderNumber': serializer.toJson<String>(orderNumber),
      'deliveryForecast': serializer.toJson<DateTime>(deliveryForecast),
      'customerName': serializer.toJson<String>(customerName),
      'customerDocument': serializer.toJson<String>(customerDocument),
      'customerEmail': serializer.toJson<String?>(customerEmail),
      'customerPhone': serializer.toJson<String?>(customerPhone),
      'originAddress': serializer.toJson<String?>(originAddress),
      'originLat': serializer.toJson<double?>(originLat),
      'originLng': serializer.toJson<double?>(originLng),
      'deliveryAddress': serializer.toJson<String>(deliveryAddress),
      'deliveryLat': serializer.toJson<double?>(deliveryLat),
      'deliveryLng': serializer.toJson<double?>(deliveryLng),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'itemsJson': serializer.toJson<String>(itemsJson),
      'routeGeometryJson': serializer.toJson<String?>(routeGeometryJson),
    };
  }

  OrderRow copyWith({
    String? id,
    String? orderNumber,
    DateTime? deliveryForecast,
    String? customerName,
    String? customerDocument,
    Value<String?> customerEmail = const Value.absent(),
    Value<String?> customerPhone = const Value.absent(),
    Value<String?> originAddress = const Value.absent(),
    Value<double?> originLat = const Value.absent(),
    Value<double?> originLng = const Value.absent(),
    String? deliveryAddress,
    Value<double?> deliveryLat = const Value.absent(),
    Value<double?> deliveryLng = const Value.absent(),
    String? status,
    DateTime? createdAt,
    String? itemsJson,
    Value<String?> routeGeometryJson = const Value.absent(),
  }) => OrderRow(
    id: id ?? this.id,
    orderNumber: orderNumber ?? this.orderNumber,
    deliveryForecast: deliveryForecast ?? this.deliveryForecast,
    customerName: customerName ?? this.customerName,
    customerDocument: customerDocument ?? this.customerDocument,
    customerEmail: customerEmail.present
        ? customerEmail.value
        : this.customerEmail,
    customerPhone: customerPhone.present
        ? customerPhone.value
        : this.customerPhone,
    originAddress: originAddress.present
        ? originAddress.value
        : this.originAddress,
    originLat: originLat.present ? originLat.value : this.originLat,
    originLng: originLng.present ? originLng.value : this.originLng,
    deliveryAddress: deliveryAddress ?? this.deliveryAddress,
    deliveryLat: deliveryLat.present ? deliveryLat.value : this.deliveryLat,
    deliveryLng: deliveryLng.present ? deliveryLng.value : this.deliveryLng,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    itemsJson: itemsJson ?? this.itemsJson,
    routeGeometryJson: routeGeometryJson.present
        ? routeGeometryJson.value
        : this.routeGeometryJson,
  );
  OrderRow copyWithCompanion(OrderRowsCompanion data) {
    return OrderRow(
      id: data.id.present ? data.id.value : this.id,
      orderNumber: data.orderNumber.present
          ? data.orderNumber.value
          : this.orderNumber,
      deliveryForecast: data.deliveryForecast.present
          ? data.deliveryForecast.value
          : this.deliveryForecast,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      customerDocument: data.customerDocument.present
          ? data.customerDocument.value
          : this.customerDocument,
      customerEmail: data.customerEmail.present
          ? data.customerEmail.value
          : this.customerEmail,
      customerPhone: data.customerPhone.present
          ? data.customerPhone.value
          : this.customerPhone,
      originAddress: data.originAddress.present
          ? data.originAddress.value
          : this.originAddress,
      originLat: data.originLat.present ? data.originLat.value : this.originLat,
      originLng: data.originLng.present ? data.originLng.value : this.originLng,
      deliveryAddress: data.deliveryAddress.present
          ? data.deliveryAddress.value
          : this.deliveryAddress,
      deliveryLat: data.deliveryLat.present
          ? data.deliveryLat.value
          : this.deliveryLat,
      deliveryLng: data.deliveryLng.present
          ? data.deliveryLng.value
          : this.deliveryLng,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      itemsJson: data.itemsJson.present ? data.itemsJson.value : this.itemsJson,
      routeGeometryJson: data.routeGeometryJson.present
          ? data.routeGeometryJson.value
          : this.routeGeometryJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderRow(')
          ..write('id: $id, ')
          ..write('orderNumber: $orderNumber, ')
          ..write('deliveryForecast: $deliveryForecast, ')
          ..write('customerName: $customerName, ')
          ..write('customerDocument: $customerDocument, ')
          ..write('customerEmail: $customerEmail, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('originAddress: $originAddress, ')
          ..write('originLat: $originLat, ')
          ..write('originLng: $originLng, ')
          ..write('deliveryAddress: $deliveryAddress, ')
          ..write('deliveryLat: $deliveryLat, ')
          ..write('deliveryLng: $deliveryLng, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('itemsJson: $itemsJson, ')
          ..write('routeGeometryJson: $routeGeometryJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    orderNumber,
    deliveryForecast,
    customerName,
    customerDocument,
    customerEmail,
    customerPhone,
    originAddress,
    originLat,
    originLng,
    deliveryAddress,
    deliveryLat,
    deliveryLng,
    status,
    createdAt,
    itemsJson,
    routeGeometryJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderRow &&
          other.id == this.id &&
          other.orderNumber == this.orderNumber &&
          other.deliveryForecast == this.deliveryForecast &&
          other.customerName == this.customerName &&
          other.customerDocument == this.customerDocument &&
          other.customerEmail == this.customerEmail &&
          other.customerPhone == this.customerPhone &&
          other.originAddress == this.originAddress &&
          other.originLat == this.originLat &&
          other.originLng == this.originLng &&
          other.deliveryAddress == this.deliveryAddress &&
          other.deliveryLat == this.deliveryLat &&
          other.deliveryLng == this.deliveryLng &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.itemsJson == this.itemsJson &&
          other.routeGeometryJson == this.routeGeometryJson);
}

class OrderRowsCompanion extends UpdateCompanion<OrderRow> {
  final Value<String> id;
  final Value<String> orderNumber;
  final Value<DateTime> deliveryForecast;
  final Value<String> customerName;
  final Value<String> customerDocument;
  final Value<String?> customerEmail;
  final Value<String?> customerPhone;
  final Value<String?> originAddress;
  final Value<double?> originLat;
  final Value<double?> originLng;
  final Value<String> deliveryAddress;
  final Value<double?> deliveryLat;
  final Value<double?> deliveryLng;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<String> itemsJson;
  final Value<String?> routeGeometryJson;
  final Value<int> rowid;
  const OrderRowsCompanion({
    this.id = const Value.absent(),
    this.orderNumber = const Value.absent(),
    this.deliveryForecast = const Value.absent(),
    this.customerName = const Value.absent(),
    this.customerDocument = const Value.absent(),
    this.customerEmail = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.originAddress = const Value.absent(),
    this.originLat = const Value.absent(),
    this.originLng = const Value.absent(),
    this.deliveryAddress = const Value.absent(),
    this.deliveryLat = const Value.absent(),
    this.deliveryLng = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.itemsJson = const Value.absent(),
    this.routeGeometryJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrderRowsCompanion.insert({
    required String id,
    required String orderNumber,
    required DateTime deliveryForecast,
    required String customerName,
    required String customerDocument,
    this.customerEmail = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.originAddress = const Value.absent(),
    this.originLat = const Value.absent(),
    this.originLng = const Value.absent(),
    required String deliveryAddress,
    this.deliveryLat = const Value.absent(),
    this.deliveryLng = const Value.absent(),
    required String status,
    required DateTime createdAt,
    required String itemsJson,
    this.routeGeometryJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       orderNumber = Value(orderNumber),
       deliveryForecast = Value(deliveryForecast),
       customerName = Value(customerName),
       customerDocument = Value(customerDocument),
       deliveryAddress = Value(deliveryAddress),
       status = Value(status),
       createdAt = Value(createdAt),
       itemsJson = Value(itemsJson);
  static Insertable<OrderRow> custom({
    Expression<String>? id,
    Expression<String>? orderNumber,
    Expression<DateTime>? deliveryForecast,
    Expression<String>? customerName,
    Expression<String>? customerDocument,
    Expression<String>? customerEmail,
    Expression<String>? customerPhone,
    Expression<String>? originAddress,
    Expression<double>? originLat,
    Expression<double>? originLng,
    Expression<String>? deliveryAddress,
    Expression<double>? deliveryLat,
    Expression<double>? deliveryLng,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<String>? itemsJson,
    Expression<String>? routeGeometryJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderNumber != null) 'order_number': orderNumber,
      if (deliveryForecast != null) 'delivery_forecast': deliveryForecast,
      if (customerName != null) 'customer_name': customerName,
      if (customerDocument != null) 'customer_document': customerDocument,
      if (customerEmail != null) 'customer_email': customerEmail,
      if (customerPhone != null) 'customer_phone': customerPhone,
      if (originAddress != null) 'origin_address': originAddress,
      if (originLat != null) 'origin_lat': originLat,
      if (originLng != null) 'origin_lng': originLng,
      if (deliveryAddress != null) 'delivery_address': deliveryAddress,
      if (deliveryLat != null) 'delivery_lat': deliveryLat,
      if (deliveryLng != null) 'delivery_lng': deliveryLng,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (itemsJson != null) 'items_json': itemsJson,
      if (routeGeometryJson != null) 'route_geometry_json': routeGeometryJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrderRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? orderNumber,
    Value<DateTime>? deliveryForecast,
    Value<String>? customerName,
    Value<String>? customerDocument,
    Value<String?>? customerEmail,
    Value<String?>? customerPhone,
    Value<String?>? originAddress,
    Value<double?>? originLat,
    Value<double?>? originLng,
    Value<String>? deliveryAddress,
    Value<double?>? deliveryLat,
    Value<double?>? deliveryLng,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<String>? itemsJson,
    Value<String?>? routeGeometryJson,
    Value<int>? rowid,
  }) {
    return OrderRowsCompanion(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      deliveryForecast: deliveryForecast ?? this.deliveryForecast,
      customerName: customerName ?? this.customerName,
      customerDocument: customerDocument ?? this.customerDocument,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      originAddress: originAddress ?? this.originAddress,
      originLat: originLat ?? this.originLat,
      originLng: originLng ?? this.originLng,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryLat: deliveryLat ?? this.deliveryLat,
      deliveryLng: deliveryLng ?? this.deliveryLng,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      itemsJson: itemsJson ?? this.itemsJson,
      routeGeometryJson: routeGeometryJson ?? this.routeGeometryJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (orderNumber.present) {
      map['order_number'] = Variable<String>(orderNumber.value);
    }
    if (deliveryForecast.present) {
      map['delivery_forecast'] = Variable<DateTime>(deliveryForecast.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (customerDocument.present) {
      map['customer_document'] = Variable<String>(customerDocument.value);
    }
    if (customerEmail.present) {
      map['customer_email'] = Variable<String>(customerEmail.value);
    }
    if (customerPhone.present) {
      map['customer_phone'] = Variable<String>(customerPhone.value);
    }
    if (originAddress.present) {
      map['origin_address'] = Variable<String>(originAddress.value);
    }
    if (originLat.present) {
      map['origin_lat'] = Variable<double>(originLat.value);
    }
    if (originLng.present) {
      map['origin_lng'] = Variable<double>(originLng.value);
    }
    if (deliveryAddress.present) {
      map['delivery_address'] = Variable<String>(deliveryAddress.value);
    }
    if (deliveryLat.present) {
      map['delivery_lat'] = Variable<double>(deliveryLat.value);
    }
    if (deliveryLng.present) {
      map['delivery_lng'] = Variable<double>(deliveryLng.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (itemsJson.present) {
      map['items_json'] = Variable<String>(itemsJson.value);
    }
    if (routeGeometryJson.present) {
      map['route_geometry_json'] = Variable<String>(routeGeometryJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderRowsCompanion(')
          ..write('id: $id, ')
          ..write('orderNumber: $orderNumber, ')
          ..write('deliveryForecast: $deliveryForecast, ')
          ..write('customerName: $customerName, ')
          ..write('customerDocument: $customerDocument, ')
          ..write('customerEmail: $customerEmail, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('originAddress: $originAddress, ')
          ..write('originLat: $originLat, ')
          ..write('originLng: $originLng, ')
          ..write('deliveryAddress: $deliveryAddress, ')
          ..write('deliveryLat: $deliveryLat, ')
          ..write('deliveryLng: $deliveryLng, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('itemsJson: $itemsJson, ')
          ..write('routeGeometryJson: $routeGeometryJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OrderRowsTable orderRows = $OrderRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [orderRows];
}

typedef $$OrderRowsTableCreateCompanionBuilder =
    OrderRowsCompanion Function({
      required String id,
      required String orderNumber,
      required DateTime deliveryForecast,
      required String customerName,
      required String customerDocument,
      Value<String?> customerEmail,
      Value<String?> customerPhone,
      Value<String?> originAddress,
      Value<double?> originLat,
      Value<double?> originLng,
      required String deliveryAddress,
      Value<double?> deliveryLat,
      Value<double?> deliveryLng,
      required String status,
      required DateTime createdAt,
      required String itemsJson,
      Value<String?> routeGeometryJson,
      Value<int> rowid,
    });
typedef $$OrderRowsTableUpdateCompanionBuilder =
    OrderRowsCompanion Function({
      Value<String> id,
      Value<String> orderNumber,
      Value<DateTime> deliveryForecast,
      Value<String> customerName,
      Value<String> customerDocument,
      Value<String?> customerEmail,
      Value<String?> customerPhone,
      Value<String?> originAddress,
      Value<double?> originLat,
      Value<double?> originLng,
      Value<String> deliveryAddress,
      Value<double?> deliveryLat,
      Value<double?> deliveryLng,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<String> itemsJson,
      Value<String?> routeGeometryJson,
      Value<int> rowid,
    });

class $$OrderRowsTableFilterComposer
    extends Composer<_$AppDatabase, $OrderRowsTable> {
  $$OrderRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deliveryForecast => $composableBuilder(
    column: $table.deliveryForecast,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerDocument => $composableBuilder(
    column: $table.customerDocument,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerEmail => $composableBuilder(
    column: $table.customerEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerPhone => $composableBuilder(
    column: $table.customerPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originAddress => $composableBuilder(
    column: $table.originAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get originLat => $composableBuilder(
    column: $table.originLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get originLng => $composableBuilder(
    column: $table.originLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deliveryAddress => $composableBuilder(
    column: $table.deliveryAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get deliveryLat => $composableBuilder(
    column: $table.deliveryLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get deliveryLng => $composableBuilder(
    column: $table.deliveryLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemsJson => $composableBuilder(
    column: $table.itemsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routeGeometryJson => $composableBuilder(
    column: $table.routeGeometryJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OrderRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderRowsTable> {
  $$OrderRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deliveryForecast => $composableBuilder(
    column: $table.deliveryForecast,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerDocument => $composableBuilder(
    column: $table.customerDocument,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerEmail => $composableBuilder(
    column: $table.customerEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerPhone => $composableBuilder(
    column: $table.customerPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originAddress => $composableBuilder(
    column: $table.originAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get originLat => $composableBuilder(
    column: $table.originLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get originLng => $composableBuilder(
    column: $table.originLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveryAddress => $composableBuilder(
    column: $table.deliveryAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get deliveryLat => $composableBuilder(
    column: $table.deliveryLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get deliveryLng => $composableBuilder(
    column: $table.deliveryLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemsJson => $composableBuilder(
    column: $table.itemsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routeGeometryJson => $composableBuilder(
    column: $table.routeGeometryJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OrderRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderRowsTable> {
  $$OrderRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deliveryForecast => $composableBuilder(
    column: $table.deliveryForecast,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerDocument => $composableBuilder(
    column: $table.customerDocument,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerEmail => $composableBuilder(
    column: $table.customerEmail,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerPhone => $composableBuilder(
    column: $table.customerPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originAddress => $composableBuilder(
    column: $table.originAddress,
    builder: (column) => column,
  );

  GeneratedColumn<double> get originLat =>
      $composableBuilder(column: $table.originLat, builder: (column) => column);

  GeneratedColumn<double> get originLng =>
      $composableBuilder(column: $table.originLng, builder: (column) => column);

  GeneratedColumn<String> get deliveryAddress => $composableBuilder(
    column: $table.deliveryAddress,
    builder: (column) => column,
  );

  GeneratedColumn<double> get deliveryLat => $composableBuilder(
    column: $table.deliveryLat,
    builder: (column) => column,
  );

  GeneratedColumn<double> get deliveryLng => $composableBuilder(
    column: $table.deliveryLng,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get itemsJson =>
      $composableBuilder(column: $table.itemsJson, builder: (column) => column);

  GeneratedColumn<String> get routeGeometryJson => $composableBuilder(
    column: $table.routeGeometryJson,
    builder: (column) => column,
  );
}

class $$OrderRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrderRowsTable,
          OrderRow,
          $$OrderRowsTableFilterComposer,
          $$OrderRowsTableOrderingComposer,
          $$OrderRowsTableAnnotationComposer,
          $$OrderRowsTableCreateCompanionBuilder,
          $$OrderRowsTableUpdateCompanionBuilder,
          (OrderRow, BaseReferences<_$AppDatabase, $OrderRowsTable, OrderRow>),
          OrderRow,
          PrefetchHooks Function()
        > {
  $$OrderRowsTableTableManager(_$AppDatabase db, $OrderRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> orderNumber = const Value.absent(),
                Value<DateTime> deliveryForecast = const Value.absent(),
                Value<String> customerName = const Value.absent(),
                Value<String> customerDocument = const Value.absent(),
                Value<String?> customerEmail = const Value.absent(),
                Value<String?> customerPhone = const Value.absent(),
                Value<String?> originAddress = const Value.absent(),
                Value<double?> originLat = const Value.absent(),
                Value<double?> originLng = const Value.absent(),
                Value<String> deliveryAddress = const Value.absent(),
                Value<double?> deliveryLat = const Value.absent(),
                Value<double?> deliveryLng = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> itemsJson = const Value.absent(),
                Value<String?> routeGeometryJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrderRowsCompanion(
                id: id,
                orderNumber: orderNumber,
                deliveryForecast: deliveryForecast,
                customerName: customerName,
                customerDocument: customerDocument,
                customerEmail: customerEmail,
                customerPhone: customerPhone,
                originAddress: originAddress,
                originLat: originLat,
                originLng: originLng,
                deliveryAddress: deliveryAddress,
                deliveryLat: deliveryLat,
                deliveryLng: deliveryLng,
                status: status,
                createdAt: createdAt,
                itemsJson: itemsJson,
                routeGeometryJson: routeGeometryJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String orderNumber,
                required DateTime deliveryForecast,
                required String customerName,
                required String customerDocument,
                Value<String?> customerEmail = const Value.absent(),
                Value<String?> customerPhone = const Value.absent(),
                Value<String?> originAddress = const Value.absent(),
                Value<double?> originLat = const Value.absent(),
                Value<double?> originLng = const Value.absent(),
                required String deliveryAddress,
                Value<double?> deliveryLat = const Value.absent(),
                Value<double?> deliveryLng = const Value.absent(),
                required String status,
                required DateTime createdAt,
                required String itemsJson,
                Value<String?> routeGeometryJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrderRowsCompanion.insert(
                id: id,
                orderNumber: orderNumber,
                deliveryForecast: deliveryForecast,
                customerName: customerName,
                customerDocument: customerDocument,
                customerEmail: customerEmail,
                customerPhone: customerPhone,
                originAddress: originAddress,
                originLat: originLat,
                originLng: originLng,
                deliveryAddress: deliveryAddress,
                deliveryLat: deliveryLat,
                deliveryLng: deliveryLng,
                status: status,
                createdAt: createdAt,
                itemsJson: itemsJson,
                routeGeometryJson: routeGeometryJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OrderRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrderRowsTable,
      OrderRow,
      $$OrderRowsTableFilterComposer,
      $$OrderRowsTableOrderingComposer,
      $$OrderRowsTableAnnotationComposer,
      $$OrderRowsTableCreateCompanionBuilder,
      $$OrderRowsTableUpdateCompanionBuilder,
      (OrderRow, BaseReferences<_$AppDatabase, $OrderRowsTable, OrderRow>),
      OrderRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OrderRowsTableTableManager get orderRows =>
      $$OrderRowsTableTableManager(_db, _db.orderRows);
}
