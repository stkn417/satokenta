# conding: utf-8

require 'sinatra'
require "sinatra/config_file"
require 'slim'
require 'net/https'
require 'rexml/document'
require 'open-uri'
require 'nokogiri'

class App < Sinatra::Base
  register Sinatra::Reloader
  register Sinatra::ConfigFile

  config_file 'config/constant.yml'

  configure :production, :development do
    enable :logging
  end

  get '/' do

    get_blog

    slim :index
  end


  def get_blog

    uri = URI.parse("https://blog.hatena.ne.jp/stkn_bb/satoken.hateblo.jp/atom/entry")
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true
    request = Net::HTTP::Get.new(uri.path)
    request.basic_auth(settings.hatena_id, settings.hatena_api_pass)
    res = https.request(request)

    doc = REXML::Document.new(res.body)

    @titles = []
    @link_urls = []
    @publisheds = []
    @images = []

    doc.each_element("//feed/entry") do |entry|

    	@titles.push(entry.elements["title"].text)

      entry.each_element(".//link") do |link|
        if link.to_s.include?("alternate")
          tmp = link.to_s[link.to_s.index("http://satoken.hateblo.jp")..link.to_s.size]
          url = tmp[0..tmp.index("\'")-1]
          @link_urls.push(url)
        end
      end
      published = entry.elements["published"].text
      @publisheds.push(published[0..published.index("T")-1])

      if @titles.size >= 4
        break
      end
    end

    @link_urls.each do |url|
      charset = nil
      html = open(url) do |f|
        charset = f.charset # 文字種別を取得
        f.read # htmlを読み込んで変数htmlに渡す
      end

      # htmlをパース(解析)してオブジェクトを作成
      html_doc = Nokogiri::HTML.parse(html, nil, charset)

      html_doc.xpath("//meta[@property='og:image']/@content").each do |attr|
        @images.push(attr.value)
      end
    end

  end
end
