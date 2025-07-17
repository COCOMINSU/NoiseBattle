import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../viewmodels/noise_map_viewmodel.dart';
import '../../viewmodels/noise_ranking_viewmodel.dart';
import '../settings/theme_settings_page.dart';

import '../noise/noise_recording_page.dart';
import '../noise/noise_map_page.dart';
import '../noise/noise_ranking_page.dart';
import '../community/community_main_page.dart';
import '../../../shared/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('소음과 전쟁'),
        actions: [
          Consumer<ThemeViewModel>(
            builder: (context, themeViewModel, child) {
              return IconButton(
                icon: Icon(
                  themeIcons[themeViewModel.currentTheme] ?? Icons.palette,
                ),
                onPressed: themeViewModel.toggleTheme,
                tooltip: '테마 전환: ${themeViewModel.currentThemeName}',
              );
            },
          ),
          Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: authViewModel.signOut,
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            // 소음녹음 탭 클릭 시 NoiseRecordingPage로 이동
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NoiseRecordingPage(),
              ),
            );
          } else {
            setState(() => _currentIndex = index);
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(
            icon: Icon(Icons.fiber_manual_record),
            label: '소음측정',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: '소음지도'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: '커뮤니티'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeScreen();
      case 1:
        return const Center(child: Text('소음녹음 화면'));
      case 2:
        return ChangeNotifierProvider(
          create: (_) => NoiseMapViewModel(),
          child: const NoiseMapPage(),
        );
      case 3:
        return const CommunityMainPage();
      case 4:
        return _buildProfileScreen();
      default:
        return _buildHomeScreen();
    }
  }

  Widget _buildHomeScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          const Text(
            '소음과 전쟁',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '아파트 소음 신고 및 관리 플랫폼',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),

          // 주요 기능 바로가기
          Text(
            '주요 기능',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // 기능 카드들
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildFeatureCard(
                  context,
                  '소음 측정',
                  '실시간 소음 측정하기',
                  Icons.mic,
                  Colors.blue,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NoiseRecordingPage(),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  '소음 지도',
                  '지역별 소음 현황 보기',
                  Icons.map,
                  Colors.green,
                  () => setState(() => _currentIndex = 2),
                ),
                _buildFeatureCard(
                  context,
                  '소음 랭킹',
                  '지역별 소음 순위 보기',
                  Icons.leaderboard,
                  Colors.orange,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (_) => NoiseRankingViewModel(),
                          child: const NoiseRankingPage(),
                        ),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  '커뮤니티',
                  '소음 관련 소통하기',
                  Icons.forum,
                  Colors.purple,
                  () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileScreen() {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 사용자 정보 카드
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            authViewModel.userModel?.photoURL != null
                            ? NetworkImage(authViewModel.userModel!.photoURL!)
                            : null,
                        child: authViewModel.userModel?.photoURL == null
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        authViewModel.userModel?.displayName ?? '사용자',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        authViewModel.userModel?.email ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 설정 메뉴
              Expanded(
                child: ListView(
                  children: [
                    Consumer<ThemeViewModel>(
                      builder: (context, themeViewModel, child) {
                        return ListTile(
                          leading: Icon(
                            themeIcons[themeViewModel.currentTheme] ??
                                Icons.palette,
                          ),
                          title: const Text('테마 설정'),
                          subtitle: Text(
                            '현재: ${themeViewModel.currentThemeName}',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ThemeSettingsPage(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.apartment),
                      title: const Text('아파트 인증'),
                      subtitle: const Text('아파트 인증을 진행하세요'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // TODO: 아파트 인증 페이지로 이동
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('아파트 인증 기능은 곧 추가됩니다!')),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('설정'),
                      subtitle: const Text('앱 설정을 관리하세요'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // TODO: 설정 페이지로 이동
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('설정 기능은 곧 추가됩니다!')),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        '로그아웃',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('로그아웃'),
                            content: const Text('정말 로그아웃하시겠습니까?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('취소'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  authViewModel.signOut();
                                },
                                child: const Text('확인'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
