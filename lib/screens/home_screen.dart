import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/station_provider.dart';
import 'media_player_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch stations when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StationProvider>(context, listen: false).fetchStations();
    });
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
          final stations = stationProvider.stations;
          if (stationProvider.loading) {
            return Center(child: CircularProgressIndicator());
          }
          if (stations.isEmpty) {
            return Center(child: Text('No stations available.'));
          }
          return ListView.builder(
            itemCount: stations.length,
            itemBuilder: (context, index) {
              final station = stations[index];
              return Card(
                child: ListTile(
                  title: Text(station.name),
                  subtitle: Text(station.tags.join(', ')),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MediaPlayerScreen(stationId: station.id),
                      ),
                    );
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
