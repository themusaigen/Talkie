-- BufferIO: A class that, based on a string representation of a data type, tells you how to read and write it
local BufferIO = {}
local BufferHelpers = require(script.Parent.Shared.BufferHelpers)

-- Non-numeric types
BufferIO.Boolean = {
	read = function(buf): boolean
		return buf:ReadBoolean()
	end,
	write = function(buf, state: boolean)
		buf:WriteBoolean(state)
	end,
}

BufferIO.String8 = {
	read = function(buf): string
    return BufferHelpers:ReadSizedString(buf, "UInt8")
	end,
  write = function(buf, str: string)
    BufferHelpers:WriteSizedString(buf, "UInt8", str)
  end
}

BufferIO.String16 = {
  read = function(buf): string
    return BufferHelpers:ReadSizedString(buf, "UInt16")
	end,
  write = function(buf, str: string)
    BufferHelpers:WriteSizedString(buf, "UInt16", str)
  end
}

BufferIO.String32 = {
  read = function(buf): string
    return BufferHelpers:ReadSizedString(buf, "UInt32")
	end,
  write = function(buf, str: string)
    BufferHelpers:WriteSizedString(buf, "UInt32", str)
  end
}

BufferIO.Vector3 = {
	read = function(buf): Vector3
		local x, y, z = buf:ReadFloat(), buf:ReadFloat(), buf:ReadFloat()
		return Vector3.new(x, y, z)
	end,
	write = function(buf, value: Vector3)
		buf:WriteFloat(value.X)
		buf:WriteFloat(value.Y)
		buf:WriteFloat(value.Z)
	end,
}

BufferIO.Vector3_64 = {
	read = function(buf): Vector3
		local x, y, z = buf:ReadFloat64(), buf:ReadFloat64(), buf:ReadFloat64()
		return Vector3.new(x, y, z)
	end,
	write = function(buf, value: Vector3)
		buf:WriteFloat64(value.X)
		buf:WriteFloat64(value.Y)
		buf:WriteFloat64(value.Z)
	end,
}

BufferIO.Struct = function(model)
  assert(typeof(model) == "table", `Struct<model> is expected to be table, got {typeof(model)}`)

  return {
    read = function(buf)
      local out = {}

      for key, io in pairs(model) do
        out[key] = io.read(buf)
      end

      return out
    end,
    write = function(buf, data)
      for key, value in pairs(data) do
        model[key].write(buf, value)
      end
    end
  }
end

BufferIO.Array8 = function(type)
  return {
    read = function(buf)
      return BufferHelpers:ReadSizedArray(buf, "UInt8", type)
    end,
    write = function(buf, array)
      BufferHelpers:WriteSizedArray(buf, "UInt8", type, array)
    end
  }
end

BufferIO.Array16 = function(type)
  return {
    read = function(buf)
      return BufferHelpers:ReadSizedArray(buf, "UInt16", type)
    end,
    write = function(buf, array)
      BufferHelpers:WriteSizedArray(buf, "UInt16", type, array)
    end
  }
end

BufferIO.Array32 = function(type)
  return {
    read = function(buf)
      return BufferHelpers:ReadSizedArray(buf, "UInt32", type)
    end,
    write = function(buf, array)
      BufferHelpers:WriteSizedArray(buf, "UInt32", type, array)
    end
  }
end

BufferIO.Optional = function(...)
	-- Pack arguments as types.
	local types = { ... }

	-- Check them.
	assert(#types > 0, "Optional must have at least one type!")

	return {
		read = function(buf)
			if buf:ReadBoolean() then
        if #types > 1 then
          local out = {}
          for index, io in types do
            out[index] = io.read(buf)
          end 
          return out
        else
          return types[1].read(buf)
        end
			end
		end,
		write = function(buf, data)
			local hasData = not (data == nil)

			-- Write boolean to mark is value provided or not.
			buf:WriteBoolean(hasData)

			-- Now write all optional types
			if hasData then
				if #types == 1 then
					types[1].write(buf, data)
				else
					assert(typeof(data) == "table", `Optional<data> is expected to be table, got {typeof(data)})`)
			
					for index, value in data do
						types[index].write(buf, value)
					end
				end
			end
		end,
	}
end

-- Generate numeric types automatically.
local methods = {
	Int8 = true,
	UInt8 = true,
	Int16 = true,
	UInt16 = true,
	Int32 = true,
	UInt32 = true,
	Float = true,
	Float32 = true,
	Float64 = true,
}

for key, _ in pairs(methods) do
	BufferIO[key] = {
		read = function(buf)
			return buf[`Read{key}`](buf)
		end,
		write = function(buf, value)
			buf[`Write{key}`](buf, value)
		end,
	}
end

return BufferIO
