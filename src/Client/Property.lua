--- @class Client.Property
--- @client
--- Wrapper for properties.
local Property = {}
Property.__index = Property

-- Types for IntelliSense.
local Types = require(script.Parent.Parent.Types)

-- Property based on reliable Event module.
local Event = require(script.Parent.Event)

--[=[
  Grabs [RemoteEvent](https://developer.roblox.com/en-us/api-reference/class/RemoteEvent) from workspace and returns property wrapper over it.

  ```lua
  local property = client:Property("MyProperty")

  property:Observe(function(value)
    print(`New value {value}`)
  end)
  ```

  @within Client.Property
]=]
function Property.new(parent: Instance, name: string, middleware: Types.ClientMiddleware?): Types.ClientProperty
  assert(typeof(parent) == "Instance", `parent expected to be Instance, got {typeof(parent)}`)
  assert(typeof(name) == "string", `name expected to be string, got {typeof(name)}`)
  assert(#name > 0, `name not expected to be empty`)

  -- Typecheck middleware if present.
  if middleware then
    assert(typeof(middleware) == "table", `middleware is expected to be table, got {typeof(middleware)}`)
  end

  -- Check for exist.
  assert(parent:FindFirstChild(name), `Property {name} expected to exist, got nil`)

  -- Create new instance
  local self = setmetatable({
    _value = nil,
    _observer = nil,
    _ready = false,
    _middleware = {
      Inbound = if middleware then if middleware.Inbound then middleware.Inbound else {} else {},
    },
  }, Property)

  -- Create new event.
  self._event = Event.new(parent, name, self._middleware)

  -- Connect event that will synchronize the property`s value.
  self._event:Connect(function(data)
    -- Invoke handler only on data updates.
    local changed = self._value ~= data
    self._value = data

    -- Mark as ready to use.
    if not self._ready then
      self._ready = true
      changed = true
    end

    -- Call handler.
    if self._observer and changed then
      self._observer(data)
    end
  end)
  self._event:Fire() -- Sync the value.

  -- Return this class instance.
  return self
end

--- Returns the current value.
--- @within Client.Property
function Property:Get(): any
  return self._value
end

--- Requests a server to synchronize value.
--- @within Client.Property
function Property:RequestToSync()
  self._event:Fire()
end

--- Assigns new observer.
--- @within Client.Property
function Property:Observe(observer: Types.ClientObserver)
  assert(typeof(observer) == "function", `observer is expecteed to be function, got {typeof(observer)}`)

  -- Assign new observer.
  self._observer = observer
end

--[=[
  Post-method for setup a middleware.
  Only inbound middleware is used bc of nature of ClientProperty.

  ```lua
  client:SetMiddleware(Talkie.Inbound(...) + Talkie.Outbound(...))
  ```

  @within Client.Property
]=]
function Property:SetMiddleware(middleware: Types.ClientMiddleware)
  assert(typeof(middleware) == "table", `middleware is expected to be table, got {typeof(middleware)}`)


  -- Only inbound middleware is used bc of nature of ClientProperty.
  if middleware.Inbound then
    assert(
      typeof(middleware.Inbound) == "table",
      `middleware.Inbound is expected to be table, got {typeof(middleware.Inbound)}`
    )

    -- Assign new middleware.
    self._middleware.Inbound = middleware.Inbound
  end
end

--- Is property initialized and ready to use.
--- @within Client.Property
function Property:IsReady(): boolean
  return self._ready
end

-- Export the module.
return Property
