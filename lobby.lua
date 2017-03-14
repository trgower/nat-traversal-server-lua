---------------------------------------
-- lobby.lua
-- Tanner Gower
-- NAT Traversal Server
---------------------------------------

Object = require "classic"

Lobby = Object:extend()

function Lobby:new(hostid, host)
  self.models = {}
  self.models["soldier"] = false
  self.models["hitman"] = false
  self.models["robot"] = false
  self.models["survivor"] = false
  
  self.peers = {}
  self.peerModels = {}
  self.readies = {}
  self.hostid = hostid
  self.host = host;
  self.delete = false
  print("Lobby created with "..tostring(self.host).." as the host("..hostid..")")
  self:join(host)
  self:ready(self.host, true)
  
  self.host:send("hostid " .. hostid .. " " .. self.peerModels[tostring(host)])
end

function Lobby:update()
  
end

function Lobby:getLockFirstAvailableModel()
  for i, v in pairs(self.models) do
    if not v then
      self.models[i] = true
      return i
    end
  end
  return nil
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
      peer:send("peerinfo " .. self.peerModels[tostring(p)] .. " " .. tostring(p))
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

function Lobby:join(peer, verbose)
  self.peers[tostring(peer)] = peer
  self.readies[tostring(peer)] = false
  self.peerModels[tostring(peer)] = self:getLockFirstAvailableModel()
  if verbose then
    print("Peer "..tostring(peer).." has joined lobby "..self.hostid)
  end
  self:sendMessageToPeers(peer, "joined " .. self.peerModels[tostring(peer)] .. " " .. tostring(peer))
  if not (self.host == peer) then
    peer:send("joingood " .. self.peerModels[tostring(peer)])
  end
  self:sendPeerInfoTo(peer)
end

function Lobby:leave(peer, verbose)
  self.peers[tostring(peer)] = nil
  self.readies[tostring(peer)] = nil
  self.models[self.peerModels[tostring(peer)]] = false
  self.peerModels[tostring(peer)] = nil
  if verbose then
    print("Peer "..tostring(peer).." has left lobby "..self.hostid)
  end
  if peer == self.host then
    self:sendMessageToPeers(peer, "hostleft")
    self:dispose()
  end
  self:sendMessageToPeers(peer, "left "..tostring(peer))
end

function Lobby:start(peer, verbose)
  if self:allReady() and (peer:connect_id() == self.hostid) then
    self:broadcast("start")
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
