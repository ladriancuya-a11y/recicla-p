import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../models/models.dart';
import '../services/waste_data_service.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _cycleStep = 0;

  final List<Map<String, dynamic>> _cycleSteps = [
    {
      'icon': '🗑️',
      'title': 'Separar en origen',
      'desc': 'Separa tus residuos en casa en tres categorías: reciclables, orgánicos y resto.',
      'color': AppColors.primaryGreen,
    },
    {
      'icon': '🚛',
      'title': 'Recolección',
      'desc': 'Los camiones especializados recogen cada tipo de residuo por separado.',
      'color': AppColors.darkGreen,
    },
    {
      'icon': '🏭',
      'title': 'Planta de reciclaje',
      'desc': 'Los materiales se clasifican, limpian y procesan para su transformación.',
      'color': AppColors.compostable,
    },
    {
      'icon': '⚙️',
      'title': 'Transformación',
      'desc': 'Cada material se convierte en materia prima para fabricar nuevos productos.',
      'color': AppColors.waste,
    },
    {
      'icon': '🛍️',
      'title': 'Nuevo producto',
      'desc': 'Los materiales reciclados se convierten en productos nuevos listos para usar.',
      'color': AppColors.primaryGreen,
    },
    {
      'icon': '♻️',
      'title': 'Economía circular',
      'desc': '¡El ciclo se repite! Cada vez reciclamos más y generamos menos residuos.',
      'color': AppColors.darkGreen,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Centro educativo'),
        backgroundColor: AppColors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGreen,
          indicatorWeight: 3,
          labelColor: AppColors.darkGreen,
          unselectedLabelColor: AppColors.mediumGray,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
          tabs: const [
            Tab(text: 'Ciclo'),
            Tab(text: 'Guías'),
            Tab(text: 'Tips'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCycleTab(),
          _buildGuidesTab(),
          _buildTipsTab(),
        ],
      ),
    );
  }

  Widget _buildCycleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ciclo del reciclaje',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Descubre cómo viajan tus residuos hasta convertirse en algo nuevo',
            style: TextStyle(fontSize: 13, color: AppColors.mediumGray),
          ),
          const SizedBox(height: 24),
          _buildCycleVisual(),
          const SizedBox(height: 24),
          _buildStepDetail(),
          const SizedBox(height: 20),
          _buildStepIndicators(),
          const SizedBox(height: 24),
          _buildCycleNavButtons(),
          const SizedBox(height: 30),
          _buildImpactSection(),
        ],
      ),
    );
  }

  Widget _buildCycleVisual() {
    final step = _cycleSteps[_cycleStep];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: Container(
        key: ValueKey(_cycleStep),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: (step['color'] as Color).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (step['color'] as Color).withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: (step['color'] as Color).withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: (step['color'] as Color).withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  step['icon'] as String,
                  style: const TextStyle(fontSize: 42),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Paso ${_cycleStep + 1} de ${_cycleSteps.length}',
              style: TextStyle(
                fontSize: 12,
                color: step['color'] as Color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              step['title'] as String,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGreen,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              step['desc'] as String,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.darkGray,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepDetail() {
    return Row(
      children: List.generate(_cycleSteps.length, (index) {
        final isActive = index == _cycleStep;
        final isPast = index < _cycleStep;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _cycleStep = index),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isActive ? 32 : 24,
                  height: isActive ? 32 : 24,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.darkGreen
                        : isPast
                            ? AppColors.primaryGreen
                            : AppColors.divider,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isActive
                        ? Text(
                            _cycleSteps[index]['icon'] as String,
                            style: const TextStyle(fontSize: 14),
                          )
                        : isPast
                            ? const Icon(Icons.check_rounded,
                                color: AppColors.white, size: 12)
                            : Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.mediumGray,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                  ),
                ),
                if (index < _cycleSteps.length - 1) ...[
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 2,
                    color: isPast ? AppColors.primaryGreen : AppColors.divider,
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStepIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_cycleSteps.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: index == _cycleStep ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: index == _cycleStep
                ? AppColors.primaryGreen
                : AppColors.divider,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildCycleNavButtons() {
    return Row(
      children: [
        if (_cycleStep > 0)
          Expanded(
            child: GreenButton(
              label: 'Anterior',
              outlined: true,
              onTap: () => setState(() => _cycleStep--),
            ),
          ),
        if (_cycleStep > 0) const SizedBox(width: 12),
        Expanded(
          child: GreenButton(
            label: _cycleStep < _cycleSteps.length - 1 ? 'Siguiente' : 'Reiniciar',
            onTap: () => setState(() {
              if (_cycleStep < _cycleSteps.length - 1) {
                _cycleStep++;
              } else {
                _cycleStep = 0;
              }
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildImpactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Impacto del reciclaje'),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.5,
          children: const [
            _ImpactCard(
              icon: '💧',
              value: '26.500 L',
              label: 'Agua ahorrada por tonelada de papel reciclado',
              color: Color(0xFF2196F3),
            ),
            _ImpactCard(
              icon: '⚡',
              value: '95%',
              label: 'Energía ahorrada reciclando aluminio',
              color: Colors.amber,
            ),
            _ImpactCard(
              icon: '🌳',
              value: '17 árboles',
              label: 'Salvados por cada tonelada de papel reciclado',
              color: AppColors.primaryGreen,
            ),
            _ImpactCard(
              icon: '🏭',
              value: '70%',
              label: 'Menos emisiones de CO₂ con vidrio reciclado',
              color: AppColors.darkGreen,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGuidesTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Guías de reciclaje',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.darkGreen,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Aprende cómo procesar cada tipo de residuo',
          style: TextStyle(fontSize: 13, color: AppColors.mediumGray),
        ),
        const SizedBox(height: 20),
        ...WasteDataService.catalog.map((item) => _GuideCard(item: item)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTipsTab() {
    final tips = [
      {
        'icon': '🛒',
        'title': 'Compra consciente',
        'desc': 'Elige productos con menos embalaje y materiales reciclables. Prefiere envases de vidrio o cartón.',
        'tag': 'Reducir',
      },
      {
        'icon': '🔄',
        'title': 'Reutiliza antes de tirar',
        'desc': 'Frascos, bolsas y cajas pueden tener segunda vida. Úsalos como organizadores, macetas o contenedores.',
        'tag': 'Reutilizar',
      },
      {
        'icon': '💧',
        'title': 'Lava los envases',
        'desc': 'Antes de reciclar, lava brevemente los envases para evitar contaminación del resto de materiales.',
        'tag': 'Reciclar',
      },
      {
        'icon': '🌿',
        'title': 'Compost en casa',
        'desc': 'Con un compostador casero puedes convertir tus restos de comida en abono para plantas en pocas semanas.',
        'tag': 'Compostar',
      },
      {
        'icon': '📱',
        'title': 'Electrónicos correctamente',
        'desc': 'Nunca tires móviles, pilas o cables a la basura normal. Llevarlos al punto limpio evita contaminación grave.',
        'tag': 'Especiales',
      },
      {
        'icon': '🏪',
        'title': 'Puntos de recogida',
        'desc': 'Muchos supermercados tienen puntos de recogida de pilas, plásticos y aceite. Aprovéchalos.',
        'tag': 'Red',
      },
      {
        'icon': '👨‍👩‍👧',
        'title': 'Involucra a tu familia',
        'desc': 'El reciclaje en casa es más efectivo cuando todos participan. Crea un sistema simple con contenedores de colores.',
        'tag': 'Hábitos',
      },
      {
        'icon': '📊',
        'title': 'Mide tu impacto',
        'desc': 'Registra cuánto reciclas cada semana. Verás cómo pequeñas acciones generan un impacto enorme con el tiempo.',
        'tag': 'Motivación',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Consejos eco',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.darkGreen,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Pequeñas acciones, gran impacto',
          style: TextStyle(fontSize: 13, color: AppColors.mediumGray),
        ),
        const SizedBox(height: 20),
        ...tips.asMap().entries.map((e) => _TipCard(
              tip: e.value,
              index: e.key,
            )),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _ImpactCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;

  const _ImpactCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.darkGray,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _GuideCard extends StatefulWidget {
  final WasteCatalogItem item;
  const _GuideCard({required this.item});

  @override
  State<_GuideCard> createState() => _GuideCardState();
}

class _GuideCardState extends State<_GuideCard> {
  bool _expanded = false;

  Color get _typeColor {
    switch (widget.item.type) {
      case WasteType.recyclable:
        return AppColors.recyclable;
      case WasteType.compostable:
        return AppColors.compostable;
      case WasteType.waste:
        return AppColors.waste;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: _typeColor, width: 4),
          top: const BorderSide(color: AppColors.divider),
          right: const BorderSide(color: AppColors.divider),
          bottom: const BorderSide(color: AppColors.divider),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(widget.item.icon, style: const TextStyle(fontSize: 22)),
              ),
            ),
            title: Text(
              widget.item.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGreen,
              ),
            ),
            subtitle: Text(
              widget.item.examples.take(3).join(', '),
              style: const TextStyle(fontSize: 11, color: AppColors.mediumGray),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                WasteTypeChip(type: widget.item.type, small: true),
                const SizedBox(width: 6),
                Icon(
                  _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: AppColors.mediumGray,
                ),
              ],
            ),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded) ...[
            const Divider(height: 1, color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.darkGray,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.item.type == WasteType.recyclable
                        ? '♻️ Cómo reciclar'
                        : widget.item.type == WasteType.compostable
                            ? '🌱 Cómo compostar'
                            : '🗑️ Cómo desechar',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _typeColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.item.howToProcess,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.darkGray,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.item.tips,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.darkGreen,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        '⭐',
                        style: TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '+${widget.item.pointsPerKg} puntos por kg',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final Map<String, String> tip;
  final int index;

  const _TipCard({required this.tip, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(tip['icon']!, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tip['title']!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.darkGreen.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tip['tag']!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.darkGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  tip['desc']!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.darkGray,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
