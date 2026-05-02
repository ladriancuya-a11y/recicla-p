import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class WasteTypeChip extends StatelessWidget {
  final WasteType type;
  final bool small;

  const WasteTypeChip({super.key, required this.type, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: small ? 6 : 8,
            height: small ? 6 : 8,
            decoration: BoxDecoration(
              color: _dotColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: small ? 4 : 6),
          Text(
            _label,
            style: TextStyle(
              fontSize: small ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }

  Color get _bgColor {
    switch (type) {
      case WasteType.recyclable:
        return AppColors.lightGreen;
      case WasteType.compostable:
        return AppColors.lightBrown;
      case WasteType.waste:
        return AppColors.lightBlue;
    }
  }

  Color get _dotColor {
    switch (type) {
      case WasteType.recyclable:
        return AppColors.recyclable;
      case WasteType.compostable:
        return AppColors.compostable;
      case WasteType.waste:
        return AppColors.waste;
    }
  }

  Color get _textColor {
    switch (type) {
      case WasteType.recyclable:
        return AppColors.darkGreen;
      case WasteType.compostable:
        return const Color(0xFF5D3F37);
      case WasteType.waste:
        return AppColors.waste;
    }
  }

  String get _label {
    switch (type) {
      case WasteType.recyclable:
        return 'Reciclable';
      case WasteType.compostable:
        return 'Compostable';
      case WasteType.waste:
        return 'Desecho';
    }
  }
}

class MinimalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? borderLeftColor;

  const MinimalCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderLeftColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: borderLeftColor != null
                ? BorderSide(color: borderLeftColor!, width: 4)
                : const BorderSide(color: AppColors.divider, width: 1),
            top: const BorderSide(color: AppColors.divider, width: 1),
            right: const BorderSide(color: AppColors.divider, width: 1),
            bottom: const BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final String icon;
  final Color? accentColor;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.mediumGray,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (accentColor != null) ...[
            const SizedBox(height: 8),
            Container(
              height: 3,
              width: 32,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class WasteItemTile extends StatelessWidget {
  final WasteItem item;
  final VoidCallback? onTap;

  const WasteItemTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(color: _typeColor, width: 4),
            top: const BorderSide(color: AppColors.divider),
            right: const BorderSide(color: AppColors.divider),
            bottom: const BorderSide(color: AppColors.divider),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _typeBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  item.icon,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      WasteTypeChip(type: item.type, small: true),
                      const SizedBox(width: 6),
                      Text(
                        '${item.weight.toStringAsFixed(2)} kg',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+${item.pointsEarned} pts',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(item.date),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.mediumGray,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color get _typeColor {
    switch (item.type) {
      case WasteType.recyclable:
        return AppColors.recyclable;
      case WasteType.compostable:
        return AppColors.compostable;
      case WasteType.waste:
        return AppColors.waste;
    }
  }

  Color get _typeBgColor {
    switch (item.type) {
      case WasteType.recyclable:
        return AppColors.lightGreen;
      case WasteType.compostable:
        return AppColors.lightBrown;
      case WasteType.waste:
        return AppColors.lightBlue;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Ayer';
    return 'Hace $diff días';
  }
}

class GreenButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final String? icon;
  final bool outlined;
  final bool fullWidth;

  const GreenButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.outlined = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Text(icon!, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: outlined ? AppColors.darkGreen : AppColors.white,
          ),
        ),
      ],
    );

    if (outlined) {
      return OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          minimumSize: fullWidth ? const Size(double.infinity, 50) : null,
          side: const BorderSide(color: AppColors.darkGreen, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkGreen,
        minimumSize: fullWidth ? const Size(double.infinity, 50) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        elevation: 0,
      ),
      child: child,
    );
  }
}
