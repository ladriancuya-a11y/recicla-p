import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recicla_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../models/models.dart';
import '../services/waste_data_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  WasteCatalogItem? _selectedItem;
  double _weight = 0.1;
  bool _showResult = false;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _weightController = TextEditingController(text: '0.10');
  List<WasteCatalogItem> _searchResults = [];
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearch = false;
      });
      return;
    }
    setState(() {
      _showSearch = true;
      _searchResults = WasteDataService.catalog
          .where((item) =>
              item.name.toLowerCase().contains(query.toLowerCase()) ||
              item.examples.any((e) => e.toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
  }

  void _selectItem(WasteCatalogItem item) {
    setState(() {
      _selectedItem = item;
      _showSearch = false;
      _showResult = false;
      _searchController.text = item.name;
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _classify() async {
    if (_selectedItem == null) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _isLoading = false;
      _showResult = true;
    });
  }

  Future<void> _registerWaste() async {
    if (_selectedItem == null) return;
    final item = _selectedItem!;
    final points = WasteDataService.calculatePoints(item.type, _weight);
    final wasteItem = WasteItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: item.name,
      type: item.type,
      category: item.category,
      description: item.description,
      howToRecycle: item.howToProcess,
      icon: item.icon,
      weight: _weight,
      date: DateTime.now(),
      pointsEarned: points,
    );
    await context.read<ReciclaProvider>().addWasteItem(wasteItem);
    if (mounted) {
      _showSuccessDialog(points);
    }
  }

  void _showSuccessDialog(int points) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('✅', style: TextStyle(fontSize: 38)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Residuo registrado!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ganaste +$points puntos eco',
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            GreenButton(
              label: 'Continuar',
              fullWidth: true,
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedItem = null;
                  _showResult = false;
                  _searchController.clear();
                  _weight = 0.1;
                  _weightController.text = '0.10';
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Clasificar residuo'),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchSection(),
            if (_showSearch && _searchResults.isNotEmpty) _buildSearchResults(),
            const SizedBox(height: 20),
            if (_selectedItem == null) _buildCatalogGrid(),
            if (_selectedItem != null && !_showResult) _buildSelectedItem(),
            if (_showResult && _selectedItem != null) _buildResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Buscar residuo',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.darkGreen,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Escribe el nombre o selecciona una categoría',
          style: TextStyle(fontSize: 13, color: AppColors.mediumGray),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _searchController,
          onChanged: _onSearch,
          decoration: InputDecoration(
            hintText: 'Ej: botella PET, cartón, cáscara...',
            hintStyle: const TextStyle(color: AppColors.mediumGray, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryGreen),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, color: AppColors.mediumGray),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _showSearch = false;
                        _searchResults = [];
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: _searchResults.map((item) {
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _typeColor(item.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(item.icon, style: const TextStyle(fontSize: 20)),
              ),
            ),
            title: Text(
              item.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGreen,
              ),
            ),
            subtitle: Text(
              item.examples.take(2).join(', '),
              style: const TextStyle(fontSize: 12, color: AppColors.mediumGray),
            ),
            trailing: WasteTypeChip(type: item.type, small: true),
            onTap: () => _selectItem(item),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCatalogGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Catálogo de residuos'),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemCount: WasteDataService.catalog.length,
          itemBuilder: (context, index) {
            final item = WasteDataService.catalog[index];
            return GestureDetector(
              onTap: () => _selectItem(item),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item.icon, style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 6),
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGreen,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 3,
                      width: 24,
                      decoration: BoxDecoration(
                        color: _typeColor(item.type),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSelectedItem() {
    final item = _selectedItem!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MinimalCard(
          borderLeftColor: _typeColor(item.type),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _typeColor(item.type).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(item.icon, style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        WasteTypeChip(type: item.type),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.mediumGray),
                    onPressed: () => setState(() {
                      _selectedItem = null;
                      _searchController.clear();
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 12),
              const Text(
                'Peso del residuo (kg)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppColors.primaryGreen,
                        inactiveTrackColor: AppColors.divider,
                        thumbColor: AppColors.darkGreen,
                        overlayColor: AppColors.primaryGreen.withValues(alpha: 0.2),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: _weight,
                        min: 0.01,
                        max: 10.0,
                        divisions: 1000,
                        onChanged: (v) {
                          setState(() {
                            _weight = double.parse(v.toStringAsFixed(2));
                            _weightController.text = _weight.toStringAsFixed(2);
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGreen,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        suffixText: 'kg',
                        suffixStyle: const TextStyle(
                          color: AppColors.mediumGray,
                          fontSize: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.divider),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.divider),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primaryGreen),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        filled: true,
                        fillColor: AppColors.lightGray,
                      ),
                      onChanged: (v) {
                        final val = double.tryParse(v);
                        if (val != null && val >= 0.01 && val <= 10) {
                          setState(() => _weight = val);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Puntos estimados: +${WasteDataService.calculatePoints(item.type, _weight)} pts',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GreenButton(
          label: _isLoading ? 'Clasificando...' : 'Clasificar residuo',
          icon: '🔍',
          fullWidth: true,
          onTap: _isLoading ? () {} : _classify,
        ),
      ],
    );
  }

  Widget _buildResult() {
    final item = _selectedItem!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _typeColor(item.type).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _typeColor(item.type).withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(item.icon, style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        WasteTypeChip(type: item.type),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _InfoRow(label: 'Peso registrado', value: '${_weight.toStringAsFixed(2)} kg'),
              _InfoRow(
                label: 'Puntos a ganar',
                value: '+${WasteDataService.calculatePoints(item.type, _weight)} pts',
                valueColor: AppColors.primaryGreen,
              ),
              const Divider(color: AppColors.divider, height: 24),
              _buildInstructions(item),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GreenButton(
                label: 'Modificar',
                outlined: true,
                onTap: () => setState(() => _showResult = false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GreenButton(
                label: 'Registrar',
                icon: '✅',
                onTap: _registerWaste,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInstructions(WasteCatalogItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _instructionTitle(item.type),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _typeColor(item.type),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.howToProcess,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.darkGray,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.tips,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.darkGray,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _instructionTitle(WasteType type) {
    switch (type) {
      case WasteType.recyclable:
        return '♻️ Cómo reciclar';
      case WasteType.compostable:
        return '🌱 Cómo compostar';
      case WasteType.waste:
        return '🗑️ Cómo desechar';
    }
  }

  Color _typeColor(WasteType type) {
    switch (type) {
      case WasteType.recyclable:
        return AppColors.recyclable;
      case WasteType.compostable:
        return AppColors.compostable;
      case WasteType.waste:
        return AppColors.waste;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.mediumGray),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.darkGreen,
            ),
          ),
        ],
      ),
    );
  }
}
