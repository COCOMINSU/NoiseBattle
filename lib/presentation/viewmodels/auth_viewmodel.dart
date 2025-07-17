import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/database_service.dart';
import '../../data/models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;
  final DatabaseService _databaseService = DatabaseService.instance;

  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;
  bool _isSignInSuccess = false;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isSignInSuccess => _isSignInSuccess;

  AuthViewModel() {
    _initializeAuthState();
  }

  void _initializeAuthState() {
    _user = _authService.currentUser;
    _loadUserData();

    _authService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserData();
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData() async {
    if (_user != null) {
      try {
        _userModel = await _databaseService.getUser(_user!.uid);
        notifyListeners();
      } catch (e) {
        debugPrint('사용자 데이터 로드 실패: $e');
      }
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();
      _isSignInSuccess = false;

      final user = await _authService.signInWithGoogle();
      _user = user;

      if (user != null) {
        await _loadUserData();

        // 로그인 성공 표시
        _isSignInSuccess = true;
        notifyListeners();

        // 1.5초 후 자동으로 홈으로 이동 (AuthWrapper에서 자동 처리됨)
        Timer(const Duration(milliseconds: 1500), () {
          // 이미 AuthWrapper에서 isAuthenticated 상태 변경으로 자동 처리됨
          notifyListeners();
        });
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.signOut();
      _user = null;
      _userModel = null;
      _isSignInSuccess = false;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUserProfile({
    String? nickname,
    String? phoneNumber,
    String? photoURL,
  }) async {
    if (_user == null) return;

    try {
      _setLoading(true);
      _clearError();

      // TODO: DatabaseService에 updateUserProfile 메소드 구현 필요
      // await _databaseService.updateUserProfile(
      //   uid: _user!.uid,
      //   nickname: nickname,
      //   phoneNumber: phoneNumber,
      //   photoURL: photoURL,
      // );

      await _loadUserData();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> requestApartmentVerification({
    required String apartmentName,
    required String address,
    required String documentUrl,
  }) async {
    if (_user == null) return;

    try {
      _setLoading(true);
      _clearError();

      // TODO: DatabaseService에 requestApartmentVerification 메소드 구현 필요
      // await _databaseService.requestApartmentVerification(
      //   uid: _user!.uid,
      //   apartmentName: apartmentName,
      //   address: address,
      //   documentUrl: documentUrl,
      // );

      await _loadUserData();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
