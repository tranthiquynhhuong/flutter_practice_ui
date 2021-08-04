import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_practice_ui/model/video.dart';
import 'package:flutter_practice_ui/res/colors.dart';
import 'package:flutter_practice_ui/res/images.dart';
import 'package:flutter_practice_ui/ui/youtube/widgets/video_card.dart';
import 'package:flutter_practice_ui/ui/youtube/youtube_clone_bloc.dart';
import 'package:flutter_practice_ui/utils/calculate_value.dart';
import 'package:interpolate/interpolate.dart';
import 'package:miniplayer/miniplayer.dart';

class YoutubeCloneView extends StatefulWidget {
  @override
  _YoutubeCloneViewState createState() => _YoutubeCloneViewState();
}

class _YoutubeCloneViewState extends State<YoutubeCloneView> {
  ScrollController scrollController;
  MiniplayerController miniplayerController;

  double bottomDelta = 0.0;
  int _selectedIndex = 0;
  double miniPlayerHeight = 60;

  Video videoSelected;
  YoutubeCloneBloc bloc = YoutubeCloneBloc();

  @override
  void initState() {
    super.initState();
    videoSelected = null;

    scrollController = ScrollController();
    miniplayerController = MiniplayerController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cl.background,
      bottomNavigationBar: StreamBuilder<double>(
          stream: bloc.bsBottomBarHeight,
          builder: (context, bsBottomBarHeight) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 100),
              height: bsBottomBarHeight.data,
              child: buildBottomNavBar(),
            );
          }),
      body: SafeArea(
        child: Stack(
          children: [
            buildMain(),
            buildVideoDetail(),
          ],
        ),
      ),
    );
  }

  Widget buildVideoDetail() {
    return Offstage(
      offstage: videoSelected == null,
      child: Miniplayer(
        controller: miniplayerController,
        maxHeight: MediaQuery.of(context).size.height,
        minHeight: miniPlayerHeight,
        builder: (height, percentage) {
          if (videoSelected == null) {
            return SizedBox.shrink();
          }

          bloc.bsBottomBarHeight.add(
            calculateInterpolate(
              val: percentage,
              lstInputRange: [0, 1, 0],
              lstOutputRange: [56, 0, 56],
            ),
          );

          return Container(
            color: Colors.amber,
            child: Center(
              child: Text(
                '$height  $percentage',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildMain() {
    return CustomScrollView(
      controller: scrollController,
      slivers: <Widget>[
        buildSliverAppbar(),
        buildListVideo(),
      ],
    );
  }

  Widget buildListVideo() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          Video video = videos[index];
          return InkWell(
            onTap: () {
              // _modalBottomSheetMenu();
              setState(() {
                videoSelected = video;
              });
            },
            child: VideoCard(
              video: video,
            ),
          );
        },
        childCount: videos.length,
      ),
    );
  }

  Widget buildSliverAppbar() {
    return SliverAppBar(
      backgroundColor: Cl.background,
      automaticallyImplyLeading: false,
      title: Container(
        width: 100,
        child: Image.asset(Images.youtubeLogoDark),
      ),
      floating: true,
      expandedHeight: 56,
      actions: [
        IconButton(icon: Icon(Icons.videocam), onPressed: () {}),
        IconButton(icon: Icon(Icons.search), onPressed: () {}),
        IconButton(
          icon: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.black54,
            backgroundImage: NetworkImage('https://picsum.photos/50/50'),
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget buildBottomNavBar() {
    return Stack(
      children: [
        Wrap(
          children: [
            BottomNavigationBar(
              backgroundColor: Cl.background,
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              onTap: (i) => setState(() => _selectedIndex = i),
              selectedFontSize: 10.0,
              unselectedFontSize: 10.0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined, color: Colors.white),
                  activeIcon: Icon(Icons.home, color: Colors.white),
                  label: 'Trang chủ',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.fireplace_outlined, color: Colors.white),
                  activeIcon: Icon(Icons.fireplace_rounded, color: Colors.white),
                  label: 'Thịnh hành',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.subscriptions_outlined, color: Colors.white),
                  activeIcon: Icon(Icons.subscriptions, color: Colors.white),
                  label: 'Kênh đăng ký',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_none_outlined, color: Colors.white),
                  activeIcon: Icon(Icons.notifications, color: Colors.white),
                  label: 'Thông báo',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.folder_open, color: Colors.white),
                  activeIcon: Icon(Icons.folder, color: Colors.white),
                  label: 'Thư viện',
                ),
              ],
            ),
          ],
        ),
        Container(
          height: 1.5,
          color: Colors.grey[700],
        ),
      ],
    );
  }
}
