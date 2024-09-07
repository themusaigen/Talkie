if game:GetService("RunService"):IsServer() then
  return require(script.Parent.Server.Property)
else
  return require(script.Parent.Client.Property)
end
