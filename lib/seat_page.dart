import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../payment_page.dart';

class SeatPage extends StatefulWidget {
  final String departure;
  final String arrival;

  SeatPage(this.departure, this.arrival);

  @override
  _SeatPageState createState() => _SeatPageState();
}

class _SeatPageState extends State<SeatPage> {
  List<List<bool>> seats = List.generate(
      20, (_) => List.generate(4, (_) => false)); // 20개의 행, 4개의 열(A/B/C/D)

  int? selectedRow;
  int? selectedColumn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('좌석 선택')),
        body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // 출발역과 도착역을 표시하는 Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(widget.departure,
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple)),
                        ),
                      ),
                      Icon(Icons.arrow_circle_right_outlined, size: 30),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(widget.arrival,
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // 좌석 상태 레이블
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(width: 4),
                      Text('선택됨'),
                      SizedBox(width: 20),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(width: 4),
                      Text('선택 안됨'),
                    ],
                  ),
                  SizedBox(height: 20),

                  // ABCD 레이블
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['A', 'B', '', 'C', 'D'] // 가운데에 빈 문자열로 간격 추가
                        .map((label) =>
                            Text(label, style: TextStyle(fontSize: 18)))
                        .toList(),
                  ),

                  // 좌석 그리드
                  // 좌석 그리드 (A/B 열과 C/D 열 사이에 열 번호 추가)
                  Expanded(
                    child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: seats[0].length +
                                1), // 가운데 빈 칸과 열 번호 포함하여 열 수 증가
                        itemCount: seats.length *
                            (seats[0].length + 1), // 총 아이템 수 (빈 칸 및 열 번호 포함)
                        itemBuilder: (context, index) {
                          if (index % (seats[0].length + 1) == 2) {
                            // 열 번호 출력
                            int row = index ~/ (seats[0].length + 1) + 1;
                            return Center(
                                child: Container(
                                    width: 50,
                                    height: 50,
                                    child: Center(
                                        child: Text(row.toString(),
                                            style: TextStyle(fontSize: 18)))));
                          }
                          int row = index ~/ (seats[0].length + 1);
                          int col = index % (seats[0].length + 1) > 2
                              ? index % (seats[0].length + 1) - 1
                              : index % (seats[0].length + 1); // 빈 칸 이후 열 계산
                          return GestureDetector(
                              onTap: () {
                                setState(() {
                                  seats[row][col] = !seats[row][col];
                                  selectedRow = seats[row][col]
                                      ? row
                                      : null; // 선택 해제 시 null로 설정
                                  selectedColumn = seats[row][col]
                                      ? col
                                      : null; // 선택 해제 시 null로 설정
                                });
                              },
                              child: Container(
                                  margin: EdgeInsets.all(4),
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: seats[row][col]
                                          ? Colors.purple
                                          : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8))));
                        }),
                  ),

                  SizedBox(height: 20),

                  // 예매하기 버튼
                  ElevatedButton(
                    onPressed: selectedRow != null
                        ? () {
                            showCupertinoDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CupertinoAlertDialog(
                                  title: Text('예매 확인'),
                                  content: Text('좌석을 예매하시겠습니까?'),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: Text('취소'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    CupertinoDialogAction(
                                      child: Text('확인'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PaymentPage(
                                              departure: widget.departure,
                                              arrival: widget.arrival,
                                              seatNumber:
                                                  '${selectedRow! + 1}${String.fromCharCode(65 + selectedColumn!)}',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        : null,
                    child: Text(
                      '예매 하기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: Size(double.infinity, 50),
                    ),
                  )
                ])));
  }
}
