import 'package:flutter/material.dart';
import 'station_list.dart';
import 'seat_page.dart';
import 'passenger_selection.dart';
import 'train_schedule.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? departureStation;
  String? arrivalStation;
  bool isRoundTrip = false;
  int adultCount = 1;
  int childCount = 0;
  int seniorCount = 0;
  DateTime? departureDate;
  DateTime? returnDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('K Rail')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('승차권 예매',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                _buildDateSelector(),
                SizedBox(height: 20),
                _buildStationSelector(),
                SizedBox(height: 20),
                _buildPassengerAndTripTypeSelector(),
                SizedBox(height: 20),
                _buildBookButton(),
                SizedBox(height: 25),
                Text('더보기',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 15),
                _buildLogoContainer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('날짜 선택',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildDateButton('가는 날', departureDate, (picked) {
                setState(() => departureDate = picked);
              }),
            ),
            if (isRoundTrip) ...[
              SizedBox(width: 10),
              Expanded(
                child: _buildDateButton('오는 날', returnDate, (picked) {
                  setState(() => returnDate = picked);
                }),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDateButton(
      String label, DateTime? date, Function(DateTime?) onPicked) {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 365)),
        );
        if (picked != null && picked != date) {
          onPicked(picked);
        }
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          date == null ? label : DateFormat('yyyy-MM-dd').format(date),
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildStationSelector() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: IconButton(
                icon: Icon(Icons.swap_horiz),
                onPressed: () {
                  setState(() {
                    final temp = departureStation;
                    departureStation = arrivalStation;
                    arrivalStation = temp;
                  });
                },
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildStationButton(
                    '출발역', departureStation, arrivalStation),
              ),
              Container(
                width: 2,
                height: 50,
                color: Colors.grey[400],
              ),
              Expanded(
                child: _buildStationButton(
                    '도착역', arrivalStation, departureStation),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStationButton(
      String label, String? station, String? otherStation) {
    return GestureDetector(
      onTap: () async {
        final selectedStation = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                StationListPage(selectedStation: otherStation),
          ),
        );
        if (selectedStation != null) {
          setState(() {
            if (label == '출발역') {
              departureStation = selectedStation;
            } else {
              arrivalStation = selectedStation;
            }
          });
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 10),
          Text(
            station ?? '선택',
            style: TextStyle(fontSize: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerAndTripTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PassengerSelectionPage(
                  adultCount: adultCount,
                  childCount: childCount,
                  seniorCount: seniorCount,
                ),
              ),
            );
            if (result != null) {
              setState(() {
                adultCount = result['adult'];
                childCount = result['child'];
                seniorCount = result['senior'];
              });
            }
          },
          child: Text(
            '인원 선택: 어른 $adultCount명${childCount > 0 ? ', 어린이 $childCount명' : ''}${seniorCount > 0 ? ', 경로 $seniorCount명' : ''}',
            style: TextStyle(fontSize: 16),
          ),
        ),
        Row(
          children: [
            Text('편도'),
            Switch(
              value: isRoundTrip,
              onChanged: (value) {
                setState(() {
                  isRoundTrip = value;
                  if (!isRoundTrip) {
                    returnDate = null;
                  }
                });
              },
            ),
            Text('왕복'),
          ],
        ),
      ],
    );
  }

  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (departureStation != null &&
                arrivalStation != null &&
                departureDate != null &&
                (!isRoundTrip || (isRoundTrip && returnDate != null)))
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrainSchedulePage(
                      departureStation: departureStation!,
                      arrivalStation: arrivalStation!,
                      departureDate: departureDate!,
                      returnDate: isRoundTrip ? returnDate : null,
                      adultCount: adultCount,
                      childCount: childCount,
                      seniorCount: seniorCount,
                      isRoundTrip: isRoundTrip,
                    ),
                  ),
                );
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Text(
            '예매하기',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoContainer() {
    return Container(
      height: 200,
      color: Colors.grey[300],
      child: Center(
        child: Image.asset(
          'asset/KRAIL_LOGO.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
