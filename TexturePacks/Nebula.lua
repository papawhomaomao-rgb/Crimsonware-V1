local thing = workspace.CurrentCamera:WaitForChild("Viewmodel").ChildAdded:Connect(function(Tool)
	if Tool:IsA("Accessory") then
		local TexturePack = game:GetObjects("rbxassetid://14654171957")
		local Import = TexturePack[1]
		Import.Parent = game.ReplicatedStorage
		for _, part in pairs(Import:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then
				pcall(function() part.CanCollide = false; part.CanQuery = false end)
			end
		end
	
		local TexturePackTable = {
			{
			  	Name = "wood_sword",
			  	Offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
			  	Model = Import:WaitForChild("Wood_Sword"),
			},	
	
			{
				Name = "stone_sword",
				Offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
				Model = Import:WaitForChild("Stone_Sword"),
			},
	
			{
				Name = "iron_sword",
				Offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
				Model = Import:WaitForChild("Iron_Sword"),
			},
	
			{
			  	Name = "diamond_sword",
			  	Offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
			  	Model = Import:WaitForChild("Diamond_Sword"),
			},	
	
			{
				Name = "emerald_sword",
				Offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
				Model = Import:WaitForChild("Emerald_Sword"),
			},
	
			{
				Name = "rageblade",
				Offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
				Model = Import:WaitForChild("Rageblade"),
			},
	
			{
				Name = "wood_scythe",
				Offset = CFrame.Angles(math.rad(0),math.rad(89),math.rad(-90)),
				Model = Import:WaitForChild("Wood_Scythe"),
			},
	
			{
				Name = "stone_scythe",
				Offset = CFrame.Angles(math.rad(0),math.rad(89),math.rad(-90)),
				Model = Import:WaitForChild("Stone_Scythe"),
			},
	
			{
				Name = "iron_scythe",
				Offset = CFrame.Angles(math.rad(0),math.rad(89),math.rad(-90)),
				Model = Import:WaitForChild("Iron_Scythe"),
			},
	
			{
				Name = "diamond_scythe",
				Offset = CFrame.Angles(math.rad(0),math.rad(89),math.rad(-90)),
				Model = Import:WaitForChild("Diamond_Scythe"),
			},
	
			{
			  	Name = "wood_pickaxe",
			  	Offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
			  	Model = Import:WaitForChild("Wood_Pickaxe"),
			},	
	
			{
			  	Name = "stone_pickaxe",
			  	Offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
			  	Model = Import:WaitForChild("Stone_Pickaxe"),
			},	
	
			{
			  	Name = "iron_pickaxe",
			  	Offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
			  	Model = Import:WaitForChild("Iron_Pickaxe"),
			},	
	
			{
				Name = "diamond_pickaxe",
				Offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-95)),
				Model = Import:WaitForChild("Diamond_Pickaxe"),
			},
	
			{
				Name = "diamond",
				Offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
				Model = Import:WaitForChild("Diamond"),
			},
	
			{
				Name = "iron",
				Offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
				Model = Import:WaitForChild("Iron"),
			},
	
			{
				Name = "emerald",
				Offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
				Model = Import:WaitForChild("Emerald"),
			},
		}
	
		for i, v in next, TexturePackTable do	
		    if v.Name == Tool.Name then
	            local Model2
	            local Model
	
				local Tool2
	
				local function ActivateTexturePack()
					for i2, v2 in next, Tool:GetDescendants() do
					   	if v2:IsA("BasePart") or v2:IsA("MeshPart") or v2:IsA("UnionOperation") then				
					   	                                                                            	v2.Transparency = 1
																										pcall(function() v.CanCollide = false; v.CanQuery = false end)
					   	end                                                                         			
					end	                                                                            	
	
					Model = v.Model:Clone()

					for _, part in pairs(Model:GetDescendants()) do
						if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then
							pcall(function() part.CanCollide = false; part.CanQuery = false end)
						end
					end

					Model.Parent = Tool		
					Model.Name = v.Name
						Model.Size *= Vector3.new(1.375, 1.375, 1.375)
	
					Model.CFrame = ((Tool:WaitForChild("Handle").CFrame * v.Offset) * CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0)))	
	
					local Weld = Instance.new("WeldConstraint")
	
					Weld.Parent = Model
					Weld.Name = "WeldConstraint"
	
					Weld.Part0 = Model
					Weld.Part1 = Tool:WaitForChild("Handle")			
	
					Tool2 = game.Players.LocalPlayer.Character:WaitForChild(v.Name)			
	
					for i2, v2 in next, Tool2:GetDescendants() do
					   	if v2:IsA("BasePart") or v2:IsA("MeshPart") or v2:IsA("UnionOperation") then	                   			
					   	                                                                            	v2.Transparency = 1				
					   	end                                                                         	
					end	                                                                            	
	
					Model2 = v.Model:Clone()
					for _, part in pairs(Model2:GetDescendants()) do
						if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then
							pcall(function() part.CanCollide = false; part.CanQuery = false end)
						end
					end

					Model2.Parent = Tool2
					Model2.Name = v.Name
	
					Model2.Anchored = false
					Model2.CFrame = ((Tool2:WaitForChild("Handle").CFrame * v.Offset)) * CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
				end
	
				if v.Name == "iron" then
					ActivateTexturePack()
	
					Model2.CFrame = (Model2.CFrame * CFrame.new(0, -0.24, 0))
				end
	
				if v.Name == "diamond" then
					ActivateTexturePack()
	
					Model2.CFrame = (Model2.CFrame * CFrame.new(0, 0.027, 0))
				end
	
				if v.Name == "emerald" then
					ActivateTexturePack()
	
					Model2.CFrame = (Model2.CFrame * CFrame.new(0, 0.001, 0))
				end
	
				if v.Name:find("pickaxe") then
					ActivateTexturePack()
	
					Model2.CFrame = ((Model2.CFrame * CFrame.new(-0.2, 0, -2.4)) + Vector3.new(0, 0, 2.12))
				end
	
				if v.Name:find("scythe") then
					ActivateTexturePack()
	
					Model2.CFrame = (Model2.CFrame * CFrame.new(-1.15, 0.2, -2.1)) 
	
				end
	
				if v.Name == "rageblade" then
					ActivateTexturePack()
	
					Model2.CFrame = (Model2.CFrame * CFrame.new(0.7, 0, -1)) 
				end
	
				if v.Name:find("sword") then
					ActivateTexturePack()
	
					Model2.CFrame = ((Model2.CFrame * CFrame.new(0.6, 0, -1.1)) + Vector3.new(0, 0, 0.3))
				end
	
				local Weld2 = Instance.new("WeldConstraint")
	
				Weld2.Parent = Model
				Weld2.Name = "WeldConstraint"
	
				Weld2.Part0 = Model2
				Weld2.Part1 = Tool2:WaitForChild("Handle")
			end
		end
	end
end)
getgenv().texturepack = thing