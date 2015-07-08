# Semplice

``Semplice`` is a [mote](https://github.com/soveran/mote) inspired
template engine with Django-like syntax and inheritance.


## Usage

``Semplice`` use is quite strightforward, put your content on a
template (or not) and call render.

```
Semplice.render('path/to/template', {
  foo: 'bar',
  baz: 'quox'
})
```

Or you can render directly from text:

```
Semplice.render_text('hello {{ world }}', {
  world: 'earthlings'
})
```

## Templates

### Values

Values passed through context can be ``rendered`` into the content by
using ``{{ ... }}`` (automatically escapes HTML) or ``{! ... !}``
(doesn't escape the content). For instance, consider ``val`` equals
to ``<strong>world</strong>``:

```
Hello {{ val }} -> Hello &lt;strong&gt;world&lt;/strong&gt;
Hello {! val !} -> Hello <strong>world</strong>
```

There's also the syntax ``{- ... -}`` that will supress the output,
this is useful for small computations, usually assignments:

```
{- foo = "bar" -}
Hello {{ foo }}
```


### Code blocks

Ruby code can be injected using the ``{% ... %}...{% end %}`` syntax:


Loops:

```
{% val.map do |v| %}
  ...
{% end %}
```

```
{% while ... %}
  ...
{% end %}
```

Conditionals:

```
{% if val == "foo" %}
  ...
{% elsif val == "bar" %}
  ...
{% else %}
  ...
{% end %}
```

```
{% case val %}
  ...
{% when "foo" %}
  ...
{% when "bar" %}
  ...
{% else %}
  ...
{% end %}
```

Any ruby construct is valid here.


### Comments

Comments can be added with ``{# ... #}``, they will be ignored from
the output.


### Inclusion

Include other templates using the ``{% include ... %}`` tag:

```
{% include "path/to/other-template" %}
```


### Content blocks

A template can define content blocks that can be overriden later when
using inheritance. For example:

```
This content goes before the block.
{% block content %}
  This is the default content of this block.
{% end %}
This content goes after the block.
```


### Inheritance

Templates can be ``extended`` using the ``{% extends ... %}`` syntax,
content blocks can be overriden to provide new content. Take for
instance this base template:

```
{# this is foo.html #}
<h1>{% block title %}Foo title{% end %}</h1>
```

Then we can extend it:

```
{# this is bar.html #}
{% extends "foo.html" %}
{% block title %}Bar title{% end %}
```

Rendering ``foo.html`` will output:

```
<h1>Foo title</h1>
```

But rendering ``bar.html``:

```
<h1>Bar title</h1>
```

## Global context

Any method defined in ``Semplice::GlobalContext`` will be available in
the template context at rendering time:

```ruby
moudle Semplice::GlobalContext
  def twice(val)
    val * 2
  end
end
```

Then:

```
10 * 2 = {{ twice(10) }}
```

## Helpers

You can include the ``Helpers`` module to simplify access to
``render`` and ``render_text`` methods.

```ruby
include Semplice::Helpers
```
