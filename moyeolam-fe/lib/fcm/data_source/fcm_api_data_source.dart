// fcm_api_service.dart
import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';

import '../../common/const/address_config.dart';
import 'package:youngjun/fcm/model/alert_service_model.dart'; // ApiArletModel 클래스를 정의한 파일을 import


part 'fcm_api_data_source.g.dart'; // api_service.g.dart 파일을 포함


@RestApi(baseUrl: BASE_URL)
abstract class FcmApiService {
  factory FcmApiService(Dio dio, {String baseUrl}) = _FcmApiService;

  @GET('/alerts')
  Future<ApiArletModel?> getPosts(
      @Header("Authorization") String token,
      );
}