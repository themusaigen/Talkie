return function ()
  beforeAll(function(context)
    context.client = context.Talkie.Client(game.ReplicatedStorage, "TestFolder_2")
  end)

  describe("0. Create", function()
    it("0. should throw error if not string provided as name", function(context)
			expect(function()
				context.client:Property(123)
			end).to.throw()
		end)

		it("1. should throw error if empty name provided", function(context)
			expect(function()
				context.client:Property("")
			end).to.throw()
		end)

    it("2. should throw error if don't exist", function(context)
      expect(function()
        context.client:Property("TestProperty_131312")
      end).to.throw()
    end)

		it("3. should throw error if not table provided as middleware", function(context)
			expect(function()
				context.client:Property("TestProperty", nil, 123)
			end).to.throw()
		end)
  end)

  describe("1. Middleware", function()
		it("0. should throw error if not table provided", function(context)
			local property = context.client:Property("TestProperty_0")

			expect(function()
				property:SetMiddleware(123)
			end).to.throw()
		end)

		it("2. should throw error if not table provided inbound", function(context)
			local property = context.client:Property("TestProperty_0")

			expect(function()
				property:SetMiddleware({ Inbound = 123 })
			end).to.throw()
		end)
	end)
end