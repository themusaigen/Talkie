return function ()
  beforeAll(function(context)
    context.Packet = require(game.ReplicatedStorage.Talkie.Packet)
    context.Types = context.Packet.Types
  end)

  -- xd
  it("0. should correctly work", function(context)
    local PacketLogin = context.Packet.new({
      name = context.Types.String8,
      score = context.Types.UInt32,
      admin = context.Types.Optional(context.Types.Struct({
        isAdmin = context.Types.Boolean,
        level = context.Types.UInt8,
        superBanCommand = context.Types.Optional(context.Types.Boolean)
      }))
    })

    local buf
    expect(function()
      buf = PacketLogin:Serialize({
        name = "Player",
        score = 999,
        admin = {
          isAdmin = false,
          level = 0
        }
      })
    end).never.to.throw()
    expect(buf).to.ok()
    expect(function()
      print(PacketLogin:Deserialize(buf:Serialize()))
    end).never.to.throw()
  end)
end