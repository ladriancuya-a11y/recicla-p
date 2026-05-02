import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recicla_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../models/models.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReciclaProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mi perfil'),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.darkGreen),
            onPressed: () => _showEditName(context, provider),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(provider),
            const SizedBox(height: 24),
            _buildLevelCard(provider),
            const SizedBox(height: 24),
            _buildStatsGrid(provider),
            const SizedBox(height: 24),
            _buildTypeBreakdown(provider),
            const SizedBox(height: 24),
            _buildBadges(provider),
            const SizedBox(height: 24),
            _buildAppInfo(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ReciclaProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                provider.userLevelIcon,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    provider.userLevel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${provider.streakDays} días de racha',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(ReciclaProvider provider) {
    final progress = provider.levelProgress / 100.0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progreso de nivel',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
              Text(
                '${provider.totalPoints} / ${provider.nextLevelPoints} pts',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryGreen,
              ),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _LevelBadge(
                label: provider.userLevel,
                icon: provider.userLevelIcon,
                isCurrent: true,
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.mediumGray,
                size: 16,
              ),
              _LevelBadge(
                label: _nextLevel(provider.totalPoints),
                icon: _nextLevelIcon(provider.totalPoints),
                isCurrent: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _nextLevel(int points) {
    if (points < 100) return 'Aprendiz Verde';
    if (points < 300) return 'Reciclador';
    if (points < 600) return 'Eco Guardián';
    if (points < 1000) return 'Maestro Verde';
    return 'Maestro Verde';
  }

  String _nextLevelIcon(int points) {
    if (points < 100) return '🌿';
    if (points < 300) return '♻️';
    if (points < 600) return '🌳';
    return '🏆';
  }

  Widget _buildStatsGrid(ReciclaProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Mis estadísticas'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                value: '${provider.totalPoints}',
                label: 'Puntos totales',
                icon: '⭐',
                accentColor: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                value: '${provider.totalWeightKg.toStringAsFixed(1)} kg',
                label: 'Total reciclado',
                icon: '♻️',
                accentColor: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                value: '${provider.totalItems}',
                label: 'Registros',
                icon: '📋',
                accentColor: AppColors.darkGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                value: '${provider.streakDays}',
                label: 'Días racha',
                icon: '🔥',
                accentColor: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeBreakdown(ReciclaProvider provider) {
    final weightByType = provider.weightByType;
    final total = weightByType.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    final types = [
      {
        'type': WasteType.recyclable,
        'label': 'Reciclable',
        'icon': '♻️',
        'color': AppColors.recyclable,
      },
      {
        'type': WasteType.compostable,
        'label': 'Compostable',
        'icon': '🌱',
        'color': AppColors.compostable,
      },
      {
        'type': WasteType.waste,
        'label': 'Desecho',
        'icon': '🗑️',
        'color': AppColors.waste,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribución por tipo',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 16),
          ...types.map((t) {
            final weight =
                weightByType[t['type'] as WasteType] ?? 0.0;
            final pct = total > 0 ? weight / total : 0.0;
            return _TypeBar(
              icon: t['icon'] as String,
              label: t['label'] as String,
              weight: weight,
              percent: pct,
              color: t['color'] as Color,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBadges(ReciclaProvider provider) {
    final badges = _getBadges(provider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Logros y medallas'),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.9,
          children: badges
              .map((b) => _BadgeCard(badge: b))
              .toList(),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getBadges(ReciclaProvider provider) {
    return [
      {
        'icon': '🌱',
        'label': 'Primer paso',
        'desc': 'Registra tu 1er residuo',
        'earned': provider.totalItems >= 1,
      },
      {
        'icon': '♻️',
        'label': 'Reciclador',
        'desc': '5 residuos registrados',
        'earned': provider.totalItems >= 5,
      },
      {
        'icon': '🌿',
        'label': 'Verde activo',
        'desc': '100 puntos acumulados',
        'earned': provider.totalPoints >= 100,
      },
      {
        'icon': '🔥',
        'label': 'Racha',
        'desc': '3 días consecutivos',
        'earned': provider.streakDays >= 3,
      },
      {
        'icon': '⚖️',
        'label': 'Pesador',
        'desc': 'Registra 1 kg',
        'earned': provider.totalWeightKg >= 1.0,
      },
      {
        'icon': '🏆',
        'label': 'Eco Maestro',
        'desc': '500 puntos acumulados',
        'earned': provider.totalPoints >= 500,
      },
    ];
  }

  Widget _buildAppInfo() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CustomPaint(
                size: const Size(36, 36),
                painter: _MiniLogoPainter(),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RECICLA-P',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'Versión 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 10),
          const Text(
            'Juntos construimos un mundo más limpio y sostenible. '
            'Cada residuo que clasificas correctamente hace la diferencia.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.mediumGray,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showEditName(BuildContext context, ReciclaProvider provider) {
    final ctrl = TextEditingController(text: provider.userName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
              alignment: Alignment.center,
            ),
            const Text(
              'Editar nombre',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Tu nombre',
                prefixIcon: Icon(Icons.person_outline_rounded,
                    color: AppColors.primaryGreen),
              ),
            ),
            const SizedBox(height: 16),
            GreenButton(
              label: 'Guardar',
              fullWidth: true,
              onTap: () {
                if (ctrl.text.trim().isNotEmpty) {
                  provider.setUserName(ctrl.text.trim());
                }
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final String label;
  final String icon;
  final bool isCurrent;

  const _LevelBadge({
    required this.label,
    required this.icon,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.lightGreen : AppColors.lightGray,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCurrent
              ? AppColors.primaryGreen.withValues(alpha: 0.4)
              : AppColors.divider,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color:
                  isCurrent ? AppColors.darkGreen : AppColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeBar extends StatelessWidget {
  final String icon;
  final String label;
  final double weight;
  final double percent;
  final Color color;

  const _TypeBar({
    required this.icon,
    required this.label,
    required this.weight,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),
              Text(
                '${weight.toStringAsFixed(2)} kg',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.mediumGray,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 36,
                child: Text(
                  '${(percent * 100).round()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final Map<String, dynamic> badge;

  const _BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    final earned = badge['earned'] as bool;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: earned ? AppColors.lightGreen : AppColors.lightGray,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: earned
              ? AppColors.primaryGreen.withValues(alpha: 0.3)
              : AppColors.divider,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Text(
                badge['icon'] as String,
                style: TextStyle(
                  fontSize: 28,
                  color: earned ? null : Colors.transparent,
                  shadows: earned
                      ? null
                      : [const Shadow(color: Colors.grey, blurRadius: 0)],
                ),
              ),
              if (!earned)
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.mediumGray,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    size: 9,
                    color: AppColors.white,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            badge['label'] as String,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: earned ? AppColors.darkGreen : AppColors.mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            badge['desc'] as String,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.mediumGray,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MiniLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      bgPaint,
    );
    final paint = Paint()
      ..color = AppColors.darkGreen
      ..style = PaintingStyle.fill;
    final s = size.width;
    final bw = s * 0.10;
    final bh = s * 0.42;
    final sy = s * 0.18;
    final r = Radius.circular(bw / 2);
    for (int i = 0; i < 3; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(s * (0.18 + i * 0.16), sy, bw, bh),
          r,
        ),
        paint,
      );
    }
    final path = Path();
    path.moveTo(s * 0.66, s * 0.32);
    path.lineTo(s * 0.82, s * 0.50);
    path.lineTo(s * 0.66, s * 0.68);
    path.close();
    canvas.drawPath(path, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.18, s * 0.58, s * 0.42, bw),
        r,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
