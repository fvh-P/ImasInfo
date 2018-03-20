require 'nokogiri'
require 'open-uri'
require 'mastodon'
require 'date'
require 'dotenv'

Dir.chdir(File.expand_path("../", __FILE__))
Dotenv.load

begin
  f = File.open(File.expand_path(ENV["FEED_LIST"], __FILE__), "r")
  feed_list = f.readlines.map do |l|
    l.to_i
  end
rescue
  feed_list = []
end

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
  f.puts("#imas_blog")
  return
end

topics = doc.xpath('//div[@id="topics"]').xpath('.//div[@class="inner"]')
article = topics.css('a')
post = Array.new
begin
  prevurl = log[-2].chomp
rescue
  return
end

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
  client.create_status(e)
  feed_list.each do |id|
    feed = "@#{client.account(id).username} \n#{e}"
    client.create_status(feed, visibility: 'direct')
  end
  f.puts()
  f.puts(Time.now)
  f.puts(e)
end

f.close
