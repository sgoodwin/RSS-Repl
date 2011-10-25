require 'json/pure'

class Item	
	attr_accessor :title
	attr_accessor :unread
	attr_accessor :date
	attr_accessor :item_id
	attr_accessor :changed

	def self.READ
		0 # 00000000 in binary
	end
	
	def self.UNREAD
		128 # 10000000 in binary
	end
	
	def initialize(rss_item)
		@unread = true
		@title = rss_item.title
		@date = rss_item.date.to_i
		@item_id = rss_item.guid.content
		@changed = false
	end

	def update_from_hash(hash)
		@changed = false
		@unread = hash['status'].to_i&128 == self.class.UNREAD # in (binary)10000000, the 1 indicates read, 0 is unread
	end

	def status
		if(@unread)
			"unread"
		else
			"read"
		end
	end

	def toggle_stats
		@unread = !@unread
		@changed = true
	end

	def ==(object)
		self.unread == object.unread
		self.title.eql?(object.title)
		self.date.eql?(object.date)
		self.item_id.eql?(object.item_id)
		self.changed == object.changed
	end

	def to_json(*a)
		stat = 0
		if(self.unread)
			stat = 128
		end
		
		{"datetime"=>self.date,"status"=>stat,"item_id"=>self.item_id}.to_json(*a)
	end
	
	def to_string
		"(#{self.status}) #{self.title}"
	end
end