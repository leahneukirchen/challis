# = Challis: a soft lightweight cloth (usually printed)
#
# Copyright (C) 2009 Christian Neukirchen <purl.org/net/chneukirchen>
#
# Challis is freely distributable under the terms of an MIT-style license.
# See COPYING or http://www.opensource.org/licenses/mit-license.php.

class Challis < String
  def pfmt(t)
    t.gsub(/&(?!#\d+;|#x[\da-fA-F]+;|\w+;)/, "&amp;"). # keep entities
      gsub("<", "&lt;").
      gsub(">", "&gt;").
      gsub('"', "&quot;").
      gsub(/\\\\$/, '<br>').
      gsub(/(`+)(.*?)\1/m,            '<code>\2</code>').
      gsub(/\*\*(.*?)\*\*/m,          '<strong>\1</strong>').
      gsub(/\*(.*?)\*/m,              '<em>\1</em>').
      gsub(/\[\[(\S+)\]\]/m,          '<img src="\1">').
      gsub(/\[\[(.*?)\s?(\S+)\]\]/m,  '<img alt="\1" src="\2">').
      gsub(/\[(\S+)\]/m,              '<a href="\1">\1</a>').
      gsub(/\[(.*?)\s?(\S+)\]/m,      '<a href="\2">\1</a>').
      gsub(/\{([\w:.-]+) (.*?)\}/m,   '<span class="\1">\2</span>').
      strip
  end
  
  def prefmt(t)
    t.gsub("&", "&amp;").
      gsub("<", "&lt;").
      gsub(">", "&gt;").
      gsub('"', "&quot;")
  end
  
  def to_html
    depth = 0
    to_close = []

    (split(/\n\n+|(?=^(?:  )*(?:\* |# |=+ ))|(---.*?^---)|^(\{\{[\w:. -]+)|^(\}\})/m).map { |par|
       case par
       when /\A---html\n(.*)^---/m: $1
       when /\A---\n(.*)^---/m:     %Q{<pre><code>#{prefmt $1}</code></pre>}
       when /\A\{\{([\w:. -]+)\z/:  %Q{<div class="#{$1}">}
       when "}}":                   %Q{</div>}
       when /\A\s*\z/:              nil  # ignore
       when /\A((?:  )*)((?:\* |# |" |.*:: ?|=+ )?)(.*)/m  #/
         indent, type, text = $1, $2, $3
         
         new_depth = indent.size/2
         new_depth += 1  unless $2.empty? || type =~ /\A(=+) \z/
         
         if text =~ /^#([A-Za-z][\w:.-]*) /  #/
           id, text = $1, $'
         end
         
         text = pfmt text
         text = "<p>#{text}</p>"  unless type =~ /\A(=+) \z/ || text.empty?  #/
         
         
         if new_depth > depth
           case type
           when '* ':  to_close << %Q{</ul>}
           when '# ':  to_close << %Q{</ol>}
           when '" ':  to_close << %Q{</blockquote>}
           when /::/:  to_close << %Q{</dl>}
           end
         end
         
         case type
         when '* ':        text = %Q{<li>#{text}}; to_close << "</li>"
         when '# ':        text = %Q{<li>#{text}}; to_close << "</li>"
         when /\A(=+) \z/: text = %Q{<h#{$1.size}>#{text}</h#{$1.size}>}
         when /\A:: ?\z/:  text = %Q{<dd>#{text}}; to_close << "</dd>"
         when /(.*):: \z/: text = %Q{<dt>#{$1}</dt><dd>#{text}}; to_close << "</dd>"
         else to_close << ""
         end
         
         text.gsub!(/\A<(\w+)>/, %Q{<\\1 id="#{id}">})  if id
         
         if new_depth > depth
           case type
           when '* ': text = %Q{<ul>#{text}}
           when '# ': text = %Q{<ol>#{text}}
           when '" ': text = %Q{<blockquote>#{text}}
           when /::/: text = %Q{<dl>#{text}}
           end
         end
         
         (2 * (depth - new_depth) + 1).times { text = "#{to_close.pop}\n\n#{text}" }
         
         depth = new_depth
         
         text
       end
     }.compact.join << to_close.reverse.join).lstrip + "\n"
  end
end
