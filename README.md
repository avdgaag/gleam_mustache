# Mustache

[![Package Version](https://img.shields.io/hexpm/v/mustache)](https://hex.pm/packages/mustache)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/mustache/)

Mustache is an implemenation of [mustache](https://mustache.github.io) in Gleam.
It provides logic-less templates that can be used for HTML or other output
formats.

## Templates

Templates are strings with special tags that will be processed by Mustache. For
a full reference of available syntax, see [the manual](https://mustache.github.io/mustache.5.html).
This library implements the following tags:

* `{{ escaped_variables }}`
* `{{ nested.variables }}`
* `{{{ unescaped_variables }}}`
* `{{! comments }}`
* `{{# sections }}...{{/ sections }}`
* `{{^ inverted_sections }}...{{/ inverted_sections }}`

## Context

The context provides the data to be interpolated into the template. You can construct
special `Context` valuesing using `mustache/context`.

## Quick start

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```

Use in your Gleam program:

``` gleam
import mustache.{render}
import mustache/context.{dict, string}

pub fn example() {
  "hello, {{ name }}"
  |> render(dict([#("name", string("world"))]))
}
```

## Installation

If available on Hex this package can be added to your Gleam project:

```sh
gleam add mustache
```

and its documentation can be found at <https://hexdocs.pm/mustache>.
