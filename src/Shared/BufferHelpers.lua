-- BufferHelpers: as name said, helpers for BufferIO.
local BufferHelpers = {}

-- Types for IntelliSense.
local Types = require(script.Parent.Parent.Types)

function BufferHelpers:ReadSizedString(buf: Types.Buffer, sizeType: Types.TrivialType<number>): string
	local size = sizeType.read(buf)
	if size == 0 then
		return ""
	end
	return buf:ReadString(size)
end

function BufferHelpers:WriteSizedString(buf: Types.Buffer, sizeType: Types.TrivialType<number>, str: string)
	sizeType.write(buf, #str)
	buf:WriteString(str)
end

function BufferHelpers:ReadSizedArray<T>(
	buf: Types.Buffer,
	sizeType: Types.TrivialType<number>,
	valueType: Types.TrivialType<T>
): { T }
	local array = {} :: {T}
	local size = sizeType.read(buf)
	for i = 1, size do
		array[i] = valueType.read(buf)
	end
	return array
end

function BufferHelpers:WriteSizedArray<T>(
	buf: Types.Buffer,
	sizeType: Types.TrivialType<number>,
	valueType: Types.TrivialType<T>,
	array: { T }
)
	sizeType.write(buf, #array)
	for i = 1, #array do
		valueType.write(buf, array[i])
	end
end

function BufferHelpers:ReadSizedMap<K, V>(
	buf: Types.Buffer,
	sizeType: Types.TrivialType<number>,
	keyType: Types.TrivialType<K>,
	valueType: Types.TrivialType<V>
): { [K]: V }
	local map = {} :: {[K]: V}
	local size = sizeType.read(buf)
	for _ = 1, size do
		map[keyType.read(buf)] = valueType.read(buf)
	end
	return map
end

local function getn(list)
	local count = 0
	for _, _ in pairs(list) do
		count += 1
	end
	return count
end

function BufferHelpers:WriteSizedMap<K, V>(
	buf: Types.Buffer,
	sizeType: Types.TrivialType<number>,
	keyType: Types.TrivialType<K>,
	valueType: Types.TrivialType<V>,
	map: {[K]: V}
)
	sizeType.write(buf, getn(map))
	for key, value in pairs(map) do
		keyType.write(buf, key)
		valueType.write(buf, value)
	end
end

-- Export the module
return BufferHelpers
