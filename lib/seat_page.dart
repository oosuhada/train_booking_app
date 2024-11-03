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
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(widget.departure,
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple)),
                        Icon(Icons.arrow_circle_right_outlined, size: 30),
                        Text(widget.arrival,
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple))
                      ]),
                  SizedBox(height: 20),
                  Expanded(
                      child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4),
                          itemCount: seats.length * seats[0].length,
                          itemBuilder: (context, index) {
                            int row = index ~/ 4;
                            int col = index % 4;
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
                                  width: 50,
                                  height: 50,
                                  color: seats[row][col]
                                      ? Colors.purple
                                      : Colors.grey[300],
                                ));
                          })),
                  SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: selectedRow != null
                          ? () {
                              Navigator.pop(context);
                            }
                          : null,
                      child: Text('예매 하기'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple))
                ])));
  }
}
