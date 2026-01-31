import '../../models/movie.dart';
import '../api/movie_api_service.dart';
import '../dto/api_movie_dto.dart';
import '../local/local_storage_service.dart';

class MovieRepository {
  MovieRepository({
    required this.apiService,
    required this.localStorage,
  });

  final MovieApiService apiService;
  final LocalStorageService localStorage;

  Future<ApiMovieListResponse> getMoviesFromApi({
    int page = 1,
    int limit = 20,
    Map<String, String>? queryParams,
  }) =>
      apiService.getMovies(page: page, limit: limit, queryParams: queryParams);

  Future<ApiMovieListResponse> searchMovies({
    required String query,
    int page = 1,
    int limit = 10,
  }) =>
      apiService.searchMovies(query: query, page: page, limit: limit);

  List<Movie> getLocalMovies() => localStorage.loadLocalMovies();

  Future<void> saveLocalMovies(List<Movie> movies) =>
      localStorage.saveLocalMovies(movies);

  Map<String, List<String>> getCategoryKeys() =>
      localStorage.loadCategoryKeys();

  Future<void> saveCategoryKeys(Map<String, List<String>> map) =>
      localStorage.saveCategoryKeys(map);

  Map<int, ApiMovieDto> getApiMovieCache() =>
      localStorage.loadApiMovieCache();

  Future<void> saveApiMovieCache(Map<int, ApiMovieDto> cache) =>
      localStorage.saveApiMovieCache(cache);

  List<String> getCustomCategories() => localStorage.loadCustomCategories();

  Future<void> saveCustomCategories(List<String> names) =>
      localStorage.saveCustomCategories(names);

  Map<String, int> getCustomCategoryIcons() =>
      localStorage.loadCustomCategoryIcons();

  Future<void> saveCustomCategoryIcons(Map<String, int> map) =>
      localStorage.saveCustomCategoryIcons(map);

  List<String> getSearchHistory() => localStorage.loadSearchHistory();
  Future<void> saveSearchHistory(List<String> list) =>
      localStorage.saveSearchHistory(list);
}
