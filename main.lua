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

function getLobbyWithPeer(peer)
  for i, lob in pairs(lobbies) do
    if lob:containsPeer(peer) then
      return lob
    end
  end
  return nil
end

function updateLobbies()
  for i, lob in pairs(lobbies) do
    lob:update()
    if lob:readyToDispose() then
      --lob:disconnectPeers()
      lobbies[i] = nil
    end
  end
end

function processEvent(event)
  if event.type == "connect" then
    print("Connection from ", event.peer)
  elseif event.type == "receive" then
    -- Split command with whitespace as delimiter
    splitted = event.data:split()
    local lobby = getLobbyWithPeer(event.peer)
    if lobby then -- Check if peer is in a lobby
      if splitted[1] == "leave" then
        lobby:leave(event.peer, true)
      elseif splitted[1] == "ready" then
        lobby:ready(event.peer)
      elseif splitted[1] == "unready" then
        lobby:unready(event.peer)
      elseif splitted[1] == "start" then
        lobby:start(event.peer, true)
      end
    else -- If not in lobby, use these commands
      if splitted[1] == "host" then
        -- Creates a new lobby and stores it in the lobbies table
        lobbies[event.peer:connect_id()] = Lobby(event.peer:connect_id(), event.peer)
      elseif splitted[1] == "join" then
        hostid = tonumber(splitted[2])
        -- Looks for the hostid in the lobbies table
        lob = lobbies[hostid]
        if lob then
          lob:join(event.peer, true)
        else
          event.peer:send("Unable to find lobby with host id: "..hostid)
        end
      elseif splitted[1] == "kill" then
        running = false
      else
        print("Unrecognized data from "..tostring(event.peer).." -> '"..event.data.."'")
      end
    end
  elseif event.type == "disconnect" then
    print("Disconnected: ", event.peer)
    local lobby = getLobbyWithPeer(event.peer)
    if lobby then
      lobby:leave(event.peer, true)
    end
  end
end

function processAllEvents()
  event = host:service()
  while event do 
    processEvent(event) 
    event = host:service()
  end
end

print "Starting server loop..."
while running do

  processAllEvents()
  updateLobbies()

end


