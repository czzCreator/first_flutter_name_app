import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];

  static const int _displayWordPairsListLength = 6;
  var _displayWordPairsList = <Map<WordPair, bool>>[];
  get displayWordPairsList => _displayWordPairsList;

  void addWord2DisplayList(WordPair onePair, bool isFavorite) {
    if (_displayWordPairsList.length >= _displayWordPairsListLength) {
      _displayWordPairsList.clear();
    }

    Map<WordPair, bool> oneItem = {onePair: isFavorite};
    _displayWordPairsList.add(oneItem);
    print("current app inner display list: $_displayWordPairsList");
    notifyListeners();
  }

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget choosenWidget;
    switch (selectedIndex) {
      case 0:
        choosenWidget = GeneratorPage();
        break;
      case 1:
        choosenWidget = FavoritesPage();
        break;
      default:
        throw UnimplementedError(
            'MyHomePage detect Invalid index: $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth > 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: choosenWidget,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  _getIconFromMapInfo(Map<WordPair, bool> oneMapInfo, Color colorFromOutSide) {
    IconData icon;
    if (oneMapInfo.values.first) {
      icon = Icons.favorite;
      Icon tmpIcon = Icon(icon, color: colorFromOutSide);
      return tmpIcon;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    var currListTiles = <ListAddAnimatedUpWidget>[];
    for (var oneWordPairInfo in appState.displayWordPairsList) {
      var tmpIcon = _getIconFromMapInfo(
          oneWordPairInfo, Theme.of(context).colorScheme.primary);

      var tmpListAddWind = ListAddAnimatedUpWidget(
          appState: appState,
          oneWordPairInfo: oneWordPairInfo,
          tmpIcon: tmpIcon);
      currListTiles.add(tmpListAddWind);
    }

    return GenerateStatefulCenter(
        currListTiles: currListTiles,
        pair: pair,
        appState: appState,
        icon: icon);
  }
}

class ListAddAnimatedUpWidget extends StatefulWidget {
  const ListAddAnimatedUpWidget({
    super.key,
    required this.appState,
    required this.oneWordPairInfo,
    required this.tmpIcon,
  });

  final MyAppState appState;
  final oneWordPairInfo;
  final tmpIcon;

  @override
  State<ListAddAnimatedUpWidget> createState() =>
      _ListAddAnimatedUpWidgetState();
}

class _ListAddAnimatedUpWidgetState extends State<ListAddAnimatedUpWidget> {
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
        left: 0.0 + MediaQuery.of(context).size.width / 2 - 180,
        bottom: 0.0 +
            50 *
                (widget.appState._displayWordPairsList.length -
                    1 -
                    widget.appState.displayWordPairsList
                        .indexOf(widget.oneWordPairInfo)),
        duration: Duration(milliseconds: 500),
        child: Row(
          children: [
            if (widget.tmpIcon != null) widget.tmpIcon,
            SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Text(
                widget.oneWordPairInfo.keys.first.asLowerCase,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
          ],
        ));
  }
}

class GenerateStatefulCenter extends StatefulWidget {
  const GenerateStatefulCenter({
    super.key,
    required this.currListTiles,
    required this.pair,
    required this.appState,
    required this.icon,
  });

  final List<ListAddAnimatedUpWidget> currListTiles;
  final WordPair pair;
  final MyAppState appState;
  final IconData icon;

  @override
  State<GenerateStatefulCenter> createState() => _GenerateStatefulCenterState();
}

class _GenerateStatefulCenterState extends State<GenerateStatefulCenter> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: widget.currListTiles,
            ),
          ),
          BigCard(pair: widget.pair),
          SizedBox(height: 15),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    widget.appState.toggleFavorite();
                  },
                  icon: Icon(widget.icon),
                  label: Text('Like'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    widget.appState.getNext();
                    widget.appState.addWord2DisplayList(widget.pair,
                        widget.appState.favorites.contains(widget.pair));
                  },
                  child: Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // ← Add this.

    // ↓ Add this.
    final styleBigcard = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary, // ← And also this.
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          pair.asPascalCase,
          style: styleBigcard, // ← Add this.
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}
