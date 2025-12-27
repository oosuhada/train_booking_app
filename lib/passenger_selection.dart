import 'package:flutter/material.dart';
import 'app_localizations.dart';
import 'v2/v2_glass.dart';

class PassengerSelectionPage extends StatefulWidget {
  final int adultCount;
  final int childCount;
  final int seniorCount;

  const PassengerSelectionPage({
    super.key,
    required this.adultCount,
    required this.childCount,
    required this.seniorCount,
  });

  @override
  State<PassengerSelectionPage> createState() => _PassengerSelectionPageState();
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
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context).translate(title),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text(AppLocalizations.of(context).translate(subtitle),
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: count > 0 ? () => onChanged(count - 1) : null,
              ),
              Text('$count', style: const TextStyle(fontSize: 18)),
              IconButton(
                icon: const Icon(Icons.add),
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
      body: Column(
        children: [
          AppGlassToolbar(
            title: AppLocalizations.of(context).translate('인원 선택'),
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildCounterRow(
                    '어른',
                    '만 13세 이상',
                    _adultCount,
                    (newCount) => setState(() => _adultCount = newCount),
                  ),
                  const Divider(height: 32),
                  _buildCounterRow(
                    '어린이',
                    '만 6세 ~ 만 12세',
                    _childCount,
                    (newCount) => setState(() => _childCount = newCount),
                  ),
                  const Divider(height: 32),
                  _buildCounterRow(
                    '경로',
                    '만 65세 이상',
                    _seniorCount,
                    (newCount) => setState(() => _seniorCount = newCount),
                  ),
                  const Spacer(),
                  AppGlassBottomBar(
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                  AppLocalizations.of(context).translate('취소')),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              Navigator.pop(context, {
                                'adult': _adultCount,
                                'child': _childCount,
                                'senior': _seniorCount,
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                  AppLocalizations.of(context).translate('확인')),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
