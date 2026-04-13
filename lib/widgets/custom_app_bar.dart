import 'package:flutter/material.dart';
import 'package:sungoods/providers/notification_provider.dart';
import 'package:sungoods/utils/colors.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController? searchController;
  final VoidCallback? onSearch;
  final String? title;
  final bool showBackButton; // New parameter
  final bool showDrawerButton; // New parameter
  final VoidCallback? onBackButtonPressed; // New parameter
  final bool showSearchBar; // New parameter

  const CustomAppBar({
    super.key,
    this.searchController, // No longer required
    this.onSearch, // No longer required
    this.title,
    this.showBackButton = false, // Default to false
    this.showDrawerButton = false, // Default to false
    this.onBackButtonPressed,
    this.showSearchBar = true, // Default to true
  });

  @override
  Size get preferredSize => showSearchBar ? const Size.fromHeight(kToolbarHeight * 2) : const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return PreferredSize(
      preferredSize: preferredSize,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              // First row: Back button (optional), Title/Logo, Globe, Notification
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row( // Group back button and title/logo together
                    children: [
                      if (showBackButton) // Conditionally display back button
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: onBackButtonPressed ?? () => Navigator.of(context).pop(),
                        )
                      else if (showDrawerButton)
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.black),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        )
                      else
                        const SizedBox(width: 16.0), // Padding if no back button or drawer button
                      Padding(
                        padding: const EdgeInsets.only(left: 0.0), // No extra left padding here
                        child: SizedBox(
                          height: 32.0,
                          child: title != null
                              ? Text( // No Align needed, it's naturally left within the Row
                                  title!,
                                  style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                )
                              : Image.asset(
                                  'assets/images/sungoods_logo.png',
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
                    ],
                  ),
                  Padding( // This is the right-aligned action icon group
                    padding: const EdgeInsets.only(right: 16.0), // 16.0 right padding
                    child: Row( // Group icons together
                      children: [
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications, color: Colors.black),
                              onPressed: () {
                                Navigator.pushNamed(context, '/notifications');
                              },
                              iconSize: 28.0, // Consistent icon size
                            ),
                            if (notificationProvider.unreadCount > 0)
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
                                    '${notificationProvider.unreadCount}',
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
                      ],
                    ),
                  ),
                ],
              ),
              if (showSearchBar) // Conditionally render search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: appColorsPrimary),
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        hintStyle: const TextStyle(height: 1.0),
                        isDense: true,
                        contentPadding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
                        border: InputBorder.none,
                        suffixIcon: Container(
                          decoration: const BoxDecoration(
                            color: appColorsPrimary,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8.0),
                              bottomRight: Radius.circular(8.0),
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: onSearch,
                            iconSize: 20.0,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                        prefixIcon: searchController?.text.isNotEmpty == true // Null check
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: appColorsPrimary),
                                onPressed: () {
                                  searchController?.clear(); // Null check
                                  onSearch?.call(); // Null check
                                },
                                iconSize: 20.0,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        onSearch?.call(); // Null check
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
