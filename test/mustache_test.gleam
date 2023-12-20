import gleeunit
import gleeunit/should
import mustache
import mustache/context

pub fn main() {
  gleeunit.main()
}

pub fn simple_string_test() {
  "Example string"
  |> mustache.render_string(context.dict([]))
  |> should.equal("Example string")
}

pub fn string_with_tag_test() {
  "Hello {{ name }}"
  |> mustache.render_string(context.dict([]))
  |> should.equal("Hello ")
}

pub fn string_with_tag_and_var_test() {
  let context = context.dict([#("name", context.string("john"))])

  "Hello {{ name }}, multiple times, {{ name }}"
  |> mustache.render_string(context)
  |> should.equal("Hello john, multiple times, john")
}

pub fn float_values_test() {
  let context = context.dict([#("weight", context.float(12.5))])
  "Your weight is {{ weight }}"
  |> mustache.render_string(context)
  |> should.equal("Your weight is 12.5")
}

pub fn int_values_test() {
  let context = context.dict([#("age", context.int(12))])
  "Your age is {{ age }}"
  |> mustache.render_string(context)
  |> should.equal("Your age is 12")
}

pub fn nested_values_test() {
  let context =
    context.dict([
      #("person", context.dict([#("name", context.string("john"))])),
    ])

  "Hello {{ person.name }}"
  |> mustache.render_string(context)
  |> should.equal("Hello john")

  "Hello {{ person.age }}"
  |> mustache.render_string(context)
  |> should.equal("Hello ")
}

pub fn escapes_values_test() {
  let context = context.dict([#("name", context.string("<b>john</b>"))])

  "Hello {{ name }}"
  |> mustache.render_string(context)
  |> should.equal("Hello &lt;b&gt;john&lt;/b&gt;")
}

pub fn raw_variable_test() {
  let context = context.dict([#("name", context.string("<b>john</b>"))])

  "Hello {{{ name }}}, {{&name}}, {{ name }}"
  |> mustache.render_string(context)
  |> should.equal("Hello <b>john</b>, <b>john</b>, &lt;b&gt;john&lt;/b&gt;")
}

pub fn boolean_section_test() {
  let context = context.dict([#("person", context.bool(False))])

  "Shown.
{{#person}}
  Never shown!
{{/person}}"
  |> mustache.render_string(context)
  |> should.equal("Shown.\n")

  let context2 = context.dict([#("person", context.bool(True))])

  "Shown.
{{#person}}
  Never shown!
{{/person}}"
  |> mustache.render_string(context2)
  |> should.equal("Shown.\n  Never shown!\n")
}

pub fn string_section_test() {
  let context = context.dict([#("person", context.string(""))])

  "Shown.
{{#person}}
  Never shown!
{{/person}}"
  |> mustache.render_string(context)
  |> should.equal("Shown.\n  Never shown!\n")
}

pub fn nested_section_test() {
  let context =
    context.dict([
      #("person", context.dict([#("name", context.string("john"))])),
    ])

  "Shown.
{{#person}}
  Never shown!
{{/person}}"
  |> mustache.render_string(context)
  |> should.equal("Shown.\n  Never shown!\n")
}

pub fn nested_section_with_vars_test() {
  let context =
    context.dict([
      #("person", context.dict([#("name", context.string("john"))])),
    ])

  "Shown.
{{#person}}
  Name: {{ name }}
{{/person}}"
  |> mustache.render_string(context)
  |> should.equal("Shown.\n  Name: john\n")
}

pub fn nested_section_with_vars_and_plain_vars_test() {
  let context = context.dict([#("name", context.string("john"))])

  "Shown.
{{#name}}
  Name: {{ name }}
{{/name}}"
  |> mustache.render_string(context)
  |> should.equal("Shown.\n  Name: \n")
}

pub fn nested_section_with_dot_for_current_contex_test() {
  let context = context.dict([#("name", context.string("john"))])

  "Shown.
{{#name}}
  Name: {{ . }}
{{/name}}"
  |> mustache.render_string(context)
  |> should.equal("Shown.\n  Name: john\n")
}

pub fn section_with_lists_test() {
  let context =
    context.dict([
      #(
        "beatles",
        context.list([
          context.string("john"),
          context.string("paul"),
          context.string("george"),
          context.string("ringo"),
        ]),
      ),
    ])

  "Shown.
{{#beatles}}
  * {{ . }}
{{/beatles}}"
  |> mustache.render_string(context)
  |> should.equal("Shown.\n  * john\n  * paul\n  * george\n  * ringo\n")
}

pub fn section_with_lists_of_complex_values_test() {
  let context =
    context.dict([
      #(
        "beatles",
        context.list([
          context.dict([#("name", context.string("john"))]),
          context.dict([#("name", context.string("paul"))]),
          context.dict([#("name", context.string("george"))]),
          context.dict([#("name", context.string("ringo"))]),
        ]),
      ),
    ])

  "Shown.
{{#beatles}}
  * {{ name }}
{{/beatles}}"
  |> mustache.render_string(context)
  |> should.equal("Shown.\n  * john\n  * paul\n  * george\n  * ringo\n")
}

pub fn empty_list_section_test() {
  let context = context.dict([#("person", context.list([]))])

  "Shown.
{{#person}}
  Never shown!
{{/person}}"
  |> mustache.render_string(context)
  |> should.equal("Shown.\n")
}

pub fn section_unknown_key_test() {
  let context = context.dict([#("person", context.list([]))])

  "Shown.
{{#beatles}}
  Never shown!
{{/beatles}}"
  |> mustache.render_string(context)
  |> should.equal("Shown.\n")
}

pub fn inverted_section_bool_test() {
  let context = context.dict([#("person", context.bool(True))])

  "Shown.
{{^person}}
  Never shown!
{{/person}}"
  |> mustache.render_string(context)
  |> should.equal("Shown.\n")

  let context2 = context.dict([#("person", context.bool(False))])

  "Shown.
{{^person}}
  Never shown!
{{/person}}"
  |> mustache.render_string(context2)
  |> should.equal("Shown.\n  Never shown!\n")
}

pub fn inverted_section_list_test() {
  let context =
    context.dict([#("person", context.list([context.string("person")]))])

  "Shown.
{{^person}}
  Never shown!
{{/person}}"
  |> mustache.render_string(context)
  |> should.equal("Shown.\n")

  let context2 = context.dict([#("person", context.list([]))])

  "Shown.
{{^person}}
  Never shown!
{{/person}}"
  |> mustache.render_string(context2)
  |> should.equal("Shown.\n  Never shown!\n")
}

pub fn comments_test() {
  "test {{! comment }}"
  |> mustache.render_string(context.bool(True))
  |> should.equal("test ")
}
