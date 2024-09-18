--- @class Talkie.Client
--- @client
--- A class to simplify working with RemoteEvents and RemoteFunctions on the client side.
local Talkie = {
	_VERSION = 1250,
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

--- @prop Inbound Middleware
--- @within Talkie.Client
--- Creates middleware for inbound calls with given functions
--- ```lua
--- local inbound = Talkie.Inbound(someFunc1, someFunc2, func3, etc...)
--- ```

--- @prop Outbound Middleware
--- @within Talkie.Client
--- Creates middleware for outbound calls with given functions
--- ```lua
--- local outbound = Talkie.Outbound(someFunc1, someFunc2, func3, etc...)
--- ```
for key, value in pairs(require(script.Parent.Shared.Middleware)) do
	Talkie[key] = value
end

-- Create storages.
local Storage = require(script.Parent.Shared.Storage)

--- @prop FunctionStorage Storage<Function>
--- @within Talkie.Client
--- A storage for all functions where Talkie caches them.
--- ```lua
--- local fun = Talkie.FunctionStorage.new(game.ReplicatedStorage, ...)
--- ```
Talkie.FunctionStorage = Storage.new(Function.new) :: Types.Storage<Types.ClientFunction>

--- @prop EventStorage Storage<Event>
--- @within Talkie.Client
--- A storage for all events where Talkie caches them.
--- ```lua
--- local event = Talkie.EventStorage.new(game.ReplicatedStorage, ...)
--- ```
Talkie.EventStorage = Storage.new(Event.new) :: Types.Storage<Types.ClientEvent>

--- @prop PropertyStorage Storage<Property>
--- @within Talkie.Client
--- A storage for all properties where Talkie caches them.
--- ```lua
--- local property = Talkie.PropertyStorage.new(game.ReplicatedStorage, ...)
--- ```
Talkie.PropertyStorage = Storage.new(Property.new) :: Types.Storage<Types.ClientProperty>

--[=[
  Creates a new instance of the clientside Talkie to work with server modules: "Function", "Event", "Property", etc...

  ```lua
  local client = Talkie.Client(game.ReplicatedStorage, "MyNamespace")
  -- ReplicatedStorage is used by default, so u can use this trick:
  local client = Talkie.Client(nil, "MyNamespace")
  ```

  @within Talkie.Client
]=]
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

--[=[
  Grabs [RemoteFunction](https://developer.roblox.com/en-us/api-reference/class/RemoteFunction) from workspace and return Talkie`s wrapper over it.

  ```lua
  local fun = client:Function("MyFunction")

  fun(42) -- or fun:Invoke
  ```

  @within Talkie.Client
]=]
function Talkie:Function(
	name: string,
	handler: Types.ClientHandler?,
	middleware: Types.ClientMiddleware?
): Types.ClientFunction
	return self.FunctionStorage.new(self._parent, name, handler, middleware)
end

--[=[
  Grabs [RemoteEvent](https://developer.roblox.com/en-us/api-reference/class/RemoteEvent) or [UnreliableRemoteEvent](https://developer.roblox.com/en-us/api-reference/class/UnreliableRemoteEvent) from workspace and return Talkie`s wrapper over it.

  ```lua
  local event = client:Event("MyEvent")

  event:Fire(24, 26)
  ```

  @within Talkie.Client
]=]
function Talkie:Event(name: string, middleware: Types.ClientMiddleware?): Types.ClientEvent
	return self.EventStorage.new(self._parent, name, middleware)
end

--[=[
  Grabs [RemoteEvent](https://developer.roblox.com/en-us/api-reference/class/RemoteEvent) from workspace and returns Talkie`s wrapper over it.

  ```lua
  local property = client:Property("MyProperty")

  property:Observe(function(value)
    print(`New value {value}`)
  end)
  ```

  @within Talkie.Client
]=]
function Talkie:Property(name: string, middleware: Types.ClientMiddleware?): Types.ClientProperty
	return self.PropertyStorage.new(self._parent, name, middleware)
end

--[=[
  Parses the current folder and returns list with remotes in it.

  ```lua
  local remotes = client:Parse()

  print(remotes.MyFunction, remotes.MyEvent, remotes.MyProperty)
  ```

  @within Talkie.Client
]=]
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

--- @function new
--- @within Talkie.Client
--- Alias for `Talkie.Client`
Talkie.new = Talkie.Client

-- Export the module.
return Talkie
