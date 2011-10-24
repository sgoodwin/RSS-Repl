require 'rubygems'
require 'lib/item'
require 'lib/subscription'

@@subscription = Subscription.new("http://feeds2.feedburner.com/lockfocus")
@@items = @@subscription.items
puts "found #{@@items.count} items:"

def help
	puts "p: print item list"
	puts "n: toggle read/unread on item n"
	puts "m: mark all as read"
	puts "u: mark all as unread"
	puts "h: show this help menu"
	puts "s: sync"
	puts "q: quit"
end

def print_item_list
	@@items.each_index do |i|
		item = @@items[i]
		puts "#{i+1}: (#{item.status}) #{item.title} @#{item.date}"
	end
end

def mark_all_read
	@@items.each do |item|
		item.unread = false
	end
	
	print_item_list
end

def mark_all_unread
	@@items.each do |item|
		item.unread = true
	end
	
	print_item_list
end

def try_to_toggle_item_number(number)
	integer = (number.to_i)-1
	if(integer >= 0)
		item = @@items[integer]
		item.unread = !item.unread
		print_item_list
	else
		print_item_list
	end
end

def sync
	puts "syncing..."
	@@subscription.sync
end

while(1) do
	a = gets.chomp
	case a.to_s
	when "h"
		help
	when "p"
		print_item_list
	when "m"
		mark_all_read
	when "u"
		mark_all_unread
	when "q"
		exit(0)
	when "s"
		sync
	else
		try_to_toggle_item_number(a)
	end
end