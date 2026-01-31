import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_state.dart';
import 'app_state_scope.dart';
import 'data/api/movie_api_service.dart';
import 'data/local/local_storage_service.dart';
import 'data/repository/movie_repository.dart';
import 'screens/home_screen.dart';

const String _apiKey = 'HRPJRHZ-5Y8M8ZZ-PGV4W6J-ZHANWZC';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storage = LocalStorageService(prefs);
  final apiService = MovieApiService(apiKey: _apiKey);
  final repository = MovieRepository(
    apiService: apiService,
    localStorage: storage,
  );
  final appState = AppState(repository: repository);
  await appState.loadFromStorage();
  runApp(MainApp(appState: appState));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key, required this.appState});

  final AppState appState;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    widget.appState.addListener(() => setState(() {}));
    widget.appState.fetchApiMovies();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      state: widget.appState,
      child: MaterialApp(
        title: 'Фильмы',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.light,
            primary: const Color(0xFF6366F1),
          ),
          useMaterial3: true,
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
          ),
          listTileTheme: ListTileThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          searchBarTheme: SearchBarThemeData(
            elevation: WidgetStateProperty.all(0),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          appBarTheme: AppBarThemeData(
            elevation: 0,
            centerTitle: true,
            scrolledUnderElevation: 1,
          ),
          chipTheme: ChipThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        home: HomeScreen(),
      ),
    );
  }
}
