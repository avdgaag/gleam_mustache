//// Mustache is an implemenation of [mustache](https://mustache.github.io) in Gleam.
//// It provides logic-less templates that can be used for HTML or other output
//// formats.
////
//// ## Templates
////
//// Templates are strings with special tags that will be processed by Mustache. For
//// a full reference of available syntax, see [the manual](https://mustache.github.io/mustache.5.html).
//// This library implements the following tags:
////
//// * `{{ escaped_variables }}`
//// * `{{ nested.variables }}`
//// * `{{{ unescaped_variables }}}`
//// * `{{! comments }}`
//// * `{{# sections }}...{{/ sections }}`
//// * `{{^ inverted_sections }}...{{/ inverted_sections }}`
////
//// ## Context
////
//// The context provides the data to be interpolated into the template. You can construct
//// special `Context` valuesing using `mustache/context`.
////
//// ## Example usage
////
////     import mustache.{render}
////     import mustache/context.{dict, string}
////
////     pub fn example() {
////       "hello, {{ name }}"
////       |> render(dict([#("name", string("world"))]))
////     }
////

import gleam/list
import gleam/string
import gleam/string_builder.{type StringBuilder}
import mustache/context.{type Context}
import mustache/parser.{type Ast}

/// Parse and render a template `input` using some context `vars` and return
/// the expanded results.
///
/// ## Example
///
///     render(
///       "hello, {{ subject }}",
///       dict([#("subject", string("world"))])
///     )
///     |> string_builder.to_string
///     /// "hello, world"
///
pub fn render(input: String, vars: Context) -> StringBuilder {
  input
  |> parser.parse([])
  |> to_string_builder(vars)
}

/// Like `render` but return `String` value instead of a `StringBuilder` value.
pub fn render_string(input: String, vars: Context) -> String {
  render(input, vars)
  |> string_builder.to_string
}

fn to_string_builder(ast: Ast, vars: Context) -> StringBuilder {
  do_to_string_builder(ast, vars, string_builder.new())
}

fn do_to_string_builder(
  ast: Ast,
  vars: Context,
  output: StringBuilder,
) -> StringBuilder {
  case ast {
    [parser.Text(str), ..rest] ->
      str
      |> string_builder.prepend(output, _)
      |> do_to_string_builder(rest, vars, _)
    [parser.InvertedSection(name: parts, content: content), ..rest] ->
      case context.get_value(vars, parts) {
        Ok(context.BoolContext(False)) | Ok(context.ListContext([])) | Error(_) ->
          content
          |> render(context.bool(False))
          |> string_builder.prepend_builder(output, _)
          |> do_to_string_builder(rest, vars, _)
        _ -> do_to_string_builder(rest, vars, output)
      }
    [parser.Section(name: parts, content: content), ..rest] ->
      case context.get_value(vars, parts) {
        Ok(context.BoolContext(True) as v)
        | Ok(context.StringContext(_) as v)
        | Ok(context.DictContext(_) as v) ->
          content
          |> render(v)
          |> string_builder.prepend_builder(output, _)
          |> do_to_string_builder(rest, vars, _)
        Ok(context.ListContext(l)) ->
          l
          |> list.map(render(content, _))
          |> list.reverse
          |> list.fold(output, string_builder.prepend_builder)
          |> do_to_string_builder(rest, vars, _)
        _ -> do_to_string_builder(rest, vars, output)
      }
    [parser.RawVar(name: parts), ..rest] -> {
      case context.get_string(vars, parts) {
        Ok(value) ->
          value
          |> string_builder.prepend(output, _)
          |> do_to_string_builder(rest, vars, _)
        _ -> do_to_string_builder(rest, vars, output)
      }
    }
    [parser.Var(name: parts), ..rest] -> {
      case context.get_string(vars, parts) {
        Ok(value) ->
          value
          |> escape
          |> string_builder.prepend(output, _)
          |> do_to_string_builder(rest, vars, _)
        _ -> do_to_string_builder(rest, vars, output)
      }
    }
    [] -> output
  }
}

fn escape(str: String) -> String {
  str
  |> string.replace("<", "&lt;")
  |> string.replace(">", "&gt;")
}
