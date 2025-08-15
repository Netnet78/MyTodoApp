import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do_app/views/views.dart';
import 'package:to_do_app/core/utils/custom_notched_shape.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const HomePageWidget(),
    const SettingsPageWidget(),
  ];

  @override
  void dispose() {
    for (AnimationController controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(2, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
        lowerBound: 1.0,
        upperBound: 1.1
      );
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Play the animation for the tapped button
    _controllers[index].forward().then((value) {
      _controllers[index].reverse();
    });
  }

  void _showAddTaskForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.95,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: const AddTaskFormWidget(),
        );
      },
    );
  }

  Widget _buildNavButton(IconData icon, int index) {
    final theme = Theme.of(context);

    bool isActive = _currentIndex == index;
    const int duration = 300;

    return ScaleTransition(
      scale: _controllers[index],
      child: GestureDetector(
        onTap: () => _onTabSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: duration),
          curve: Curves.easeInOut,
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive ? theme.primaryColor : Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: _pages[_currentIndex],
        ),
      ),

      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        automaticallyImplyLeading: false,
        title: Text(
          'Welcome to Nitofy!',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        elevation: 2,
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: BottomAppBar(
          color: Colors.transparent,
          shape: SmoothCircularNotchedRectangle(),
          notchMargin: 8.0,
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: theme.primaryColor,
              border: BoxBorder.all(
                color: theme.dividerColor,
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavButton(Icons.list_alt, 0),
                const SizedBox(width: 10), // space for FAB
                _buildNavButton(Icons.settings, 1),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: FloatingActionButton(
          backgroundColor: theme.primaryColor,
          onPressed: () => _showAddTaskForm(),
          shape: CircleBorder(
            side: BorderSide(
              color: theme.colorScheme.primary,
              width: 3.0, 
            ),
          ),
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),
    );
  }
}
