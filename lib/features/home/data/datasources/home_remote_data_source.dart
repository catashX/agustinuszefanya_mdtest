import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../auth/data/models/user_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<UserModel>> getUsers();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final FirebaseFirestore firestore;

  HomeRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      final querySnapshot = await firestore.collection('users').get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
