# README

## Name

RArrow

## Description

RArrow is a Ruby bindings of Apache Arrow. RArrow is based on GObject Introspection.

[Apache Arrow](https://arrow.apache.org/) is an in-memory columnar data store. It's used by many products for data analytics.

[GObject Introspection](https://wiki.gnome.org/action/show/Projects/GObjectIntrospection) is a middleware for language bindings of C library. GObject Introspection can generate language bindings automatically at runtime.

RArrow uses [arrow-glib](https://github.com/kou/arrow-glib) and [gobject-introspection gem](https://rubygems.org/gems/gobject-introspection) to generate Ruby bindings of Apache Arrow.

arrow-glib is a C wrapper for Apache Arrow. Apache Arrow is a C++ library. So GObject Introspection can't use Apache Arrow directly. arrow-glib is a bridge between Apache Arrow and GObject Introspection.

gobject-introspection gem is a Ruby bindings of GObject Introspection. RArrow uses GObject Introspection via gobject-introspection gem.

## Usage

```ruby
require "arrow"

# TODO
```

## Dependencies

* [Apache Arrow](https://arrow.apache.org/)

* [arrow-glib](https://github.com/kou/arrow-glib)

* [gobject-introspection gem](https://rubygems.org/gems/gobject-introspection)

## Authors

* Kouhei Sutou \<kou@clear-code.com\>

## License

Apache License 2.0. See doc/text/apache-2.0.txt for details.

(Kouhei Sutou has a right to change the license including contributed
patches.)
