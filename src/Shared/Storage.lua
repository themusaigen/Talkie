-- Storage: class that caches all Talkie`s entities.
local Storage = {}

-- Types for IntelliSense
local Types = require(script.Parent.Parent.Types)

-- Returns new storage.
function Storage.new(ctor)
  local self = {
    _storage = {} :: {[Instance]: Types.SharedEntityList}
  }
  
  -- Parent and name are default parameters for all modules so use it by yourself
  self.new = function(parent: Instance, name: string, ...)
    local storage = self._storage[parent]
    if not storage then
      storage = {}

      self._storage[parent] = storage
    end

    local entity = storage[name]
    if not entity then
      entity = ctor(parent, name, ...)
      storage[name] = entity
    end
    
    return entity
  end

  return self
end

-- Export module.
return Storage