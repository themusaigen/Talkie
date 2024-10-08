return function()
	beforeAll(function(context)
		context.parent = context.Talkie.Client(game.ReplicatedStorage, "TestFolder_2")._parent
	end)

	describe("0. Create", function()
		it("0. should throw error if not string provided as name", function(context)
			expect(function()
				context.Event.new(context.parent, 123)
			end).to.throw()
		end)

		it("1. should throw error if empty name provided", function(context)
			expect(function()
				context.Event.new(context.parent, "")
			end).to.throw()
		end)

		it("3. should throw error if don't exist", function(context)
      expect(function()
        context.Event.new(context.parent, "TestEvent_3232")
      end).to.throw()
    end)

		it("4. should throw error if not table provided as middleware", function(context)
			expect(function()
				context.Event.new(context.parent, "TestEvent", 123)
			end).to.throw()
		end)
	end)

  describe("1. Connect, Once",function()
    it("0. should throw error if not function provided", function(context)
      local event = context.Event.new(context.parent, "TestEvent")
      expect(function()
        event:Connect(123)
      end).to.throw()
      expect(function()
        event:Once(123)
      end).to.throw()
      event:Destroy()
    end)
  end)

  describe("2. Middleware", function()
    it("0. should throw error if not table provided", function(context)
			local event = context.Event.new(context.parent, "TestEvent")

			expect(function()
				event:SetMiddleware(123)
			end).to.throw()

			event:Destroy()
		end)

		it("1. should throw error if not table provided in inbound", function(context)
			local event = context.Event.new(context.parent, "TestEvent")

			expect(function()
				event:SetMiddleware({ Inbound = 123 })
			end).to.throw()

			event:Destroy()
		end)

		it("2. should throw error if not table provided in outbound", function(context)
			local event = context.Event.new(context.parent, "TestEvent")

			expect(function()
				event:SetMiddleware({ Outbound = 123 })
			end).to.throw()

			event:Destroy()
		end)
  end)
end
