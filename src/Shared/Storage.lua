-- Storage: class that caches all Talkie`s entities.
local Storage = {}

-- Types for IntelliSense
local Types = require(script.Parent.Parent.Types)

-- Returns new storage with specified constructor for remote objects.
function Storage.new(ctor: (parent: Instance, name: string, ...any) -> any)
  local self = {
    _storage = {} :: {[Instance]: Types.SharedEntityList}
  }
  
  -- Parent and name are default parameters for all modules so use it.

  -- Creates new object or returns cached-one
  self.new = function(parent: Instance, name: string, ...)
    -- If storage for this parent don't exist create new one
    local storage = self._storage[parent]
    if not storage then
      storage = {}

      self._storage[parent] = storage
    end

    -- Check for entity. If don't exist construct new one
    local entity = storage[name]
    if not entity then
      -- Construct.
      entity = ctor(parent, name, ...)

      -- Cache this one.
      storage[name] = entity
    end
    
    -- Return.
    return entity
  end

  -- Return storage.
  return self
end

-- Export module.
return Storage