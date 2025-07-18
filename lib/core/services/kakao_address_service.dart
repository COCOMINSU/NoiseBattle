import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// 카카오 지도 API를 사용하여 지번주소를 가져오는 서비스
class KakaoAddressService {
  // 카카오 REST API 키 (실제 사용시에는 환경변수나 설정 파일에서 관리)
  static const String _apiKey =
      '8e29f01d3a99dc660789e19d8a7b65da'; // 실제 API 키로 교체 필요

  /// 좌표를 지번주소로 변환
  ///
  /// [latitude]: 위도
  /// [longitude]: 경도
  /// Returns: 지번주소 문자열
  static Future<String?> getJibunAddress(
    double latitude,
    double longitude,
  ) async {
    try {
      // 카카오 좌표-주소 변환 API 호출
      final url = Uri.parse(
        'https://dapi.kakao.com/v2/local/geo/coord2address.json?x=$longitude&y=$latitude&input_coord=WGS84',
      );

      if (kDebugMode) {
        print('🗺️ 카카오 API 호출 URL: $url');
        print('🗺️ 카카오 API 키: $_apiKey');
      }

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'KakaoAK $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (kDebugMode) {
          print('🗺️ 카카오 API 응답 상태: ${response.statusCode}');
          print('🗺️ 카카오 API 응답 헤더: ${response.headers}');
          print('🗺️ 카카오 API 응답 본문: $data');
        }

        if (data['documents'] != null && data['documents'].isNotEmpty) {
          final document = data['documents'][0];
          final address = document['address'];

          if (address != null) {
            // 지번주소 구성: 시/도 + 시/군/구 + 읍/면/동
            final addressParts = <String>[];

            // 1. 시/도
            if (address['region_1depth_name'] != null) {
              addressParts.add(address['region_1depth_name']);
            }

            // 2. 시/군/구
            if (address['region_2depth_name'] != null) {
              addressParts.add(address['region_2depth_name']);
            }

            // 3. 읍/면/동
            if (address['region_3depth_name'] != null) {
              addressParts.add(address['region_3depth_name']);
            }

            final jibunAddress = addressParts.join(' ');

            if (kDebugMode) {
              print('🏠 카카오 지번주소: $jibunAddress');
              print('📍 상세 정보:');
              print('  - 시/도: ${address['region_1depth_name']}');
              print('  - 시/군/구: ${address['region_2depth_name']}');
              print('  - 읍/면/동: ${address['region_3depth_name']}');
              print('  - 도로명: ${address['road_name']}');
              print('  - 건물번호: ${address['main_building_no']}');
            }

            return jibunAddress;
          }
        }
      } else {
        if (kDebugMode) {
          print('❌ 카카오 API 호출 실패: ${response.statusCode}');
          print('응답: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 카카오 주소 변환 실패: $e');
      }
    }

    return null;
  }

  /// API 키가 설정되어 있는지 확인
  static bool get isApiKeyConfigured {
    final configured =
        _apiKey != 'YOUR_KAKAO_REST_API_KEY' && _apiKey.isNotEmpty;
    if (kDebugMode) {
      print('🗺️ 카카오 API 키 설정 상태: $configured');
      print('🗺️ 카카오 API 키 값: $_apiKey');
      print('🗺️ 카카오 API 키 길이: ${_apiKey.length}');
      print('🗺️ 카카오 API 키가 기본값인가: ${_apiKey == 'YOUR_KAKAO_REST_API_KEY'}');
    }
    return configured;
  }
}
