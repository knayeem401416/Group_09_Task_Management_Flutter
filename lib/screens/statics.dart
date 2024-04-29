import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Statics extends StatelessWidget {
  const Statics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Statics'),
      ),
      body: StreamBuilder<QuerySnapshot?>(
        stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot?> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No Data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          } else {
            var countComplete = 0;
            var countOngoing = 0;

            snapshot.data!.docs.forEach((doc) {
              if (doc['status'] == 'done') {
                countComplete++;
              } else {
                countOngoing++;
              }
            });

            // Pie chart data
            List<PieChartSectionData> sections = [
              PieChartSectionData(
                color: Colors.green,
                value: countComplete.toDouble(),
                title: '${(countComplete / (countComplete + countOngoing) * 100).toStringAsFixed(1)}%',
                titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              PieChartSectionData(
                color: Colors.red,
                value: countOngoing.toDouble(),
                title: '${(countOngoing / (countComplete + countOngoing) * 100).toStringAsFixed(1)}%',
                titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ];

            return Column(
              children: [
                Expanded(
                  flex: 1,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 60,
                      sectionsSpace: 0,
                      startDegreeOffset: -90,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: ListView(
                    children: [
                      taskStatisticCard('Completed Tasks', countComplete, Colors.green),
                      taskStatisticCard('Ongoing Tasks', countOngoing, Colors.red),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget taskStatisticCard(String title, int count, Color color) {
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withOpacity(0.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
          SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
