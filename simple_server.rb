require 'socket'
require 'json'

port = 2000

def parse_request(request)
  {
    :method => request.scan(/[A-Z]+(?=\s)/)[0],
    :path => request.scan(/(?!HTTP)(?<=\s\/)\S*/)[0],
    :version => request.scan(/HTTP\/.+\d/)[0],
    :body => request.split("\r\n\r\n").last
  }
end

def success_response(request, body)
  "#{request[:version]} 200 OK\r\n" +
  "Date: #{Time.now.ctime}\r\n" +
  "Content-Type: text/html\r\n" +
  "Content-Length: #{body.size}\r\n" +
  "\r\n" +
  body
end

def not_found_response(request)
  body = File.read("file_not_found.html")

  "#{request[:version]} 404 Not Found\r\n" +
  "Date: #{Time.now.ctime}\r\n" +
  "Content-Type: text/html\r\n" +
  "Content-Length: #{body.size}\r\n" +
  "\r\n" +
  body
end

def process_get(client, request)
  if File.exist?(request[:path])
    body = File.read(request[:path])
    client.puts success_response(request, body)
  else
    client.puts not_found_response(request)
  end
end

def generate_body(data)
  params = JSON.parse(data)
  formatted_viking_info = ""
  params["viking"].each_pair do |key, value|
    formatted_viking_info << "<li>#{key.capitalize}: #{value}</li>"
  end
  template = File.read("thanks.html")
  template.gsub!("<%= yield %>", formatted_viking_info)
end

def process_post(client, request)
  if File.exist?(request[:path])
    body = generate_body(request[:body])
    client.puts success_response(request, body)
  else
    client.puts not_found_response(request)
  end
end

server = TCPServer.new port
loop {
  Thread.new(server.accept) do |client|
    request = parse_request(client.recv(512))
    if request[:method] == "GET"
      process_get(client, request)
    elsif request[:method] == "POST"
      process_post(client, request)
    end
    client.close
  end
}
