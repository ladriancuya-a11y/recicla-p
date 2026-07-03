import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recicla_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/recicla_logo.dart';
import '../widgets/common_widgets.dart';
import '../models/models.dart';
import '../widgets/smart_bin_card.dart';
import 'education_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReciclaProvider>().loadDemoData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReciclaProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: AppColors.divider,
        title: const ReciclaLogo(size: 32, showText: true),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.darkGreen),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(provider),
              const SizedBox(height: 20),
              _buildHeroCard(provider),
              const SizedBox(height: 24),
              // ── Tarjeta del Tacho Inteligente BLE ──────────────────
              const SmartBinCard(),
              const SizedBox(height: 24),
              // ────────────────────────────────────────────────────────
              _buildStatsRow(provider),
              const SizedBox(height: 24),
              _buildQuickActions(context, provider),
              const SizedBox(height: 24),
              _buildCategoriesSection(context),
              const SizedBox(height: 24),
              _buildRecentHistory(context, provider),
              const SizedBox(height: 20),
              _buildEduBanner(context),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(ReciclaProvider provider) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Buenos días';
    } else if (hour < 18) {
      greeting = 'Buenas tardes';
    } else {
      greeting = 'Buenas noches';
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting,',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.mediumGray,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                provider.userName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                provider.userLevelIcon,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 6),
              Text(
                provider.userLevel,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.darkGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(ReciclaProvider provider) {
    final progress = provider.levelProgress / 100.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tus puntos eco',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${provider.totalPoints}',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                      height: 1.0,
                    ),
                  ),
                  const Text(
                    'puntos',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    provider.userLevelIcon,
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                provider.userLevel,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${provider.nextLevelPoints} pts',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
              const SizedBox(width: 4),
              Text(
                '${provider.streakDays} días de racha',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ReciclaProvider provider) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            value: '${provider.totalWeightKg.toStringAsFixed(1)} kg',
            label: 'Total reciclado',
            icon: '♻️',
            accentColor: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(width: 12),
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
            value: '${provider.countByType[WasteType.recyclable] ?? 0}',
            label: 'Reciclables',
            icon: '🌱',
            accentColor: AppColors.recyclable,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, ReciclaProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Acciones rápidas'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: '📷',
                label: 'Clasificar residuo',
                subtitle: 'Escanea o selecciona',
                color: AppColors.darkGreen,
                onTap: () => provider.setSelectedTab(1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: '📍',
                label: 'Puntos cercanos',
                subtitle: 'Ver en el mapa',
                color: AppColors.primaryGreen,
                light: true,
                onTap: () => provider.setSelectedTab(2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Categorías',
          actionLabel: 'Ver todo',
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EducationScreen()),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _CategoryCard(
                icon: '♻️',
                label: 'Reciclable',
                count: '4 tipos',
                color: AppColors.recyclable,
                bgColor: AppColors.lightGreen,
                type: WasteType.recyclable,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CategoryCard(
                icon: '🌱',
                label: 'Compostable',
                count: '2 tipos',
                color: AppColors.compostable,
                bgColor: AppColors.lightBrown,
                type: WasteType.compostable,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CategoryCard(
                icon: '🗑️',
                label: 'Desecho',
                count: '3 tipos',
                color: AppColors.waste,
                bgColor: AppColors.lightBlue,
                type: WasteType.waste,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentHistory(BuildContext context, ReciclaProvider provider) {
    if (provider.recentHistory.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Actividad reciente',
          actionLabel: 'Ver todo',
          onAction: () => provider.setSelectedTab(3),
        ),
        const SizedBox(height: 12),
        ...provider.recentHistory
            .take(3)
            .map((item) => WasteItemTile(item: item)),
      ],
    );
  }

  Widget _buildEduBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EducationScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.lightGreen,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text('🎓', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aprende a reciclar mejor',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Guía paso a paso del ciclo de reciclaje',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.darkGreen),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool light;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: light ? AppColors.lightGreen : color,
          borderRadius: BorderRadius.circular(16),
          border: light ? Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: light ? AppColors.darkGreen : AppColors.white,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: light
                    ? AppColors.mediumGray
                    : AppColors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String icon;
  final String label;
  final String count;
  final Color color;
  final Color bgColor;
  final WasteType type;

  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.bgColor,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color == AppColors.recyclable ? AppColors.darkGreen : color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            count,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}
