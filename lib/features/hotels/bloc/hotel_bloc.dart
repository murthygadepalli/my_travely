import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/hotel_model.dart';
import '../../../core/repository/hotel_repository.dart';

/// ----------------------
/// EVENTS
/// ----------------------
abstract class HotelEvent {}

class LoadHotels extends HotelEvent {
  final Map<String, dynamic> body;
  LoadHotels(this.body);
}

class LoadMoreHotels extends HotelEvent {}

/// ----------------------
/// STATES
/// ----------------------
abstract class HotelState {}

class HotelInitial extends HotelState {}

class HotelLoading extends HotelState {}

class HotelLoaded extends HotelState {
  final List<Hotel> hotels;
  final bool hasMore;
  final bool isLoadingMore;
  HotelLoaded(this.hotels, {this.hasMore = true, this.isLoadingMore = false});

  HotelLoaded copyWith({
    List<Hotel>? hotels,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return HotelLoaded(
      hotels ?? this.hotels,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class HotelError extends HotelState {
  final String message;
  HotelError(this.message);
}

/// ----------------------
/// BLOC IMPLEMENTATION
/// ----------------------
class HotelBloc extends Bloc<HotelEvent, HotelState> {
  final HotelRepository repository;

  int _currentPage = 0;
  bool _hasMore = true;
  List<Hotel> _allHotels = [];
  Map<String, dynamic>? _lastRequestBody;
  final int _limit = 10;

  HotelBloc(this.repository) : super(HotelInitial()) {
    on<LoadHotels>(_onLoadHotels);
    on<LoadMoreHotels>(_onLoadMoreHotels);
  }

  /// Initial fetch
  Future<void> _onLoadHotels(LoadHotels event, Emitter<HotelState> emit) async {
    emit(HotelLoading());
    try {
      _currentPage = 0;
      _hasMore = true;
      _lastRequestBody = event.body;

      final body = _attachPagination(event.body, _currentPage);
      final hotels = await repository.fetchHotels(body);

      _allHotels = hotels;

      // ✅ Stop pagination if returned list < limit
      _hasMore = hotels.length >= _limit;

      emit(HotelLoaded(_allHotels, hasMore: _hasMore));
    } catch (e) {
      emit(HotelError(e.toString()));
    }
  }

  /// Load next page
  Future<void> _onLoadMoreHotels(
      LoadMoreHotels event, Emitter<HotelState> emit) async {
    if (!_hasMore || _lastRequestBody == null || state is HotelLoading) return;

    if (state is HotelLoaded) {
      emit((state as HotelLoaded).copyWith(isLoadingMore: true));
    }

    try {
      _currentPage++;
      final body = _attachPagination(_lastRequestBody!, _currentPage);
      final moreHotels = await repository.fetchHotels(body);

      if (moreHotels.isEmpty || moreHotels.length < _limit) {
        _hasMore = false;
      }

      _allHotels.addAll(moreHotels);

      emit(HotelLoaded(
        List.from(_allHotels),
        hasMore: _hasMore,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(HotelError(e.toString()));
    }
  }

  /// Helper for pagination body
  Map<String, dynamic> _attachPagination(Map<String, dynamic> baseBody, int page) {
    final updated = Map<String, dynamic>.from(baseBody);
    final int offset = page * _limit;

    if (updated.containsKey('popularStay')) {
      updated['popularStay'] = {
        ...updated['popularStay'],
        'limit': _limit,
        'rid': offset,
      };
    } else if (updated.containsKey('getSearchResultListOfHotels')) {
      final searchCriteria =
      updated['getSearchResultListOfHotels']['searchCriteria'];
      updated['getSearchResultListOfHotels']['searchCriteria'] = {
        ...searchCriteria,
        'limit': _limit,
        'rid': offset,
      };
    }

    return updated;
  }
}
