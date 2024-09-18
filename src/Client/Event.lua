--- @class Client.Event
--- @client
--- Clientside wrapper over [RemoteEvent](https://developer.roblox.com/en-us/api-reference/class/RemoteEvent)
local Event = {}
Event.__index = Event

-- Types for IntelliSense.
local Types = require(script.Parent.Parent.Types)

-- Signal module required to easily implement middlewares.
local Signal = require(script.Parent.Parent.Shared.Signal)

-- Utility for processing middlewares.
local ProcessMiddleware = require(script.Parent.Parent.Shared.MiddlewareProcessor)

--[=[
  Grabs [RemoteEvent](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent) or [UnreliableRemoteEvent](https://create.roblox.com/docs/reference/engine/classes/UnreliableRemoteEvent) instance and return wrapper for it.

  ```lua
  local event = client:Event("MyEvent")

  event:Fire(24, 26)
  ```

  @within Client.Event
]=]
function Event.new(parent: Instance, name: string, middleware: Types.ClientMiddleware?): Types.ClientEvent
  assert(typeof(parent) == "Instance", `parent is expected to be Instance, got {typeof(parent)}`)
  assert(typeof(name) == "string", `name is expected to be string, got {typeof(name)}`)
  assert(#name > 0, "name is not expected to be empty")

  -- Typecheck middleware if present.
  if middleware then
    assert(typeof(middleware) == "table", `middleware is expected to be table, got {typeof(middleware)}`)
  end

  -- Find remote.
  local remote = parent:FindFirstChild(name) :: RemoteEvent | UnreliableRemoteEvent
  assert(remote, `RemoteEvent {name} expected to exist, got nil`)

  -- Create new instance.
  local self = setmetatable({
    _remote = remote,
    _signal = Signal.new(),
    _middleware = if middleware then middleware else {},
  }, Event)

  -- Handle OnServerEvent.
  self._remote.OnClientEvent:Connect(function(...)
    -- Pack arguments as always.
    local args = { ... }

    -- Process middleware on them.
    do
      local success = ProcessMiddleware(self._middleware.Inbound, args)
      if not success then
        return
      end
    end

    -- Call signal.
    self._signal:Fire(table.unpack(args))
  end)

  -- And return it.
  return self
end

--- Appends new connection to the event.
--- @within Client.Event
function Event:Connect(handler: Types.ClientHandler): Signal.Connection
  -- Signal don't checks handler param.
  assert(typeof(handler) == "function", `handler is expected to be function, got {typeof(handler)}`)

  return self._signal:Connect(handler)
end

--- Appends new connection that will fired only once.
--- @within Client.Event
function Event:Once(handler: Types.ClientHandler): Signal.Connection
  -- Signal don't checks handler param.
  assert(typeof(handler) == "function", `handler is expected to be function, got {typeof(handler)}`)

  return self._signal:Once(handler)
end

--- Yields the current thread until the signal is fired, and returns the arguments fired from the signal.
--- @within Client.Event
--- @yields
function Event:Wait()
  return self._signal:Wait()
end

--- Fires the event on server with middlewares applied.
--- @within Client.Event
function Event:Fire(...: any)
  -- Packing arguments to pass them into middleware.
  local args = { ... }

  -- Process middleware.
  local success = ProcessMiddleware(self._middleware.Outbound, args)

  -- If allowed to continue
  if success then
    self._remote:FireServer(table.unpack(args))
  end
end

--[=[
  Post-method for setup a middleware

  ```lua
  event:SetMiddleware(Talkie.Inbound(...) + Talkie.Outbound(...))
  ```

  @within Client.Event
]=]
function Event:SetMiddleware(middleware: Types.ClientMiddleware)
  assert(typeof(middleware) == "table", `middleware is expected to be table, got {typeof(middleware)}`)

  if middleware.Outbound then
    assert(
      typeof(middleware.Outbound) == "table",
      `middleware.Outbound is expected to be table, got {typeof(middleware.Outbound)}`
    )

    -- Assign new middleware.
    self._middleware.Outbound = middleware.Outbound
  end

  if middleware.Inbound then
    assert(
      typeof(middleware.Inbound) == "table",
      `middleware.Inbound is expected to be table, got {typeof(middleware.Inbound)}`
    )

    -- Assign new middleware.
    self._middleware.Inbound = middleware.Inbound
  end
end

--- Destroys the event.
--- @within Client.Event
function Event:Destroy()
  self._signal:Destroy()
end

-- Export the module.
return Event
