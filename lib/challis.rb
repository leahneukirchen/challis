# = Challis: a soft lightweight cloth (usually printed)
#
# Copyright (C) 2009, 2010 Christian Neukirchen <purl.org/net/chneukirchen>
#
# Challis is freely distributable under the terms of an MIT-style license.
# See README or <http://www.opensource.org/licenses/mit-license.php>.

class Challis < String
  def pfmt(t)
    t.gsub(/\\([^\\\n]|\\(?!\n))/) { "&ChallisEscape#{$&.unpack("U*")[1]};" }.
      gsub(/&(?!#\d+;|#x[\da-fA-F]+;|\w+;)/, "&amp;"). # keep entities
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
      gsub(/&ChallisEscape(\d+);/) { [$1.to_i].pack("U*") }.
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
    last = ""

    (split(/\n\n+|(?=^(?:  )*(?:\* |# |=+ ))|^(---.*?^---)|^(\{\{[\w:. -]+)|^(\}\})/m).map { |par|
       case par
       when /\A---html\n(.*)^---/m; $1
       when /\A---\n(.*)^---/m;     %Q{<pre><code>#{prefmt $1}</code></pre>}
       when /\A\{\{([\w:. -]+)\z/;  %Q{<div class="#{$1}">}
       when "}}";                   %Q{</div>}
       when /\A\s*\z/;              nil  # ignore
       when /\A((?:  )*)((?:\* |# |" |.*::(?: |$)|=+ )?)(.*)/m  #/
         indent, type, text = $1, $2.strip, $3

         if type =~ /::\z/
           dt, type = $`, $&
         end

         new_depth = indent.size/2
         new_depth += 1  unless type.empty? || type =~ /\A(=+)\z/
         
         if text =~ /^#([A-Za-z][\w:.-]*) /  #/
           id, text = $1, $'
         end
         
         text = pfmt text
         text = "<p>#{text}</p>"  unless type =~ /\A(=+)\z/ || text.empty?  #/

         closing = to_close.slice!(0, [depth - new_depth, 0].max).join
         
         fresh = new_depth > depth

         if depth == new_depth && type != last && !type.empty?
           closing = to_close.shift.to_s
           fresh = true
         end

         if fresh
           case type
           when '*';  to_close.unshift %Q{</li></ul>}
           when '#';  to_close.unshift %Q{</li></ol>}
           when '"';  to_close.unshift %Q{</blockquote>}
           when '::'; to_close.unshift %Q{</dd></dl>}
           end
         end

         case type
         when '*';        text = "<li>" + text
         when '#';        text = "<li>" + text
         when /\A(=+)\z/; text = "<h#{$1.size}>#{text}</h#{$1.size}>"
         when '::';       text = (dt.empty? ? "" : "<dt>#{dt}</dt>") + "<dd>" + text
         end
         
         text.gsub!(/\A<(\w+)>/, %Q{<\\1 id="#{id}">})  if id

         case type
         when '*';  text = (fresh ? "<ul>"         : "</li>") + text
         when '#';  text = (fresh ? "<ol>"         : "</li>") + text
         when '"';  text = (fresh ? "<blockquote>" : ""     ) + text
         when '::'; text = (fresh ? "<dl>"         : "</dd>") + text
         end

         depth = new_depth
         last = type  unless type.empty?
         
         closing + "\n\n" + text
       end
     }.compact.join << to_close.reverse.join).lstrip + "\n"
  end
end
