local Talkie = {
	_VERSION = 1240,
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

-- Append middlewares in the Talkie.
for key, value in pairs(require(script.Parent.Shared.Middleware)) do
	Talkie[key] = value
end

-- Create storages.
local Storage = require(script.Parent.Shared.Storage)
Talkie.FunctionStorage = Storage.new(Function.new)
Talkie.EventStorage = Storage.new(Event.new)
Talkie.PropertyStorage = Storage.new(Property.new)

--[[
	Creates new Client instance.

	```
	local client = Talkie.Client(game.ReplicatedStorage, "SomeService")

	local someFun = client:Function(...) -- Will get RemoteFunction from the workspace.
	```
]]
function Talkie.Client(parent: Instance?, namespace: string?): Types.Client
	-- Typecheck parent if present.
	if parent then
		assert(typeof(parent) == "Instance", `parent is expected to be Instance, got {typeof(parent)}`)
	else -- In other way, use replicated storage for all remotes.
		parent = game.ReplicatedStorage
	end

	-- Typecheck namespace if present
	if namespace then
		assert(typeof(namespace) == "string", `namespace is expected to be string, got {typeof(namespace)}`)
		assert(#namespace > 0, "namespace is not expected to be empty")

		-- Find a folder in the parent.
		local folder = parent:FindFirstChild(namespace)
		assert(folder, "folder is expected to exist, got nil")
		assert(folder.ClassName == "Folder", `folder is expected to be instance of Folder, got {folder.ClassName}`)

		-- Assign new parent.
		parent = folder
	end

	-- Create new instance and return it.
	return setmetatable({ _parent = parent }, Talkie)
end

--[[
	All these methods will get some entity (Event, Function, Property) from the...
	...game`s workspace and will return wrapper on them.
]]
function Talkie:Function(
	name: string,
	handler: Types.ClientHandler?,
	middleware: Types.ClientMiddleware?
): Types.ClientFunction
	return self.FunctionStorage.new(self._parent, name, handler, middleware)
end

function Talkie:Event(name: string, middleware: Types.ClientMiddleware?): Types.ClientEvent
	return self.EventStorage.new(self._parent, name, middleware)
end

function Talkie:Property(name: string, middleware: Types.ClientMiddleware?): Types.ClientProperty
	return self.PropertyStorage.new(self._parent, name, middleware)
end

-- Parses the current folder and returns list with remotes in it.
function Talkie:Parse(): Types.ClientParseResult
	local entities = {}
	local types = {
		["RemoteFunction"] = self.FunctionStorage,
		["RemoteEvent"] = self.EventStorage,
		["UnreliableRemoteEvent"] = self.EventStorage,
	}
	for _, children: Instance in self._parent:GetChildren() do
		if children:HasTag("TalkieProperty") then
			entities[children.Name] = self:Property(children.Name)
		elseif types[children.ClassName] then
			local remote = types[children.ClassName]
			entities[children.Name] = remote.new(self._parent, children.Name)
		end
	end
	return entities
end

-- Alias for `Talkie.Client`
Talkie.new = Talkie.Client

-- Export the module.
return Talkie
