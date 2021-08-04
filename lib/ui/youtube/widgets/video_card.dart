import 'package:flutter/material.dart';
import 'package:flutter_practice_ui/model/video.dart';
import 'package:timeago/timeago.dart' as timeago;

class VideoCard extends StatelessWidget {
  final Video video;
  final bool hasPadding;

  const VideoCard({
    Key key,
    @required this.video,
    this.hasPadding = false,
  }) : super(key: key);

  // onTap: () {
  //   context.read(selectedVideoProvider).state = video;
  //   context.read(miniPlayerControllerProvider).state.animateToHeight(state: PanelState.MAX);
  //   if (onTap != null) onTap!();
  // },

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: hasPadding ? 12.0 : 0,
              ),
              child: Image.network(
                video.thumbnailUrl,
                height: 220.0,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 8.0,
              right: hasPadding ? 20.0 : 8.0,
              child: Container(
                padding: const EdgeInsets.all(4.0),
                color: Colors.black,
                child: Text(
                  video.duration,
                  style: Theme.of(context).textTheme.caption.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 35),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => print('Navigate to profile'),
                child: CircleAvatar(
                  foregroundImage: NetworkImage(video.author.profileImageUrl),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              fontSize: 15.0,
                              color: Colors.white,
                            ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Flexible(
                      child: Text(
                        '${video.author.username} • ${video.viewCount} views • ${timeago.format(video.timestamp)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.caption.copyWith(
                              fontSize: 14.0,
                              color: Colors.grey.shade500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Icon(Icons.more_vert, size: 20.0),
              ),
            ],
          ),
        ),
        Container(
          height: 1.5,
          color: Colors.grey[700],
        ),
      ],
    );
  }
}
