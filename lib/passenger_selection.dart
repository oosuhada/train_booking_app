import 'package:flutter/material.dart';

class PassengerSelectionPage extends StatefulWidget {
  final int adultCount;
  final int childCount;
  final int seniorCount;

  PassengerSelectionPage({
    required this.adultCount,
    required this.childCount,
    required this.seniorCount,
  });

  @override
  _PassengerSelectionPageState createState() => _PassengerSelectionPageState();
}

class _PassengerSelectionPageState extends State<PassengerSelectionPage> {
  late int _adultCount;
  late int _childCount;
  late int _seniorCount;

  @override
  void initState() {
    super.initState();
    _adultCount = widget.adultCount;
    _childCount = widget.childCount;
    _seniorCount = widget.seniorCount;
  }

  Widget _buildCounterRow(
      String title, String subtitle, int count, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: count > 0 ? () => onChanged(count - 1) : null,
              ),
              Text('$count', style: TextStyle(fontSize: 18)),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => onChanged(count + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('인원 선택'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCounterRow(
              '어른',
              '만 13세 이상',
              _adultCount,
              (newCount) => setState(() => _adultCount = newCount),
            ),
            Divider(),
            _buildCounterRow(
              '어린이',
              '만 6세 ~ 만 12세',
              _childCount,
              (newCount) => setState(() => _childCount = newCount),
            ),
            Divider(),
            _buildCounterRow(
              '경로',
              '만 65세 이상',
              _seniorCount,
              (newCount) => setState(() => _seniorCount = newCount),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('취소'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'adult': _adultCount,
                      'child': _childCount,
                      'senior': _seniorCount,
                    });
                  },
                  child: Text('확인'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
