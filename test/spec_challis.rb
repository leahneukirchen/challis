require 'bacon'
require 'challis'

describe "Challis" do
  
  def fmt(a, b)
    Challis.new(a).to_html.should.equal(b)
  end

  should "support paragraphs" do
    fmt(<<'IN', <<'OUT')
This is a paragraph.

This is
another.
IN
<p>This is a paragraph.</p>

<p>This is
another.</p>
OUT
  end

  should "support headers" do
    fmt(<<'IN', <<'OUT')
= top level

== second
=== third

==== four
IN
<h1>top level</h1>

<h2>second</h2>

<h3>third</h3>

<h4>four</h4>
OUT
  end

  should "support unordered lists" do
    fmt(<<'IN', <<'OUT')
* A simple list

* with a total
of three

* entries.
IN
<ul><li><p>A simple list</p>

</li><li><p>with a total
of three</p>

</li><li><p>entries.</p></li></ul>
OUT

    fmt(<<'IN', <<'OUT')
* A simple list
* with a total
of three
* entries.
IN
<ul><li><p>A simple list</p>

</li><li><p>with a total
of three</p>

</li><li><p>entries.</p></li></ul>
OUT

    fmt(<<'IN', <<'OUT')
* Item 1

  Still item 1

* Item 2
IN
<ul><li><p>Item 1</p>

<p>Still item 1</p>

</li><li><p>Item 2</p></li></ul>
OUT

  end

  should "support ordered lists" do
    fmt(<<'IN', <<'OUT')
# A simple list

# with a total
of three

# entries.
IN
<ol><li><p>A simple list</p>

</li><li><p>with a total
of three</p>

</li><li><p>entries.</p></li></ol>
OUT

    fmt(<<'IN', <<'OUT')
# A simple list
# with a total
of three
# entries.
IN
<ol><li><p>A simple list</p>

</li><li><p>with a total
of three</p>

</li><li><p>entries.</p></li></ol>
OUT
  end

  should "support definition lists" do
    fmt(<<'IN', <<'OUT')
foo:: a metasyntactic variable

hui buh:: a ghost

bar:: a place to get drinks

:: also, see foo.
IN
<dl><dt>foo</dt><dd><p>a metasyntactic variable</p>

</dd><dt>hui buh</dt><dd><p>a ghost</p>

</dd><dt>bar</dt><dd><p>a place to get drinks</p>

</dd><dd><p>also, see foo.</p></dd></dl>
OUT

    # no compact syntax for now.
  end

  should "escape HTML special chars" do
    fmt(<<'IN', <<'OUT')
Look at this: < > & " '

[http://example.com/?foo=1&bar=2]
IN
<p>Look at this: &lt; &gt; &amp; &quot; '</p>

<p><a href="http://example.com/?foo=1&amp;bar=2">http://example.com/?foo=1&amp;bar=2</a></p>
OUT
  end

  should "keep HTML entities" do
    fmt(<<'IN', <<'OUT')
Look at this: &copy; &#8364; &#x20ac;
IN
<p>Look at this: &copy; &#8364; &#x20ac;</p>
OUT
  end

  should "support URL links" do
    fmt(<<'IN', <<'OUT')
Just: [http://example.org/]
IN
<p>Just: <a href="http://example.org/">http://example.org/</a></p>
OUT
  end

  should "support code blocks" do
    fmt(<<'IN', <<'OUT')
---
foo
* bar
&quux;
---
IN
<pre><code>foo
* bar
&amp;quux;
</code></pre>
OUT
  end

  should "support code blocks in blockquotes" do
    fmt(<<'IN', <<'OUT')
" 
---
code
---
IN
<blockquote><pre><code>code
</code></pre></blockquote>
OUT
  end


  should "support inline code" do
    fmt(<<'IN', <<'OUT')
Easy: `single`, or ``dou`ble``,
or even ```tr``ip`l``e```.
IN
<p>Easy: <code>single</code>, or <code>dou`ble</code>,
or even <code>tr``ip`l``e</code>.</p>
OUT
  end

  should "support hard wraps" do
    fmt(<<'IN', <<'OUT')
This works\\
just
like in LaTeX\\
with two backspaces.
IN
<p>This works<br>
just
like in LaTeX<br>
with two backspaces.</p>
OUT
  end

  should "support images" do
    fmt(<<'IN', <<'OUT')
[[http://example.org/pic.jpg]]

[[A nice pic http://example.org/pic.jpg]]
IN
<p><img src="http://example.org/pic.jpg"></p>

<p><img alt="A nice pic" src="http://example.org/pic.jpg"></p>
OUT
  end

  should "support inline HTML" do
    fmt(<<'IN', <<'OUT')
---html
This is passed <verbatim>.
---
IN
This is passed <verbatim>.

OUT
  end

  should "support links" do
    fmt(<<'IN', <<'OUT')
Look at [this picture http://example.org/pic.jpg].

Look at [this nice subpage /foo].
IN
<p>Look at <a href="http://example.org/pic.jpg">this picture</a>.</p>

<p>Look at <a href="/foo">this nice subpage</a>.</p>
OUT
  end

  should "support blockquotes" do
    fmt(<<'IN', <<'OUT')
" Blockquotes are simply introduced by a quotation mark and a space at
the beginning of the line.

  You can continue them by using proper indentation.

  " This is how you nest them.

  Back in the outer blockquote.
IN
<blockquote><p>Blockquotes are simply introduced by a quotation mark and a space at
the beginning of the line.</p>

<p>You can continue them by using proper indentation.</p>

<blockquote><p>This is how you nest them.</p></blockquote>

<p>Back in the outer blockquote.</p></blockquote>
OUT
  end

  should "support inline formatting" do
    fmt(<<'IN', <<'OUT')
Challis can do *italic* and **bold**.

They also *work
for **multiple**
lines*.
IN
<p>Challis can do <em>italic</em> and <strong>bold</strong>.</p>

<p>They also <em>work
for <strong>multiple</strong>
lines</em>.</p>
OUT
  end

  should "correctly translate a complex text" do
    fmt(<<'IN', <<'OUT')
* A list item
* that includes a

  paragraph

  definition list:: 

    # with a numbered list

    and a

---
piece of code
---

  and an

  [[image]]
IN
<ul><li><p>A list item</p>

</li><li><p>that includes a</p>

<p>paragraph</p>

<dl><dt>definition list</dt><dd>

<ol><li><p>with a numbered list</p></li></ol>

<p>and a</p><pre><code>piece of code
</code></pre></dd></dl>

<p>and an</p>

<p><img src="image"></p></li></ul>
OUT
  end

  should "support span" do
    fmt(<<'IN', <<'OUT')
I'll tell you: {spoiler The sleigh is called rosebud.}
IN
<p>I'll tell you: <span class="spoiler">The sleigh is called rosebud.</span></p>
OUT
  end

  should "support div" do
    fmt(<<'IN', <<'OUT')
{{sidebar
Yada yada yada...

Foo.
}}
IN
<div class="sidebar">

<p>Yada yada yada...</p>

<p>Foo.</p></div>
OUT
  end

  should "not fail on special cases" do
    fmt(<<'IN', <<'OUT')
These are---I think---long dashes.

Test::Unit

* foo
# bar
IN
<p>These are---I think---long dashes.</p>

<p>Test::Unit</p>

<ul><li><p>foo</p></li></ul>

<ol><li><p>bar</p></li></ol>
OUT
  end
end
