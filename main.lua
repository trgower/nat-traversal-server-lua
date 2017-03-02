---------------------------------------
-- main.lua
-- Tanner Gower
-- NAT Traversal Server
---------------------------------------
require "enet"
require "lobby"
require("pl.stringx").import()
local host = enet.host_create("*:34567")

local lobbies = {}
local running = true
print "Starting server loop..."
while running do
  event = host:service(50)
  -- Did we receive an event?
  if event then
    if event.type == "connect" then
      print("Connection from ", event.peer)
    elseif event.type == "receive" then
      -- Split command with whitespace as delimiter
      splitted = event.data:split()
      if splitted[1] == "host" then
        -- Creates a new lobby and stores it in the lobbies table
        table.insert(lobbies, Lobby(event.peer:connect_id(), event.peer))
      elseif splitted[1] == "join" then
        hostid = splitted[2]
        -- Looks for the hostid in the lobbies table
        found = false
        for i, lob in ipairs(lobbies) do
          if lob:getHostId() == hostid then
            -- Join the lobby
            lob:join(event.peer, true)
            found = true
          end
        end
        if not found then
          event.peer:send("Unable to find lobby with host id: "..hostid)
        end
      elseif splitted[1] == "kill" then
        running = false
      else
        print("Unrecognized data from "..tostring(event.peer).." -> '"..event.data.."'")
      end
    elseif event.type == "disconnect" then
      print("Disconnected: ", event.peer)
    end
  end
end


