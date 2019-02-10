import socket

HOST = '127.0.0.1'
PORT = 65432

# create a socket object, closes automatically when finished
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
	# connect to the server
	s.connect((HOST, PORT))

	# send message to server
	s.sendall(b'Hello, world')

	# recieve the servers reply
	data = s.recv(1024)

print('received', repr(data))