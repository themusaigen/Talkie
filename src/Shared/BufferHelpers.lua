local BufferHelpers = {}

function BufferHelpers:ReadSizedString(buf, sizeType): string
  local size = buf[`Read{sizeType}`](buf)
  if size == 0 then
    return ""
  end
  return buf:ReadString(size)
end

function BufferHelpers:WriteSizedString(buf, sizeType, str)
  buf[`Write{sizeType}`](buf, #str)
  buf:WriteString(str)
end

function BufferHelpers:ReadSizedArray(buf, sizeType, valueType)
  local array = {}
  local size = buf[`Read{sizeType}`](buf)
  for i = 1, size do
    array[i] = valueType.read(buf)
  end
  return array
end

function BufferHelpers:WriteSizedArray(buf, sizeType, valueType, array)
  buf[`Write{sizeType}`](buf, #array)
  for i = 1, #array do
    valueType.write(buf, array[i])
  end
end

-- Export the module
return BufferHelpers