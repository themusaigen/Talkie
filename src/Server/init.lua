local Talkie = {
	_VERSION = 1220,
}
Talkie.__index = Talkie

-- Types for IntelliSense.
local Types = require(script.Parent.Types)
--[[
	Group of Talkie`s modules.
]]

local Function = require(script.Function)
local Event = require(script.Event)
local Property = require(script.Property)

-- Append middlewares in Talkie.
for key, value in pairs(require(script.Parent.Shared.Middleware)) do
	Talkie[key] = value
end

--[[
	Creates new Server instance.

	```
	local server = Talkie.Server(game.ReplicatedStorage, "SomeService")

	local someFun = server:Function(...) -- Will create RemoteFunction in the workspace.
	```
]]
function Talkie.Server(parent: Instance?, namespace: string?): Types.Server
	
	-- Typecheck parent if present.
	if parent then
		assert(typeof(parent) == "Instance", `parent is expected to be Instance, got {typeof(parent)}`)
	else -- In other way use replicated storage for all remotes.
		parent = game.ReplicatedStorage
	end

	-- Typecheck namespace if present
	if namespace then
		assert(typeof(namespace) == "string", `namespace is expected to be string, got {typeof(namespace)}`)
		assert(#namespace > 0, "namespace is not expected to be empty")

		-- Find a folder in the parent.
		local folder = parent:FindFirstChild(namespace)
		if folder then
			assert(folder.ClassName == "Folder", `folder is expected to be instance of Folder, got {folder.ClassName}`)
		else
			folder = Instance.new("Folder")
			folder.Name = namespace
			folder.Parent = parent
		end

		-- Assign new parent.
		parent = folder
	end

	-- Create new instance and return it.
	return setmetatable({ _parent = parent }, Talkie)
end

-- Alias for `Talkie.Server`
Talkie.new = Talkie.Server

--[[
	All these methods will create some entity (Event, Function, Property) in the...
	...game`s workspace and will return wrapper on them
]]

function Talkie:Function(
	name: string,
	handler: Types.ServerHandler?,
	middleware: Types.ServerMiddleware?
): Types.ServerFunction
	return Function.new(self._parent, name, handler, middleware)
end

function Talkie:Event(name: string, unreliable: boolean?, middleware: Types.ServerMiddleware?): Types.ServerEvent
	return Event.new(self._parent, name, unreliable, middleware)
end

function Talkie:Property(name: string, value: any, middleware: Types.ServerMiddleware?): Types.ServerProperty
	return Property.new(self._parent, name, value, middleware)
end

-- Export the Talkie module.
return Talkie
