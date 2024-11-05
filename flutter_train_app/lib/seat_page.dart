import 'package:flutter/material.dart';
import 'payment_page.dart';

class SeatPage extends StatefulWidget {
  final String departure;
  final String arrival;
  final int passengerCount;
  final bool isRoundTrip;

  SeatPage({
    required this.departure,
    required this.arrival,
    required this.passengerCount,
    required this.isRoundTrip,
  });

  @override
  _SeatPageState createState() => _SeatPageState();
}

class _SeatPageState extends State<SeatPage> {
  List<List<bool>> seats =
      List.generate(20, (_) => List.generate(4, (_) => false));
  List<String> selectedSeats = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('좌석 선택')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['A', 'B', '', 'C', 'D']
                  .map((label) => Text(label, style: TextStyle(fontSize: 18)))
                  .toList(),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: seats[0].length + 1),
                itemCount: seats.length * (seats[0].length + 1),
                itemBuilder: (context, index) {
                  if (index % (seats[0].length + 1) == 2) {
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
                      : index % (seats[0].length + 1);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (seats[row][col]) {
                          seats[row][col] = false;
                          selectedSeats.remove(
                              '${row + 1}${String.fromCharCode(65 + col)}');
                        } else if (selectedSeats.length <
                            widget.passengerCount) {
                          seats[row][col] = true;
                          selectedSeats.add(
                              '${row + 1}${String.fromCharCode(65 + col)}');
                        }
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
                            borderRadius: BorderRadius.circular(8))),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('선택한 좌석: ${selectedSeats.join(", ")}'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedSeats.length == widget.passengerCount
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentPage(
                            departure: widget.departure,
                            arrival: widget.arrival,
                            seatNumbers: selectedSeats,
                            isRoundTrip: widget.isRoundTrip,
                          ),
                        ),
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
            ),
          ],
        ),
      ),
    );
  }
}
