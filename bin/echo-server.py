import socket

HOST = '127.0.0.1' # standard loopback interface address (localhost)
PORT = 65432 # port to listen on (non-priviledged ports are > 1023)

#socket.socket() creates a socket object that supports the
# context manager type, so you can use it in a with statement.
# There’s no need to call s.close():
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
	s.bind((HOST, PORT))
	s.listen()
	conn, addr = s.accept()

	# After getting the client socket object conn from accept(),
	# an infinite while loop is used to loop over blocking calls
	# to conn.recv(). 
	with conn:
		print('connected by', addr)
		while True:
			data = conn.recv(1024)
			if not data:
				break
			print('Received', repr(data))
			conn.sendall(data)

