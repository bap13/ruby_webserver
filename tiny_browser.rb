require 'socket'
require 'json'

$host = 'localhost'
$port = 2000

def send_request(request)
  socket = TCPSocket.open($host, $port)
  socket.print(request)
  response = socket.read
  headers, body = response.split("\r\n\r\n", 2)
  print body
  socket.close
end

def get(path)
  request = "GET " + path + " HTTP/1.0\r\n\r\n"
  send_request(request)
end

def post(path)
  params = {:viking => {:name => nil, :email => nil}}

  puts "Viking Sign Up Form"
  printf "Viking's Name: "
  params[:viking][:name] = gets.chomp
  printf "Viking's Email: "
  params[:viking][:email] = gets.chomp
  form_data = params.to_json

  request = "POST #{path} HTTP/1.0\r\n" +
            "Content-Type: text/json\r\n" +
            "Content-Length: #{form_data.size}\r\n" +
            "\r\n" +
            form_data

  send_request(request)
end

input = ""
while input != "q"
  puts "(G)ET / (P)OST"
  command = gets.chomp.downcase
  printf "Path: "
  path = gets.chomp.downcase
  case command
  when "q" then puts "Goodbye!"
  when "g" then get(path)
  when "p" then post(path)
  else
    puts "Unknown command"
  end
end
