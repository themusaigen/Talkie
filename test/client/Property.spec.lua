return function ()
  beforeAll(function(context)
    context.parent = context.Talkie.Client(game.ReplicatedStorage, "TestFolder_2")._parent
  end)

  describe("0. Create", function()
    it("0. should throw error if not string provided as name", function(context)
			expect(function()
				context.Property.new(context.parent, 123)
			end).to.throw()
		end)

		it("1. should throw error if empty name provided", function(context)
			expect(function()
				context.Property.new(context.parent, "")
			end).to.throw()
		end)

    it("2. should throw error if don't exist", function(context)
      expect(function()
        context.Property.new(context.parent, "TestProperty_131312")
      end).to.throw()
    end)

		it("3. should throw error if not table provided as middleware", function(context)
			expect(function()
				context.Property.new(context.parent, "TestProperty", nil, 123)
			end).to.throw()
		end)
  end)

  describe("1. Middleware", function()
		it("0. should throw error if not table provided", function(context)
			local property = context.Property.new(context.parent, "TestProperty_0")

			expect(function()
				property:SetMiddleware(123)
			end).to.throw()
		end)

		it("2. should throw error if not table provided inbound", function(context)
			local property = context.Property.new(context.parent, "TestProperty_0")

			expect(function()
				property:SetMiddleware({ Inbound = 123 })
			end).to.throw()
		end)
	end)
end