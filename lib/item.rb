require 'json/pure'

class Item
	attr_accessor :title
	attr_accessor :unread
	attr_accessor :date
	attr_accessor :item_id
	
	def initialize(rss_item)
		@unread = true
		@title = rss_item.title
		@date = rss_item.date.to_i
		@item_id = rss_item.guid.content
	end
	
	def status
		if(@unread)
			"unread"
		else
			"read"
		end
	end
	
	def to_json(*a)
		stat = 10000000
		if(self.unread)
			stat = 10000000
		else
			stat = 00000000
		end
		{
			"datetime"=>self.date,
			"status"=>stat,
			"item_id"=>self.item_id
		}.to_json(*a)
	end
end