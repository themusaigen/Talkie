return function()
  beforeAll(function(context)
    context.client = context.Talkie.Client(game.ReplicatedStorage, "TestFolder_2")
    context.test1 = context.client:Function("TestFunction_1", function()
      return 1337
    end)
    context.dummy = function()
      
    end
  end)

  describe("0. Create", function()
    it("0. should throw error if not string provided as name", function(context)
      expect(function()
        context.client:Function(123)
      end).to.throw()
    end)

    it("1. should throw error if name is empty", function(context)
      expect(function()
        context.client:Function("")
      end).to.throw()
    end)

    it("2. should throw error if not function provided as handler", function(context)
      expect(function()
        context.client:Function("TestFunction_0", 123)
      end).to.throw()
    end)

    it("3. should throw error if not table provided as middleware", function(context)
      expect(function()
        context.client:Function("TestFunction_0", context.dummy, 123)
      end).to.throw()
    end)

    it("4. should throw error if remote don't exist", function(context)
      expect(function()
        context.client:Function("ErrorFunction")
      end).to.throw()
    end)
  end)

  describe("1. Listen", function()
    it("0. should throw error if not function provided as handler", function(context)
      expect(function()
        context.client:Function("TestFunction_0"):Listen(123)
      end).to.throw()
    end)
  end)

  describe("2. Middleware", function()
		it("0. should throw error if not table provided", function(context)
			expect(function()
				context.client:Function("TestFunction_0"):SetMiddleware(123)
			end).to.throw()
		end)

		it("1. should throw error if not table provided in inbound", function(context)
			expect(function()
				context.client:Function("TestFunction_0"):SetMiddleware({ Inbound = 123 })
			end).to.throw()
		end)

		it("2. should throw error if not table provided in outbound", function(context)
			expect(function()
				context.client:Function("TestFunction_0"):SetMiddleware({ Outbound = 123 })
			end).to.throw()
		end)
	end)

  describeSKIP("3. Handle", function()
    it("0. should handle server invokes", function(context)    
      local output
      context.client:Function("TestFunction_0", function(arg)
        output = arg
      end)

      expect(context.AwaitCondition(function()
        return (output == 123)
      end)).to.equal(true)
    end)

    it("1. should properly handle return values", function(context)
      local value = context.client:Function("TestFunction_0")()

      expect(context.AwaitCondition(function()
        return (value == 1337)
      end)).to.equal(true)
    end)
  end)

  describeSKIP("4. Invoke", function()
    it("0. should properly invoke server", function(context)
      expect(function()
        context.test1(123)
      end).never.to.throw()
    end)
  end)
end