module Jekyll
    class RenderPgTreeTagBlock < Liquid::Block

      def whitespace(c)
        c == ' ' || c == '\t' || c == '\r' || c == '\n'
      end

      def tokenize(text)
        text.gsub("(", " ( ").gsub(")", " ) ").split
      end

      def parse_pgtree(tokens)
        result = [":)"]
        stack = []
        tokens.each { |token|
            created = nil
            if token[0] == '{'
                created = ["obj", token, []]
            elsif token == '('
                created = ["arr", []]
            elsif token == ')' || token == '}'
                if stack.last[0] == "val"
                    stack.pop
                end
                result = stack.last
                stack.pop
            elsif token[0] == ':'
                if stack.last[0] == "val"
                    stack.pop
                end
                stack.last[2].push([token, nil])
            elsif stack.last[0] != "val"
                created = ["val", [token]]
            else
                stack.last[1].push(token)
            end

            if !created.nil?
                if !stack.empty?
                    if stack.last[0] == "arr"
                        stack.last[1].push(created)
                    elsif stack.last[0] == "obj"
                        stack.last[2].last[1] = created
                    end
                end
                stack.push(created)
            end
        }
        result
      end

      def render_obj(p, isroot)
        id = rand(10000000)
        checked = ""
        if isroot
            checked = "checked"
        end
        result = "<ul><li><input #{checked} type='checkbox' id='chk-#{id}' /><label for='chk-#{id}'>#{p[1]}</label><ul class='obj-contents'>"
        p[2].each { |kv|
            result += "<li>"
            result += "<b>#{kv[0]}</b> "
            result += render_rec(kv[1], false)
            result += "</li>"
        }
        result += "</ul>"
        result += "<div class='obj-placeholder'>&nbsp;&nbsp;&nbsp;&nbsp;...</div>"
        result += "</li><li>&nbsp;&nbsp;}</li></ul>"
        result
      end

      def render_arr(p, isroot)
        id = rand(10000000)
        cnt = p[1].length
        checked = ""
        if cnt < 2
            checked = "checked"
        end
        result = "<ul><li><input #{checked} type='checkbox' id='chk-#{id}' /><label for='chk-#{id}'>(</label><ul class='obj-contents'>"
        p[1].each { |v|
            result += "<li>"
            result += render_rec(v, false)
            result += "</li>"
        }
        result += "</ul>"
        result += "<div class='obj-placeholder'>&nbsp;&nbsp;&nbsp;&nbsp;(#{cnt} items)</div>"
        result += "</li><li>&nbsp;&nbsp;)</li></ul>"
        result
      end

      def render_val(p, isroot)
        p[1].join(" ")
      end

      def render_rec(p, isroot)
        result = ""
        if p[0] == "obj"
            result = render_obj(p, isroot)
        elsif p[0] == "arr"
            result = render_arr(p, isroot)
        elsif p[0] == "val"
            result = render_val(p, isroot)
        end
        result
      end
  
      def render(context)
        text = super
        # ""
        result = render_rec(parse_pgtree(tokenize(text)), true)
        result = "<div class='pgtree'>#{result}</div>"
      end
  
    end
  end
  
  Liquid::Template.register_tag('pgtree', Jekyll::RenderPgTreeTagBlock)
  