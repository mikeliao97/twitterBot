require 'jumpstart_auth'
require 'bitly'


class MicroBlogger
	attr_reader :client

	def initialize
		puts "Initializing..."
		@client = JumpstartAuth.twitter
	end
	
	def run
		puts "Welcome to the JSL twitter client"
		command = ""
		while command != "q" do
			printf "enter command: "
			input = gets.chomp
			parts = input.split(" ")
			command = parts[0]
			case command
				when 'q' then puts "Goodbye!"
				when 't' then tweet(parts[1..-1].join(" "))
				when 'dm' then dm(parts[1], parts[2..-1].join(" "))
				when 'spam' then spam_my_followers(parts[1..-1].join(" "))
				when 'elt' then everyones_last_tweet
				when 's' then shorten(parts[1])
				when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
				else 
				puts "Sorry, I don't know how to #{command}"

			end
		end
	end

	def tweet(message)
		if message.length <= 140
			@client.update(message)
		else
			print "Error, message too long!"
		end
	end	

	def dm(target, message)
		puts "Trying to send #{target} this direct message: "
		puts message
		message = "d @#{target} #{message}"

		screen_names = @client.followers.collect {|follower| @client.user(follower).screen_name}
		if screen_names.include? target
			tweet(message)
		else
			puts "You can only DM people who follow you"
		end
	end

	def followers_list
		screen_names = []
		screen_names << @client.followers.collect {|follower| @client.user(follower).screen_name}
		if screen_names.empty?
			puts "You have no friends!"
		else
			return screen_names
		end
	end

	def spam_my_followers(message)
		followers_list.each {|follower| dm(follower.join(""), message )}
	end

	def everyones_last_tweet
		friends = @client.friends
		friends = friends.sort_by {|friend| @client.user(friend).screen_name}

		friends.each do |friend|						
			screen_name = @client.user(friend).screen_name
			status = @client.user(friend).status.text
			time = @client.user(friend).status.created_at

			puts "#{screen_name} said the following on #{time.strftime("%A, %b %d")}: #{status}"
			puts ""
		end
	end

	def shorten(url)
		Bitly.use_api_version_3
		bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
		
		puts "Shortening this URL: #{url}"
		puts bitly.shorten(url).short_url
		return bitly.shorten(url).short_url
	end
end

blogger = MicroBlogger.new
blogger.run


