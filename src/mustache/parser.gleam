import gleam/regex
import gleam/string
import gleam/option.{None, Some}

pub type Ast =
  List(Node)

pub type Node {
  Text(content: String)
  Var(name: List(String))
  Section(name: List(String), content: String)
  InvertedSection(name: List(String), content: String)
  RawVar(name: List(String))
}

pub fn parse(input: String, ast: Ast) -> Ast {
  use <- parse_comment(input, ast)
  use <- parse_section(input, ast)
  use <- parse_raw_var(input, ast)
  use <- parse_var(input, ast)
  use <- parse_text(input, ast)
  ast
}

fn parse_comment(input: String, ast: Ast, next: fn() -> Ast) -> Ast {
  let assert Ok(re) =
    regex.compile(
      "\\A\\{\\{![^}]+\\}\\}",
      regex.Options(multi_line: False, case_insensitive: False),
    )
  case regex.scan(re, input) {
    [regex.Match(content: content, ..)] ->
      input
      |> drop(content)
      |> parse(ast)
    _ -> next()
  }
}

fn parse_section(input: String, ast: Ast, next: fn() -> Ast) -> Ast {
  let assert Ok(re) =
    regex.compile(
      "\\A\\{\\{([#^])\\s*([^}\\s]+?)\\s*\\}\\}\n?(\\s*)(.+)(\\s*)\n?\\{\\{/\\s*\\2\\s*\\}\\}",
      regex.Options(multi_line: True, case_insensitive: False),
    )
  case regex.scan(re, input) {
    [
      regex.Match(
        submatches: [
          Some("^"),
          Some(parts_str),
          Some(lws),
          Some(section_content),
          Some(tws),
        ],
        content: content,
      ),
    ] ->
      input
      |> drop(content)
      |> parse([
        InvertedSection(parse_parts(parts_str), lws <> section_content <> tws),
        ..ast
      ])
    [
      regex.Match(
        submatches: [
          Some("#"),
          Some(parts_str),
          Some(lws),
          Some(section_content),
          Some(tws),
        ],
        content: content,
      ),
    ] ->
      input
      |> drop(content)
      |> parse([
        Section(parse_parts(parts_str), lws <> section_content <> tws),
        ..ast
      ])

    _ -> next()
  }
}

fn parse_raw_var(input: String, ast: Ast, next: fn() -> Ast) -> Ast {
  let assert Ok(re) =
    regex.compile(
      "\\A(?:\\{\\{\\{\\s*([^}\\s]+)\\s*\\}\\}\\}|\\{\\{&\\s*([^}\\s]+)\\s*\\}\\})",
      regex.Options(multi_line: False, case_insensitive: False),
    )
  case regex.scan(re, input) {
    [regex.Match(submatches: [Some(parts_str)], content: content), ..]
    | [regex.Match(submatches: [None, Some(parts_str)], content: content), ..] -> {
      input
      |> drop(content)
      |> parse([RawVar(parse_parts(parts_str)), ..ast])
    }
    _ -> next()
  }
}

fn parse_var(input: String, ast: Ast, next: fn() -> Ast) -> Ast {
  let assert Ok(re) =
    regex.compile(
      "\\A\\{\\{\\s*([^}\\s]+)\\s*\\}\\}",
      regex.Options(multi_line: False, case_insensitive: False),
    )
  case regex.scan(re, input) {
    [regex.Match(submatches: [Some(parts_str)], content: content), ..] -> {
      input
      |> drop(content)
      |> parse([Var(parse_parts(parts_str)), ..ast])
    }
    _ -> next()
  }
}

fn parse_text(input: String, ast: Ast, next: fn() -> Ast) -> Ast {
  let assert Ok(re) =
    regex.compile(
      "\\A[^{]+",
      regex.Options(multi_line: True, case_insensitive: False),
    )
  case regex.scan(re, input) {
    [regex.Match(submatches: [], content: content), ..] -> {
      input
      |> drop(content)
      |> parse([Text(content), ..ast])
    }
    _ -> next()
  }
}

fn drop(input: String, substr: String) -> String {
  string.drop_left(input, string.length(substr))
}

fn parse_parts(input: String) -> List(String) {
  case input {
    "." -> [input]
    _ -> string.split(input, ".")
  }
}
