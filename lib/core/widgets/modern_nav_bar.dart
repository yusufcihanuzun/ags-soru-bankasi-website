import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/responsive_helper.dart';

class ModernNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const ModernNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: ResponsiveHelper.isExtraSmallScreen(context)
            ? 15
            : ResponsiveHelper.isSmallScreen(context)
                ? 20
                : 30,
        right: ResponsiveHelper.isExtraSmallScreen(context)
            ? 15
            : ResponsiveHelper.isSmallScreen(context)
                ? 20
                : 30,
        bottom: ResponsiveHelper.isExtraSmallScreen(context)
            ? 6
            : ResponsiveHelper.isSmallScreen(context)
                ? 8
                : 12,
        top: ResponsiveHelper.isExtraSmallScreen(context)
            ? 6
            : ResponsiveHelper.isSmallScreen(context)
                ? 8
                : 12,
      ),
      height: ResponsiveHelper.getNavBarHeight(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFF6D79EC).withOpacity(0.03),
            const Color(0xFF8B5CF6).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(
            ResponsiveHelper.getNavBarHeight(context) / 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D79EC).withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.isExtraSmallScreen(context)
                ? 4
                : ResponsiveHelper.isSmallScreen(context)
                    ? 6
                    : 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (showBackButton) ...[
              // Geri butonu - Sol köşede
              _buildModernNavItem(
                context: context,
                icon: Icons.arrow_back_ios_rounded,
                isActive: false,
                isPrimary: false,
                onTap: onBackPressed ?? () => Navigator.pop(context),
              ),
            ],
            // Ana Sayfa
            _buildModernNavItem(
              context: context,
              icon: Icons.home_rounded,
              isActive: selectedIndex == 0,
              isPrimary: selectedIndex == 0,
              onTap: () => onTap(0),
            ),
            // Profil
            _buildModernNavItem(
              context: context,
              icon: Icons.person_rounded,
              isActive: selectedIndex == 1,
              isPrimary: selectedIndex == 1,
              onTap: () => onTap(1),
            ),
            // İlerleme (Progress)
            _buildModernNavItem(
              context: context,
              icon: Icons.trending_up_rounded,
              isActive: selectedIndex == 2,
              isPrimary: selectedIndex == 2,
              onTap: () => onTap(2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernNavItem({
    required BuildContext context,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: isPrimary
            ? ResponsiveHelper.getNavBarItemSize(context)
            : ResponsiveHelper.getNavBarItemSize(context) * 0.83,
        height: isPrimary
            ? ResponsiveHelper.getNavBarItemSize(context)
            : ResponsiveHelper.getNavBarItemSize(context) * 0.83,
        decoration: BoxDecoration(
          color: isPrimary
              ? Colors.white
              : isActive
                  ? const Color(0xFF6D79EC).withOpacity(0.15)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(isPrimary
              ? ResponsiveHelper.getNavBarItemSize(context) / 2
              : ResponsiveHelper.getNavBarItemSize(context) * 0.83 / 2),
          border: isPrimary
              ? Border.all(
                  color: const Color(0xFF6D79EC).withOpacity(0.1),
                  width: 1,
                )
              : isActive
                  ? Border.all(
                      color: const Color(0xFF6D79EC).withOpacity(0.2),
                      width: 1,
                    )
                  : null,
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: const Color(0xFF6D79EC).withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: isPrimary
              ? ResponsiveHelper.getNavBarIconSize(context)
              : ResponsiveHelper.getNavBarIconSize(context) * 0.83,
          color: isPrimary
              ? const Color(0xFF6D79EC)
              : isActive
                  ? const Color(0xFF6D79EC)
                  : const Color(0xFF6D79EC).withOpacity(0.4),
        ),
      ),
    );
  }
}
