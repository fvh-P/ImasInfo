require 'nokogiri'
require 'open-uri'
require 'mastodon'
require 'date'
require 'dotenv'

Dir.chdir(File.expand_path("../", __FILE__))
Dotenv.load

f = File.open(File.expand_path("../ImasInfo.log", __FILE__),"r")
log = f.readlines
f.close

f = File.open(File.expand_path("../ImasInfo.log", __FILE__),"a")
client = Mastodon::REST::Client.new(base_url: ENV["MASTODON_URL"], bearer_token: ENV["MASTODON_ACCESS_TOKEN"])
src = "http://idolmaster.jp/blog/"

begin
    doc = Nokogiri::HTML(open(src))
rescue
    f.puts()
    f.puts(Time.now)
    f.puts("アクセスできませんでした。\n#{src}")
    f.puts(log[-2])
    return
end

topics = doc.xpath('//div[@id="topics"]').xpath('.//div[@class="inner"]')
article = topics.css('a')
post = Array.new
prevurl = log[-2].chomp

article.each_with_index do |e, i|
    title = e.inner_html
    url = e.attribute('href').value
    if(prevurl.eql?(url))
        break
    else
        post << "【アイマス公式ブログ更新情報】\n#{title}\n#{url}\n#imas_blog\n"
    end
end

post.reverse.each do |e|
    puts e
    client.create_status(e)
    f.puts()
    f.puts(Time.now)
    f.puts(e)
end

f.close
