import 'package:app/data/notifiers.dart';
import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';


class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder<bool>(
          valueListenable: isLightModeNotifier,
          builder: (context, isLightMode, child) {
            final appColors = isLightMode ? themeProvider.lightColors : themeProvider.darkColors;

            return ListView(
              children: [
                SwitchListTile(
                  title: const Text('Light Mode'),
                  value: isLightMode,
                  onChanged: (value) {
                    isLightModeNotifier.value = value;
                  },
                ),
                ColorPickerTile(
                  title: 'Primary Color (${isLightMode ? "Light" : "Dark"})',
                  color: appColors.primaryColor,
                  onColorChanged: (color) {
                    if (isLightMode) {
                      themeProvider.updateLightColors(primaryColor: color);
                    } else {
                      themeProvider.updateDarkColors(primaryColor: color);
                    }
                  },
                ),
                ColorPickerTile(
                  title: 'Secondary Color (${isLightMode ? "Light" : "Dark"})',
                  color: appColors.secondaryColor,
                  onColorChanged: (color) {
                    if (isLightMode) {
                      themeProvider.updateLightColors(secondaryColor: color);
                    } else {
                      themeProvider.updateDarkColors(secondaryColor: color);
                    }
                  },
                ),
                ColorPickerTile(
                  title: 'Sound Color (${isLightMode ? "Light" : "Dark"})',
                  color: appColors.soundColor,
                  onColorChanged: (color) {
                    if (isLightMode) {
                      themeProvider.updateLightColors(soundColor: color);
                    } else {
                      themeProvider.updateDarkColors(soundColor: color);
                    }
                  },
                ),
                ColorPickerTile(
                  title: 'Pattern Color (${isLightMode ? "Light" : "Dark"})',
                  color: appColors.patternColor,
                  onColorChanged: (color) {
                    if (isLightMode) {
                      themeProvider.updateLightColors(patternColor: color);
                    } else {
                      themeProvider.updateDarkColors(patternColor: color);
                    }
                  },
                ),
                ColorPickerTile(
                  title: 'Dictionary Color (${isLightMode ? "Light" : "Dark"})',
                  color: appColors.dictionaryColor,
                  onColorChanged: (color) {
                    if (isLightMode) {
                      themeProvider.updateLightColors(dictionaryColor: color);
                    } else {
                      themeProvider.updateDarkColors(dictionaryColor: color);
                    }
                  },
                ),
                ColorPickerTile(
                  title: 'Background Color (${isLightMode ? "Light" : "Dark"})',
                  color: appColors.backgroundColor,
                  onColorChanged: (color) {
                    if (isLightMode) {
                      themeProvider.updateLightColors(backgroundColor: color);
                    } else {
                      themeProvider.updateDarkColors(backgroundColor: color);
                    }
                  },
                ),
                ColorPickerTile(
                  title: 'Accent Color (${isLightMode ? "Light" : "Dark"})',
                  color: appColors.accentColor,
                  onColorChanged: (color) {
                    if (isLightMode) {
                      themeProvider.updateLightColors(accentColor: color);
                    } else {
                      themeProvider.updateDarkColors(accentColor: color);
                    }
                  },
                ),
                ColorPickerTile(
                  title: 'Nav Selected Color (${isLightMode ? "Light" : "Dark"})',
                  color: appColors.navSelectedColor,
                  onColorChanged: (color) {
                    if (isLightMode) {
                      themeProvider.updateLightColors(navSelectedColor: color);
                    } else {
                      themeProvider.updateDarkColors(navSelectedColor: color);
                    }
                  },
                ),
                ColorPickerTile(
                  title: 'Nav Unselected Color (${isLightMode ? "Light" : "Dark"})',
                  color: appColors.navUnselectedColor,
                  onColorChanged: (color) {
                    if (isLightMode) {
                      themeProvider.updateLightColors(navUnselectedColor: color);
                    } else {
                      themeProvider.updateDarkColors(navUnselectedColor: color);
                    }
                  },
                ),
                ColorPickerTile(
                  title: 'Card Color (${isLightMode ? "Light" : "Dark"})',
                  color: appColors.cardColor,
                  onColorChanged: (color) {
                    if (isLightMode) {
                      themeProvider.updateLightColors(cardColor: color);
                    } else {
                      themeProvider.updateDarkColors(cardColor: color);
                    }
                  },
                ),
                ColorPickerTile(
                  title: 'Button Primary Color (${isLightMode ? "Light" : "Dark"})',
                  color: appColors.buttonPrimaryColor,
                  onColorChanged: (color) {
                    if (isLightMode) {
                      themeProvider.updateLightColors(buttonPrimaryColor: color);
                    } else {
                      themeProvider.updateDarkColors(buttonPrimaryColor: color);
                    }
                  },
                ),
                ColorPickerTile(
                  title: 'Button Secondary Color (${isLightMode ? "Light" : "Dark"})',
                  color: appColors.buttonSecondaryColor,
                  onColorChanged: (color) {
                    if (isLightMode) {
                      themeProvider.updateLightColors(buttonSecondaryColor: color);
                    } else {
                      themeProvider.updateDarkColors(buttonSecondaryColor: color);
                    }
                  },
                ),
                ColorPickerTile(
                  title: 'Button Tertiary Color (${isLightMode ? "Light" : "Dark"})',
                  color: appColors.buttonTertiaryColor,
                  onColorChanged: (color) {
                    if (isLightMode) {
                      themeProvider.updateLightColors(buttonTertiaryColor: color);
                    } else {
                      themeProvider.updateDarkColors(buttonTertiaryColor: color);
                    }
                  },
                ),
                ColorPickerTile(
                  title: 'Waveform Live Color (${isLightMode ? "Light" : "Dark"})',
                  color: appColors.waveformLiveColor,
                  onColorChanged: (color) {
                    if (isLightMode) {
                      themeProvider.updateLightColors(waveformLiveColor: color);
                    } else {
                      themeProvider.updateDarkColors(waveformLiveColor: color);
                    }
                  },
                ),
                ColorPickerTile(
                  title: 'Waveform Fixed Color (${isLightMode ? "Light" : "Dark"})',
                  color: appColors.waveformFixedColor,
                  onColorChanged: (color) {
                    if (isLightMode) {
                      themeProvider.updateLightColors(waveformFixedColor: color);
                    } else {
                      themeProvider.updateDarkColors(waveformFixedColor: color);
                    }
                  },
                ),
                ColorPickerTile(
                  title: 'Waveform Seek Color (${isLightMode ? "Light" : "Dark"})',
                  color: appColors.waveformSeekColor,
                  onColorChanged: (color) {
                    if (isLightMode) {
                      themeProvider.updateLightColors(waveformSeekColor: color);
                    } else {
                      themeProvider.updateDarkColors(waveformSeekColor: color);
                    }
                  },
                ),
                ColorPickerTile(
                  title: 'Gradient Start Color (${isLightMode ? "Light" : "Dark"})',
                  color: appColors.gradientStartColor,
                  onColorChanged: (color) {
                    if (isLightMode) {
                      themeProvider.updateLightColors(gradientStartColor: color);
                    } else {
                      themeProvider.updateDarkColors(gradientStartColor: color);
                    }
                  },
                ),
                ColorPickerTile(
                  title: 'Gradient End Color (${isLightMode ? "Light" : "Dark"})',
                  color: appColors.gradientEndColor,
                  onColorChanged: (color) {
                    if (isLightMode) {
                      themeProvider.updateLightColors(gradientEndColor: color);
                    } else {
                      themeProvider.updateDarkColors(gradientEndColor: color);
                    }
                  },
                ),
                ColorPickerTile(
                  title: 'Highlight Color (${isLightMode ? "Light" : "Dark"})',
                  color: appColors.highlightColor,
                  onColorChanged: (color) {
                    if (isLightMode) {
                      themeProvider.updateLightColors(highlightColor: color);
                    } else {
                      themeProvider.updateDarkColors(highlightColor: color);
                    }
                  },
                ),
                ColorPickerTile(
                  title: 'Error Color (${isLightMode ? "Light" : "Dark"})',
                  color: appColors.errorColor,
                  onColorChanged: (color) {
                    if (isLightMode) {
                      themeProvider.updateLightColors(errorColor: color);
                    } else {
                      themeProvider.updateDarkColors(errorColor: color);
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ColorPickerTile extends StatelessWidget {
  final String title;
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerTile({
    super.key,
    required this.title,
    required this.color,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey),
        ),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            Color pickerColor = color;
            return AlertDialog(
              title: Text('Pick $title'),
              content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: pickerColor,
                  onColorChanged: (newColor) {
                    pickerColor = newColor;
                  },
                  showLabel: true,
                  pickerAreaHeightPercent: 0.8,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    onColorChanged(pickerColor);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}