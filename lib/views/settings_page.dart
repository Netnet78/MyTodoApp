import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_app/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPageWidget extends ConsumerStatefulWidget {
  const SettingsPageWidget ({super.key});

  @override
  ConsumerState<SettingsPageWidget> createState() => _SettingsPageWidgetState();
}

class _SettingsPageWidgetState extends ConsumerState<SettingsPageWidget> {

  bool _isDarkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSwitchValue();
  }

  void _loadSwitchValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkModeEnabled = prefs.getBool('darkMode') ?? false;
    });  
  }
  void _saveSwitchValue(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);
  }

  @override
  Widget build(BuildContext context) {

    final titleStyle = GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).textTheme.bodyLarge?.color,
    );

    final descStyle = GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Theme.of(context).textTheme.bodyMedium?.color,
    );

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
                boxShadow: const [BoxShadow(
                  blurRadius: 2.0,
                  color: Color.fromARGB(68, 0, 0, 0),
                  offset: Offset(0, 3)
                )],
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(10))
              ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.dark_mode, color: Theme.of(context).textTheme.bodyMedium?.color,),
                          const SizedBox(width: 5), // spacing between icon and text
                          Text(
                            "Dark mode",
                            style: titleStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Enables dark mode for easier visibility",
                        style: descStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Switch(
                  activeTrackColor: Theme.of(context).primaryColor,
                  activeColor: Colors.white,
                  inactiveThumbColor: Theme.of(context).primaryColor,
                  value: _isDarkModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _isDarkModeEnabled = value;
                    });
                    _saveSwitchValue(value);
                    ref.read(themeModeProvider.notifier).toggle(value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}