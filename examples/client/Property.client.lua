local Talkie = require(game.ReplicatedStorage.Talkie)

local client = Talkie.Client(game.ReplicatedStorage.Services, "PropertyExample")

-- name: string, middleware
local coolProperty = client:Property("MyCoolProperty")

coolProperty:Observe(function(value)
	if value == (1337 / 2) then
		print("You are half leet")
	elseif value == 1337 then
		print("You are leet")
	end
end)

--[[
  local value = coolProperty:Get()

  -- Send request to server for sync the value (i don't think this useful)
  coolPropety:RequestToSync()

  if coolProperty:IsReady() then
    local value = coolProperty:Get()
    ...
  end
]]
