import sys
import socket
import selectors
import types

sel = selectors.DefaultSelector()

def accept_wrapper(sock):
    conn, addr = sock.accept()  # Should be ready to read
    print("accepted connection from", addr)
    conn.setblocking(False)

    # we create an object to hold the data we want included 
    # along with the socket using the class: types.SimpleNamespace
    data = types.SimpleNamespace(addr=addr, inb=b"", outb=b"")

    # we want to know when the client connection is ready for reading and writing
    events = selectors.EVENT_READ | selectors.EVENT_WRITE

    sel.register(conn, events, data=data)

# key is the namedtuple returned from select() that contains the socket object (fileobj) and data object
def service_connection(key, mask):
    sock = key.fileobj
    data = key.data
    if mask & selectors.EVENT_READ:
        recv_data = sock.recv(1024)  # Should be ready to read
        if recv_data:
            data.outb += recv_data
        else:
            print("closing connection to", data.addr)
            sel.unregister(sock)
            sock.close()
    if mask & selectors.EVENT_WRITE:
        if data.outb:
            print("echoing", repr(data.outb), "to", data.addr)
            sent = sock.send(data.outb)  # Should be ready to write
            data.outb = data.outb[sent:]


if len(sys.argv) != 3:
    print("usage:", sys.argv[0], "<host> <port>")
    sys.exit(1)

host, port = sys.argv[1], int(sys.argv[2])
lsock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
lsock.bind((host, port))
lsock.listen()
print("listening on", (host, port))
lsock.setblocking(False)

# sel.register() registers the socket to be monitored with sel.select() for the events you’re interested in.
# For the listening socket, we want read events: selectors.EVENT_READ.

# data is used to store whatever arbitrary data you’d like along with the socket. 
# It’s returned when select() returns. We’ll use data to keep track of what’s been 
# sent and received on the socket.
sel.register(lsock, selectors.EVENT_READ, data=None)

# EVENT LOOP
# sel.select(timeout=None) blocks until there are sockets ready for I/O
# It returns a list of (key, events) tuples, one for each socket
# -	key is a SelectorKey namedtuple that contains a fileobj attribute
# 		- key.fileobj is the socket object
#		- mask is an event mask of the operations that are ready.
try:
    while True:
        events = sel.select(timeout=None)
        for key, mask in events:
            if key.data is None:
                accept_wrapper(key.fileobj)
            else:
                service_connection(key, mask)
except KeyboardInterrupt:
    print("caught keyboard interrupt, exiting")
finally:
    sel.close()