import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import '../providers/station_provider.dart';
import '../providers/media_player_provider.dart';
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // title: Text('Stations', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              Provider.of<StationProvider>(context, listen: false).fetchStations();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Rive animation background
          Positioned.fill(
            child: RiveAnimation.asset(
              'assets/rive/treesv2.riv',
              fit: BoxFit.cover,
            ),
          ),
          // Foreground content
          Consumer2<StationProvider, MediaPlayerProvider>(
            builder: (context, stationProvider, mediaPlayerProvider, child) {
              final stations = stationProvider.stations;
              if (stationProvider.loading) {
                return Center(child: CircularProgressIndicator());
              }
              if (stations.isEmpty) {
                return Center(child: Text('No stations available.'));
              }
              return Padding(
                padding: const EdgeInsets.only(top: 100.0), // Adjust padding as needed
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 items per row
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 1, // Makes the tiles square
                  ),
                  itemCount: stations.length,
                  itemBuilder: (context, index) {
                    final station = stations[index];
                    final animationFile = index % 2 == 0
                        ? 'assets/rive/library.riv'
                        : 'assets/rive/anime_music8.riv';
                    final isPlayingStation = mediaPlayerProvider.isPlayingStation(station.id);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MediaPlayerScreen(
                              stationId: station.id,
                              animationFilePath: animationFile,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        child: Stack(
                          children: [
                            // Rive animation as background
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: RiveAnimation.asset(
                                  animationFile,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Station information
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                  ),
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      station.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      station.tags.join(', '),
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (isPlayingStation)
                                      Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
