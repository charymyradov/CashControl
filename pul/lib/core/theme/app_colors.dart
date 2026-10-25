import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFF8F6F3);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFECEBED);
  static const ink = Color(0xFF17222C);
  static const inkSoft = Color(0xFF24384D);
  static const navy = Color(0xFF20354A);
  static const navyDeep = Color(0xFF162B3E);
  static const textSecondary = Color(0xFF8A939C);
  static const textTertiary = Color(0xFFAEB5BB);
  static const line = Color(0xFFEFEDEA);
  static const lineStrong = Color(0xFFE4E1DD);

  static const green = Color(0xFF2FC787);
  static const greenDark = Color(0xFF159A63);
  static const greenSoft = Color(0xFFE8F8F0);
  static const greenTint = Color(0xFFF1FBF6);

  static const coral = Color(0xFFF17568);
  static const coralDark = Color(0xFFD95547);
  static const coralSoft = Color(0xFFFDEDEA);
  static const coralTint = Color(0xFFFFF7F5);

  static const amber = Color(0xFFF5B84B);
  static const blue = Color(0xFF3D8BEC);
  static const violet = Color(0xFF8B79CF);
  static const pink = Color(0xFFE770A5);
  static const teal = Color(0xFF2FAE9A);
  static const orchid = Color(0xFF9B6FD1);
  static const slate = Color(0xFF778899);

  static const navyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF273F56), Color(0xFF182C3E)],
  );
}
