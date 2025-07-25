import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
// import 'package:provider/provider.dart';
// import '../services/water_tracking_service.dart';
// import '../services/auth_service.dart';
import '../models/drink_entry.dart';
import '../theme/app_theme.dart';
import '../widgets/app_components.dart';
import '../widgets/achievement_widgets.dart' as achievement_widgets;
import '../services/water_tracking_service.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final double _dailyGoal = 2500; // ml
  double _currentIntake = 0;
  List<DrinkEntry> _todayEntries = [];
  bool _loadingToday = true;
  final WaterTrackingService _waterService = WaterTrackingService();
  
  // Theme and context awareness
  late Color _currentThemeColor;
  List<int> _contextualVolumes = [250, 500, 750, 1000];
  String? _lastAddedId;
  bool _showUndoButton = false;
  DrinkEntry? _lastEntry;

  // Animation controllers
  late AnimationController _progressAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _entryAnimationController;
  late AnimationController _fabAnimationController;
  late AnimationController _liquidAnimationController;
  late AnimationController _celebrationController;
  late AnimationController _undoButtonController;
  late AnimationController _insightController;

  // Animations
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _entrySlideAnimation;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _liquidWaveAnimation;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _undoSlideAnimation;
  late Animation<double> _insightFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadTodayData();
    _updateThemeColor();
    _generateContextualVolumes();
  }

  void _initAnimations() {
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _entryAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _liquidAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _undoButtonController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _insightController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressAnimationController, curve: Curves.easeOutCubic),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseAnimationController, curve: Curves.easeInOut),
    );
    _entrySlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryAnimationController, curve: Curves.elasticOut),
    );
    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.elasticOut),
    );
    _liquidWaveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _liquidAnimationController, curve: Curves.linear),
    );
    _celebrationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );
    _undoSlideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _undoButtonController, curve: Curves.easeOutCubic),
    );
    _insightFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _insightController, curve: Curves.easeOut),
    );

    _pulseAnimationController.repeat(reverse: true);
    _liquidAnimationController.repeat();
    _fabAnimationController.forward();
    _insightController.forward();
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _pulseAnimationController.dispose();
    _entryAnimationController.dispose();
    _fabAnimationController.dispose();
    _liquidAnimationController.dispose();
    _celebrationController.dispose();
    _undoButtonController.dispose();
    _insightController.dispose();
    super.dispose();
  }

  void _updateThemeColor() {
    final hour = DateTime.now().hour;
    if (hour < 6) {
      _currentThemeColor = const Color(0xFF1A237E); // Night blue
    } else if (hour < 12) {
      _currentThemeColor = const Color(0xFF0D47A1); // Morning blue
    } else if (hour < 18) {
      _currentThemeColor = const Color(0xFF01579B); // Afternoon blue
    } else {
      _currentThemeColor = const Color(0xFF3F51B5); // Evening purple-blue
    }
  }

  void _generateContextualVolumes() {
    final hour = DateTime.now().hour;
    if (hour < 8) {
      _contextualVolumes = [200, 300, 500, 250]; // Morning smaller amounts
    } else if (hour < 12) {
      _contextualVolumes = [250, 500, 750, 300]; // Mid-morning
    } else if (hour < 18) {
      _contextualVolumes = [300, 500, 750, 1000]; // Afternoon larger amounts
    } else {
      _contextualVolumes = [200, 400, 600, 500]; // Evening moderate amounts
    }
  }

  Future<void> _loadTodayData() async {
    setState(() => _loadingToday = true);
    try {
      final today = DateTime.now();
      final entries = await _waterService.getDrinkEntriesForDate(today);
      print('Loaded ${entries.length} entries for today');
      double total = 0.0;
      for (final entry in entries) {
        print('Entry: ${entry.volumeMl}ml at ${entry.timestamp}');
        total += entry.effectiveVolumeMl;
      }
      final prevIntake = _currentIntake;
      setState(() {
        _todayEntries = entries;
        _currentIntake = total;
      });
      print('Current intake after load: $_currentIntake');
      _progressAnimationController.forward();
      
      // Trigger celebration if goal is reached now but wasn't before
      if (_currentIntake >= _dailyGoal && prevIntake < _dailyGoal) {
        _showGoalCelebration();
      }
    } catch (e, st) {
      print('Error in _loadTodayData: $e\n$st');
    } finally {
      setState(() => _loadingToday = false);
    }
  }

  Future<void> _resetToday() async {
    final today = DateTime.now();
    await _waterService.deleteDrinkEntriesForDate(today);
    await _loadTodayData();
    _showCustomSnackBar('Counter reset! 🔄', Icons.refresh, Colors.orange);
  }

  void _addWater(int volume, {String drinkType = 'water'}) async {
    // Enhanced haptic feedback
    HapticFeedback.mediumImpact();
    
    final entry = DrinkEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      volumeMl: volume,
      drinkType: drinkType,
      effectiveVolumeMl: volume.toDouble(),
      timestamp: DateTime.now(),
    );
    
    await _waterService.addDrinkEntry(entry);
    
    // Store for undo functionality
    _lastEntry = entry;
    _lastAddedId = entry.id;
    setState(() => _showUndoButton = true);
    _undoButtonController.forward();
    
    // Hide undo button after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _lastAddedId == entry.id) {
        _hideUndoButton();
      }
    });
    
    await _loadTodayData();
    
    // Trigger animations
    _entryAnimationController.reset();
    _entryAnimationController.forward();
    _progressAnimationController.reset();
    _progressAnimationController.forward();
    
    // Water drop animation effect
    _showWaterDropEffect();
    
    _showCustomSnackBar('Added ${volume}ml of $drinkType! 💧', Icons.water_drop, _currentThemeColor);
  }

  void _undoLastEntry() async {
    if (_lastEntry != null) {
      await _waterService.deleteDrinkEntry(_lastEntry!.id);
      await _loadTodayData();
      _hideUndoButton();
      _showCustomSnackBar('Undid last entry', Icons.undo, Colors.grey);
      HapticFeedback.lightImpact();
    }
  }

  void _hideUndoButton() {
    setState(() => _showUndoButton = false);
    _undoButtonController.reverse();
  }

  void _showWaterDropEffect() {
    // This would trigger particle effects in a real implementation
    _celebrationController.reset();
    _celebrationController.forward();
  }

  void _showGoalCelebration() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _EnhancedCelebrationDialog(onClose: () => Navigator.pop(context)),
    );
  }

  void _showCustomSnackBar(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSmartVolumeDialog() {
    final controller = TextEditingController();
    final drinkTypes = ['water', 'coffee', 'tea', 'juice', 'sports drink'];
    String selectedType = 'water';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_currentThemeColor.withOpacity(0.2), _currentThemeColor.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.water_drop, color: _currentThemeColor),
              ),
              const SizedBox(width: 12),
              const Flexible(child: Text('Add Custom Drink')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Volume (ml)',
                  suffixText: 'ml',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _currentThemeColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(
                  labelText: 'Drink Type',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: drinkTypes.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.toUpperCase()),
                )).toList(),
                onChanged: (value) => setDialogState(() => selectedType = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentThemeColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final volume = int.tryParse(controller.text);
                if (volume != null && volume > 0) {
                  _addWater(volume, drinkType: selectedType);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteEntry(DrinkEntry entry) async {
    await _waterService.deleteDrinkEntry(entry.id);
    await _loadTodayData();
    _showCustomSnackBar('Entry deleted', Icons.delete, Colors.red);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildEnhancedAppBar(),
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: [
              _buildTrackingTab(),
              _buildProgressTab(),
              _buildHistoryTab(),
              _buildAchievementsTab(),
            ],
          ),
          // Undo button overlay
          if (_showUndoButton) _buildUndoButton(),
        ],
      ),
      bottomNavigationBar: _buildEnhancedBottomNav(),
      floatingActionButton: _selectedIndex == 0 
        ? ScaleTransition(
            scale: _fabScaleAnimation,
            child: FloatingActionButton.extended(
              onPressed: _showSmartVolumeDialog,
              backgroundColor: _currentThemeColor,
              elevation: 8,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Custom', style: TextStyle(color: Colors.white)),
            ),
          )
        : null,
    );
  }

  PreferredSizeWidget _buildEnhancedAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _currentThemeColor.withOpacity(0.1),
              Colors.transparent,
            ],
          ),
        ),
      ),
      title: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [_currentThemeColor, _currentThemeColor.withOpacity(0.7)],
        ).createShader(bounds),
        child: const Text(
          'Watter',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _currentThemeColor.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.settings_outlined, color: _currentThemeColor),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
            HapticFeedback.selectionClick();
          },
          selectedItemColor: _currentThemeColor,
          unselectedItemColor: Colors.grey[400],
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.water_drop_outlined),
              activeIcon: Icon(Icons.water_drop),
              label: 'Track',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              activeIcon: Icon(Icons.emoji_events),
              label: 'Awards',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUndoButton() {
    return Positioned(
      top: 100,
      right: 16,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(_undoSlideAnimation),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _undoLastEntry,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.undo, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text('Undo', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingTab() {
    final progress = _currentIntake / _dailyGoal;
    if (_loadingToday) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: _currentThemeColor),
            const SizedBox(height: 16),
            const Text('Loading your hydration data...'),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Smart insights card
          _buildSmartInsightsCard(),
          const SizedBox(height: 20),
          
          // Enhanced Progress Ring with liquid effect
          _buildLiquidProgressRing(progress),
          const SizedBox(height: 30),

          // Contextual Quick Add Section
          _buildContextualQuickAddSection(),
          const SizedBox(height: 30),

          // Today's Entries with swipe actions
          if (_todayEntries.isNotEmpty) _buildSwipeableEntries(),
          
          // Motivational footer
          const SizedBox(height: 20),
          _buildMotivationalFooter(),
        ],
      ),
    );
  }

  Widget _buildSmartInsightsCard() {
    final insights = _generateSmartInsights();
    if (insights.isEmpty) return const SizedBox.shrink();
    
    return FadeTransition(
      opacity: _insightFadeAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _currentThemeColor.withOpacity(0.1),
              _currentThemeColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _currentThemeColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _currentThemeColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.lightbulb_outline, color: _currentThemeColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Smart Insight',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(insights.first, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _generateSmartInsights() {
    final insights = <String>[];
    final hour = DateTime.now().hour;
    final progress = _currentIntake / _dailyGoal;
    
    if (hour < 12 && progress > 0.3) {
      insights.add("Great start! You're ahead of schedule today 🌟");
    } else if (hour > 15 && progress < 0.5) {
      insights.add("Consider drinking more water this afternoon 💧");
    } else if (progress > 0.8) {
      insights.add("You're crushing your hydration goals! 🎉");
    } else if (_todayEntries.length > 5) {
      insights.add("Consistent sipping is better than large amounts at once");
    }
    
    return insights;
  }

  Widget _buildLiquidProgressRing(double progress) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: _currentThemeColor.withOpacity(0.1),
              blurRadius: 40,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _progressAnimation,
                      _pulseAnimation,
                      _liquidWaveAnimation
                    ]),
                    builder: (context, child) {
                      return ScaleTransition(
                        scale: _pulseAnimation,
                        child: CustomPaint(
                          size: const Size(220, 220),
                          painter: _LiquidProgressRingPainter(
                            progress * _progressAnimation.value,
                            _currentIntake >= _dailyGoal,
                            _liquidWaveAnimation.value,
                            _currentThemeColor,
                          ),
                          child: SizedBox(
                            width: 220,
                            height: 220,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 500),
                                    child: Text(
                                      _currentIntake.toStringAsFixed(0),
                                      key: ValueKey(_currentIntake),
                                      style: TextStyle(
                                        fontSize: 42,
                                        fontWeight: FontWeight.w800,
                                        color: _currentThemeColor,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'ml',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _currentThemeColor.withOpacity(0.7),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(progress * 100).toStringAsFixed(1)}% of goal',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.refresh_outlined, color: Colors.redAccent),
                    tooltip: 'Reset counter',
                    onPressed: () => _showResetDialog(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Goal: ${_dailyGoal.toStringAsFixed(0)} ml',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${(_dailyGoal - _currentIntake).toStringAsFixed(0)} ml to go',
                  style: TextStyle(
                    fontSize: 16,
                    color: _currentThemeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showResetDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_outlined, color: Colors.orange),
            SizedBox(width: 8),
            Text('Reset Counter'),
          ],
        ),
        content: const Text('Are you sure you want to reset today\'s water counter? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _resetToday();
    }
  }

  Widget _buildContextualQuickAddSection() {
    final hour = DateTime.now().hour;
    String sectionTitle;
    String sectionSubtitle;
    IconData sectionIcon;

    if (hour < 8) {
      sectionTitle = 'Morning Hydration';
      sectionSubtitle = 'Start your day right';
      sectionIcon = Icons.wb_sunny_outlined;
    } else if (hour < 12) {
      sectionTitle = 'Mid-Morning Boost';
      sectionSubtitle = 'Keep the momentum';
      sectionIcon = Icons.local_cafe_outlined;
    } else if (hour < 18) {
      sectionTitle = 'Afternoon Refresh';
      sectionSubtitle = 'Stay energized';
      sectionIcon = Icons.refresh_outlined;
    } else {
      sectionTitle = 'Evening Wind-down';
      sectionSubtitle = 'Gentle hydration';
      sectionIcon = Icons.nights_stay_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_currentThemeColor.withOpacity(0.2), _currentThemeColor.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(sectionIcon, color: _currentThemeColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sectionTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      sectionSubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: [
              _buildSmartQuickAddButton(_contextualVolumes[0], _getContextualLabel(_contextualVolumes[0]), _getContextualIcon(_contextualVolumes[0])),
              _buildSmartQuickAddButton(_contextualVolumes[1], _getContextualLabel(_contextualVolumes[1]), _getContextualIcon(_contextualVolumes[1])),
              _buildSmartQuickAddButton(_contextualVolumes[2], _getContextualLabel(_contextualVolumes[2]), _getContextualIcon(_contextualVolumes[2])),
              _buildSmartQuickAddButton(_contextualVolumes[3], _getContextualLabel(_contextualVolumes[3]), _getContextualIcon(_contextualVolumes[3])),
            ],
          ),
        ],
      ),
    );
  }

  String _getContextualLabel(int volume) {
    if (volume <= 250) return '${volume}ml\nSip';
    if (volume <= 500) return '${volume}ml\nGlass';
    if (volume <= 750) return '${volume}ml\nBig Glass';
    return '${volume}ml\nBottle';
  }

  IconData _getContextualIcon(int volume) {
    if (volume <= 250) return Icons.local_cafe;
    if (volume <= 500) return Icons.local_drink;
    if (volume <= 750) return Icons.sports_bar;
    return Icons.water_drop;
  }

  Widget _buildSmartQuickAddButton(int volume, String label, IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _addWater(volume);
          HapticFeedback.mediumImpact();
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _currentThemeColor.withOpacity(0.15),
                _currentThemeColor.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _currentThemeColor.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: _currentThemeColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: _currentThemeColor, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: _currentThemeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeableEntries() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_currentThemeColor.withOpacity(0.2), _currentThemeColor.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.history_outlined, color: _currentThemeColor, size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Entries',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Swipe left to delete',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _todayEntries.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _entryAnimationController,
                curve: Interval(index * 0.1, 1.0, curve: Curves.elasticOut),
              )),
              child: _buildSwipeableEntryCard(_todayEntries[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeableEntryCard(DrinkEntry entry) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        HapticFeedback.heavyImpact();
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Delete Entry'),
            content: Text('Delete ${entry.volumeMl}ml of ${entry.drinkType}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) => _deleteEntry(entry),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_currentThemeColor.withOpacity(0.2), _currentThemeColor.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getDrinkIcon(entry.drinkType),
                color: _currentThemeColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.volumeMl} ml',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${entry.drinkType.toUpperCase()} • ${_formatTime(entry.timestamp)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _currentThemeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getTimeCategory(entry.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: _currentThemeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDrinkIcon(String drinkType) {
    switch (drinkType.toLowerCase()) {
      case 'coffee':
        return Icons.local_cafe;
      case 'tea':
        return Icons.emoji_food_beverage;
      case 'juice':
        return Icons.local_drink;
      case 'sports drink':
        return Icons.sports_bar;
      default:
        return Icons.water_drop;
    }
  }

  String _getTimeCategory(DateTime time) {
    final hour = time.hour;
    if (hour < 6) return 'NIGHT';
    if (hour < 12) return 'MORNING';
    if (hour < 18) return 'AFTERNOON';
    return 'EVENING';
  }

  Widget _buildMotivationalFooter() {
    final motivationalMessages = [
      "Every drop counts! 💧",
      "You're doing great! Keep going! 🌟",
      "Hydration is self-care 💙",
      "Your body will thank you! 🙏",
      "Stay consistent, stay healthy! 💪",
    ];
    
    final randomMessage = motivationalMessages[DateTime.now().millisecond % motivationalMessages.length];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_currentThemeColor.withOpacity(0.1), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        randomMessage,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _currentThemeColor,
        ),
      ),
    );
  }

  Widget _buildProgressTab() {
    return _EnhancedProgressTab(waterService: _waterService, themeColor: _currentThemeColor);
  }

  Widget _buildHistoryTab() {
    return _EnhancedHistoryTab(waterService: _waterService, themeColor: _currentThemeColor);
  }

  Widget _buildAchievementsTab() {
    return _EnhancedAchievementsTab(
      todayEntries: _todayEntries,
      currentIntake: _currentIntake,
      dailyGoal: _dailyGoal,
      themeColor: _currentThemeColor,
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class _LiquidProgressRingPainter extends CustomPainter {
  final double progress;
  final bool isGoalReached;
  final double waveAnimation;
  final Color themeColor;

  _LiquidProgressRingPainter(this.progress, this.isGoalReached, this.waveAnimation, this.themeColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    
    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Liquid fill effect
    if (progress > 0) {
      final liquidHeight = progress * (radius * 2);
      final liquidRect = Rect.fromCenter(
        center: center,
        width: radius * 2,
        height: radius * 2,
      );
      
      final liquidPath = Path();
      for (double x = -radius; x <= radius; x += 2) {
        final y = center.dy + radius - liquidHeight + 
                  math.sin((x / radius * 2 + waveAnimation * 4) * math.pi) * 6;
        if (x == -radius) {
          liquidPath.moveTo(center.dx + x, y);
        } else {
          liquidPath.lineTo(center.dx + x, y);
        }
      }
      liquidPath.lineTo(center.dx + radius, center.dy + radius);
      liquidPath.lineTo(center.dx - radius, center.dy + radius);
      liquidPath.close();
      
      // Clip to circle
      canvas.clipPath(Path()..addOval(liquidRect));
      
      final liquidPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isGoalReached 
            ? [Colors.green.withOpacity(0.3), Colors.green.withOpacity(0.6)]
            : [themeColor.withOpacity(0.3), themeColor.withOpacity(0.6)],
        ).createShader(liquidRect);
      
      canvas.drawPath(liquidPath, liquidPaint);
      
      // Reset clip
      canvas.restore();
      canvas.save();
    }
    
    // Progress arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        colors: isGoalReached 
          ? [Colors.green, Colors.lightGreen, Colors.green]
          : [themeColor, themeColor.withOpacity(0.7), themeColor],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
    
    // Animated glow effect when goal reached
    if (isGoalReached) {
      final glowPaint = Paint()
        ..color = Colors.green.withOpacity(0.3 + 0.2 * math.sin(waveAnimation * 2 * math.pi))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 25
        ..strokeCap = StrokeCap.round;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        glowPaint,
      );
    }
    
    // Progress indicator dot
    if (progress > 0) {
      final dotAngle = -math.pi / 2 + 2 * math.pi * progress;
      final dotPosition = Offset(
        center.dx + radius * math.cos(dotAngle),
        center.dy + radius * math.sin(dotAngle),
      );
      
      final dotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(dotPosition, 8, dotPaint);
      
      final dotBorderPaint = Paint()
        ..color = isGoalReached ? Colors.green : themeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      
      canvas.drawCircle(dotPosition, 8, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _EnhancedCelebrationDialog extends StatefulWidget {
  final VoidCallback onClose;

  const _EnhancedCelebrationDialog({required this.onClose});

  @override
  State<_EnhancedCelebrationDialog> createState() => _EnhancedCelebrationDialogState();
}

class _EnhancedCelebrationDialogState extends State<_EnhancedCelebrationDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _controller.forward();
    _confettiController.forward();
    
    // Auto close after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) widget.onClose();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti effect
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) => CustomPaint(
              size: const Size(300, 300),
              painter: _ConfettiPainter(_confettiController.value),
            ),
          ),
          // Main dialog
          ScaleTransition(
            scale: _scaleAnimation,
            child: RotationTransition(
              turns: _rotationAnimation,
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.green, Colors.lightGreen],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 40,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.green,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '🎉 GOAL ACHIEVED! 🎉',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Fantastic! You\'ve reached your daily\nhydration goal! Your body is thanking you! 💧',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16, 
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: widget.onClose,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 8,
                      ),
                      child: const Text(
                        'AWESOME!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double animation;

  _ConfettiPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final colors = [Colors.red, Colors.blue, Colors.yellow, Colors.green, Colors.purple];
    
    for (int i = 0; i < 50; i++) {
      final progress = (animation + i * 0.02) % 1.0;
      final x = (i % 10) * (size.width / 10) + math.sin(progress * 4 * math.pi) * 20;
      final y = progress * size.height;
      final rotation = progress * 4 * math.pi;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      
      paint.color = colors[i % colors.length];
      canvas.drawRect(const Rect.fromLTWH(-3, -8, 6, 16), paint);
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Enhanced tab implementations with better UI
class _EnhancedHistoryTab extends StatefulWidget {
  final WaterTrackingService waterService;
  final Color themeColor;
  
  const _EnhancedHistoryTab({required this.waterService, required this.themeColor});

  @override
  State<_EnhancedHistoryTab> createState() => _EnhancedHistoryTabState();
}

class _EnhancedHistoryTabState extends State<_EnhancedHistoryTab> {
  final int daysToShow = 14; // Show more days
  late List<DateTime> _dates;
  late Map<DateTime, List<DrinkEntry>> _entriesByDate;
  late Map<DateTime, bool> _expanded;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _dates = List.generate(daysToShow, (i) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
    });
    _entriesByDate = {};
    _expanded = {};
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    try {
      final Map<DateTime, List<DrinkEntry>> map = {};
      for (final date in _dates) {
        final entries = await widget.waterService.getDrinkEntriesForDate(date);
        map[date] = entries;
      }
      setState(() {
        _entriesByDate = map;
        _expanded = {for (var d in _dates) d: false};
      });
    } catch (e) {
      print('Error loading history: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  double _totalFor(List<DrinkEntry> entries) {
    return entries.fold(0.0, (sum, e) => sum + e.effectiveVolumeMl);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Yesterday';
    }
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  Color _getProgressColor(double total) {
    final progress = total / 2500; // Assuming 2500ml goal
    if (progress >= 1.0) return Colors.green;
    if (progress >= 0.7) return widget.themeColor;
    if (progress >= 0.4) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: widget.themeColor),
            const SizedBox(height: 16),
            const Text('Loading your history...'),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      color: widget.themeColor,
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _dates.length,
        itemBuilder: (context, i) {
          final date = _dates[i];
          final entries = _entriesByDate[date] ?? [];
          final total = _totalFor(entries);
          final expanded = _expanded[date] ?? false;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              childrenPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getProgressColor(total).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.water_drop,
                  color: _getProgressColor(total),
                  size: 24,
                ),
              ),
              title: Text(
                _formatDate(date),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${total.toStringAsFixed(0)} ml • ${entries.length} entries'),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: (total / 2500).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(_getProgressColor(total)),
                  ),
                ],
              ),
              initiallyExpanded: expanded,
              onExpansionChanged: (val) => setState(() => _expanded[date] = val),
              children: entries.isEmpty
                  ? [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            'No entries for this day',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      )
                    ]
                  : entries.map((e) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getDrinkIcon(e.drinkType),
                            color: widget.themeColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${e.volumeMl} ml of ${e.drinkType}',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Text(
                            '${e.timestamp.hour.toString().padLeft(2, '0')}:${e.timestamp.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
            ),
          );
        },
      ),
    );
  }

  IconData _getDrinkIcon(String drinkType) {
    switch (drinkType.toLowerCase()) {
      case 'coffee':
        return Icons.local_cafe;
      case 'tea':
        return Icons.emoji_food_beverage;
      case 'juice':
        return Icons.local_drink;
      case 'sports drink':
        return Icons.sports_bar;
      default:
        return Icons.water_drop;
    }
  }
}

class _EnhancedProgressTab extends StatefulWidget {
  final WaterTrackingService waterService;
  final Color themeColor;
  
  const _EnhancedProgressTab({required this.waterService, required this.themeColor});

  @override
  State<_EnhancedProgressTab> createState() => _EnhancedProgressTabState();
}

class _EnhancedProgressTabState extends State<_EnhancedProgressTab> {
  double? _weeklyTotal;
  double? _monthlyTotal;
  int? _streak;
  bool _loading = true;
  List<double> _last7Days = [];
  List<DateTime> _last7Dates = [];
  double? _bestDay;
  double? _worstDay;
  int? _daysTracked;
  double? _weeklyAverage;
  double? _monthlyAverage;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() => _loading = true);
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfMonth = DateTime(now.year, now.month, 1);
      
      final weeklyTotal = await widget.waterService.getWeeklyTotal(startOfWeek);
      final monthlyTotal = await widget.waterService.getMonthlyTotal(startOfMonth);
      final streak = await widget.waterService.getCurrentStreak();
      
      // Last 7 days data
      List<double> last7 = [];
      List<DateTime> last7Dates = [];
      double? best;
      double? worst;
      int daysTracked = 0;
      
      for (int i = 6; i >= 0; i--) {
        final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
        final total = await widget.waterService.getDailyTotal(date);
        last7.add(total);
        last7Dates.add(date);
        
        if (total > 0) {
          daysTracked++;
          if (best == null || total > best) best = total;
          if (worst == null || (total < worst && total > 0)) worst = total;
        }
      }
      
      setState(() {
        _weeklyTotal = weeklyTotal;
        _monthlyTotal = monthlyTotal;
        _streak = streak;
        _last7Days = last7;
        _last7Dates = last7Dates;
        _bestDay = best;
        _worstDay = worst;
        _daysTracked = daysTracked;
        _weeklyAverage = weeklyTotal > 0 ? weeklyTotal / 7 : 0;
        _monthlyAverage = monthlyTotal > 0 ? monthlyTotal / now.day : 0;
      });
    } catch (e) {
      print('Error loading progress: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  String _formatShortDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: widget.themeColor),
            const SizedBox(height: 16),
            const Text('Analyzing your progress...'),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      color: widget.themeColor,
      onRefresh: _loadProgress,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Weekly Chart
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: widget.themeColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.bar_chart, color: widget.themeColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Last 7 Days',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (_last7Days.isNotEmpty ? _last7Days.reduce((a, b) => a > b ? a : b) : 2500) * 1.2,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: widget.themeColor.withOpacity(0.8),
                          tooltipRoundedRadius: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${rod.toY.round()} ml',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${(value / 1000).toStringAsFixed(1)}L',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              int idx = value.toInt();
                              if (idx < 0 || idx >= _last7Dates.length) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _formatShortDate(_last7Dates[idx]),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                            reservedSize: 32,
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(_last7Days.length, (i) {
                        final value = _last7Days[i];
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: value,
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: value >= 2000
                                    ? [Colors.green, Colors.lightGreen]
                                    : [widget.themeColor, widget.themeColor.withOpacity(0.7)],
                              ),
                              width: 20,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _buildStatCard(
                icon: Icons.calendar_view_week,
                title: 'This Week',
                value: '${_weeklyTotal?.toStringAsFixed(0) ?? '0'} ml',
                subtitle: 'Avg: ${_weeklyAverage?.toStringAsFixed(0) ?? '0'} ml/day',
                color: widget.themeColor,
              ),
              _buildStatCard(
                icon: Icons.calendar_month,
                title: 'This Month',
                value: '${_monthlyTotal?.toStringAsFixed(0) ?? '0'} ml',
                subtitle: 'Avg: ${_monthlyAverage?.toStringAsFixed(0) ?? '0'} ml/day',
                color: Colors.indigo,
              ),
              _buildStatCard(
                icon: Icons.local_fire_department,
                title: 'Current Streak',
                value: '${_streak ?? 0}',
                subtitle: 'days in a row',
                color: Colors.orange,
              ),
              _buildStatCard(
                icon: Icons.star,
                title: 'Best Day',
                value: _bestDay != null ? '${_bestDay!.toStringAsFixed(0)}' : '0',
                subtitle: 'ml achieved',
                color: Colors.green,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Additional Stats
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Additional Insights',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildInsightRow(
                  Icons.trending_up,
                  'Days Tracked',
                  '${_daysTracked ?? 0} days',
                  Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildInsightRow(
                  Icons.trending_down,
                  'Lowest Day',
                  _worstDay != null ? '${_worstDay!.toStringAsFixed(0)} ml' : '0 ml',
                  Colors.red,
                ),
                const SizedBox(height: 16),
                _buildInsightRow(
                  Icons.insights,
                  'Consistency',
                  '${((_daysTracked ?? 0) / 7 * 100).toStringAsFixed(1)}%',
                  Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(IconData icon, String title, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _EnhancedAchievementsTab extends StatefulWidget {
  final List<DrinkEntry> todayEntries;
  final double currentIntake;
  final double dailyGoal;
  final Color themeColor;
  
  const _EnhancedAchievementsTab({
    required this.todayEntries,
    required this.currentIntake,
    required this.dailyGoal,
    required this.themeColor,
  });

  @override
  State<_EnhancedAchievementsTab> createState() => _EnhancedAchievementsTabState();
}

class _EnhancedAchievementsTabState extends State<_EnhancedAchievementsTab>
    with TickerProviderStateMixin {
  int streak = 5;
  int plantLevel = 1;
  late AnimationController _badgeAnimationController;

  @override
  void initState() {
    super.initState();
    _badgeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _badgeAnimationController.dispose();
    super.dispose();
  }

  void _showBadgeDialog(achievement_widgets.Badge badge) async {
    HapticFeedback.lightImpact();
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: badge.unlocked
                  ? [Colors.amber.withOpacity(0.1), Colors.orange.withOpacity(0.1)]
                  : [Colors.grey.withOpacity(0.1), Colors.grey.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: badge.unlocked
                      ? const LinearGradient(colors: [Colors.amber, Colors.orange])
                      : LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade400]),
                  shape: BoxShape.circle,
                  boxShadow: badge.unlocked
                      ? [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          )
                        ]
                      : [],
                ),
                child: Icon(
                  badge.unlocked ? Icons.emoji_events : Icons.lock,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                badge.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              if (badge.unlocked)
                const Text(
                  '🎉 Achievement Unlocked! 🎉',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                )
              else
                Column(
                  children: [
                    Text(
                      'Progress: ${badge.progress}/${badge.goal}',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: badge.progress / badge.goal,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation(widget.themeColor),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.themeColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Close', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final badges = [
      achievement_widgets.Badge(
        'First Drop',
        widget.currentIntake > 0,
        widget.currentIntake > 0 ? 1 : 0,
        1,
      ),
      achievement_widgets.Badge(
        'Hydration Hero',
        widget.currentIntake >= widget.dailyGoal,
        widget.currentIntake.toInt(),
        widget.dailyGoal.toInt(),
      ),
      achievement_widgets.Badge(
        'Consistency King',
        streak >= 7,
        streak,
        7,
      ),
      achievement_widgets.Badge(
        'Early Bird',
        false,
        2,
        5,
      ),
      achievement_widgets.Badge(
        'Night Owl',
        false,
        0,
        5,
      ),
      achievement_widgets.Badge(
        'Hydration Master',
        false,
        15,
        30,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Enhanced Virtual Plant
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.withOpacity(0.1),
                  Colors.lightGreen.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.local_florist, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Your plant is thriving! 🌱✨'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              child: achievement_widgets.VirtualPlantWidget(level: plantLevel, streak: streak),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Enhanced Weekly Challenge
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: widget.themeColor.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: achievement_widgets.WeeklyChallengeWidget(),
          ),
          
          const SizedBox(height: 32),
          
          // Badges Section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Your Achievements',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Enhanced Badges Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.85,
            ),
            itemCount: badges.length,
            itemBuilder: (context, i) {
              final badge = badges[i];
              return GestureDetector(
                onTap: () => _showBadgeDialog(badge),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: badge.unlocked
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.amber, Colors.orange],
                          )
                        : LinearGradient(
                            colors: [Colors.grey.shade200, Colors.grey.shade300],
                          ),
                    boxShadow: badge.unlocked
                        ? [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 2,
                              offset: const Offset(0, 6),
                            )
                          ]
                        : [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        badge.unlocked ? Icons.emoji_events : Icons.lock,
                        color: badge.unlocked ? Colors.white : Colors.grey,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        badge.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: badge.unlocked ? Colors.white : Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (!badge.unlocked) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${badge.progress}/${badge.goal}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: badge.progress / badge.goal,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation(widget.themeColor),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}