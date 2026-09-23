// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'm_user.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMUserCollection on Isar {
  IsarCollection<MUser> get mUsers => this.collection();
}

const MUserSchema = CollectionSchema(
  name: r'MUser',
  id: 7096010947383041483,
  properties: {
    r'email': PropertySchema(id: 0, name: r'email', type: IsarType.string),
    r'encryptedMasterKey': PropertySchema(
      id: 1,
      name: r'encryptedMasterKey',
      type: IsarType.string,
    ),
    r'encryptedRecoveryMasterKey': PropertySchema(
      id: 2,
      name: r'encryptedRecoveryMasterKey',
      type: IsarType.string,
    ),
    r'fullName': PropertySchema(
      id: 3,
      name: r'fullName',
      type: IsarType.string,
    ),
    r'joined': PropertySchema(id: 4, name: r'joined', type: IsarType.string),
    r'loginMethod': PropertySchema(
      id: 5,
      name: r'loginMethod',
      type: IsarType.string,
    ),
    r'passwordHash': PropertySchema(
      id: 6,
      name: r'passwordHash',
      type: IsarType.string,
    ),
    r'recoveryKeyHash': PropertySchema(
      id: 7,
      name: r'recoveryKeyHash',
      type: IsarType.string,
    ),
    r'securityVersion': PropertySchema(
      id: 8,
      name: r'securityVersion',
      type: IsarType.long,
    ),
    r'uid': PropertySchema(id: 9, name: r'uid', type: IsarType.string),
  },

  estimateSize: _mUserEstimateSize,
  serialize: _mUserSerialize,
  deserialize: _mUserDeserialize,
  deserializeProp: _mUserDeserializeProp,
  idName: r'id',
  indexes: {
    r'uid': IndexSchema(
      id: 8193695471701937315,
      name: r'uid',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'uid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _mUserGetId,
  getLinks: _mUserGetLinks,
  attach: _mUserAttach,
  version: '3.3.2',
);

int _mUserEstimateSize(
  MUser object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.email.length * 3;
  {
    final value = object.encryptedMasterKey;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.encryptedRecoveryMasterKey;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.fullName.length * 3;
  bytesCount += 3 + object.joined.length * 3;
  bytesCount += 3 + object.loginMethod.length * 3;
  {
    final value = object.passwordHash;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.recoveryKeyHash;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.uid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _mUserSerialize(
  MUser object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.email);
  writer.writeString(offsets[1], object.encryptedMasterKey);
  writer.writeString(offsets[2], object.encryptedRecoveryMasterKey);
  writer.writeString(offsets[3], object.fullName);
  writer.writeString(offsets[4], object.joined);
  writer.writeString(offsets[5], object.loginMethod);
  writer.writeString(offsets[6], object.passwordHash);
  writer.writeString(offsets[7], object.recoveryKeyHash);
  writer.writeLong(offsets[8], object.securityVersion);
  writer.writeString(offsets[9], object.uid);
}

MUser _mUserDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MUser(
    email: reader.readString(offsets[0]),
    encryptedMasterKey: reader.readStringOrNull(offsets[1]),
    encryptedRecoveryMasterKey: reader.readStringOrNull(offsets[2]),
    fullName: reader.readString(offsets[3]),
    joined: reader.readString(offsets[4]),
    loginMethod: reader.readString(offsets[5]),
    passwordHash: reader.readStringOrNull(offsets[6]),
    recoveryKeyHash: reader.readStringOrNull(offsets[7]),
    securityVersion: reader.readLongOrNull(offsets[8]) ?? 1,
    uid: reader.readStringOrNull(offsets[9]),
  );
  object.id = id;
  return object;
}

P _mUserDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset) ?? 1) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _mUserGetId(MUser object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _mUserGetLinks(MUser object) {
  return [];
}

void _mUserAttach(IsarCollection<dynamic> col, Id id, MUser object) {
  object.id = id;
}

extension MUserByIndex on IsarCollection<MUser> {
  Future<MUser?> getByUid(String? uid) {
    return getByIndex(r'uid', [uid]);
  }

  MUser? getByUidSync(String? uid) {
    return getByIndexSync(r'uid', [uid]);
  }

  Future<bool> deleteByUid(String? uid) {
    return deleteByIndex(r'uid', [uid]);
  }

  bool deleteByUidSync(String? uid) {
    return deleteByIndexSync(r'uid', [uid]);
  }

  Future<List<MUser?>> getAllByUid(List<String?> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uid', values);
  }

  List<MUser?> getAllByUidSync(List<String?> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uid', values);
  }

  Future<int> deleteAllByUid(List<String?> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uid', values);
  }

  int deleteAllByUidSync(List<String?> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uid', values);
  }

  Future<Id> putByUid(MUser object) {
    return putByIndex(r'uid', object);
  }

  Id putByUidSync(MUser object, {bool saveLinks = true}) {
    return putByIndexSync(r'uid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUid(List<MUser> objects) {
    return putAllByIndex(r'uid', objects);
  }

  List<Id> putAllByUidSync(List<MUser> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'uid', objects, saveLinks: saveLinks);
  }
}

extension MUserQueryWhereSort on QueryBuilder<MUser, MUser, QWhere> {
  QueryBuilder<MUser, MUser, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MUserQueryWhere on QueryBuilder<MUser, MUser, QWhereClause> {
  QueryBuilder<MUser, MUser, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<MUser, MUser, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<MUser, MUser, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterWhereClause> uidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'uid', value: [null]),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterWhereClause> uidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'uid',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterWhereClause> uidEqualTo(String? uid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'uid', value: [uid]),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterWhereClause> uidNotEqualTo(String? uid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [],
                upper: [uid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [uid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [uid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [],
                upper: [uid],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension MUserQueryFilter on QueryBuilder<MUser, MUser, QFilterCondition> {
  QueryBuilder<MUser, MUser, QAfterFilterCondition> emailEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'email',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> emailGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'email',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> emailLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'email',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> emailBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'email',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> emailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'email',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> emailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'email',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> emailContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'email',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> emailMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'email',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> emailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'email', value: ''),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> emailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'email', value: ''),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> encryptedMasterKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'encryptedMasterKey'),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition>
  encryptedMasterKeyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'encryptedMasterKey'),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> encryptedMasterKeyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'encryptedMasterKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition>
  encryptedMasterKeyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'encryptedMasterKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> encryptedMasterKeyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'encryptedMasterKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> encryptedMasterKeyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'encryptedMasterKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition>
  encryptedMasterKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'encryptedMasterKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> encryptedMasterKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'encryptedMasterKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> encryptedMasterKeyContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'encryptedMasterKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> encryptedMasterKeyMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'encryptedMasterKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition>
  encryptedMasterKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'encryptedMasterKey', value: ''),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition>
  encryptedMasterKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'encryptedMasterKey', value: ''),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition>
  encryptedRecoveryMasterKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'encryptedRecoveryMasterKey'),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition>
  encryptedRecoveryMasterKeyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(
          property: r'encryptedRecoveryMasterKey',
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition>
  encryptedRecoveryMasterKeyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'encryptedRecoveryMasterKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition>
  encryptedRecoveryMasterKeyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'encryptedRecoveryMasterKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition>
  encryptedRecoveryMasterKeyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'encryptedRecoveryMasterKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition>
  encryptedRecoveryMasterKeyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'encryptedRecoveryMasterKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition>
  encryptedRecoveryMasterKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'encryptedRecoveryMasterKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition>
  encryptedRecoveryMasterKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'encryptedRecoveryMasterKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition>
  encryptedRecoveryMasterKeyContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'encryptedRecoveryMasterKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition>
  encryptedRecoveryMasterKeyMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'encryptedRecoveryMasterKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition>
  encryptedRecoveryMasterKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'encryptedRecoveryMasterKey',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition>
  encryptedRecoveryMasterKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'encryptedRecoveryMasterKey',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> fullNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fullName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> fullNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fullName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> fullNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fullName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> fullNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fullName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> fullNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'fullName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> fullNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'fullName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> fullNameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'fullName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> fullNameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'fullName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> fullNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fullName', value: ''),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> fullNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'fullName', value: ''),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> joinedEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'joined',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> joinedGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'joined',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> joinedLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'joined',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> joinedBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'joined',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> joinedStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'joined',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> joinedEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'joined',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> joinedContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'joined',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> joinedMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'joined',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> joinedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'joined', value: ''),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> joinedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'joined', value: ''),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> loginMethodEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'loginMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> loginMethodGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'loginMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> loginMethodLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'loginMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> loginMethodBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'loginMethod',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> loginMethodStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'loginMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> loginMethodEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'loginMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> loginMethodContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'loginMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> loginMethodMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'loginMethod',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> loginMethodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'loginMethod', value: ''),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> loginMethodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'loginMethod', value: ''),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> passwordHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'passwordHash'),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> passwordHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'passwordHash'),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> passwordHashEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'passwordHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> passwordHashGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'passwordHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> passwordHashLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'passwordHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> passwordHashBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'passwordHash',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> passwordHashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'passwordHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> passwordHashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'passwordHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> passwordHashContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'passwordHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> passwordHashMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'passwordHash',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> passwordHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'passwordHash', value: ''),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> passwordHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'passwordHash', value: ''),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> recoveryKeyHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'recoveryKeyHash'),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> recoveryKeyHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'recoveryKeyHash'),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> recoveryKeyHashEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'recoveryKeyHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> recoveryKeyHashGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'recoveryKeyHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> recoveryKeyHashLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'recoveryKeyHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> recoveryKeyHashBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'recoveryKeyHash',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> recoveryKeyHashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'recoveryKeyHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> recoveryKeyHashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'recoveryKeyHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> recoveryKeyHashContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'recoveryKeyHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> recoveryKeyHashMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'recoveryKeyHash',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> recoveryKeyHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'recoveryKeyHash', value: ''),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition>
  recoveryKeyHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'recoveryKeyHash', value: ''),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> securityVersionEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'securityVersion', value: value),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> securityVersionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'securityVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> securityVersionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'securityVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> securityVersionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'securityVersion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> uidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'uid'),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> uidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'uid'),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> uidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> uidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> uidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> uidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'uid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> uidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> uidContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> uidMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'uid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uid', value: ''),
      );
    });
  }

  QueryBuilder<MUser, MUser, QAfterFilterCondition> uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uid', value: ''),
      );
    });
  }
}

extension MUserQueryObject on QueryBuilder<MUser, MUser, QFilterCondition> {}

extension MUserQueryLinks on QueryBuilder<MUser, MUser, QFilterCondition> {}

extension MUserQuerySortBy on QueryBuilder<MUser, MUser, QSortBy> {
  QueryBuilder<MUser, MUser, QAfterSortBy> sortByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> sortByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> sortByEncryptedMasterKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedMasterKey', Sort.asc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> sortByEncryptedMasterKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedMasterKey', Sort.desc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> sortByEncryptedRecoveryMasterKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedRecoveryMasterKey', Sort.asc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy>
  sortByEncryptedRecoveryMasterKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedRecoveryMasterKey', Sort.desc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> sortByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> sortByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> sortByJoined() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'joined', Sort.asc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> sortByJoinedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'joined', Sort.desc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> sortByLoginMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginMethod', Sort.asc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> sortByLoginMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginMethod', Sort.desc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> sortByPasswordHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passwordHash', Sort.asc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> sortByPasswordHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passwordHash', Sort.desc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> sortByRecoveryKeyHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recoveryKeyHash', Sort.asc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> sortByRecoveryKeyHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recoveryKeyHash', Sort.desc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> sortBySecurityVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'securityVersion', Sort.asc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> sortBySecurityVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'securityVersion', Sort.desc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }
}

extension MUserQuerySortThenBy on QueryBuilder<MUser, MUser, QSortThenBy> {
  QueryBuilder<MUser, MUser, QAfterSortBy> thenByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> thenByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> thenByEncryptedMasterKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedMasterKey', Sort.asc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> thenByEncryptedMasterKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedMasterKey', Sort.desc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> thenByEncryptedRecoveryMasterKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedRecoveryMasterKey', Sort.asc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy>
  thenByEncryptedRecoveryMasterKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedRecoveryMasterKey', Sort.desc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> thenByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> thenByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> thenByJoined() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'joined', Sort.asc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> thenByJoinedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'joined', Sort.desc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> thenByLoginMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginMethod', Sort.asc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> thenByLoginMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginMethod', Sort.desc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> thenByPasswordHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passwordHash', Sort.asc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> thenByPasswordHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passwordHash', Sort.desc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> thenByRecoveryKeyHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recoveryKeyHash', Sort.asc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> thenByRecoveryKeyHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recoveryKeyHash', Sort.desc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> thenBySecurityVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'securityVersion', Sort.asc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> thenBySecurityVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'securityVersion', Sort.desc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<MUser, MUser, QAfterSortBy> thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }
}

extension MUserQueryWhereDistinct on QueryBuilder<MUser, MUser, QDistinct> {
  QueryBuilder<MUser, MUser, QDistinct> distinctByEmail({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'email', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MUser, MUser, QDistinct> distinctByEncryptedMasterKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'encryptedMasterKey',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<MUser, MUser, QDistinct> distinctByEncryptedRecoveryMasterKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'encryptedRecoveryMasterKey',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<MUser, MUser, QDistinct> distinctByFullName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fullName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MUser, MUser, QDistinct> distinctByJoined({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'joined', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MUser, MUser, QDistinct> distinctByLoginMethod({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loginMethod', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MUser, MUser, QDistinct> distinctByPasswordHash({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'passwordHash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MUser, MUser, QDistinct> distinctByRecoveryKeyHash({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'recoveryKeyHash',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<MUser, MUser, QDistinct> distinctBySecurityVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'securityVersion');
    });
  }

  QueryBuilder<MUser, MUser, QDistinct> distinctByUid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }
}

extension MUserQueryProperty on QueryBuilder<MUser, MUser, QQueryProperty> {
  QueryBuilder<MUser, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MUser, String, QQueryOperations> emailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'email');
    });
  }

  QueryBuilder<MUser, String?, QQueryOperations> encryptedMasterKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'encryptedMasterKey');
    });
  }

  QueryBuilder<MUser, String?, QQueryOperations>
  encryptedRecoveryMasterKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'encryptedRecoveryMasterKey');
    });
  }

  QueryBuilder<MUser, String, QQueryOperations> fullNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fullName');
    });
  }

  QueryBuilder<MUser, String, QQueryOperations> joinedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'joined');
    });
  }

  QueryBuilder<MUser, String, QQueryOperations> loginMethodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loginMethod');
    });
  }

  QueryBuilder<MUser, String?, QQueryOperations> passwordHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'passwordHash');
    });
  }

  QueryBuilder<MUser, String?, QQueryOperations> recoveryKeyHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recoveryKeyHash');
    });
  }

  QueryBuilder<MUser, int, QQueryOperations> securityVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'securityVersion');
    });
  }

  QueryBuilder<MUser, String?, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }
}
