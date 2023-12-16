//// The context provides data to a template in a type-safe way. You
//// can compose values togehter using various utility functions such
//// as `string`, `list` and `dict`.
////
//// ## Example
////
//// To provide two variables to a template, one with the number of beatles
//// and list of members of the Beatles, you can create a `Context` value like
//// so:
////
////     dict([
////       #("member_count", int(4)),
////       #("members", list([
////         dict([#("name", string("Paul"))]),
////         dict([#("name", string("John"))]),
////         dict([#("name", string("George"))]),
////         dict([#("name", string("Ringo"))]),
////         ]))
////       ])
////
//// You could render this value with a template like this:
////
////     "<p>There are {{ member_count }} members of the Beatles:</p>
////
////     <ul>
////       {{# members }}
////       <li>{{ name }}</li>
////       {{/ members }}
////     </ul>"
////

import gleam/float
import gleam/int
import gleam/dict.{type Dict}

pub type Context {
  BoolContext(value: Bool)
  StringContext(value: String)
  DictContext(value: Dict(String, Context))
  ListContext(value: List(Context))
}

/// Encode a `Float` value by transforming it to a `String`.
///
/// ## Example
///
///     float(1.3) /// StringContext("1.3")
///
pub fn float(value: Float) -> Context {
  StringContext(float.to_string(value))
}

/// Encode a `Int` value by transforming it to a `String`.
///
/// ## Example
///
///     int(3) /// StringContext("3")
///
pub fn int(value: Int) -> Context {
  StringContext(int.to_string(value))
}

/// Encode a `Dict` value from a list of key/value pairs.
///
/// ## Example
///
///     dict([#("name", string("John")), #("age", int(38))])
///
pub fn dict(value: List(#(String, Context))) -> Context {
  DictContext(dict.from_list(value))
}

/// Encode a `List` value.
///
/// ## Example
///
///     list(string("John"), int(41))
///
pub fn list(value: List(Context)) -> Context {
  ListContext(value)
}

/// Encode a `Bool` value.
///
/// ## Example
///
///     bool(True)
///
pub fn bool(value: Bool) -> Context {
  BoolContext(value)
}

/// Encode a `String` value.
///
/// ## Example
///
///     string("John")
///
pub fn string(value: String) -> Context {
  StringContext(value)
}

/// Retrieve a potentially nested value from a `Context` value.  When given
/// multiple parts, values will be looked up in nested dictionaries.
/// When names cannot be resolved, this will result in `Error(Nil)`.
///
/// ## Example
///
///     let context = dict([
///       #("beatles", dict([
///         #("paul", string("bass"))
///       ]))
///     ])
///     get_value(context, ["beatles", "paul"]) /// Ok(StringContext("bass"))
///     get_value(context, ["beatles", "john"]) /// Error(Nil)
///     get_value(context, ["beatles"]) /// Ok(dict([#("paul", string("bass"))]))
pub fn get_value(ctx: Context, parts: List(String)) -> Result(Context, Nil) {
  case ctx, parts {
    DictContext(d), [first] ->
      case dict.get(d, first) {
        Ok(v) -> Ok(v)
        Error(_) -> Error(Nil)
      }
    DictContext(d), [first, ..rest] ->
      case dict.get(d, first) {
        Ok(DictContext(_) as c) -> get_value(c, rest)
        _ -> Error(Nil)
      }
    other, ["."] -> Ok(other)
    _, _ -> Error(Nil)
  }
}

/// Retrieve a potentially nested terminal string value from a `Context` value.
/// When given multiple parts, values will be looked up in nested dictionaries.
/// When names cannot be resolved, this will result in `Error(Nil)`.
///
/// ## Example
///
///     let context = dict([
///       #("beatles", dict([
///         #("paul", string("bass"))
///       ]))
///     ])
///     get_value(context, ["beatles", "paul"]) /// Ok("bass")
///     get_value(context, ["beatles", "john"]) /// Error(Nil)
///     get_value(context, ["beatles"]) /// Error(Nil)
pub fn get_string(ctx: Context, parts: List(String)) -> Result(String, Nil) {
  case get_value(ctx, parts) {
    Ok(StringContext(s)) -> Ok(s)
    _ -> Error(Nil)
  }
}
