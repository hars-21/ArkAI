import 'package:flutter/material.dart';
import 'package:arkai/core/theme/app_theme.dart';

class AppAddressBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final bool isLoading;
  final bool showNavigation;
  final VoidCallback? onBack;
  final VoidCallback? onForward;
  final VoidCallback? onRefresh;
  final VoidCallback? onClear;
  final Function(String)? onSubmit;
  final String displayUrl;

  const AppAddressBar({
    super.key,
    this.controller,
    this.hintText = 'Search or enter website name',
    this.isLoading = false,
    this.showNavigation = false,
    this.onBack,
    this.onForward,
    this.onRefresh,
    this.onClear,
    this.onSubmit,
    this.displayUrl = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppTheme.primaryBackground,
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          if (showNavigation) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              color: Colors.white,
              onPressed: onBack,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 20),
              color: Colors.white,
              onPressed: onForward,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              color: Colors.white.withValues(alpha: 0.3),
              onPressed: null,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 20),
              color: Colors.white.withValues(alpha: 0.3),
              onPressed: null,
            ),
          ],
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(
                    displayUrl.isEmpty ? Icons.search : Icons.lock_outline,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: controller != null
                        ? TextField(
                            controller: controller,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              hintText: hintText,
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: onSubmit,
                            textInputAction: TextInputAction.go,
                            keyboardType: TextInputType.url,
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              displayUrl.isEmpty
                                  ? 'arkai://browser'
                                  : displayUrl,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(right: 12.0),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.accentPurple,
                        ),
                      ),
                    )
                  else if (controller != null)
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 16),
                      color: Colors.white.withValues(alpha: 0.5),
                      onPressed: onRefresh,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.only(right: 12),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.close),
            color: Colors.white,
            onPressed: onClear,
          ),
        ],
      ),
    );
  }
}
