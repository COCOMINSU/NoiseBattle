import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// 파일명 및 설정 입력 다이얼로그
///
/// 사용자가 녹음 파일에 대한 이름, 제목, 공개설정, 아파트인증을 설정할 수 있는 다이얼로그
class FileNameInputDialog extends StatefulWidget {
  final String initialFileName;
  final Position? currentLocation;

  const FileNameInputDialog({
    super.key,
    this.initialFileName = '',
    this.currentLocation,
  });

  @override
  State<FileNameInputDialog> createState() => _FileNameInputDialogState();
}

class _FileNameInputDialogState extends State<FileNameInputDialog> {
  late TextEditingController _fileNameController;
  late TextEditingController _titleController;
  String? _errorText;
  bool _isPublic = false;
  bool _isApartmentVerified = false;

  @override
  void initState() {
    super.initState();
    _fileNameController = TextEditingController(text: widget.initialFileName);
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final fileName = _fileNameController.text.trim();

    if (fileName.isEmpty) {
      setState(() {
        _errorText = '파일명을 입력해주세요';
      });
      return;
    }

    if (fileName.length < 2) {
      setState(() {
        _errorText = '파일명은 2글자 이상이어야 합니다';
      });
      return;
    }

    // 특수문자 검증 (Windows/Android 파일명 제한)
    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    if (invalidChars.hasMatch(fileName)) {
      setState(() {
        _errorText = '파일명에 특수문자(<>:"/\\|?*)는 사용할 수 없습니다';
      });
      return;
    }

    // 결과 반환
    final result = {
      'fileName': fileName,
      'title': _titleController.text.trim().isEmpty
          ? null
          : _titleController.text.trim(),
      'isPublic': _isPublic,
      'isApartmentVerified': _isApartmentVerified,
    };

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.save, size: 24),
          SizedBox(width: 8),
          Text('녹음 저장'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '녹음 파일을 저장하기 위한 정보를 입력해주세요.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),

            // 파일명 입력
            TextField(
              controller: _fileNameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: '파일명 *',
                hintText:
                    '예: 우리집_소음측정_${DateTime.now().month}월${DateTime.now().day}일',
                prefixIcon: const Icon(Icons.audio_file),
                border: const OutlineInputBorder(),
                errorText: _errorText,
              ),
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() {
                    _errorText = null;
                  });
                }
              },
              onSubmitted: (_) => _validateAndSubmit(),
            ),

            const SizedBox(height: 16),

            // 내용 입력 (선택사항)
            TextField(
              controller: _titleController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '내용 (선택사항)',
                hintText: '예: 아파트 위층에서 들려오는 소음, 시간이나 상황, 소음에 대한 설명을 간략히 적어주세요',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // 공개 설정
            Card(
              child: SwitchListTile(
                title: const Text('공개 설정'),
                subtitle: Text(_isPublic ? '다른 사용자도 볼 수 있습니다' : '나만 볼 수 있습니다'),
                value: _isPublic,
                onChanged: (value) {
                  setState(() {
                    _isPublic = value;
                  });
                },
                secondary: Icon(_isPublic ? Icons.public : Icons.lock),
              ),
            ),

            const SizedBox(height: 8),

            // 아파트 인증
            Card(
              child: CheckboxListTile(
                title: const Text('아파트 인증'),
                subtitle: const Text('아파트 주소와 GPS 위치 일치 확인'),
                value: _isApartmentVerified,
                onChanged: (value) {
                  setState(() {
                    _isApartmentVerified = value ?? false;
                  });
                },
                secondary: const Icon(Icons.apartment),
              ),
            ),

            if (_isApartmentVerified) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, size: 16, color: Colors.orange),
                        SizedBox(width: 4),
                        Text(
                          '아파트 인증 안내',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '아파트 인증을 선택하시면 현재 GPS 위치와 아파트 주소가 일치하는지 확인합니다. 일치하지 않으면 저장되지 않습니다.',
                      style: TextStyle(fontSize: 11, color: Colors.orange),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates,
                        size: 16,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '팁',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• 날짜와 시간을 포함하면 구분하기 쉬워요\n• 장소나 상황을 명시하면 나중에 찾기 편해요\n• 내용에는 소음 상황이나 시간대 등을 자세히 적어주세요\n• 한글, 영문, 숫자, 언더바(_), 하이픈(-)만 사용하세요',
                    style: TextStyle(fontSize: 11, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(onPressed: _validateAndSubmit, child: const Text('저장')),
      ],
    );
  }
}
