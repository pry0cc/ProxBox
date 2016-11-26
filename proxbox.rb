#!/usr/bin/env ruby
#i
#
require 'rubygems'
require 'open-uri'
require 'mechanize'
require 'nokogiri'

@agent = Mechanize.new()
puts "Scraping page..."
data = ""
for i in 0..20
	puts "Scraping page #{i}"
	suffix = ""
	if i < 10
		suffix = "0" + i.to_s
	else
		suffix = i.to_s
	end
	data += @agent.get("http://samair.ru/proxy/proxy-"+suffix+".htm").body()
end

puts "Parsing page"
anon = Nokogiri::HTML(data).css("#proxylist").css(".anon")
elite = Nokogiri::HTML(data).css("#proxylist").css(".elite")

proxies = []

@agent.open_timeout=4
@agent.read_timeout=4

puts "Scanning elite proxies."
for table in elite
	proxies.push(table.css("td")[1].text)
end

puts "Scanning anon proxies"
for table in anon
	proxies.push(table.css("td")[1].text)
end

working = []

puts ""
puts "*-----------------*"
puts "* Testing proxies *"
puts "*-----------------*"

for proxy in proxies.to_set
Thread.start {
	ip = proxy.split(":")[0]
	port = proxy.split(":")[1]
	@agent.set_proxy(ip, port)
	# puts "Testing #{proxy}"
	result = ""
	begin
		result = @agent.get("http://icanhazip.com").body()
	rescue
		return "HEY"
		#puts "Took too long."
	else
		if ip == result.chomp
			puts "Connection through #{proxy} was succesful"
			working.push(proxy)
		end
	end
}
sleep 0.2
end
puts ""
puts "Waiting a minute for threads to return."

sleep 60

puts ""
puts "Working proxies:"
for proxy in working
	puts "http " + proxy.split(":")[0] + " " + proxy.split(":")[1]
end
