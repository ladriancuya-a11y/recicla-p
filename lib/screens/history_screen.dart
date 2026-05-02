import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recicla_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../models/models.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  WasteType? _filterType;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReciclaProvider>();
    final filtered = _filterType == null
        ? provider.history
        : provider.history.where((i) => i.type == _filterType).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historial'),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          if (provider.history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.mediumGray),
              onPressed: () => _confirmClear(context, provider),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryBar(provider),
          _buildFilterRow(),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                    itemCount: filtered.length,
                    itemBuilder: (_, index) => WasteItemTile(item: filtered[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(ReciclaProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            value: provider.totalItems.toString(),
            label: 'Total',
            color: AppColors.darkGreen,
          ),
          _Divider(),
          _SummaryItem(
            value: '${provider.totalWeightKg.toStringAsFixed(1)} kg',
            label: 'Peso total',
            color: AppColors.primaryGreen,
          ),
          _Divider(),
          _SummaryItem(
            value: '${provider.totalPoints}',
            label: 'Puntos',
            color: AppColors.compostable,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    final filters = <WasteType?>[null, WasteType.recyclable, WasteType.compostable, WasteType.waste];
    final labels = ['Todos', 'Reciclable', 'Compostable', 'Desecho'];
    final colors = [AppColors.darkGreen, AppColors.recyclable, AppColors.compostable, AppColors.waste];

    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, i) {
          final isSelected = _filterType == filters[i];
          return GestureDetector(
            onTap: () => setState(() => _filterType = filters[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? colors[i] : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? colors[i] : AppColors.divider,
                ),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.white : AppColors.darkGray,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('📋', style: TextStyle(fontSize: 42)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sin registros aún',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Empieza clasificando tu primer residuo',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, ReciclaProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Borrar historial',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.darkGreen),
        ),
        content: const Text(
          '¿Seguro que quieres borrar todo el historial y puntos? Esta acción no se puede deshacer.',
          style: TextStyle(color: AppColors.darkGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.mediumGray)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(ctx);
            },
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _SummaryItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.mediumGray,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.divider,
    );
  }
}
