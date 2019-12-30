import 'package:flutter/material.dart';

class ReactPortal {
  final Key key;
  final bool asWideAsParent, asTallAsParent;
  double left;
  double bottom;
  double right;
  double top;
  final double width, height;
  final WidgetBuilder builder;
  final RenderObject ancestor;
  final bool maintainState;
  final bool opaque;
  final Alignment alignment;

  ReactPortal({
    this.key,
    @required this.builder,
    this.asWideAsParent = false,
    this.asTallAsParent = false,
    this.bottom,
    this.left = 0,
    this.top = 0,
    this.right,
    this.width,
    this.height,
    this.alignment,
    this.ancestor,
    this.maintainState = false,
    this.opaque = false,
  });

  OverlayEntry show(
    BuildContext context, {
    OverlayEntry above,
    OverlayEntry below,
  }) {
    OverlayEntry _entry = buildEntry(context);
    final _portal = PortalProvider.of(context);
    if (_portal != null) {
      _portal.addEntry(context, _entry, key: key, above: above, below: below);
    } else {
      final _overlay = Overlay.of(context);
      _overlay.insert(_entry, above: above, below: below);
    }
    return _entry;
  }

  OverlayEntry buildEntry(BuildContext context) {
    RenderBox renderBox = context.findRenderObject();
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero, ancestor: ancestor);
    final _entry = OverlayEntry(
      opaque: opaque,
      maintainState: maintainState,
      builder: (context) {
        final _child = builder(context);
        final _isMaterial = _child is Material || _child is Card;
        final _size = Size(asWideAsParent ? size.width : width,
            asTallAsParent ? size.height : height);
        if (alignment != null) {
          return Positioned.fill(
            child: Container(
              alignment: alignment,
              width: _size.width,
              height: _size.height,
              child: _buildChild(_child, _isMaterial, _size),
            ),
          );
        }
        return Positioned(
          left: left == null ? null : offset.dx + left,
          right: right == null ? null : offset.dx + right,
          bottom: bottom == null ? null : offset.dy + bottom,
          top: top == null ? null : offset.dy + top,
          width: _size.width,
          height: _size.height,
          child: _buildChild(_child, _isMaterial, _size),
        );
      },
    );
    return _entry;
  }

  Widget _buildChild(Widget child, bool isMaterial, Size size) {
    Widget _child = child;
    if (size?.width != null && size?.height != null) {
      _child = SizedBox.fromSize(child: child, size: size);
    }
    if (isMaterial) {
      return _child;
    }
    return Material(
      color: Colors.transparent,
      child: _child,
    );
  }
}

class PortalProvider extends InheritedWidget {
  PortalProvider({
    @required Widget child,
  }) : _child = child;

  @override
  Widget get child => _child;

  final Widget _child;
  final Map<Key, OverlayEntry> _entries = {};
  List<OverlayEntry> get entries => _entries.values;

  void updateEntries(
    BuildContext context,
    List<OverlayEntry> entries, {
    OverlayEntry below,
    OverlayEntry above,
  }) {
    final _overlay = Overlay.of(context);
    _overlay.rearrange(entries, above: above, below: below);
    _entries.clear();
    if (entries != null && entries.isNotEmpty) {
      for (var entry in entries) {
        _entries[ValueKey(entry.hashCode)] = entry;
      }
    }
  }

  void addEntry(
    BuildContext context,
    OverlayEntry entry, {
    Key key,
    OverlayEntry below,
    OverlayEntry above,
  }) {
    final _overlay = Overlay.of(context);
    removeEntry(_entries[key]);
    _entries[key ?? ValueKey(entry.hashCode)] = entry;
    _overlay.insert(entry, above: above, below: below);
  }

  void removeEntry(OverlayEntry entry) {
    if (entry != null) {
      _entries.remove(entry);
      try {
        entry.remove();
      } catch (e) {}
    }
  }

  void removeKey(Key key) {
    final entry = _entries[key];
    if (entry != null) removeEntry(entry);
  }

  @override
  bool updateShouldNotify(PortalProvider old) {
    return entries != old.entries || entries != old.entries;
  }

  static PortalProvider of(BuildContext context, [String aspect = 'entries']) {
    return context.dependOnInheritedWidgetOfExactType<PortalProvider>();
  }
}
