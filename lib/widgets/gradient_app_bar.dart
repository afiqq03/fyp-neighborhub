import 'package:flutter/material.dart';
import 'package:rukuntetangga/widgets/constants.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? titleColor;
  final Widget? leading;
  final double elevation;
  final bool showGreeting;
  final String? username;
  final int? notificationCount;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.titleColor = Colors.white,
    this.leading,
    this.elevation = 0,
    this.showGreeting = false,
    this.username,
    this.notificationCount,
    this.onSearchTap,
    this.onNotificationTap,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kPrimaryColor,
            kPrimaryColor.withAlpha(26),
            const Color.fromARGB(255, 0, 0, 0),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: AppBar(
        title: showGreeting && username != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_getGreeting()}, ${username!.split(' ').first}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            : Text(
                title,
                style: TextStyle(color: titleColor),
              ),
        backgroundColor: Colors.transparent,
        elevation: elevation,
        centerTitle: centerTitle,
        leading: leading,
        actions: [
          if (onSearchTap != null)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: onSearchTap,
              tooltip: 'Search',
            ),
          if (onNotificationTap != null)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                  ),
                  onPressed: onNotificationTap,
                  tooltip: 'Notifications',
                ),
                if (notificationCount != null && notificationCount! > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        notificationCount! <= 9
                            ? '$notificationCount'
                            : '9+',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          if (actions != null) ...actions!,
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 