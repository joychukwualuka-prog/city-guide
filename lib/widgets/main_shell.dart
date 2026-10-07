
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/city_model.dart';
import '../screens/home/explore_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/map/google_map_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/profile/profile_screen.dart';

class MainShell extends StatefulWidget {
final CityModel city;
final VoidCallback onChangeCity;

const MainShell({
super.key,
required this.city,
required this.onChangeCity,
});

@override
State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
int _index = 0;

@override
Widget build(BuildContext context) {
final tabs = [
ExploreScreen(city: widget.city),
SearchScreen(city: widget.city),
GoogleMapScreen(city: widget.city),
const FavoritesScreen(),
ProfileScreen(
onChangeCity: widget.onChangeCity,
),
];

return Scaffold(
body: IndexedStack(
index: _index,
children: tabs,
),

bottomNavigationBar: BottomNavigationBar(
currentIndex: _index,
onTap: (i) {
setState(() {
_index = i;
});
},

type: BottomNavigationBarType.fixed,

backgroundColor: Colors.white,
selectedItemColor: AppColors.primary,
unselectedItemColor: AppColors.textSecondary,

selectedIconTheme: const IconThemeData(
size: 26,
color: AppColors.primary,
),

unselectedIconTheme: const IconThemeData(
size: 23,
color: AppColors.textSecondary,
),

selectedLabelStyle: const TextStyle(
fontWeight: FontWeight.w600,
fontSize: 12,
),

unselectedLabelStyle: const TextStyle(
fontWeight: FontWeight.w400,
fontSize: 11,
),

showSelectedLabels: true,
showUnselectedLabels: true,

elevation: 12,

items: const [
BottomNavigationBarItem(
icon: Icon(Icons.home_outlined),
activeIcon: Icon(Icons.home),
label: 'Home',
),
BottomNavigationBarItem(
icon: Icon(Icons.search),
activeIcon: Icon(Icons.search),
label: 'Search',
),
BottomNavigationBarItem(
icon: Icon(Icons.map_outlined),
activeIcon: Icon(Icons.map),
label: 'Map',
),
BottomNavigationBarItem(
icon: Icon(Icons.favorite_border),
activeIcon: Icon(Icons.favorite),
label: 'Favorites',
),
BottomNavigationBarItem(
icon: Icon(Icons.person_outline),
activeIcon: Icon(Icons.person),
label: 'Profile',
),
],
),
);
}
}
