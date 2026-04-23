import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.isEmailVerified,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return UserModel(
      id: id ?? json['id'] ?? '',
      email: json['user_email'] ?? json['email'] ?? '',
      name: json['user_name'] ?? json['name'] ?? '',
      isEmailVerified: json['isEmailVerified'] ?? false,
      createdAt: json['user_created_at'] != null 
          ? (json['user_created_at'] as Timestamp).toDate() 
          : null,
      updatedAt: json['user_updated_at'] != null 
          ? (json['user_updated_at'] as Timestamp).toDate() 
          : null,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return UserModel.fromJson(doc.data() ?? {}, id: doc.id);
  }

  Map<String, dynamic> toJson({bool isUpdate = false}) {
    final data = <String, dynamic>{
      'user_name': name,
      'user_email': email,
      'user_updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
    
    if (!isUpdate) {
      data['user_created_at'] = createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp();
    }
    
    return data;
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      isEmailVerified: entity.isEmailVerified,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
