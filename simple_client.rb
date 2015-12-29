require 'socket'

host = 'localhost'
port = 2000

socket = TCPSocket.open(host, port)

while line = socket.gets
  puts line.chomp
end
socket.close
