---------------------------------------
-- lobby.lua
-- Tanner Gower
-- NAT Traversal Server
---------------------------------------

Object = require "classic"

Lobby = Object:extend()

function Lobby:new(hostid, host)
  self.peers = {}
  self.hostid = ""..hostid
  self.host = host;
  print("Lobby created with "..tostring(self.host).." as the host("..hostid..")")
  self.host:send(hostid)
  self:join(host, false)
end

function Lobby:join(peer, verbose)
  table.insert(self.peers, peer)
  if verbose then
    print("Peer "..tostring(peer).." has joined lobby "..self.hostid)
  end
end

function Lobby:getHostId()
  return self.hostid
end
