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
		@changed = false
		@feed_url = feed_url
		content = "" # raw content of rss feed will be loaded here
		open(@feed_url) do |s|
			content = s.read 
		end
		rss = RSS::Parser.parse(content, false)
		@web_url = rss.channel.link
		@name = rss.channel.title
		@items = {}
		rss.items.each do |item_dict|
			item = Item.new(item_dict)
			@items[item.item_id] = item
		end
		@type = rss.feed_type
	end

	def sync
		# Get remotely changed items
		self.get_changes
		# Save remote changes

		# Get locally changed items
		old_items = self.changed_items
		puts "#{old_items.count} items to send to server..."

		# Send remaining changes to the server
		self.send_changed(old_items)
	end

	def changed_items
		items = @items.values.reject do |item|
			!item.changed
		end
		return items
	end

	def get_changes
		if($modified.nil?)
			$modified = 0
		end
		
		puts "Sending timestamp #{$modified}"
		url = URI.parse("http://0.0.0.0:4567/items.json")
		req = Net::HTTP::Get.new(url.path)
		req.add_field('If-Modified-Since', $modified.to_s)		
		res = Net::HTTP.start(url.host, url.port) do |http|
			http.request(req)
		end
		$modified = res["Last-Modified"]
		puts "Last-modified is now #{res["Last-Modified"]}"
		if(res.code.to_i == 200)
			items = JSON.parse(res.body)
			puts "#{items.count} items changed"
			
			puts "saving #{items.count} changes from server..."
			items.each do |item_hash|
				item = @items[item_hash['item_id']]
				item.update_from_hash(item_hash)
			end
		end
	end

	def send_changed(items)
		if(items.empty?)
			return
		end
		
		url = "http://0.0.0.0:4567/items.json"
		uri = URI.parse(url)
		content = items.to_json
		data = "items=#{content}"
		http = Net::HTTP.new(uri.host, uri.port)
		request = Net::HTTP::Post.new(uri.request_uri)
		request.body = data
		request.content_type = "application/x-www-form-urlencoded"
		res = http.request(request)

		if(res.code.to_i != 200)
			puts "Failed to send request: #{url}, #{res.code}"
			return
		end
		
		items.each do |item|
			item.changed = false
		end
	end
end