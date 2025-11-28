import 'package:dartz/dartz.dart';
import 'package:eshop/core/usecases/usecase.dart';

import '../../../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user/delivery_info.dart';
import '../../domain/repositories/delivery_info_repository.dart';
import '../data_sources/local/delivery_info_local_data_source.dart';
import '../data_sources/local/user_local_data_source.dart';
import '../data_sources/remote/delivery_info_remote_data_source.dart';
import '../models/user/delivery_info_model.dart';

class DeliveryInfoRepositoryImpl implements DeliveryInfoRepository {
  final DeliveryInfoRemoteDataSource remoteDataSource;
  final DeliveryInfoLocalDataSource localDataSource;
  final UserLocalDataSource userLocalDataSource;
  final NetworkInfo networkInfo;

  DeliveryInfoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.userLocalDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<DeliveryInfo>>> getRemoteDeliveryInfo() async {
    // No remote API for delivery info - just return local data
    print('📍 [DEBUG] No remote delivery info API - returning local data');
    return getLocalDeliveryInfo();
  }

  @override
  Future<Either<Failure, List<DeliveryInfo>>> getLocalDeliveryInfo() async {
    try {
      final result = await localDataSource.getDeliveryInfo();
      return Right(result);
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, DeliveryInfo>> addDeliveryInfo(params) async {
    try {
      print('📍 [DEBUG] Saving delivery info locally (no API endpoint)');
      // Save locally only - no API endpoint exists for delivery info
      final deliveryInfo = DeliveryInfoModel.fromEntity(params);
      await localDataSource.updateDeliveryInfo(deliveryInfo);
      print('✅ [DEBUG] Delivery info saved locally');
      return Right(deliveryInfo);
    } on Failure catch (failure) {
      print('❌ [DEBUG] Failed to save delivery info: $failure');
      return Left(failure);
    } catch (e, stackTrace) {
      print('❌ [DEBUG] Exception saving delivery info: $e');
      print('📋 [DEBUG] Stack trace: $stackTrace');
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, DeliveryInfo>> editDeliveryInfo(
      DeliveryInfoModel params) async {
    try {
      print('📍 [DEBUG] Updating delivery info locally');
      // Update locally only - no API endpoint exists for delivery info
      await localDataSource.updateDeliveryInfo(params);
      print('✅ [DEBUG] Delivery info updated locally');
      return Right(params);
    } on Failure catch (failure) {
      print('❌ [DEBUG] Failed to update delivery info: $failure');
      return Left(failure);
    } catch (e, stackTrace) {
      print('❌ [DEBUG] Exception updating delivery info: $e');
      print('📋 [DEBUG] Stack trace: $stackTrace');
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, DeliveryInfo>> selectDeliveryInfo(
      DeliveryInfo params) async {
    try {
      await localDataSource
          .updateSelectedDeliveryInfo(DeliveryInfoModel.fromEntity(params));
      return Right(params);
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, DeliveryInfo>> getSelectedDeliveryInfo() async {
    try {
      final result = await localDataSource.getSelectedDeliveryInfo();
      return Right(result);
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, NoParams>> deleteLocalDeliveryInfo() async {
    try {
      await localDataSource.clearDeliveryInfo();
      return Right(NoParams());
    } on Failure catch (failure) {
      return Left(failure);
    }
  }
}
