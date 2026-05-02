import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/waste_data_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String _selectedFilter = 'Todos';
  final List<String> _filters = ['Todos', 'Plástico', 'Cartón', 'Vidrio', 'Metal', 'Electrónicos', 'Orgánico'];

  @override
  Widget build(BuildContext context) {
    final centers = WasteDataService.nearbycenters;
    final filtered = _selectedFilter == 'Todos'
        ? centers
        : centers.where((c) => c.acceptedMaterials.any((m) => m.contains(_selectedFilter))).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Puntos de reciclaje'),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded, color: AppColors.primaryGreen),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          _buildMapPlaceholder(),
          _buildFilterRow(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return _RecyclingCenterCard(center: filtered[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 220,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
      ),
      child: Stack(
        children: [
          // Mapa simulado con gradiente
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CustomPaint(
              size: const Size(double.infinity, 220),
              painter: _MapPainter(),
            ),
          ),
          // Pins de reciclaje
          Positioned(top: 60, left: 80,
            child: _MapPin(color: AppColors.primaryGreen)),
          Positioned(top: 100, left: 180,
            child: _MapPin(color: AppColors.darkGreen)),
          Positioned(top: 40, left: 240,
            child: _MapPin(color: AppColors.primaryGreen)),
          Positioned(top: 140, left: 120,
            child: _MapPin(color: AppColors.compostable)),
          Positioned(top: 80, left: 310,
            child: _MapPin(color: AppColors.primaryGreen)),
          // Overlay info
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: AppColors.primaryGreen, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '5 centros de reciclaje cerca de ti',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Ver mapa',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.darkGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.darkGreen : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.darkGreen : AppColors.divider,
                ),
              ),
              child: Text(
                filter,
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
}

class _MapPin extends StatelessWidget {
  final Color color;
  const _MapPin({required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Text('♻️', style: TextStyle(fontSize: 14)),
          ),
        ),
        Container(
          width: 2,
          height: 8,
          color: color,
        ),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Fondo del mapa simulado
    final bgPaint = Paint()..color = const Color(0xFFE8F4F0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = AppColors.white
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final roadPaint2 = Paint()
      ..color = AppColors.white.withValues(alpha: 0.7)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    // Calles horizontales
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.3), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.6), Offset(size.width, size.height * 0.6), roadPaint2);

    // Calles verticales
    canvas.drawLine(Offset(size.width * 0.25, 0), Offset(size.width * 0.25, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.6, 0), Offset(size.width * 0.6, size.height), roadPaint2);

    // Bloques de edificios simulados
    final blockPaint = Paint()..color = AppColors.primaryGreen.withValues(alpha: 0.12);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(30, 20, 120, 60), const Radius.circular(4)), blockPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(200, 20, 80, 50), const Radius.circular(4)), blockPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(30, 110, 90, 70), const Radius.circular(4)), blockPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(300, 100, 60, 80), const Radius.circular(4)), blockPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RecyclingCenterCard extends StatelessWidget {
  final dynamic center;
  const _RecyclingCenterCard({required this.center});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('♻️', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      center.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      center.address,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        center.rating.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${center.distanceKm} km',
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: (center.acceptedMaterials as List<String>).map((m) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  m,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.darkGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 12, color: AppColors.mediumGray),
              const SizedBox(width: 4),
              Text(
                center.schedule,
                style: const TextStyle(fontSize: 11, color: AppColors.mediumGray),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Cómo llegar',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
