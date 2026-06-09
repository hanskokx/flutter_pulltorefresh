import "dart:async";
import "dart:convert" show json;

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:http/http.dart" as HTTP;
import "package:pull_to_refresh/pull_to_refresh.dart";

class Test2 extends StatefulWidget {
  const Test2({super.key});

  @override
  _Test2State createState() => _Test2State();
}

class _Test2State extends State<Test2> with TickerProviderStateMixin {
  late RefreshController _controller;
  int indexPage = 0;
  List<String> data = [];

  void _fetch() {
    HTTP
        .get(
          Uri.parse(
            "https://gank.io/api/v2/data/category/Girl/type/Girl/page/$indexPage/count/10",
          ),
        )
        .then((HTTP.Response response) {
          final Map<String, dynamic> map =
              json.decode(response.body) as Map<String, dynamic>;
          return map["data"] as List<dynamic>? ?? const <dynamic>[];
        })
        .then((List<dynamic> array) {
          for (final dynamic item in array) {
            final Map<String, dynamic> mapItem = item as Map<String, dynamic>;
            final String? url = mapItem["url"] as String?;
            if (url != null) {
              data.add(url);
            }
          }
          if (mounted) setState(() {});
          _controller.loadFailed();
          indexPage++;
        })
        .catchError((_) {
          debugPrint("error");
          _controller.loadComplete();
        });
  }

  void _onRefresh() {
    Future.delayed(const Duration(milliseconds: 2009)).then((val) {
      _controller.refreshCompleted();
      //                refresher.sendStatus(RefreshStatus.completed);
    });
  }

  void _onLoading() {
    Future.delayed(const Duration(milliseconds: 2009)).then((val) {
      _fetch();
    });
  }

  Widget buildImage(BuildContext context, int index) {
    return GestureDetector(
      child: Item(url: data[index]),
      onTap: () {
        debugPrint("tap");
        //        _controller.requestRefresh().then((_){
        //          debugPrint("request complete");
        //        });
        _controller.requestRefresh(needMove: false)?.then((_) {
          debugPrint("request complete");
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = RefreshController(initialLoadStatus: LoadStatus.failed);
    _fetch();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      controller: _controller,
      onRefresh: _onRefresh,
      header: const MaterialClassicHeader(),
      onLoading: _onLoading,
      child: GridView.builder(
        primary: false,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: data.length,
        itemBuilder: buildImage,
      ),
    );
  }
}

class Item extends StatefulWidget {
  final String url;

  const Item({required this.url, super.key});

  @override
  _ItemState createState() => _ItemState();
}

class _ItemState extends State<Item> {
  @override
  Widget build(BuildContext context) {
    return FadeInImage(
      placeholder: const AssetImage("images/empty.png"),
      image: NetworkImage(widget.url),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
