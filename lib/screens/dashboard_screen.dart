import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final totalContent = appState.totalContent;
        final totalAsset = appState.totalAsset;
        final draft = appState.countContentByStatus('draft');
        final publish = appState.countContentByStatus('publish');
        final scheduled = appState.countContentByStatus('scheduled');

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ringkasan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text('Total Content: $totalContent'),
                      Text('Total Asset: $totalAsset'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Distribusi Content / Asset', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 220,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                color: Colors.blue,
                                value: totalContent.toDouble().clamp(0, double.infinity),
                                title: 'Content',
                                radius: 70,
                                titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              PieChartSectionData(
                                color: Colors.orange,
                                value: totalAsset.toDouble().clamp(0, double.infinity),
                                title: 'Asset',
                                radius: 70,
                                titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                            sectionsSpace: 4,
                            centerSpaceRadius: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Status Content', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 220,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: [draft, publish, scheduled].fold<int>(0, (prev, next) => next > prev ? next : prev).toDouble() + 1,
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const labels = ['Draft', 'Publish', 'Scheduled'];
                                    final index = value.toInt();
                                    return SideTitleWidget(
                                      meta: meta,
                                      child: Text(labels[index]),
                                    );
                                  },
                                  reservedSize: 40,
                                ),
                              ),
                              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                            ),
                            barGroups: [
                              BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: draft.toDouble(), color: Colors.blue)]),
                              BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: publish.toDouble(), color: Colors.green)]),
                              BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: scheduled.toDouble(), color: Colors.orange)]),
                            ],
                            gridData: FlGridData(show: true),
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
      },
    );
  }
}
