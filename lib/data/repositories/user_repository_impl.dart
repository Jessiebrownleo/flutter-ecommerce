import 'package:dartz/dartz.dart';
import 'package:eshop/core/usecases/usecase.dart';

import '../../../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../data_sources/local/user_local_data_source.dart';
import '../data_sources/remote/user_remote_data_source.dart';
import '../models/user/authentication_response_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> signIn(params) async {
    print('🔐 [DEBUG] UserRepository.signIn called with email: ${params.username}');
    if (!await networkInfo.isConnected) {
      print('🔐 [DEBUG] No network connection');
      return Left(NetworkFailure());
    }
    try {
      final remoteResponse = await remoteDataSource.signIn(params);
      try {
        await localDataSource.saveToken(remoteResponse.token);
        await localDataSource.saveUser(remoteResponse.user);
        print('🔐 [DEBUG] Token and user saved locally');
      } catch (e, stack) {
        print('🔐 [DEBUG] Error saving token/user locally: $e');
        print('🔐 [DEBUG] Stack: $stack');
      }
      return Right(remoteResponse.user);
    } on Failure catch (failure) {
      print('🔐 [DEBUG] SignIn Failure: $failure');
      return Left(failure);
    } catch (e, stack) {
      print('🔐 [DEBUG] SignIn Exception: $e');
      print('🔐 [DEBUG] Stack: $stack');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, User>> signUp(params) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    try {
      final remoteResponse = await remoteDataSource.signUp(params);
      try {
        await localDataSource.saveToken(remoteResponse.token);
        await localDataSource.saveUser(remoteResponse.user);
      } catch (e, stack) {
        print('📝 [DEBUG] Error saving token/user locally: $e');
        print('📝 [DEBUG] Stack: $stack');
      }
      return Right(remoteResponse.user);
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, NoParams>> signOut() async {
    try {
      await localDataSource.clearCache();
      return Right(NoParams());
    } on CacheFailure {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getLocalUser() async {
    try {
      final user = await localDataSource.getUser();
      return Right(user);
    } on CacheFailure {
      return Left(CacheFailure());
    }
  }
}
