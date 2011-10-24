require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'
require 'net/http'
require 'uri'
require 'json/pure'
require 'lib/item'


class Subscription
	attr_accessor :feed_url
	attr_accessor :web_url
	attr_accessor :name
	attr_accessor :type
	attr_accessor :items
	
	def initialize(feed_url)
		@feed_url = feed_url
		
		content = "" # raw content of rss feed will be loaded here
		open(@feed_url) do |s|
			content = s.read 
		end
		rss = RSS::Parser.parse(content, false)
		@web_url = rss.channel.link
		@name = rss.channel.title
		@items = []
		rss.items.each do |item|
			@items.push(Item.new(item))
		end
		@type = rss.feed_type
	end
	
	def sync
		url = "http://0.0.0.0:4567/items.json"
		uri = URI.parse(url)
		content = @items.to_json
		data = "items=#{content}"
		http = Net::HTTP.new(uri.host, uri.port)
		request = Net::HTTP::Post.new(uri.request_uri)
		request.body = data
		request.content_type = "application/x-www-form-urlencoded"
		res = http.request(request)
		
		if(res.code != Net::HTTPOK)
			puts "Faild to send request: #{url}, #{res.code}"
		else
			puts res.body
		end		
	end
end