import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:csc_picker/csc_picker.dart';
import '../../../core/models/currency_model.dart';
import '../../../core/repository/hotel_repository.dart';
import '../../../core/routes/app_routes.dart';
import '../../../helper/token_storage.dart';
import '../bloc/hotel_bloc.dart';
import '../widgets/hotel_card.dart';
import '../widgets/shimmer_loader.dart';
import 'search_results_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final HotelBloc _hotelBloc;

  List<Map<String, dynamic>> _suggestions = [];
  List<Currency> currencyList = [];

  bool _isSearching = false;
  String _searchQuery = '';
  String _selectedEntityType = 'Any';
  String _selectedSearchType = 'byRandom';
  String? _country;
  String? _state;
  String? _city;

  @override
  void initState() {
    super.initState();
    _hotelBloc = HotelBloc(HotelRepository());
    _loadHotels();
    _loadCurrencies();

    _scrollController.addListener(() {
      final currentState = _hotelBloc.state;
      if (currentState is HotelLoaded &&
          currentState.hasMore &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
        _hotelBloc.add(LoadMoreHotels());
      }
    });
  }

  void _loadCurrencies() async {
    try {
      currencyList = await HotelRepository().fetchCurrencyList();
      setState(() {});
    } catch (e) {
      print("❌ Failed to load currencies: $e");
    }
  }

  String _getCurrencySymbolForCountry() {
    if (_country != null && currencyList.isNotEmpty) {
      final match = currencyList.firstWhere(
            (c) => _country!.toLowerCase().contains(c.country.toLowerCase()),
        orElse: () => Currency(country: "India", code: "INR", symbol: "₹"),
      );
      return match.symbol;
    }
    return "₹";
  }

  void _loadHotels() {
    final searchTypeInfo = <String, String>{};
    if (_selectedSearchType == 'byCountry' && _country != null) {
      searchTypeInfo['country'] = _country!;
    } else if (_selectedSearchType == 'byState' &&
        _country != null &&
        _state != null) {
      searchTypeInfo['country'] = _country!;
      searchTypeInfo['state'] = _state!;
    } else if (_selectedSearchType == 'byCity' &&
        _country != null &&
        _state != null &&
        _city != null) {
      searchTypeInfo['country'] = _country!;
      searchTypeInfo['state'] = _state!;
      searchTypeInfo['city'] = _city!;
    }

    final match = _country != null
        ? currencyList.firstWhere(
          (c) => _country!.toLowerCase().contains(c.country.toLowerCase()),
      orElse: () => Currency(code: "INR", country: "India", symbol: "₹"),
    )
        : Currency(code: "INR", country: "India", symbol: "₹");

    final body = {
      "action": "popularStay",
      "popularStay": {
        "limit": 10,
        "entityType": _selectedEntityType,
        "filter": {
          "searchType": _selectedSearchType,
          "searchTypeInfo": searchTypeInfo,
        },
        "currency": match.code
      }
    };

    _hotelBloc.add(LoadHotels(body));
  }

  void _onSearchChanged(String value) async {
    setState(() {
      _searchQuery = value;
      _isSearching = true;
    });

    if (value.isEmpty) {
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
      return;
    }

    final results =
    await _hotelBloc.repository.fetchAutoComplete(value.trim());
    setState(() {
      _suggestions = results;
      _isSearching = false;
    });
  }

  void _onSuggestionTap(Map<String, dynamic> item) async {
    FocusScope.of(context).unfocus(); // dismiss keyboard

    try {
      final searchArray = item["searchArray"];
      final searchType = searchArray["type"];
      final searchQuery = searchArray["query"];

      final body = {
        "action": "getSearchResultListOfHotels",
        "getSearchResultListOfHotels": {
          "searchCriteria": {
            "checkIn": "2026-07-11",
            "checkOut": "2026-07-12",
            "rooms": 1,
            "adults": 2,
            "children": 0,
            "searchType": searchType,
            "searchQuery": searchQuery,
            "accommodation": ["all", "hotel"],
            "arrayOfExcludedSearchType": ["street"],
            "highPrice": "3000000",
            "lowPrice": "0",
            "limit": 5,
            "preloaderList": [],
            "currency": "INR",
            "rid": 0
          }
        }
      };

      final hotels = await _hotelBloc.repository.fetchHotels(body);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchResultPage(hotels: hotels),
        ),
      );
    } catch (e) {
      print("❌ Search error: $e");
    }
  }


  Future<void> _openFilterSheet() async {
    String tempEntityType = _selectedEntityType;
    String tempSearchType = _selectedSearchType;
    String? tempCountry = _country;
    String? tempState = _state;
    String? tempCity = _city;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFF8EC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Handle
                  Container(
                    height: 5,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  const Text(
                    "Filter Your Stay",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF622A39),
                      fontFamily: "Poppins",
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Entity Type
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Entity Type",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: tempEntityType,
                    dropdownColor: const Color(0xFFFFF8EC),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFFFF8EC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF622A39), width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF622A39), width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      'Any',
                      'hotel',
                      'resort',
                      'Home Stay',
                      'Camp_sites/tent',
                    ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setModalState(() => tempEntityType = v!),
                  ),

                  const SizedBox(height: 20),

                  // Search Type
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Search Type",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: tempSearchType,
                    dropdownColor: const Color(0xFFFFF8EC),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFFFF8EC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF622A39), width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF622A39), width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      'byRandom',
                      'byCountry',
                      'byState',
                      'byCity',
                    ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) {
                      setModalState(() {
                        tempSearchType = v!;
                        tempCountry = null;
                        tempState = null;
                        tempCity = null;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // Location Picker (Conditional)
                  if (tempSearchType != 'byRandom') ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Select Location",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CSCPicker(
                      key: ValueKey(tempSearchType),
                      showStates: tempSearchType != 'byCountry',
                      showCities: tempSearchType == 'byCity',

                      // 🎨 Custom Theme for all dropdowns
                      dropdownDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFFFF8EC),
                        border: Border.all(color: const Color(0xFF622A39), width: 1.2),
                      ),
                      disabledDropdownDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFFFF8EC),
                        border: Border.all(color: Colors.grey.shade400),
                      ),

                      selectedItemStyle: const TextStyle(
                        color: Color(0xFF622A39),
                        fontFamily: "Poppins",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      dropdownHeadingStyle: const TextStyle(
                        color: Color(0xFF622A39),
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.bold,
                      ),

                      onCountryChanged: (value) {
                        setModalState(() {
                          tempCountry = value;
                          tempCity = null;
                        });
                      },
                      onStateChanged: (value) {
                        setModalState(() {
                          tempState = value;
                          tempCity = null;
                        });
                      },
                      onCityChanged: (value) => setModalState(() => tempCity = value),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (tempSearchType == 'byCountry' && tempCountry == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select a country.')),
                          );
                          return;
                        }
                        if (tempSearchType == 'byState' && (tempCountry == null || tempState == null)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select country and state.')),
                          );
                          return;
                        }
                        if (tempSearchType == 'byCity' && (tempCountry == null || tempState == null || tempCity == null)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select country, state, and city.')),
                          );
                          return;
                        }

                        setState(() {
                          _selectedEntityType = tempEntityType;
                          _selectedSearchType = tempSearchType;
                          _country = tempCountry;
                          _state = tempState;
                          _city = tempCity;
                        });
                        Navigator.pop(context);
                        _loadHotels();
                      },
                      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                      label: const Text(
                        "Apply Filters",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF622A39),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 👇 exit the app when back button is pressed
        return true;
      },
      child: BlocProvider.value(
        value: _hotelBloc,
        child: Scaffold(

          backgroundColor: Color(0xFFFFF8EC),
          appBar: AppBar(
            automaticallyImplyLeading: false, // ⛔ removes back button
            title: const Text(
              "Stays",
              style: TextStyle(
                fontSize: 20,
                fontFamily: "Poppins",
              ),
            ),
            centerTitle: true,
            backgroundColor: const Color(0xFF622A39),
            // backgroundColor:  Colors.deepOrange,
            foregroundColor: Colors.white,
            elevation: 2,

            // 👇 Add Logout Icon Button on the right
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: "Logout",
                onPressed: () async {
                  // 🧹 Clear saved visitor token
                  await TokenStorage.clearToken();

                  // 🧭 Navigate to SignInPage and clear navigation stack
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      Routes.signIn,
                          (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
          body: GestureDetector(
            onTap: () => setState(() => _suggestions.clear()), // dismiss suggestions
            child: Column(
              children: [
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8EC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF622A39)),
                              ),
                              child: TextField(
                                controller: _searchController,
                                textAlignVertical: TextAlignVertical.center, // ✅ aligns text + icon vertically
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(top: 4), // ✅ removes default padding for perfect center alignment
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.only(left: 10, right: 6,top: 4), // balanced horizontal spacing
                                    child: Icon(
                                      Icons.search,
                                      color: Color(0xFF622A39),
                                      size: 20, // slightly smaller for visual symmetry
                                    ),
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                  hintText: "Search hotels, cities, countries...",
                                  hintStyle: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                onChanged: _onSearchChanged,
                              ),
                            ),
                            if (_suggestions.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFF8EC),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black12, blurRadius: 6)
                                  ],
                                ),
                                constraints:
                                const BoxConstraints(maxHeight: 250),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _suggestions.length,
                                  itemBuilder: (context, i) {
                                    final item = _suggestions[i];
                                    final address =
                                        item['address'] as Map<String, dynamic>? ??
                                            {};
                                    final subtitle = [
                                      address['city'],
                                      address['state'],
                                      address['country']
                                    ].where((e) => e != null).join(', ');
                                    return ListTile(
                                      title: Text(item['value']),
                                      subtitle: Text(subtitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      onTap: () => _onSuggestionTap(item),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 44,
                        width: 44, // 👈 square button for symmetry
                        child: Material(
                          color: const Color(0xFF622A39),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _openFilterSheet,
                            child: const Center( // 👈 centers the icon perfectly
                              child: Icon(
                                Icons.filter_list,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: BlocBuilder<HotelBloc, HotelState>(
                    builder: (context, state) {
                      if (state is HotelLoading) {
                        return const HotelListShimmer();
                      } else if (state is HotelLoaded) {
                        if (state.hotels.isEmpty) {
                          return const Center(child: Text("No hotels found."));
                        }

                        return ListView.builder(
                          controller: _scrollController,
                          itemCount:
                          state.hotels.length + (state.hasMore ? 1 : 0),
                          itemBuilder: (context, i) {
                            if (i < state.hotels.length) {
                              return HotelCard(
                                hotel: state.hotels[i],
                                currencySymbol: _getCurrencySymbolForCountry(),
                              );
                            } else {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child:
                                Center(child: CircularProgressIndicator()),
                              );
                            }
                          },
                        );
                      } else if (state is HotelError) {
                        return Center(child: Text(state.message));
                      }
                      return const SizedBox();
                    },
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
