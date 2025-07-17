import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF2F2F7), // 라이트 테마 배경
              Color(0xFFFFFFFF), // 흰색
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 로고 컨테이너 (소음지옥 테마 색상 적용)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF8B0000), // 소음지옥 테마 primary
                          Color(0xFF660000), // 소음지옥 테마 primaryDark
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B0000).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.volume_off,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 앱 제목 (소음지옥 테마 색상 적용)
                  const Text(
                    '소음과 전쟁',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B0000), // 소음지옥 테마 primary
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 부제목 (소음지옥 테마 색상으로 포인트)
                  const Text(
                    '우리 아파트 소음 신고 서비스',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF660000), // 소음지옥 테마 primaryDark
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // 성공 메시지 또는 웰컴 메시지
                  Consumer<AuthViewModel>(
                    builder: (context, authViewModel, child) {
                      if (authViewModel.isSignInSuccess) {
                        return Column(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 48,
                              color: Color(0xFF34C759), // 성공 색상
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '로그인 성공!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF34C759),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '잠시 후 홈 화면으로 이동합니다',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF3C3C43),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            const Text(
                              '환영합니다!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF000000), // 라이트 테마 textPrimary
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '구글 계정으로 간편하게 시작하세요\n처음 이용하시면 자동으로 회원가입됩니다',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(
                                  0xFF3C3C43,
                                ), // 라이트 테마 textSecondary
                                height: 1.4,
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 40),

                  // 구글 로그인 버튼 (라이트 테마 스타일)
                  Consumer<AuthViewModel>(
                    builder: (context, authViewModel, child) {
                      return Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFFFFFFF,
                          ), // 라이트 테마 surfacePrimary
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF007AFF), // 라이트 테마 primary
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF007AFF).withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed:
                              authViewModel.isLoading ||
                                  authViewModel.isSignInSuccess
                              ? null
                              : () async {
                                  await authViewModel.signInWithGoogle();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFFFF),
                            foregroundColor: const Color(
                              0xFF007AFF,
                            ), // 라이트 테마 primary
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: authViewModel.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF007AFF),
                                    ),
                                  ),
                                )
                              : authViewModel.isSignInSuccess
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check,
                                      color: Color(0xFF34C759),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      '로그인 완료',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF34C759),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/google_logo.png',
                                      width: 20,
                                      height: 20,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.login,
                                              color: Color(0xFF007AFF),
                                              size: 20,
                                            );
                                          },
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Google로 시작하기',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // 추가 정보 (라이트 테마 스타일)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7), // 라이트 테마 surfaceSecondary
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.security,
                              color: Color(0xFF8E8E93), // 라이트 테마 textTertiary
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '안전한 구글 로그인',
                              style: TextStyle(
                                color: Color(0xFF8E8E93), // 라이트 테마 textTertiary
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_add,
                              color: Color(0xFF8E8E93), // 라이트 테마 textTertiary
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '처음 이용 시 자동 회원가입',
                              style: TextStyle(
                                color: Color(0xFF8E8E93), // 라이트 테마 textTertiary
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 에러 메시지 (라이트 테마 스타일)
                  Consumer<AuthViewModel>(
                    builder: (context, authViewModel, child) {
                      if (authViewModel.error != null &&
                          authViewModel.error!.isNotEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFF3B30,
                            ).withOpacity(0.1), // 라이트 테마 error
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFF3B30).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Color(0xFFFF3B30), // 라이트 테마 error
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  authViewModel.error!,
                                  style: const TextStyle(
                                    color: Color(0xFFFF3B30), // 라이트 테마 error
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Color(0xFFFF3B30), // 라이트 테마 error
                                  size: 20,
                                ),
                                onPressed: () {
                                  authViewModel.clearError();
                                },
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 24),

                  // 서비스 약관 (라이트 테마 스타일)
                  const Text(
                    '계속 진행하면 서비스 약관과 개인정보 처리방침에 동의하게 됩니다',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFC7C7CC), // 라이트 테마 textQuaternary
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
