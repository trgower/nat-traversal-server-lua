require "enet"
local address, port = "127.0.0.1", 34567
local host = enet.host_create()

server = host:connect(address..":"..port)
event = host:service(16)
if event.type == "connect" then
  print("Connected to server!")
else
  print("Failed to connect.")
  exit(1)
end

while server:state() == "connected" do
  event = host:service(16)
  if event then
    if event.type == "receive" then
      print(event.data)
    end
  end
  input = io.read()
  if input == "exit" then 
    server:disconnect()
    return 
  end
  host:broadcast(input)
end
