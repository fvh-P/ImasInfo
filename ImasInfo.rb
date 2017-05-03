require 'nokogiri'
require 'open-uri'
require 'mastodon'
require 'date'
require 'dotenv'

Dotenv.load
f = File.open("#{ENV["LOG_FILE"]}","r")
log = f.readlines
f.close
f = File.open("#{ENV["LOG_FILE"]}","a")
client = Mastodon::REST::Client.new(base_url: ENV["MASTODON_URL"], bearer_token: ENV["MASTODON_ACCESS_TOKEN"])
src = "http://idolmaster.jp/blog/"
begin
    doc = Nokogiri::HTML(open(src))
rescue
    f.puts(Time.now)
    f.puts("アクセスできませんでした。\n#{src}")
    f.puts(log[-2])
    f.puts()
end

if doc == nil
    return
end

topics = doc.xpath('//div[@id="topics"]').xpath('.//div[@class="inner"]')
article = topics.css('a')
post = []
prevurl = log[-1].chomp
article.each_with_index do |e, i|
    title = e.inner_html
    url = e.attribute('href').value
    if(prevurl.eql?(url))
        break
    else
        post << "【アイマス公式ブログ更新情報】\n#{title}\n#{url}"
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
