require "socket"
require "json"

server = TCPServer.new("localhost", 3000)

loop do
	Thread.new(server.accept) do |client|
		array = []
		until (response = client.gets) == "\r\n"
			array << response
		end

		verb, path, http = array.first.split
		path = path.reverse.chop.reverse

		case verb
		when /^GET/
			if File.exists?(path)
				client.puts "HTTP/1.0 200 OK\n"
				client.puts(File.read(path))
			else
				client.puts "HTTP/1.0 404 Not Found"
			end
		when /^POST/
			parse = JSON.parse(array.last)
			data = File.read("thanks.html")
			names = parse["viking"].map { |k, v| "<li>#{k}: #{v}</li>"}.join
			data.gsub!("<%= yield %>", names)
			client.puts(data)
		end

		client.close
	end
end

