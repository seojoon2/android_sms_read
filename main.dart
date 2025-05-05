import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SmsReader(),
    );
  }
}

class SmsReader extends StatefulWidget {
  @override
  _SmsReaderState createState() => _SmsReaderState();
}

class _SmsReaderState extends State<SmsReader> {
  final Telephony telephony = Telephony.instance;
  List<SmsMessage> inboxMessages = []; // 받은 SMS 리스트 저장
  SmsMessage? selectedSms; // 선택된 SMS 저장

  @override
  void initState() {
    super.initState();
    requestPermissions(); // 앱 실행 시 권한 요청
  }

  // 권한 요청 함수
  Future<void> requestPermissions() async {
    bool? permissionsGranted = await telephony.requestSmsPermissions;
    if (permissionsGranted == true) {
      getSms(); // 권한 승인되면 SMS 가져오기
    } else {
      print("SMS 읽기 권한이 거부되었습니다.");
    }
  }

  // SMS 읽기 함수
  Future<void> getSms() async {
    List<SmsMessage> messages = await telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY],
    );
    setState(() {
      inboxMessages = messages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SMS 읽기 앱")),
      body: Row(
        children: [
          // 왼쪽: 받은 SMS 리스트
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: inboxMessages.length,
              itemBuilder: (context, index) {
                SmsMessage sms = inboxMessages[index];
                return ListTile(
                  title: Text(sms.address ?? "Unknown"), // 발신자 주소
                  subtitle: Text(
                    sms.body != null
                        ? (sms.body!.length >= 20 ? sms.body!.substring(0, 20) : sms.body!)
                        : "",
                  ), // 메시지 일부 표시
                  onTap: () {
                    setState(() {
                      selectedSms = sms; // 클릭 시 선택된 SMS 업데이트
                    });
                  },
                );
              },
            ),
          ),
          // 오른쪽: 선택된 SMS 내용
          Expanded(
            flex: 2,
            child: selectedSms != null
                ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("From: ${selectedSms!.address}"),
                  SizedBox(height: 10),
                  Text("Body: ${selectedSms!.body}"),
                ],
              ),
            )
                : Center(child: Text("SMS를 선택하세요")),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getSms,
        child: Icon(Icons.refresh),
        tooltip: "SMS 읽기",
      ),
    );
  }
}
