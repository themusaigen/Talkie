--- @class Talkie.Server
--- @server
--- A class to simplify working with RemoteEvents and RemoteFunctions on the server side.
--- ```lua
--- local Talkie = require(game.ReplicatedStorage.Talkie)
--- ```

local Talkie = {
  _VERSION = 1250,
}
Talkie.__index = Talkie

-- Types for IntelliSense.
local Types = require(script.Parent.Types)

-- Group of Talkie`s modules.
local Function = require(script.Function)
local Event = require(script.Event)
local Property = require(script.Property)

--- @prop Inbound Middleware
--- @within Talkie.Server
--- Creates middleware for inbound calls with given functions
--- ```lua
--- local inbound = Talkie.Inbound(someFunc1, someFunc2, func3, etc...)
--- ```

--- @prop Outbound Middleware
--- @within Talkie.Server
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
--- @within Talkie.Server
--- A storage for all functions where Talkie caches them.
--- ```lua
--- local fun = Talkie.FunctionStorage.new(game.ReplicatedStorage, ...)
--- ```
Talkie.FunctionStorage = Storage.new(Function.new) :: Types.Storage<Types.ServerFunction>

--- @prop EventStorage Storage<Event>
--- @within Talkie.Server
--- A storage for all events where Talkie caches them.
--- ```lua
--- local event = Talkie.EventStorage.new(game.ReplicatedStorage, ...)
--- ```
Talkie.EventStorage = Storage.new(Event.new) :: Types.Storage<Types.ServerEvent>

--- @prop PropertyStorage Storage<Property>
--- @within Talkie.Server
--- A storage for all properties where Talkie caches them.
--- ```lua
--- local property = Talkie.PropertyStorage.new(game.ReplicatedStorage, ...)
--- ```
Talkie.PropertyStorage = Storage.new(Property.new) :: Types.Storage<Types.ServerProperty>

--[=[
  Creates a new instance of the serverside Talkie to work with server modules: "Function", "Event", "Property", etc...

  ```lua
  local server = Talkie.Server(game.ReplicatedStorage, "MyNamespace")
  -- ReplicatedStorage is used by default, so u can use this trick:
  local server = Talkie.Server(nil, "MyNamespace")
  ```

  @within Talkie.Server
]=]
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

--[=[
  Creates a RemoteFunction object, cache it and returns a wrapper over it.

  ```lua
  local function logger(args)
    for k, v in args do
      print(`{k} = {v}`)
    end
  end

  local function doubleArgs(args)
    for k, v in args do
      if typeof(v) == "number" then
        args[k] *= 2
      end
    end
  end

  local fun = server:Function("MyFunction", function(player, arg)
    print(`Player {player.Name} send us arg: {arg}`)
    return 42
  end, Talkie.Inbound(logger) + Talkie.Outbound(doubleArgs))
  ```

  @within Talkie.Server
]=]
function Talkie:Function(
  name: string,
  handler: Types.ServerHandler?,
  middleware: Types.ServerMiddleware?
): Types.ServerFunction
  return self.FunctionStorage.new(self._parent, name, handler, middleware)
end

--[=[
  Creates a RemoteEvent (by default) or UnreliableRemoteEvent object, cache it and returns a wrapper over it.

  ```lua
  local function Typechecker(...)
    local types = {...}
    return function(args)
      for k, v in args do
        if not (typeof(v) == types[k]) then
          return false -- Don't proccess the event.
        end
      end
    end
  end

  -- Middleware template for inbound calls.
  local typecheckerMiddleware = Talkie.Inbound(Typechecker("number", "string"))

  -- Creates reliable event (by default)
  local event = server:Event("MyReliableEvent", false, typecheckerMiddleware)

  -- Creates unreliable event
  local event0 = server:Event("MyUnreliableEvent", true, typecheckerMiddleware)

  -- Connecting.
  event:Connect(function(player, arg0, arg1)
    print("We got good arguments!")
    print(arg0, arg1)
  end)

  -- Fire example.
  game.Players.PlayerAdded:Connect(function(player)
    event:Fire(player, "Hello, waiting for invokes")
  end)
  ```

  @within Talkie.Server
]=]
function Talkie:Event(name: string, unreliable: boolean?, middleware: Types.ServerMiddleware?): Types.ServerEvent
  return self.EventStorage.new(self._parent, name, unreliable, middleware)
end

--[=[
  Creates a Property based on RemoteEvent, cache it and returns wrapper over it.

  ```lua
  -- All players will have 0 by default.
  local property = server:Property("MyScoreProperty", 0)

  game.Players.PlayerAdded:Connect(function(player)
    -- Getting score from our real and cool database.
    local score = MagicDatabase:GetProperty("game.score", player)

    -- Set only for this player his score.
    -- Everything will be automatically handled by Talkie on Server and Client.
    property:SetFor(player, score)
  end)
  ```

  @within Talkie.Server
]=]
function Talkie:Property(name: string, value: any, middleware: Types.ServerMiddleware?): Types.ServerProperty
  return self.PropertyStorage.new(self._parent, name, value, middleware)
end

--- @function new
--- @within Talkie.Server
--- Just an alias for Talkie.Server
Talkie.new = Talkie.Server

-- Export the Talkie module.
return Talkie
