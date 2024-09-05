-- [[ Script -> Packages -> init.lua (talkie) -> SCOPE_NAME@VER -> Signal ]]

local success, Signal = pcall(function()
	return script.Parent.Parent.Parent.Signal
end)

if success then
	return require(Signal)
else
	return require(game.ReplicatedStorage.Packages.Signal)
end
