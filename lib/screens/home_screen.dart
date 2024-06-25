import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/station_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch stations when the HomeScreen is initialized
    Provider.of<StationProvider>(context, listen: false).fetchStations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              Provider.of<StationProvider>(context, listen: false).fetchStations();
            },
          ),
        ],
      ),
      body: Consumer<StationProvider>(
        builder: (context, stationProvider, child) {
          if (stationProvider.loading) {
            return Center(child: CircularProgressIndicator());
          }
          if (stationProvider.stations.isEmpty) {
            return Center(child: Text('No stations available.'));
          }
          return ListView.builder(
            itemCount: stationProvider.stations.length,
            itemBuilder: (context, index) {
              final station = stationProvider.stations[index];
              return Card(
                child: ListTile(
                  title: Text(station.name),
                  subtitle: Text(station.tags.join(', ')),
                  onTap: () {
                    // Navigate to station details or play songs
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
