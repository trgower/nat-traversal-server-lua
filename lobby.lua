---------------------------------------
-- lobby.lua
-- Tanner Gower
-- NAT Traversal Server
---------------------------------------

Object = require "classic"

Lobby = Object:extend()

function Lobby:new(hostid, host, hostname)
  self.spots = {false, false, false, false}
  self.peerSpots = {}
  self.models = {}
  self.names = {}
  self.buffer = 10
  self.peers = {}
  self.readies = {}
  self.hostid = hostid
  self.host = host;
  self.delete = false
  print("Lobby created with "..tostring(self.host).." as the host("..hostid..")")
  self:join(host, hostname)
  self:ready(self.host, true)
  
  self.host:send("hostid " .. hostid .. " " .. self.peerSpots[tostring(host)] .. " " .. hostname)
end

function Lobby:update()
  
end

function Lobby:getLockFirstAvailableSpot()
  for i, v in pairs(self.spots) do
    if not v then
      self.spots[i] = true
      return i
    end
  end
  return nil
end

function Lobby:setCharacterModel(p, m)
  self.models[p] = m
end

function Lobby:setAllReady(r)
  for i, re in pairs(self.readies) do
    self.readies[i] = r
  end
end

function Lobby:allReady()
  for i, re in pairs(self.readies) do
    if not re then
      return false
    end
  end
  return true
end

function Lobby:sendPeerInfoTo(peer)
  for i, p in pairs(self.peers) do
    if not (peer == p) then
      peer:send("peerinfo " .. tostring(p) .. " " .. self.peerSpots[tostring(p)] .. " "
        .. self.models[tostring(p)] .. " " .. self.names[tostring(p)])
    end
  end
end

function Lobby:sendMessageToPeers(sender, msg)
  for i, p in pairs(self.peers) do
    if not (sender == p) then
      p:send(msg)
    end
  end
end

function Lobby:broadcast(msg)
  for i, p in pairs(self.peers) do
    p:send(msg)
  end
end

function Lobby:join(peer, name, verbose)
  self.peers[tostring(peer)] = peer
  self.readies[tostring(peer)] = false
  self.peerSpots[tostring(peer)] = self:getLockFirstAvailableSpot()
  self.models[tostring(peer)] = self.peerSpots[tostring(peer)]
  self.names[tostring(peer)] = name
  if verbose then
    print("Peer "..tostring(peer).." has joined lobby "..self.hostid)
  end
  self:sendMessageToPeers(peer, "joined " .. name .. " " .. tostring(peer) .. " " .. self.peerSpots[tostring(peer)])
  if not (self.host == peer) then
    peer:send("joingood " .. self.peerSpots[tostring(peer)] .. " " .. name)
  end
  self:sendPeerInfoTo(peer)
end

function Lobby:leave(peer, verbose)
  self.peers[tostring(peer)] = nil
  self.readies[tostring(peer)] = nil
  self.spots[self.peerSpots[tostring(peer)]] = false
  self.peerSpots[tostring(peer)] = nil
  self.models[tostring(peer)] = nil
  self.names[tostring(peer)] = nil
  if verbose then
    print("Peer "..tostring(peer).." has left lobby "..self.hostid)
  end
  if peer == self.host then
    self:sendMessageToPeers(peer, "hostleft")
    self:dispose()
  else
    self:sendMessageToPeers(peer, "left "..tostring(peer))
  end
end

function Lobby:bufferUp()
  self.buffer = self.buffer + 1
  self.host:send("buk")
end

function Lobby:bufferDown()
  self.buffer = self.buffer - 1
  self.host:send("bdk")
end

function Lobby:start(peer, verbose)
  if self:allReady() and (peer:connect_id() == self.hostid) then
    self:broadcast("start " .. self.buffer)
    self:dispose()
  end
end

function Lobby:ready(peer, quiet)
  self.readies[tostring(peer)] = true
  if not quiet then
    peer:send("readygood")
  end
end

function Lobby:unready(peer, quiet)
  self.readies[tostring(peer)] = false
  if not quiet then
    peer:send("unreadygood")
  end
end

function Lobby:containsPeer(peer)
  for i, p in pairs(self.peers) do
    if peer == p then
      return true
    end
  end
  return false
end

function Lobby:disconnectPeers()
  for i, p in pairs(self.peers) do
    p:disconnect()
  end
end

function Lobby:dispose()
  self.delete = true
  print("Lobby with host id = " .. self.hostid .. " has been deleted")
end

function Lobby:readyToDispose()
  return self.delete
end

function Lobby:getHostId()
  return self.hostid
end
