require 'cgi'

module Semplice
  VERSION = '0.0.1'
  TPL_PATTERN = /(\{[%\{\-#!])\s*(.*?)\s*[%\}\-#!]\}/

  @locations = []

  module GlobalContext
    # Define your methods in this module, they will be included
    # automatically in the template context
  end

  class Template
    include GlobalContext

    def self.render(__params)
      new.__render(__params)
    end

    def __render(__params)
      ''
    end

    def include(path, params)
      Semplice.render(path, params).chomp
    end

    def h(val)
      val = CGI.escape_html(val) if val.is_a?(String)
      val
    end
  end

  module TemplateParser
    @@template_dirs = []

    def self.parse(content, names=[])
      tpl = parse_content(content.split(TPL_PATTERN))
      context_vars = names.map{|name| "%s = __params[%p]" % [name, name]}.join(';')
      render_code = tpl[:methods].map{|name, code|
        "def __block_#{name}(__params);#{context_vars};__out = [];#{code};__out.join;end"
      }

      unless tpl[:base]
        render_code << "def __render(__params)"
        render_code <<   context_vars
        render_code <<   "__out = [super(__params)]"
        render_code <<   tpl[:code].join("\n")
        render_code <<   "__out.join.chomp"
        render_code << "end"
      end

      cls = Class.new(tpl[:base] ? template(tpl[:base], names) : Semplice::Template)
      cls.class_eval(render_code.join("\n"))
      cls
    end

    def self.template(path, names)
      cache[path] ||= parse(content_for(path), names)
    end

    private

    def self.content_for(path)
      unless File.exists?(path)
        path = @@template_dirs.map{|l|
          File.join(l, path)
        }.select{|p|
          File.exists?(p)
        }.first
      end
               
      File.read(path)
    end

    def self.template_dirs(dirs = [])
      @@template_dirs = dirs
    end

    def self.parse_content(tokens, content: nil, stopwords: [])
      content ||= {code: [], methods: {}, base: nil}

      while token = tokens.shift
        case token
        when '{%' then
          sub_token = tokens.shift
          case sub_token
          when /^\bblock\b/
            block_name = /^block (?<name>.*)$/.match(sub_token)[:name]
            block_content = parse_content(tokens, stopwords: ['end'])
            content[:methods].merge!(block_content[:methods])
            content[:methods][block_name.to_sym] = block_content[:code].join("\n")
            content[:code] << "__out << __block_#{block_name}(__params)"
          when /\bextends\b/
            content[:base] = /^extends\s+["'](?<tpl>.*)["']$/.match(sub_token)[:tpl]
          when /\binclude\b/
            path = /^include\s+["'](?<tpl>.*)["']$/.match(sub_token)[:tpl]
            content[:code] << "__out << include(\"#{path}\", __params)"
          when /\bend\b/
            return content if stopwords.include?('end')
            content[:code] << 'end'
          else
            content[:code] << sub_token
          end
        when '{{' then # output value
          content[:code] << "__out << (h(#{tokens.shift})).to_s"
        when '{!' then # output value
          content[:code] << "__out << (#{tokens.shift}).to_s"
        when '{-' then # suppress output
          content[:code] << "(#{tokens.shift}).to_s"
        when '{#' then # igore comments
          tokens.shift
        else
          content[:code] << "__out << #{token.dump}" if token != ''
        end
      end

      content
    end

    def self.cache
      Thread.current[:simplex_cache] ||= {}
    end
  end

  module Helpers
    def self.render(path, params={})
      TemplateParser
        .template(path, params.keys)
        .render(params)
    end

    def self.render_text(content, params={})
      TemplateParser
        .parse(content, params.keys)
        .render(params)
    end
  end

  def self.render(*args)
    Helpers.render(*args)
  end

  def self.render_text(*args)
    Helpers.render_text(*args)
  end

  def self.template_dirs(dirs = [])
    TemplateParser.template_dirs(dirs)
  end
end
