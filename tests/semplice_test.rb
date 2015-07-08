require 'minitest/autorun'
require 'semplice'

Semplice.template_dirs([
  File.join(File.dirname(__FILE__), 'templates')
])


describe Semplice do
  describe "text rendering" do
    it "must render plain text" do
      Semplice.render_text("hello").must_equal('hello')
    end

    it "must include the given value" do
      Semplice.render_text("hello {{ name }}", name: 'world').must_equal('hello world')
    end

    it "must verify an 'if' clause" do
      Semplice.render_text("hello {% if name == 'world' %}mundo{% else %}{{ name }}{% end %}",
                           name: 'world').must_equal('hello mundo')
      Semplice.render_text("hello {% if name == 'world' %}mundo{% else %}{{ name }}{% end %}",
                           name: 'semplice').must_equal('hello semplice')
    end

    it "must verify a 'while' clause" do
      Semplice.render_text("hello{% while name = names.shift %} {{ name }}{% end %}",
                           names: ['world', 'mundo']).must_equal('hello world mundo')
    end

    it "must verify a 'case' clause" do
      Semplice.render_text("hello{% case name %}{% when 'world' then %} World{% end %}",
                           name: 'world').must_equal('hello World')
    end

    it "must verify a 'map' block" do
      Semplice.render_text("hello{% names.map do |name| %} {{ name }}{% end %}",
                           names: ['world', 'mundo']).must_equal('hello world mundo')
    end

    it "must verify comments" do
      Semplice.render_text("{# just a comment #}").must_equal('')
    end

    it "must verify XML automatic escaping" do
      Semplice.render_text("hello {{ name }}", name: '<strong>world</strong>')
        .must_equal('hello &lt;strong&gt;world&lt;/strong&gt;')
    end

    it "must verify XML no-escaping" do
      Semplice.render_text("hello {! name !}", name: '<strong>world</strong>')
        .must_equal('hello <strong>world</strong>')
    end

    it "must verify content suppressing" do
      Semplice.render_text("hello {- name -}", name: 'world')
        .must_equal('hello ')
    end

    it "must verify inline computation" do
      Semplice.render_text("hello {{ name * 2 }}", name: 'world')
        .must_equal('hello worldworld')
      Semplice.render_text("{- a = 10 -}hello {{ a * 2 }}")
        .must_equal('hello 20')
    end
  end

  describe "template rendering" do
    it "must render plain text" do
      Semplice.render("test_render_plain.txt")
        .must_equal("hello")
    end

    it "must include the given value" do
      Semplice.render("test_render_context.txt", name: 'world')
        .must_equal("hello world")
    end

    it "must verify an 'if' clause" do
      Semplice.render("test_if.txt", name: 'world')
        .must_equal("hello mundo")
      Semplice.render("test_if.txt", name: 'semplice')
        .must_equal("hello semplice")
    end

    it "must verify a 'while' clause" do
      Semplice.render("test_while.txt", names: ['world', 'mundo'])
        .must_equal("hello world mundo")
    end

    it "must verify a 'case' clause" do
      Semplice.render("test_case.txt", name: 'world')
        .must_equal("hello World")
    end

    it "must verify a 'map' block" do
      Semplice.render("test_map.txt", names: ['world', 'mundo'])
        .must_equal("hello world mundo")
    end

    it "must verify comments" do
      Semplice.render("test_comment.txt")
        .must_equal("")
    end

    it "must verify XML automatic escaping" do
      Semplice.render("test_escaping.xml", name: '<strong>world</strong>')
        .must_equal("hello &lt;strong&gt;world&lt;/strong&gt;")
    end

    it "must verify XML no-escaping" do
      Semplice.render("test_no_escaping.xml", name: '<strong>world</strong>')
        .must_equal("hello <strong>world</strong>")
    end

    it "must verify content suppressing" do
      Semplice.render("test_content_suppressing.txt", name: 'world')
        .must_equal("hello ")
    end

    it "must verify inline computation" do
      Semplice.render("test_verify_computation1.txt", name: 'world')
        .must_equal("hello worldworld")
      Semplice.render("test_verify_computation2.txt")
        .must_equal("hello 20")
    end
  end

  describe "template inclusion" do
    it "must render the included template" do
      Semplice.render("test_inclusion.txt")
        .must_equal("before include\ninclude this\nafter include")
    end
  end

  describe "template inheritance" do
    it "must render the base template" do
      Semplice.render("test_inheritance_base.txt")
        .must_equal("base template\n\ndefault block content\n")
    end

    it "must render the child template" do
      Semplice.render("test_inheritance_child.txt")
        .must_equal("base template\n\ncontent replacement\n")
    end
  end

  describe "global context" do
    it "must use the defined function" do
      module Semplice::GlobalContext
        def twice(val)
          val * 2
        end
      end

      Semplice.render("test_global_context.txt")
        .must_equal("twice 10 is 20")
    end
  end
end
