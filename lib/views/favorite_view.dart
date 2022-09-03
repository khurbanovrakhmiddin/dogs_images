import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:dogs_images/models/favorite_image.dart';
import 'package:dogs_images/services/network_service.dart';

class FavoriteView extends StatefulWidget {
  final crossAxisCount;
  const FavoriteView({Key? key, this.crossAxisCount}) : super(key: key);

  @override
  State<FavoriteView> createState() => _FavoriteViewState();
}

class _FavoriteViewState extends State<FavoriteView> with AutomaticKeepAliveClientMixin {

  int page = 0;
  List<Image> list = [];
  final ScrollController _scrollController = ScrollController();



  int get limit {
    print(widget.crossAxisCount );
    return widget.crossAxisCount * list.length >= 100 ? 90 : widget.crossAxisCount * list.length;
  }
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _apiGetAllImage(page++);
    _scrollController.addListener(_pagination);
  }

  void _apiGetAllImage(int screen) async {
    String response = await NetworkService.GET(NetworkService.API_MY_FAVORITE, NetworkService.paramsVotesList(limit: 30, page: screen)) ?? "[]";
    List<Favorite> items = favoriteListFromJson(response);
    for(Favorite item in items) {
      if(item.image != null && item.image!.url != null) {
        list.add(item.image!);
      }
    }

    setState(() {});
  }

  void _pagination() {
    if(_scrollController.position.maxScrollExtent == _scrollController.position.pixels) {
      _apiGetAllImage(page++);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.width);
    return   MasonryGridView.count(
      shrinkWrap: true,
      crossAxisCount: widget.crossAxisCount,
      itemCount: list.length,
      mainAxisSpacing: 10,
      crossAxisSpacing: widget.crossAxisCount,
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, index) {
        return CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: list[index].url!,
          placeholder: (context, url) => Container(
            color: Colors.primaries[Random().nextInt(18) % 18],
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        );
      },
    );

  }

}
