// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$eventsByDateHash() => r'120ef14b68acaa7d3aa30de5d565923aeb1c18cd';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [eventsByDate].
@ProviderFor(eventsByDate)
const eventsByDateProvider = EventsByDateFamily();

/// See also [eventsByDate].
class EventsByDateFamily extends Family<AsyncValue<List<EventModel>>> {
  /// See also [eventsByDate].
  const EventsByDateFamily();

  /// See also [eventsByDate].
  EventsByDateProvider call(
    DateTime date,
  ) {
    return EventsByDateProvider(
      date,
    );
  }

  @override
  EventsByDateProvider getProviderOverride(
    covariant EventsByDateProvider provider,
  ) {
    return call(
      provider.date,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'eventsByDateProvider';
}

/// See also [eventsByDate].
class EventsByDateProvider extends AutoDisposeFutureProvider<List<EventModel>> {
  /// See also [eventsByDate].
  EventsByDateProvider(
    DateTime date,
  ) : this._internal(
          (ref) => eventsByDate(
            ref as EventsByDateRef,
            date,
          ),
          from: eventsByDateProvider,
          name: r'eventsByDateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$eventsByDateHash,
          dependencies: EventsByDateFamily._dependencies,
          allTransitiveDependencies:
              EventsByDateFamily._allTransitiveDependencies,
          date: date,
        );

  EventsByDateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final DateTime date;

  @override
  Override overrideWith(
    FutureOr<List<EventModel>> Function(EventsByDateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EventsByDateProvider._internal(
        (ref) => create(ref as EventsByDateRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<EventModel>> createElement() {
    return _EventsByDateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EventsByDateProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EventsByDateRef on AutoDisposeFutureProviderRef<List<EventModel>> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _EventsByDateProviderElement
    extends AutoDisposeFutureProviderElement<List<EventModel>>
    with EventsByDateRef {
  _EventsByDateProviderElement(super.provider);

  @override
  DateTime get date => (origin as EventsByDateProvider).date;
}

String _$eventsByDateRangeHash() => r'3325df89f46a1e9fce65cc7f140e8c6f960f9344';

/// See also [eventsByDateRange].
@ProviderFor(eventsByDateRange)
const eventsByDateRangeProvider = EventsByDateRangeFamily();

/// See also [eventsByDateRange].
class EventsByDateRangeFamily extends Family<AsyncValue<List<EventModel>>> {
  /// See also [eventsByDateRange].
  const EventsByDateRangeFamily();

  /// See also [eventsByDateRange].
  EventsByDateRangeProvider call(
    DateTime start,
    DateTime end,
  ) {
    return EventsByDateRangeProvider(
      start,
      end,
    );
  }

  @override
  EventsByDateRangeProvider getProviderOverride(
    covariant EventsByDateRangeProvider provider,
  ) {
    return call(
      provider.start,
      provider.end,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'eventsByDateRangeProvider';
}

/// See also [eventsByDateRange].
class EventsByDateRangeProvider
    extends AutoDisposeFutureProvider<List<EventModel>> {
  /// See also [eventsByDateRange].
  EventsByDateRangeProvider(
    DateTime start,
    DateTime end,
  ) : this._internal(
          (ref) => eventsByDateRange(
            ref as EventsByDateRangeRef,
            start,
            end,
          ),
          from: eventsByDateRangeProvider,
          name: r'eventsByDateRangeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$eventsByDateRangeHash,
          dependencies: EventsByDateRangeFamily._dependencies,
          allTransitiveDependencies:
              EventsByDateRangeFamily._allTransitiveDependencies,
          start: start,
          end: end,
        );

  EventsByDateRangeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.start,
    required this.end,
  }) : super.internal();

  final DateTime start;
  final DateTime end;

  @override
  Override overrideWith(
    FutureOr<List<EventModel>> Function(EventsByDateRangeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EventsByDateRangeProvider._internal(
        (ref) => create(ref as EventsByDateRangeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        start: start,
        end: end,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<EventModel>> createElement() {
    return _EventsByDateRangeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EventsByDateRangeProvider &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, start.hashCode);
    hash = _SystemHash.combine(hash, end.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EventsByDateRangeRef on AutoDisposeFutureProviderRef<List<EventModel>> {
  /// The parameter `start` of this provider.
  DateTime get start;

  /// The parameter `end` of this provider.
  DateTime get end;
}

class _EventsByDateRangeProviderElement
    extends AutoDisposeFutureProviderElement<List<EventModel>>
    with EventsByDateRangeRef {
  _EventsByDateRangeProviderElement(super.provider);

  @override
  DateTime get start => (origin as EventsByDateRangeProvider).start;
  @override
  DateTime get end => (origin as EventsByDateRangeProvider).end;
}

String _$eventByIdHash() => r'b586308e7723490d266eb9f79073467f66bde38a';

/// See also [eventById].
@ProviderFor(eventById)
const eventByIdProvider = EventByIdFamily();

/// See also [eventById].
class EventByIdFamily extends Family<AsyncValue<EventModel?>> {
  /// See also [eventById].
  const EventByIdFamily();

  /// See also [eventById].
  EventByIdProvider call(
    String id,
  ) {
    return EventByIdProvider(
      id,
    );
  }

  @override
  EventByIdProvider getProviderOverride(
    covariant EventByIdProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'eventByIdProvider';
}

/// See also [eventById].
class EventByIdProvider extends AutoDisposeFutureProvider<EventModel?> {
  /// See also [eventById].
  EventByIdProvider(
    String id,
  ) : this._internal(
          (ref) => eventById(
            ref as EventByIdRef,
            id,
          ),
          from: eventByIdProvider,
          name: r'eventByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$eventByIdHash,
          dependencies: EventByIdFamily._dependencies,
          allTransitiveDependencies: EventByIdFamily._allTransitiveDependencies,
          id: id,
        );

  EventByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<EventModel?> Function(EventByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EventByIdProvider._internal(
        (ref) => create(ref as EventByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<EventModel?> createElement() {
    return _EventByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EventByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EventByIdRef on AutoDisposeFutureProviderRef<EventModel?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _EventByIdProviderElement
    extends AutoDisposeFutureProviderElement<EventModel?> with EventByIdRef {
  _EventByIdProviderElement(super.provider);

  @override
  String get id => (origin as EventByIdProvider).id;
}

String _$eventListHash() => r'f5d5faa944b02c78a30b4f9eb58a44f78c003487';

/// See also [EventList].
@ProviderFor(EventList)
final eventListProvider =
    AutoDisposeAsyncNotifierProvider<EventList, List<EventModel>>.internal(
  EventList.new,
  name: r'eventListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$eventListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EventList = AutoDisposeAsyncNotifier<List<EventModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
