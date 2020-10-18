import 'package:flutter/material.dart';
import 'package:youtubapi/models/channel_model.dart';
import 'package:youtubapi/models/video_model.dart';
import 'package:youtubapi/screens/video_screen.dart';
import 'package:youtubapi/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Channel _channel;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initChannel();
  }

  _initChannel() async {
    Channel channel = await APIService.instance
        .fetchChannel(channelId: 'UCeLNPJoPAio9rT2GAdXDVmw');
    setState(() {
      _channel = channel;
    });
  }

  _loadMoreVideos() async {
    _isLoading = true;
    List<Video> moreVideos = await APIService.instance
        .fetchVideosFromPlaylist(playlistId: _channel.uploadPlaylistId);
    List<Video> allVideos = _channel.videos..addAll(moreVideos);
    setState(() {
      _channel.videos = allVideos;
    });
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData _mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.9),
      appBar: AppBar(
          backgroundColor: Colors.black54,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            iconSize: 25.0,
            color: Colors.white,
            onPressed: () => {},
          ),
          title: Center(
              child: new Text(
            'Streaming',
            style: TextStyle(color: Colors.white),
          )),
          actions: [
            // action button
            IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ],
          automaticallyImplyLeading: false),
      body: _channel != null
          ? NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollDetails) {
                if (!_isLoading &&
                    _channel.videos.length != int.parse(_channel.videoCount) &&
                    scrollDetails.metrics.pixels ==
                        scrollDetails.metrics.maxScrollExtent) {
                  _loadMoreVideos();
                }
                return false;
              },
              child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(0.5),
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30)),
                          image: DecorationImage(
                            image: AssetImage('assets/images/stream.jpeg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          overflow: Overflow.visible,
                          children: [
                            Positioned(
                              bottom: -30.0,
                              left: 25,
                              child: SizedBox(
                                height: 70,
                                child: FlatButton(
                                  onPressed: () {
                                  },
                                  child: Icon(Icons.play_circle_fill,size: 65,color: Colors.red,),
                                  shape: CircleBorder(),
                                  splashColor: Colors.blueAccent,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                      SizedBox(height: 40),
                      GridView(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                        children: _channel.videos.map((value) {
                          return GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => VideoScreen(id: value.id))),
                            child: GridTile(
                              child: Column(
                                children: [
                                  SizedBox(height: 11.0),
                                  Container(
                                    height: _mediaQueryData.size.width / 2.9,
                                    width: _mediaQueryData.size.width / 2.2,
                                    padding: const EdgeInsets.all(2.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                      borderRadius: BorderRadius.circular(5.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.4),
                                          spreadRadius: 5,
                                          blurRadius: 5,
                                          offset: Offset(0,
                                              2), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Image(
                                      width: 550,
                                      image: NetworkImage(value.thumbnailUrl),
                                    ),
                                  ),
                                  SizedBox(height: 10.0),
                                  Container(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      (value.title),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ]),
              ),
            )
          : Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor, // Red
                ),
              ),
            ),
    );
  }
}
