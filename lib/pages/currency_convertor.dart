import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safetravelfrontend/providers/user_provider.dart';

class CurrencyConverter extends StatefulWidget {
  @override
  _CurrencyConverterState createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'SGD';
  String? _convertedAmount;

  @override
  void initState() {
    super.initState();
    _loadCurrencyPreferences();
  }

  // Load saved currency preferences
  Future<void> _loadCurrencyPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _fromCurrency = prefs.getString('fromCurrency') ?? 'USD';
      _toCurrency = prefs.getString('toCurrency') ?? 'SGD';
    });
  }

  // Save currency preferences
  Future<void> _saveCurrencyPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fromCurrency', _fromCurrency);
    await prefs.setString('toCurrency', _toCurrency);
  }

  // Swap from and to currencies
  void _swapCurrencies() {
    setState(() {
      String temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _saveCurrencyPreferences();
    });
  }

  // Convert currency and update the UI
  void _convertCurrency() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    double amount = double.parse(_amountController.text);

    var response = await userProvider.convertCurrency(
      amount: amount,
      fromCurrency: _fromCurrency,
      toCurrency: _toCurrency,
    );

    setState(() {
      if (response.containsKey('error')) {
        _convertedAmount = 'Error: ${response['error']}';
      } else {
        _convertedAmount = response['convertedAmount'].toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  'Currency Converter',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  color: Colors.white,
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Amount Input and From Currency Dropdown
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Amount',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            DropdownButton<String>(
                              value: _fromCurrency,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _fromCurrency = newValue!;
                                  _saveCurrencyPreferences();
                                });
                              },
                              items: <String>[
                                'USD', 'SGD', 'EUR', 'GBP', 'JPY', 'AUD'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/${value.toLowerCase()}_flag.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                      SizedBox(width: 8),
                                      Text(value),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Convert Switch Icon
                        IconButton(
                          icon: Image.asset(
                            'assets/images/replace.png',
                            width: 40,
                            height: 40,
                          ),
                          onPressed: _swapCurrencies,
                        ),
                        SizedBox(height: 16),
                        // Converted Amount and To Currency Dropdown
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Converted Amount',
                                  border: OutlineInputBorder(),
                                  hintText: _convertedAmount ?? '0.00',
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            DropdownButton<String>(
                              value: _toCurrency,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _toCurrency = newValue!;
                                  _saveCurrencyPreferences();
                                });
                              },
                              items: <String>[
                                'USD', 'SGD', 'EUR', 'GBP', 'JPY', 'AUD'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/${value.toLowerCase()}_flag.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                      SizedBox(width: 8),
                                      Text(value),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _convertCurrency,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Image.asset(
                    'assets/images/convert.png',
                    height: 50,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _convertedAmount != null
                        ? 'Converted Amount: $_convertedAmount'
                        : 'Conversion not yet done',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
