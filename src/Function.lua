if game:GetService("RunService"):IsServer() then
  return require(script.Parent.Server.Function)
else
  return require(script.Parent.Client.Function)
end
