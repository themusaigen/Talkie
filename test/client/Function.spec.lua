return function()
	beforeAll(function(context)
		context.parent = context.Talkie.Client(game.ReplicatedStorage, "TestFolder_2")._parent
	end)

	describe("0. Create", function()
		it("0. should throw error if not string provided as name", function(context)
			expect(function()
				context.Function.new(context.parent, 123)
			end).to.throw()
		end)

		it("1. should throw error if name is empty", function(context)
			expect(function()
				context.Function.new(context.parent, "")
			end).to.throw()
		end)

		it("2. should throw error if not function provided as handler", function(context)
			expect(function()
				context.Function.new(context.parent, "TestFunction_0", 123)
			end).to.throw()
		end)

		it("3. should throw error if not table provided as middleware", function(context)
			expect(function()
				context.Function.new(context.parent, "TestFunction_0", context.dummy, 123)
			end).to.throw()
		end)

		it("4. should throw error if remote don't exist", function(context)
			expect(function()
				context.Function.new(context.parent, "ErrorFunction")
			end).to.throw()
		end)
	end)

	describe("1. Listen", function()
		it("0. should throw error if not function provided as handler", function(context)
			expect(function()
				context.Function.new(context.parent, "TestFunction_0"):Listen(123)
			end).to.throw()
		end)
	end)

	describe("2. Middleware", function()
		it("0. should throw error if not table provided", function(context)
			expect(function()
				context.Function.new(context.parent, "TestFunction_0"):SetMiddleware(123)
			end).to.throw()
		end)

		it("1. should throw error if not table provided in inbound", function(context)
			expect(function()
				context.Function.new(context.parent, "TestFunction_0"):SetMiddleware({ Inbound = 123 })
			end).to.throw()
		end)

		it("2. should throw error if not table provided in outbound", function(context)
			expect(function()
				context.Function.new(context.parent, "TestFunction_0"):SetMiddleware({ Outbound = 123 })
			end).to.throw()
		end)
	end)
end
