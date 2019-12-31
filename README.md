# portal

A flutter plugin to build a widget outside of it's current tree. Similar to [React Portals](https://reactjs.org/docs/portals.html).

![image](https://github.com/rive-app/portal/blob/master/docs/portal.jpg?raw=true)

Thanks to @TahaTesser [here](https://twitter.com/tahatesser/status/1212040458064367618?s=21)

## Demo

https://rive-app.github.io/portal/

## Example

```dart
import 'package:flutter/material.dart';

import 'package:portal/portal.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PortalProvider(
      child: MaterialApp(
        home: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _provider = PortalProvider.of(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('React Portal Example'),
      ),
      body: ListView.separated(
        itemCount: 500,
        separatorBuilder: (_, index) =>
            Container(height: 2, color: Colors.grey),
        itemBuilder: (_, index) {
          final _key = ValueKey(index);

          return Builder(
            builder: (context) => ListTile(
              title: Text('Test Portal: $index'),
              onTap: () {
                final _portal = ReactPortal(
                    key: _key,
                    builder: (_) => Card(
                          elevation: 5,
                          child: InkWell(
                            onTap: () {
                              _provider.removeKey(_key);
                            },
                            child: Container(
                              width: 200,
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    title: Text('Info about the list item..'),
                                    subtitle: Text(index.toString()),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ));
                _portal.show(context);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.visibility),
        onPressed: () {
          final _key = ValueKey('popup');
          final _portal = ReactPortal(
              key: _key,
              alignment: Alignment.center,
              width: 200,
              height: 500,
              builder: (_) => Card(
                    elevation: 20.0,
                    child: Container(
                      child: Stack(
                        children: <Widget>[
                          Positioned.fill(
                            child: Column(
                              children: <Widget>[
                                ListTile(
                                  title: Text('Popu Up Card'),
                                  subtitle: Text('Sub List Example'),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: 100,
                                    itemBuilder: (_, index) => ListTile(
                                      title: Text(index.toString()),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                _provider.removeKey(_key);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ));
          _portal.show(context);
        },
      ),
    );
  }
}

```