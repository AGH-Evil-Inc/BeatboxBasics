import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../main.dart';

ValueNotifier<int> selectedPageNotifier = ValueNotifier<int>(0);
ValueNotifier<bool> isLightModeNotifier = ValueNotifier<bool>(true);
ValueNotifier<AppColors> customColorsNotifier = ValueNotifier<AppColors>(AppColors.light());