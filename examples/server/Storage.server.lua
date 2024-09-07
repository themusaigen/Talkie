local Talkie = require(game.ReplicatedStorage.Talkie)

local server = Talkie.Server(game.ReplicatedStorage.Services, "StorageService")
local server1 = Talkie.Server(game.ReplicatedStorage.Services, "StorageService")
--- < v1.24.0
-- server/MyCoolService.lua
local event0 =server:Event("CachedEvent")
-- Need to export this event, if I want to use it in other scripts

-- server/MyAnotherCoolService.lua (create talkie, etc..)
local cachedEvent = server1:Event("CachedEvent") -- got error or overwrited the remote, nip nip nip

-- But now, with version 1.24.0 or greater, Talkie caches all objects created.
-- Even absolutely different instances of Talkie used.
local isTheSame = event0 == cachedEvent

print("[S] isTheSame: ", isTheSame) -- -> true 

-- You can use standalone storages without creating an instance
do
  local event = Talkie.EventStorage.new(game.ReplicatedStorage.Services.StorageService, "CachedEvent")

  print("[S] isTheSame2: ", event == event0)

  -- Create new one also.
  local newCachedEvent = Talkie.EventStorage.new(game.ReplicatedStorage.Services.StorageService, "NewCachedEvent")
  
  -- NOTE: If you use standalone version of Talkie`s modules (Function, Event, etc), it will not cache the instance!
  -- Only instances created from Talkie`s instance or storages directly will be cached!
end