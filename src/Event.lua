if game:GetService("RunService"):IsServer() then
  return require(script.Parent.Server.Event)
else
  return require(script.Parent.Client.Event)
end
