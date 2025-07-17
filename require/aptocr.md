# 모듈 2: AI 서류 인증 모듈 개발 계획

이 모듈은 사용자가 올린 관리비 고지서 등의 서류 이미지에서 텍스트를 자동으로 인식(OCR)하여, 아파트 주소를 확인하고 인증 처리를 수행하는 기능입니다.

## 1. 기술 원리 (AI는 어떻게 글자를 읽을까?)
1.  **이미지 업로드:** 사용자가 앱에서 서류 사진을 찍거나 갤러리에서 선택합니다.
2.  **클라우드 스토리지 저장:** 이 이미지는 **Firebase Cloud Storage**와 같은 안전한 클라우드 공간에 임시로 업로드됩니다.
3.  **OCR API 호출:** 앱의 백엔드(**Firebase Cloud Functions**)에서 업로드된 이미지 파일을 **Google Cloud Vision AI**나 **Naver CLOVA OCR** 같은 외부 AI 서비스로 보냅니다.
4.  **텍스트 추출:** AI 서비스는 이미지 속의 글자들을 분석하여 텍스트 데이터로 변환하고, 그 결과를 JSON 형태로 백엔드에 돌려줍니다.
5.  **정보 파싱 및 검증:** 백엔드는 AI가 보내준 텍스트 뭉치 속에서 'OO아파트', '101동', '101호'와 같이 미리 정의된 패턴이나 키워드를 찾아냅니다.
6.  **인증 처리:** 파싱한 주소 정보가 사용자가 입력한 정보와 일치하는지 비교하고, 일치하면 사용자의 DB 정보를 '인증 완료' 상태로 업데이트합니다.
7.  **임시 파일 삭제:** **가장 중요!** 인증이 끝나면 개인정보 보호를 위해 Cloud Storage에 올렸던 서류 이미지를 즉시 삭제합니다.

## 2. 구현 알고리즘 (어떤 순서로 만들까?)
1.  **(앱)** 사용자가 주소를 입력하고, 증빙 서류 이미지를 Firebase Cloud Storage에 업로드합니다.
2.  **(앱 -> 백엔드)** '인증 요청' 버튼을 누르면, 백엔드의 Cloud Function을 호출하며 사용자 ID, 입력 주소, 이미지 파일 주소를 전달합니다.
3.  **(백엔드)** Cloud Function이 실행되어, 이미지 주소를 Google Cloud Vision AI API로 보내 텍스트 추출을 요청합니다.
4.  **(백엔드)** Vision AI로부터 받은 텍스트에서 정규표현식 등으로 주소를 추출하고, 사용자가 입력한 주소와 비교합니다.
5.  **(백엔드)** 일치하면 Firestore DB에서 해당 사용자의 `isVerified` 필드를 `true`로 업데이트합니다.
6.  **(백엔드)** Cloud Storage의 이미지 파일을 삭제합니다.
7.  **(백엔드 -> 앱)** 처리 결과를 앱으로 반환하여 사용자에게 "인증이 완료되었습니다" 또는 "실패했습니다" 메시지를 보여줍니다.

## 3. 추천 서비스 및 핵심 코드 예시 (Firebase Cloud Functions - Node.js)
- **외부 서비스:** **Google Cloud Vision AI** (Firebase와 연동이 쉬움)
- **백엔드 환경:** **Firebase Cloud Functions** (Node.js 기반)

- **핵심 코드 예시 (`functions/index.js`):**
    ```javascript
    const functions = require("firebase-functions");
    const admin = require("firebase-admin");
    const vision = require("@google-cloud/vision");

    admin.initializeApp();
    const visionClient = new vision.ImageAnnotatorClient();

    exports.verifyApartmentDocument = functions.region("asia-northeast3") // 서울 리전
      .https.onCall(async (data, context) => {
        const userId = context.auth.uid;
        const userInputAddress = data.address;
        const imagePath = data.imagePath;

        if (!userId) {
          throw new functions.https.HttpsError("unauthenticated", "로그인이 필요합니다.");
        }

        try {
          const [result] = await visionClient.textDetection(`gs://${process.env.GCLOUD_STORAGE_BUCKET}/${imagePath}`);
          const fullText = result.fullTextAnnotation.text;

          if (fullText.includes(userInputAddress)) {
            await admin.firestore().collection("users").doc(userId).update({
              isVerified: true,
              verifiedAddress: userInputAddress,
            });
            await admin.storage().bucket().file(imagePath).delete();
            return { success: true, message: "아파트 인증이 완료되었습니다." };
          } else {
            await admin.storage().bucket().file(imagePath).delete();
            return { success: false, message: "서류에서 주소 정보를 찾을 수 없습니다." };
          }
        } catch (error) {
          console.error("Verification Error:", error);
          throw new functions.https.HttpsError("internal", "인증 처리 중 오류가 발생했습니다.");
        }
      });
    ```
## 4. 주의사항 및 팁
- **보안 및 개인정보:** 사용자 서류는 민감 정보이므로, 반드시 암호화하여 전송하고, 인증 완료 즉시 삭제해야 합니다. 관련 법규(개인정보보호법)를 반드시 준수해야 합니다.
- **정확도:** OCR의 정확도는 100%가 아니므로, 실패 시 "사진을 다시 선명하게 찍어주세요" 같은 안내와 함께 **'관리자 수동 검토 요청'** 기능을 두는 것이 좋습니다.
- **비용:** Cloud Vision AI 같은 서비스는 사용량에 따라 비용이 발생합니다. 대부분 넉넉한 무료 사용량을 제공하지만, 사용자가 많아지면 비용을 고려해야 합니다.