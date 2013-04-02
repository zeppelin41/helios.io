class Web < Sinatra::Base
  helpers Sinatra::ContentFor

  set :markdown, layout_engine: :haml

  helpers do
    def markdown(template, options = {}, locals = {})
      options.merge!({
        hard_wrap: true,
        filter_html: true,
        autolink: true,
        no_intraemphasis: true,
        fenced_code_blocks: true,
        gh_codeblock: true,
        with_toc_data: true
      })

      @toc = render(:markdown, template, options.merge(renderer: Redcarpet::Render::HTML_TOC, layout: false), locals)

      render(:markdown, template, options.merge(renderer: Redcarpet::Render::HTML.new(with_toc_data: true)), locals)
    end
  end

  get '/' do
    cache_control :public, :must_revalidate, max_age: 3600

    haml :index
  end
end

module Haml::Filters::Markdown
  require 'redcarpet/compat'
  include Haml::Filters::Base
  lazy_require "redcarpet"

  def render(text)
    ::Markdown.new(text).to_html
  end
end
