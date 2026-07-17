if texturepack then texturepack:Disconnect() end
local Pack = game:GetObjects("rbxassetid://100570768622198")
Pack[1].Parent = game:GetService("ReplicatedStorage")
for _, part in pairs(Pack[1]:GetDescendants()) do
	if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then
		pcall(function() part.CanCollide = false; part.CanQuery = false end)
	end
end
local Items = Pack[1]:GetChildren()
local lplr = game.Players.LocalPlayer
getgenv().texturepack = workspace.CurrentCamera.Viewmodel.DescendantAdded:Connect(function(m)
	local item = nil
	local offset = CFrame.new(0,0.45,0) * CFrame.Angles(math.rad(0),math.rad(-10),math.rad(-95))
	for i, v in Items do
		if v.Name:lower() == m.Name then
			item = v
			if v.Name:find("Sword") then
				offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90))
			end
			break
		end
	end
	if item ~= nil then
		-- VIEWMODEL
		for i, v in m:GetDescendants() do
			if (v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
				v.Transparency = 1
				pcall(function() v.CanCollide = false; v.CanQuery = false end)
			end
		end
		local mesh = item:Clone()
		for _, part in pairs(mesh:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then
				pcall(function() part.CanCollide = false; part.CanQuery = false end)
			end
		end
		mesh.Anchored = false
		mesh.Parent = m
		mesh.CFrame = m:WaitForChild("Handle").CFrame * offset
		mesh.CFrame *= CFrame.Angles(0,math.rad(-50),0)
		mesh.Size *= Vector3.new(1.375, 1.375, 1.375)
		local weld  = Instance.new("WeldConstraint", mesh)
		weld.Part0 = mesh
		weld.Part1 = m:WaitForChild("Handle")
		-- THIRD PERSON
		for i, v in lplr.Character:WaitForChild(m.Name, 9e9):GetDescendants() do
			if (v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
				v.Transparency = 1
				pcall(function() v.CanCollide = false; v.CanQuery = false end)
			end
		end
		local mesh = item:Clone()
		for _, part in pairs(mesh:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then
				pcall(function() part.CanCollide = false; part.CanQuery = false end)
			end
		end
		mesh.Anchored = false
		mesh.Parent = lplr.Character:WaitForChild(m.Name, 9e9)
		mesh.CFrame = m:WaitForChild("Handle").CFrame * offset
		mesh.CFrame *= CFrame.Angles(0,math.rad(-50),0)
		mesh.Size *= Vector3.new(1.375, 1.375, 1.375)
		local weld  = Instance.new("WeldConstraint", mesh)
		weld.Part0 = mesh
		weld.Part1 = m:WaitForChild("Handle")
	end
end)
