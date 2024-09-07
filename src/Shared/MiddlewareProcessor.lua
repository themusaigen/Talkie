-- Types for IntelliSense.
local Types = require(script.Parent.Parent.Types)

local ProcessMiddleware
if game:GetService("RunService"):IsServer() then
	function ProcessMiddleware(player: Player, middleware: Types.ServerMiddlewareList, args: { any })
		if not middleware then
			return true
		end

		for _, dispatch in middleware do
			local nparams = debug.info(dispatch, "a")

			-- Call this middleware.
			local result: boolean?, outValue: table?

			if nparams == 1 then
				result, outValue = dispatch(args)
			else
				result, outValue = dispatch(player, args)
			end

			-- If we want to return our value do it.
			if result == false then
				return false, if outValue then outValue else {}
			end
		end

		-- Continue to process anyways.
		return true
	end
else
	function ProcessMiddleware(middleware: Types.ClientMiddlewareList, args: { any })
		if not middleware then
			return true
		end

		for _, dispatch in middleware do
			-- Call this middleware.
			local result: boolean?, outValue: table? = dispatch(args)

			-- If we want to return our value -> do it.
			if result == false then
				return false, if outValue then outValue else {}
			end
		end

		-- Continue to process anyways.
		return true
	end
end

-- Export module
return ProcessMiddleware

