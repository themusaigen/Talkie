return function()
  local Packet, Types, Types1

  beforeAll(function(context)
    Packet = require(game.ReplicatedStorage.Talkie.Packet)
    Types = Packet.Types
  end)

  it("0. should work with primitive packets", function()
    local PacketLogin = Packet.new(0, { name = Types.String8 }, { score = Types.UInt32 })

    -- Now serialize this packet.
    local packet
    expect(function()
      packet = PacketLogin:Serialize({
        name = "Player",
        score = 999,
      })
    end).never.to.throw()

    -- We are expecting that valid buf returned.
    expect(packet).to.ok()

    -- Shift the cursor.
    packet:IgnoreBytes(2)

    -- Now deserialize this packet.
    expect(function()
      print(PacketLogin:Deserialize(packet))
    end).never.to.throw()
  end)

  it("1. should work with more complex types", function(context)
    local packet = Packet.new(
      1,
      { position = Types.Vector3 },
      { orientation = Types.Vector3 },
      { data = Types.Struct({ value = Types.Int8 }, { value2 = Types.Int8 }) },
      { opt = Types.Optional(Types.Int8, Types.Struct({ value = Types.Int8 })) }
    )

    -- serialize this packet.
    local data
    expect(function()
      local t = {
        position = Vector3.new(0, 2, 0),
        orientation = Vector3.new(0, 90, 0),
        data = {
          value = 32,
          value2 = 64,
        },
        opt = { 2, {
          value = 16,
        } },
      }

      data = packet:Serialize(t)
    end).never.to.throw()

    expect(data).to.ok()

    -- Shift the cursor.
    data:IgnoreBytes(2)

    -- Printing to inspect the deserialized data.
    expect(function()
      print(packet:Deserialize(data))
    end).never.to.throw()
  end)
end
