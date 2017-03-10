---------------------------------------
-- lobby.lua
-- Tanner Gower
-- NAT Traversal Server
---------------------------------------

Object = require "classic"

Lobby = Object:extend()

function Lobby:new(hostid, host)
  self.peers = {}
  self.ready = {}
  self.hostid = hostid
  self.host = host;
  print("Lobby created with "..tostring(self.host).." as the host("..hostid..")")
  self.host:send(hostid)
  self:join(host)
end

function Lobby:update()
  
end

function Lobby:setAllReady(r)
  for i, re in pairs(self.ready) do
    self.ready[i] = r
  end
end

function Lobby:allReady()
  for i, re in pairs(self.ready) do
    if not re then
      return false
    end
  end
  return true
end

function Lobby:sendPeerInfoTo(peer)
  for i, p in pairs(self.peers) do
    if not (peer == p) then
      peer:send("peerinfo "..tostring(p))
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
  self.peers[peer:connect_id()] = peer
  self.ready[peer:connect_id()] = false
  if verbose then
    print("Peer "..peer:connect_id().." has joined lobby "..self.hostid)
  end
  self:sendMessageToPeers(peer, "joined "..tostring(peer))
  self:sendPeerInfoTo(peer)
  self:setAllReady(false)
end

function Lobby:leave(peer, verbose)
  self.peers[peer:connect_id()] = nil
  self.ready[peer:connect_id()] = nil
  if verbose then
    print("Peer "..peer:connect_id().." has left lobby "..self.hostid)
  end
  self:sendMessageToPeers(peer, "left "..tostring(peer))
  self:setAllReady(false)
end

function Lobby:start(peer, verbose)
  if allReady() and (peer:connect_id() == self.hostid) then
    self:broadcast("start")
  end
end

function Lobby:setReady(peer, r)
  self.ready[peer:connect_id()] = r
  peer:send("Ready status: "..r)
end

function Lobby:containsPeer(peer)
  for i, p in pairs(self.peers) do
    if peer == p then
      return true
    end
  end
  return false
end

function Lobby:getHostId()
  return self.hostid
end
