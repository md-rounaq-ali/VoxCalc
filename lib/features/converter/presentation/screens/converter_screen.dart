import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../../calculator/presentation/providers/calc_provider.dart';
import '../../../calculator/presentation/widgets/custom_scaffold.dart';

/// Elite physical unit & simulated live currency converter portal.
class ConverterScreen extends StatefulWidget {
  const ConverterScreen({Key? key}) : super(key: key);

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Length converter parameters
  final TextEditingController _unitInput = TextEditingController(text: "1");
  String _lengthFrom = "m";
  String _lengthTo = "km";
  String _unitResult = "";

  // Currency parameters
  final TextEditingController _currencyInput = TextEditingController(text: "100");
  String _currencyFrom = "USD";
  String _currencyTo = "EUR";
  String _currencyResult = "";

  // Live Exchange Rate State Variables
  Map<String, double> _liveRates = {};
  bool _isLoadingRates = false;
  String _ratesStatus = "Offline Backup Rates";

  static const Map<String, String> currencyNames = {
    'AED': 'United Arab Emirates Dirham',
    'AFN': 'Afghanistan Afghani',
    'ALL': 'Albania Lek',
    'AMD': 'Armenia Dram',
    'ANG': 'Netherlands Antilles Guilder',
    'AOA': 'Angola Kwanza',
    'ARS': 'Argentina Peso',
    'AUD': 'Australia Dollar',
    'AWG': 'Aruba Guilder',
    'AZN': 'Azerbaijan Manat',
    'BAM': 'Bosnia & Herzegovina Convertible Mark',
    'BBD': 'Barbados Dollar',
    'BDT': 'Bangladesh Taka',
    'BGN': 'Bulgaria Lev',
    'BHD': 'Bahrain Dinar',
    'BIF': 'Burundi Franc',
    'BMD': 'Bermuda Dollar',
    'BND': 'Brunei Darussalam Dollar',
    'BOB': 'Bolivia Boliviano',
    'BRL': 'Brazil Real',
    'BSD': 'Bahamas Dollar',
    'BTN': 'Bhutan Ngultrum',
    'BWP': 'Botswana Pula',
    'BYN': 'Belarus Ruble',
    'BZD': 'Belize Dollar',
    'CAD': 'Canada Dollar',
    'CDF': 'Congo Democratic Republic Franc',
    'CHF': 'Switzerland Franc',
    'CLP': 'Chile Peso',
    'CNY': 'China Yuan Renminbi',
    'COP': 'Colombia Peso',
    'CRC': 'Costa Rica Colon',
    'CUP': 'Cuba Peso',
    'CVE': 'Cape Verde Escudo',
    'CZK': 'Czech Republic Koruna',
    'DJF': 'Djibouti Franc',
    'DKK': 'Denmark Krone',
    'DOP': 'Dominican Republic Peso',
    'DZD': 'Algeria Dinar',
    'EGP': 'Egypt Pound',
    'ERN': 'Eritrea Nakfa',
    'ETB': 'Ethiopia Birr',
    'EUR': 'Eurozone Euro',
    'FJD': 'Fiji Dollar',
    'FKP': 'Falkland Islands Pound',
    'GBP': 'United Kingdom Pound Sterling',
    'GEL': 'Georgia Lari',
    'GHS': 'Ghana Cedi',
    'GIP': 'Gibraltar Pound',
    'GMD': 'Gambia Dalasi',
    'GNF': 'Guinea Franc',
    'GTQ': 'Guatemala Quetzal',
    'GYD': 'Guyana Dollar',
    'HKD': 'Hong Kong Dollar',
    'HNL': 'Honduras Lempira',
    'HRK': 'Croatia Kuna',
    'HTG': 'Haiti Gourde',
    'HUF': 'Hungary Forint',
    'IDR': 'Indonesia Rupiah',
    'ILS': 'Israel Shekel',
    'INR': 'India Rupee',
    'IQD': 'Iraq Dinar',
    'IRR': 'Iran Rial',
    'ISK': 'Iceland Krona',
    'JMD': 'Jamaica Dollar',
    'JOD': 'Jordan Dinar',
    'JPY': 'Japan Yen',
    'KES': 'Kenya Shilling',
    'KGS': 'Kyrgyzstan Som',
    'KHR': 'Cambodia Riel',
    'KMF': 'Comoros Franc',
    'KPW': 'Korea North Won',
    'KRW': 'Korea South Won',
    'KWD': 'Kuwait Dinar',
    'KYD': 'Cayman Islands Dollar',
    'KZT': 'Kazakhstan Tenge',
    'LAK': 'Laos Kip',
    'LBP': 'Lebanon Pound',
    'LKR': 'Sri Lanka Rupee',
    'LRD': 'Liberia Dollar',
    'LSL': 'Lesotho Loti',
    'LYD': 'Libya Dinar',
    'MAD': 'Morocco Dirham',
    'MDL': 'Moldova Leu',
    'MGA': 'Madagascar Ariary',
    'MKD': 'Macedonia Denar',
    'MMK': 'Myanmar Kyat',
    'MNT': 'Mongolia Tughrik',
    'MOP': 'Macau Pataca',
    'MRU': 'Mauritania Ouguiya',
    'MUR': 'Mauritius Rupee',
    'MVR': 'Maldives Rufiyaa',
    'MWK': 'Malawi Kwacha',
    'MXN': 'Mexico Peso',
    'MYR': 'Malaysia Ringgit',
    'MZN': 'Mozambique Metical',
    'NAD': 'Namibia Dollar',
    'NGN': 'Nigeria Naira',
    'NIO': 'Nicaragua Cordoba',
    'NOK': 'Norway Krone',
    'NPR': 'Nepal Rupee',
    'NZD': 'New Zealand Dollar',
    'OMR': 'Oman Rial',
    'PAB': 'Panama Balboa',
    'PEN': 'Peru Sol',
    'PGK': 'Papua New Guinea Kina',
    'PHP': 'Philippines Peso',
    'PKR': 'Pakistan Rupee',
    'PLN': 'Poland Zloty',
    'PYG': 'Paraguay Guarani',
    'QAR': 'Qatar Riyal',
    'RON': 'Romania Leu',
    'RSD': 'Serbia Dinar',
    'RUB': 'Russia Ruble',
    'RWF': 'Rwanda Franc',
    'SAR': 'Saudi Arabia Riyal',
    'SBD': 'Solomon Islands Dollar',
    'SCR': 'Seychelles Rupee',
    'SDG': 'Sudan Pound',
    'SEK': 'Sweden Krona',
    'SGD': 'Singapore Dollar',
    'SHP': 'St. Helena Pound',
    'SLL': 'Sierra Leone Leone',
    'SOS': 'Somalia Shilling',
    'SRD': 'Suriname Dollar',
    'SSP': 'South Sudan Pound',
    'STN': 'Sao Tome & Principe Dobra',
    'SVC': 'El Salvador Colon',
    'SYP': 'Syria Pound',
    'SZL': 'Eswatini Lilangeni',
    'THB': 'Thailand Baht',
    'TJS': 'Tajikistan Somoni',
    'TMT': 'Turkmenistan Manat',
    'TND': 'Tunisia Dinar',
    'TOP': 'Tonga Pa\'anga',
    'TRY': 'Turkey Lira',
    'TTD': 'Trinidad & Tobago Dollar',
    'TWD': 'Taiwan New Dollar',
    'TZS': 'Tanzania Shilling',
    'UAH': 'Ukraine Hryvnia',
    'UGX': 'Uganda Shilling',
    'USD': 'United States Dollar',
    'UYU': 'Uruguay Peso',
    'UZS': 'Uzbekistan Som',
    'VES': 'Venezuela Bolivar',
    'VND': 'Vietnam Dong',
    'VUV': 'Vanuatu Vatu',
    'WST': 'Samoa Tala',
    'XAF': 'Central African CFA Franc BEAC',
    'XCD': 'East Caribbean Dollar',
    'XOF': 'West African CFA Franc BCEAO',
    'XPF': 'CFP Franc',
    'YER': 'Yemen Rial',
    'ZAR': 'South Africa Rand',
    'ZMW': 'Zambia Kwacha',
    'ZWL': 'Zimbabwe Dollar',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _convertUnits();
    _convertCurrency();
    _fetchLiveRates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchLiveRates() async {
    if (_isLoadingRates) return;
    setState(() {
      _isLoadingRates = true;
      _ratesStatus = "Syncing live rates...";
    });
    try {
      final response = await http.get(Uri.parse('https://open.er-api.com/v6/latest/USD')).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] == 'success' && data['rates'] != null) {
          final Map<String, dynamic> rawRates = data['rates'];
          final Map<String, double> parsedRates = {};
          rawRates.forEach((key, value) {
            if (value is num) {
              parsedRates[key] = value.toDouble();
            }
          });
          setState(() {
            _liveRates = parsedRates;
            _isLoadingRates = false;
            _ratesStatus = "Live rates updated";
          });
          _convertCurrency();
          return;
        }
      }
    } catch (e) {
      debugPrint("Error fetching live rates: $e");
    }
    setState(() {
      _isLoadingRates = false;
      _ratesStatus = "Offline Backup (Tap to retry)";
    });
  }

  // ==========================================
  // Unit conversion logic (Length meters conversion standard)
  // ==========================================
  void _convertUnits() {
    final double? val = double.tryParse(_unitInput.text);
    if (val == null) {
      setState(() => _unitResult = "Error: Invalid number input");
      return;
    }

    // Convert everything to meters first
    double metersVal = 0.0;
    switch (_lengthFrom) {
      case 'm':
        metersVal = val;
        break;
      case 'km':
        metersVal = val * 1000;
        break;
      case 'cm':
        metersVal = val / 100;
        break;
      case 'mile':
        metersVal = val * 1609.34;
        break;
    }

    // Convert meters to output unit
    double finalVal = 0.0;
    switch (_lengthTo) {
      case 'm':
        finalVal = metersVal;
        break;
      case 'km':
        finalVal = metersVal / 1000;
        break;
      case 'cm':
        finalVal = metersVal * 100;
        break;
      case 'mile':
        finalVal = metersVal / 1609.34;
        break;
    }

    setState(() {
      _unitResult = "${val.toString()} $_lengthFrom = ${finalVal.toStringAsFixed(4)} $_lengthTo";
    });
  }

  // ==========================================
  // Currency converter logic (Offline fallback exchange rates)
  // ==========================================
  void _convertCurrency() {
    final double? val = double.tryParse(_currencyInput.text);
    if (val == null) {
      setState(() => _currencyResult = "Error: Invalid number input");
      return;
    }

    // Static standard values maps (simulates API results offline)
    final Map<String, double> usdRates = {
      'AED': 3.67, 'AFN': 70.80, 'ALL': 92.50, 'AMD': 388.00, 'ANG': 1.79,
      'AOA': 850.00, 'ARS': 890.00, 'AUD': 1.50, 'AWG': 1.79, 'AZN': 1.70,
      'BAM': 1.80, 'BBD': 2.00, 'BDT': 117.00, 'BGN': 1.80, 'BHD': 0.38,
      'BIF': 2870.00, 'BMD': 1.00, 'BND': 1.35, 'BOB': 6.91, 'BRL': 5.15,
      'BSD': 1.00, 'BTN': 83.50, 'BWP': 13.60, 'BYN': 3.27, 'BZD': 2.00,
      'CAD': 1.36, 'CDF': 2780.00, 'CHF': 0.91, 'CLP': 920.00, 'CNY': 7.24,
      'COP': 3820.00, 'CRC': 515.00, 'CUP': 24.00, 'CVE': 101.40, 'CZK': 22.80,
      'DJF': 177.70, 'DKK': 6.86, 'DOP': 58.20, 'DZD': 134.50, 'EGP': 47.10,
      'ERN': 15.00, 'ETB': 57.30, 'EUR': 0.92, 'FJD': 2.24, 'FKP': 0.79,
      'GBP': 0.79, 'GEL': 2.72, 'GHS': 14.50, 'GIP': 0.79, 'GMD': 67.80,
      'GNF': 8600.00, 'GTQ': 7.76, 'GYD': 209.00, 'HKD': 7.81, 'HNL': 24.70,
      'HRK': 7.00, 'HTG': 132.00, 'HUF': 355.00, 'IDR': 15980.00, 'ILS': 3.72,
      'INR': 83.50, 'IQD': 1310.00, 'IRR': 42000.00, 'ISK': 138.00, 'JMD': 155.00,
      'JOD': 0.71, 'JPY': 156.45, 'KES': 131.00, 'KGS': 88.50, 'KHR': 4080.00,
      'KMF': 452.00, 'KPW': 900.00, 'KRW': 1362.40, 'KWD': 0.31, 'KYD': 0.83,
      'KZT': 442.00, 'LAK': 21400.00, 'LBP': 89500.00, 'LKR': 299.50, 'LRD': 194.00,
      'LSL': 18.25, 'LYD': 4.83, 'MAD': 10.02, 'MDL': 17.70, 'MGA': 4400.00,
      'MKD': 56.50, 'MMK': 2100.00, 'MNT': 3450.00, 'MOP': 8.05, 'MRU': 39.60,
      'MUR': 46.20, 'MVR': 15.40, 'MWK': 1730.00, 'MXN': 16.68, 'MYR': 4.69,
      'MZN': 63.90, 'NAD': 18.25, 'NGN': 1450.00, 'NIO': 36.80, 'NOK': 10.70,
      'NPR': 133.60, 'NZD': 1.63, 'OMR': 0.38, 'PAB': 1.00, 'PEN': 3.72,
      'PGK': 3.87, 'PHP': 57.85, 'PKR': 278.20, 'PLN': 3.93, 'PYG': 7450.00,
      'QAR': 3.64, 'RON': 4.58, 'RSD': 108.00, 'RUB': 90.85, 'RWF': 1300.00,
      'SAR': 3.75, 'SBD': 8.50, 'SCR': 13.50, 'SDG': 601.00, 'SEK': 10.74,
      'SGD': 1.35, 'SHP': 0.79, 'SLL': 22000.00, 'SOS': 571.00, 'SRD': 34.20,
      'SSP': 1000.00, 'STN': 22.50, 'SVC': 8.75, 'SYP': 13000.00, 'SZL': 18.25,
      'THB': 36.35, 'TJS': 10.90, 'TMT': 3.50, 'TND': 3.12, 'TOP': 2.35,
      'TRY': 32.22, 'TTD': 6.76, 'TWD': 32.30, 'TZS': 2590.00, 'UAH': 39.80,
      'UGX': 3780.00, 'USD': 1.0, 'UYU': 38.50, 'UZS': 12600.00, 'VES': 36.50,
      'VND': 25425.00, 'VUV': 118.00, 'WST': 2.70, 'XAF': 603.00, 'XCD': 2.70,
      'XOF': 603.00, 'XPF': 110.00, 'YER': 250.00, 'ZAR': 18.25, 'ZMW': 25.20,
      'ZWL': 361.90
    };

    final activeRates = _liveRates.isNotEmpty ? _liveRates : usdRates;

    final double usdVal = val / (activeRates[_currencyFrom] ?? 1.0);
    final double converted = usdVal * (activeRates[_currencyTo] ?? 1.0);

    setState(() {
      _currencyResult = "${val.toString()} $_currencyFrom = ${converted.toStringAsFixed(2)} $_currencyTo\n"
          "(Rate: 1 $_currencyFrom = ${(converted / val).toStringAsFixed(4)} $_currencyTo)";
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalcProvider>(context);
    final mode = provider.themeMode;
    final accent = AppTheme.getAccentColor(mode);

    return CustomScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: accent),
          onPressed: () {
            HapticHelper.triggerLightImpact();
            Navigator.pop(context);
          },
        ),
        title: Text(
          "CONVERTER MODULES",
          style: AppTextStyles.headerStyle(mode, fontSize: 16, glow: true),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accent,
          labelColor: accent,
          unselectedLabelColor: AppTheme.getTextColor(mode).withOpacity(0.5),
          tabs: const [
            Tab(text: "Length Units"),
            Tab(text: "Live Currency"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLengthTab(mode, accent),
          _buildCurrencyTab(mode, accent),
        ],
      ),
    );
  }

  Widget _buildLengthTab(ThemeMode mode, Color accent) {
    final list = ["m", "km", "cm", "mile"];
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Input value
            _buildInputField("Value to convert", _unitInput, mode, onChanged: (_) => _convertUnits()),
            const SizedBox(height: 16),

            // Dropdowns selections
            Row(
              children: [
                Expanded(child: _buildDropdown("From Unit", _lengthFrom, list, mode, (val) => setState(() {
                  _lengthFrom = val!;
                  _convertUnits();
                }))),
                const SizedBox(width: 16),
                Icon(Icons.swap_horiz_rounded, color: accent),
                const SizedBox(width: 16),
                Expanded(child: _buildDropdown("To Unit", _lengthTo, list, mode, (val) => setState(() {
                  _lengthTo = val!;
                  _convertUnits();
                }))),
              ],
            ),
            const SizedBox(height: 32),

            // Conversion result screen box (Glass container)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.getKeyColor(mode, isOperator: true).withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.fromBorderSide(AppTheme.getBorderSide(mode)),
              ),
              child: Text(
                _unitResult,
                style: AppTextStyles.displayStyle(mode, fontSize: 20, glow: true),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyTab(ThemeMode mode, Color accent) {
    final list = [
      "AED", "AFN", "ALL", "AMD", "ANG", "AOA", "ARS", "AUD", "AWG", "AZN",
      "BAM", "BBD", "BDT", "BGN", "BHD", "BIF", "BMD", "BND", "BOB", "BRL",
      "BSD", "BTN", "BWP", "BYN", "BZD", "CAD", "CDF", "CHF", "CLP", "CNY",
      "COP", "CRC", "CUP", "CVE", "CZK", "DJF", "DKK", "DOP", "DZD", "EGP",
      "ERN", "ETB", "EUR", "FJD", "FKP", "GBP", "GEL", "GHS", "GIP", "GMD",
      "GNF", "GTQ", "GYD", "HKD", "HNL", "HRK", "HTG", "HUF", "IDR", "ILS",
      "INR", "IQD", "IRR", "ISK", "JMD", "JOD", "JPY", "KES", "KGS", "KHR",
      "KMF", "KPW", "KRW", "KWD", "KYD", "KZT", "LAK", "LBP", "LKR", "LRD",
      "LSL", "LYD", "MAD", "MDL", "MGA", "MKD", "MMK", "MNT", "MOP", "MRU",
      "MUR", "MVR", "MWK", "MXN", "MYR", "MZN", "NAD", "NGN", "NIO", "NOK",
      "NPR", "NZD", "OMR", "PAB", "PEN", "PGK", "PHP", "PKR", "PLN", "PYG",
      "QAR", "RON", "RSD", "RUB", "RWF", "SAR", "SBD", "SCR", "SDG", "SEK",
      "SGD", "SHP", "SLL", "SOS", "SRD", "SSP", "STN", "SVC", "SYP", "SZL",
      "THB", "TJS", "TMT", "TND", "TOP", "TRY", "TTD", "TWD", "TZS", "UAH",
      "UGX", "USD", "UYU", "UZS", "VES", "VND", "VUV", "WST", "XAF", "XCD",
      "XOF", "XPF", "YER", "ZAR", "ZMW", "ZWL"
    ];
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Input value
            _buildInputField("Amount to convert", _currencyInput, mode, onChanged: (_) => _convertCurrency()),
            const SizedBox(height: 16),

            // Tactile search-enabled selectors
            Row(
              children: [
                Expanded(
                  child: _buildCurrencySelectorButton(
                    "From Currency",
                    _currencyFrom,
                    list,
                    mode,
                    accent,
                    (val) => setState(() {
                      _currencyFrom = val;
                      _convertCurrency();
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.compare_arrows_rounded, color: accent),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCurrencySelectorButton(
                    "To Currency",
                    _currencyTo,
                    list,
                    mode,
                    accent,
                    (val) => setState(() {
                      _currencyTo = val;
                      _convertCurrency();
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Conversion result screen box (Glass container)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.getKeyColor(mode, isOperator: true).withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.fromBorderSide(AppTheme.getBorderSide(mode)),
              ),
              child: Text(
                _currencyResult,
                style: AppTextStyles.displayStyle(mode, fontSize: 18, glow: true),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _liveRates.isNotEmpty ? Colors.greenAccent : Colors.orangeAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_liveRates.isNotEmpty ? Colors.greenAccent : Colors.orangeAccent).withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _ratesStatus,
                  style: AppTextStyles.bodyStyle(mode, fontSize: 10, customColor: AppTheme.getTextColor(mode).withOpacity(0.4)),
                ),
                if (_isLoadingRates) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(accent),
                    ),
                  ),
                ] else if (_liveRates.isEmpty) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _fetchLiveRates,
                    child: Icon(Icons.refresh_rounded, size: 12, color: accent),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController ctrl, ThemeMode mode, {required ValueChanged<String> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.getKeyColor(mode, isOperator: true).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getAccentColor(mode).withOpacity(0.1), width: 1.2),
      ),
      child: TextField(
        controller: ctrl,
        onChanged: onChanged,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: AppTextStyles.bodyStyle(mode, fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppTheme.getTextColor(mode).withOpacity(0.4)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ThemeMode mode, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.getKeyColor(mode, isOperator: true).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getAccentColor(mode).withOpacity(0.1), width: 1.2),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((unit) => DropdownMenuItem(value: unit, child: Text(unit.toUpperCase()))).toList(),
        onChanged: (val) {
          HapticHelper.triggerLightImpact();
          onChanged(val);
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppTheme.getTextColor(mode).withOpacity(0.4)),
          border: InputBorder.none,
        ),
        dropdownColor: AppTheme.getKeyColor(mode, isOperator: true),
        style: AppTextStyles.bodyStyle(mode, fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildCurrencySelectorButton(
    String label,
    String currentValue,
    List<String> list,
    ThemeMode mode,
    Color accent,
    ValueChanged<String> onSelected,
  ) {
    final displayName = currencyNames[currentValue] ?? '';
    
    return GestureDetector(
      onTap: () => _showCurrencySearchSheet(currentValue, list, mode, accent, onSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.getKeyColor(mode, isOperator: true).withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.getAccentColor(mode).withOpacity(0.1), width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.getTextColor(mode).withOpacity(0.4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        currentValue,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.getTextColor(mode).withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: accent, size: 20),
          ],
        ),
      ),
    );
  }

  void _showCurrencySearchSheet(
    String currentValue,
    List<String> list,
    ThemeMode mode,
    Color accent,
    ValueChanged<String> onSelected,
  ) {
    String searchQuery = "";
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filteredList = list.where((code) {
              final name = (currencyNames[code] ?? '').toLowerCase();
              final cCode = code.toLowerCase();
              final q = searchQuery.toLowerCase();
              return cCode.contains(q) || name.contains(q);
            }).toList();

            final activeTheme = AppTheme.currentTheme;

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.65,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppTheme.getBgGradient(activeTheme),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border(top: AppTheme.getBorderSide(activeTheme)),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Handle Bar
                      Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.getTextColor(activeTheme).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                      
                      // Header Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Text(
                          "SELECT CURRENCY",
                          style: AppTextStyles.headerStyle(mode, fontSize: 16, glow: true),
                        ),
                      ),

                      // Search Field Box
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: TextField(
                          autofocus: true,
                          style: TextStyle(color: AppTheme.getTextColor(activeTheme)),
                          decoration: InputDecoration(
                            hintText: "Search by code or country (e.g. INR, India...)",
                            hintStyle: TextStyle(color: AppTheme.getTextColor(activeTheme).withOpacity(0.3)),
                            prefixIcon: Icon(Icons.search_rounded, color: accent),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.04),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: accent.withOpacity(0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: accent, width: 1.5),
                            ),
                          ),
                          onChanged: (val) {
                            setSheetState(() {
                              searchQuery = val;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      // High-performance smooth list
                      Expanded(
                        child: filteredList.isEmpty
                          ? Center(
                              child: Text(
                                "No currencies match your search",
                                style: TextStyle(color: AppTheme.getTextColor(activeTheme).withOpacity(0.4)),
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: filteredList.length,
                              itemBuilder: (context, idx) {
                                final code = filteredList[idx];
                                final fullName = currencyNames[code] ?? '';
                                final isSelected = code == currentValue;

                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected ? accent.withOpacity(0.08) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: ListTile(
                                    leading: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: accent.withOpacity(isSelected ? 0.2 : 0.05),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        code,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: isSelected ? accent : AppTheme.getTextColor(activeTheme),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      code,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.getTextColor(activeTheme),
                                      ),
                                    ),
                                    subtitle: Text(
                                      fullName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.getTextColor(activeTheme).withOpacity(0.5),
                                      ),
                                    ),
                                    trailing: isSelected
                                        ? Icon(Icons.check_circle_rounded, color: accent)
                                        : null,
                                    onTap: () {
                                      HapticHelper.triggerMediumImpact();
                                      onSelected(code);
                                      Navigator.pop(context);
                                    },
                                  ),
                                );
                              },
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
