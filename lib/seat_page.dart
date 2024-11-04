import 'package:flutter/material.dart';

class SeatPage extends StatefulWidget {
  final String departure;
  final String arrival;

  SeatPage(this.departure, this.arrival);

  @override
  _SeatPageState createState() => _SeatPageState();
}

class _SeatPageState extends State<SeatPage> {
  List<List<bool>> seats =
      List.generate(10, (_) => List.generate(4, (_) => false)); // 좌석 상태 저장 변수

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
                      ]),
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
                    children: ['A', 'B', 'C', 'D']
                        .map((label) =>
                            Text(label, style: TextStyle(fontSize: 18)))
                        .toList(),
                  ),

                  // 좌석 그리드
                  Expanded(
                      child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: seats[0].length),
                          itemCount:
                              seats.length * seats[0].length + seats.length,
                          itemBuilder: (context, index) {
                            if (index % 5 == 0) {
                              int row = index ~/ 5 + 1;
                              return Center(
                                  child: Container(
                                      width: 50,
                                      height: 50,
                                      child: Center(
                                          child: Text(row.toString(),
                                              style:
                                                  TextStyle(fontSize: 18)))));
                            }
                            int row = index ~/ 5;
                            int col = index % 5 - 1;
                            return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    seats[row][col] = !seats[row][col];
                                    selectedRow = row;
                                    selectedColumn = col;
                                  });
                                },
                                child: Container(
                                    margin: EdgeInsets.all(4),
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                        color: seats[row][col]
                                            ? Colors.purple
                                            : Colors.grey[300],
                                        borderRadius:
                                            BorderRadius.circular(8))));
                          })),

                  SizedBox(height: 20),

                  // 예매하기 버튼
                  ElevatedButton(
                      onPressed: selectedRow != null
                          ? () {
                              Navigator.pop(context);
                            }
                          : null,
                      child: Text('예매 하기',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          minimumSize: Size(double.infinity, 50)))
                ])));
  }
}
