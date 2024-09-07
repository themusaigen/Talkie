return function()
	it("0. should return same entity", function(context)
		local client = context.Talkie.Client(game.ReplicatedStorage, "StorageTest")
		local fun0 = client:Function("Function0")
		local fun1 = client:Function("Function1")
		local fun0copy = client:Function("Function0")

		expect(fun0copy).to.equal(fun0)
		expect(fun1).never.to.equal(fun0)
	end)
end
