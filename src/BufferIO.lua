--!optimize 2
--!native

-- BufferIO: A class that, based on a string representation of a data type, tells you how to read and write it
local BufferIO = {}

-- Types for IntelliSense.
local Types = require(script.Parent.Types)

BufferIO = BufferIO :: Types.BufferIO

-- Helpers for size-based types.
local BufferHelpers = require(script.Parent.Shared.BufferHelpers)

-- Trivial types from the start of the file, functional from the end.

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
		read = function(buf): number
			return buf[`Read{key}`](buf)
		end,
		write = function(buf: Types.Buffer, value: number)
			buf[`Write{key}`](buf, value)
		end,
	} :: Types.TrivialType<number>
end

-- Non-numeric types
BufferIO.Boolean = {
	read = function(buf: Types.Buffer): boolean
		return buf:ReadBoolean()
	end,
	write = function(buf: Types.Buffer, state: boolean)
		buf:WriteBoolean(state)
	end,
} :: Types.TrivialType<boolean>

BufferIO.String8 = {
	read = function(buf: Types.Buffer): string
    return BufferHelpers:ReadSizedString(buf, BufferIO.UInt8)
	end,
  write = function(buf: Types.Buffer, str: string)
    BufferHelpers:WriteSizedString(buf, BufferIO.UInt8, str)
  end
} :: Types.TrivialType<string>

BufferIO.String16 = {
  read = function(buf: Types.Buffer): string
    return BufferHelpers:ReadSizedString(buf, BufferIO.UInt16)
	end,
  write = function(buf: Types.Buffer, str: string)
    BufferHelpers:WriteSizedString(buf, BufferIO.UInt16, str)
  end
} :: Types.TrivialType<string>

BufferIO.String32 = {
  read = function(buf: Types.Buffer): string
    return BufferHelpers:ReadSizedString(buf, BufferIO.UInt32)
	end,
  write = function(buf: Types.Buffer, str: string)
    BufferHelpers:WriteSizedString(buf, BufferIO.UInt32, str)
  end
} :: Types.TrivialType<string>

BufferIO.Vector2 = {
  read = function(buf: Types.Buffer): Vector2
    local x, y = buf:ReadFloat(), buf:ReadFloat()
    return Vector2.new(x, y)
  end,
  write = function(buf: Types.Buffer, value: Vector2)
    buf:WriteFloat(value.X)
    buf:WriteFloat(value.Y)
  end
} :: Types.TrivialType<Vector2>

BufferIO.Vector2int16 = {
  read = function(buf: Types.Buffer): Vector2int16
    local x, y = buf:ReadInt16(), buf:ReadInt16()
    return Vector2int16.new(x, y)
  end,
  write = function(buf: Types.Buffer, value: Vector2int16)
    buf:WriteInt16(value.X)
    buf:WriteInt16(value.Y)
  end
} :: Types.TrivialType<Vector2int16>

BufferIO.Vector3 = {
	read = function(buf: Types.Buffer): Vector3
		local x, y, z = buf:ReadFloat(), buf:ReadFloat(), buf:ReadFloat()
		return Vector3.new(x, y, z)
	end,
	write = function(buf: Types.Buffer, value: Vector3)
		buf:WriteFloat(value.X)
		buf:WriteFloat(value.Y)
		buf:WriteFloat(value.Z)
	end,
} :: Types.TrivialType<Vector3>

BufferIO.Vector3int16 = {
  read = function(buf: Types.Buffer): Vector3int16
    local x, y, z = buf:ReadInt16(), buf:ReadInt16(), buf:ReadInt16()
    return Vector3int16.new(x, y, z)
  end,
  write = function(buf: Types.Buffer, value: Vector3int16)
    buf:WriteInt16(value.X)
    buf:WriteInt16(value.Y)
    buf:WriteInt16(value.Z)
  end
} :: Types.TrivialType<Vector3int16>

BufferIO.Color3 = {
  read = function(buf: Types.Buffer): Color3
    local r, g, b = buf:ReadUInt8(), buf:ReadUInt8(), buf:ReadUInt8()
    return Color3.fromRGB(r, g, b)
  end,
  write = function(buf: Types.Buffer, color: Color3)
    buf:WriteUInt8(math.ceil(color.R * 255))
    buf:WriteUInt8(math.ceil(color.G * 255))
    buf:WriteUInt8(math.ceil(color.B * 255))
  end
} :: Types.TrivialType<Color3>


BufferIO.CFrame = {
  read = function(buf: Types.Buffer): CFrame
    -- Roblox does this more effectively by native.
    local position = BufferIO.Vector3.read(buf)
    local rotation = BufferIO.Vector3.read(buf)
    return CFrame.new(position) * CFrame.Angles(rotation.X, rotation.Y, rotation.Z)
  end,
  write = function(buf: Types.Buffer, cframe: CFrame)
    BufferIO.Vector3.write(buf, cframe.Position)
    BufferIO.Vector3.write(buf, cframe.Rotation)
  end
}

function BufferIO.Array8<T>(type: Types.TrivialType<T>): Types.TrivialType<{T}>
  return {
    read = function(buf: Types.Buffer): {T}
      return BufferHelpers:ReadSizedArray(buf, BufferIO.UInt8, type)
    end,
    write = function(buf: Types.Buffer, array: {T})
      BufferHelpers:WriteSizedArray(buf, BufferIO.UInt8, type, array)
    end
  }
end

function BufferIO.Array16<T>(type: Types.TrivialType<T>): Types.TrivialType<{T}>
  return {
    read = function(buf: Types.Buffer)
      return BufferHelpers:ReadSizedArray(buf, BufferIO.UInt16, type)
    end,
    write = function(buf: Types.Buffer, array)
      BufferHelpers:WriteSizedArray(buf, BufferIO.UInt16, type, array)
    end
  }
end

function BufferIO.Array32<T>(type: Types.TrivialType<T>): Types.TrivialType<{T}>
  return {
    read = function(buf: Types.Buffer)
      return BufferHelpers:ReadSizedArray(buf, BufferIO.UInt32, type)
    end,
    write = function(buf: Types.Buffer, array)
      BufferHelpers:WriteSizedArray(buf, BufferIO.UInt32, type, array)
    end
  }
end

function BufferIO.Optional<Args...>(...: Args...): Types.TrivialType<{[string]:  any}>
	-- Pack arguments as types.
	local types = { ... }

	-- Check them.
	assert(#types > 0, "Optional must have at least one type!")

	return {
		read = function(buf: Types.Buffer): {[string]: any}
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
		write = function(buf: Types.Buffer, data: {[string]: any})
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

function BufferIO.Struct(model: {[string]: Types.TrivialType<any>}): Types.TrivialType<{[string]: any}>
  assert(typeof(model) == "table", `Struct<model> is expected to be table, got {typeof(model)}`)

  return {
    read = function(buf: Types.Buffer): {[string]: any}
      local out = {}

      for key, io in pairs(model) do
        out[key] = io.read(buf)
      end

      return out
    end,
    write = function(buf: Types.Buffer, data: {[string]: any})
      for key, value in pairs(data) do
        model[key].write(buf, value)
      end
    end
  }
end

function BufferIO.Default<T>(valueType: Types.TrivialType<T>, default: T): Types.TrivialType<T>
  return {
    read = function(buf: Types.Buffer): T
      return valueType.read(buf)
    end,
    write = function(buf: Types.Buffer, value: T)
      valueType.write(buf, if value ~= nil then value else default)
    end
  }
end

function BufferIO.Map8<K, V>(keyType: Types.TrivialType<K>, valueType: Types.TrivialType<V>): Types.TrivialType<{[K]: V}>
  return {
    read = function(buf: Types.Buffer): {[K]: V}
      return BufferHelpers:ReadSizedMap(buf, BufferIO.UInt8, keyType, valueType)
    end,
    write = function(buf: Types.Buffer, map: {[K]: V})
      BufferHelpers:WriteSizedMap(buf, BufferIO.UInt8, keyType, valueType, map)
    end
  }
end

function BufferIO.Map16<K, V>(keyType: Types.TrivialType<K>, valueType: Types.TrivialType<V>): Types.TrivialType<{[K]: V}>
  return {
    read = function(buf: Types.Buffer): {[K]: V}
      return BufferHelpers:ReadSizedMap(buf, BufferIO.UInt16, keyType, valueType)
    end,
    write = function(buf: Types.Buffer, map: {[K]: V})
      BufferHelpers:WriteSizedMap(buf, BufferIO.UInt16, keyType, valueType, map)
    end
  }
end

function BufferIO.Map32<K, V>(keyType: Types.TrivialType<K>, valueType: Types.TrivialType<V>): Types.TrivialType<{[K]: V}>
  return {
    read = function(buf: Types.Buffer): {[K]: V}
      return BufferHelpers:ReadSizedMap(buf, BufferIO.UInt32, keyType, valueType)
    end,
    write = function(buf: Types.Buffer, map: {[K]: V})
      BufferHelpers:WriteSizedMap(buf, BufferIO.UInt32, keyType, valueType, map)
    end
  }
end

return BufferIO :: Types.BufferIO
