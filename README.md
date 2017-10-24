# README

## Name

Red Arrow

## Description

Red Arrow is a Ruby bindings of Apache Arrow. Red Arrow is based on GObject Introspection.

[packages.red-data-tools.org]( https://github.com/red-data-tools/packages.red-data-tools.org) is an in-memory columnar data store. It's used by many products for data analytics.

[GObject Introspection](https://wiki.gnome.org/action/show/Projects/GObjectIntrospection) is a middleware for language bindings of C library. GObject Introspection can generate language bindings automatically at runtime.

Red Arrow uses [Arrow GLib](https://github.com/apache/arrow/tree/master/c_glib) and [gobject-introspection gem](https://rubygems.org/gems/gobject-introspection) to generate Ruby bindings of Apache Arrow.

Arrow GLib is a C wrapper for [Arrow C++](https://github.com/apache/arrow/tree/master/cpp). GObject Introspection can't use Arrow C++ directly. Arrow GLib is a bridge between Arrow C++ and GObject Introspection.

gobject-introspection gem is a Ruby bindings of GObject Introspection. Red Arrow uses GObject Introspection via gobject-introspection gem.

## Install

Install Arrow GLib before install Red Arrow. Use [Apache Arrow packages](https://github.com/red-data-tools/arrow-packages) for installing Arrow GLib.

Install Red Arrow after you install Arrow GLib:

```text
% gem install red-arrow
```

## Usage

```ruby
require "arrow"

# TODO
```

## Dependencies

* [Apache Arrow](https://arrow.apache.org/)

* [Arrow GLib](https://github.com/apache/arrow/tree/master/c_glib)

* [gobject-introspection gem](https://rubygems.org/gems/gobject-introspection)

## Authors

* Kouhei Sutou \<kou@clear-code.com\>

## License

Apache License 2.0. See `doc/text/apache-2.0.txt` and `NOTICE` for
details.

(Kouhei Sutou has a right to change the license including contributed
patches.)
