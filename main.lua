local license = ... or {}
license.Key = script_key or license.Key or '_key'
getgenv().license = license
repeat task.wait() until game:IsLoaded()
if shared.vape then shared.vape:Uninject() end

local vape
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))
local httpService = cloneref(game:GetService('HttpService'))

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/papawhomaomao-rgb/Crimsonware-V1/'..readfile('crimsonware/profiles/commit.txt')..'/'..select(1, path:gsub('crimsonware/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			task.spawn(error, res)
		end
		if suc then
			if path:find('.lua') then
				res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
			end
			writefile(path, res)
		end
	end
	return (func or readfile)(path)
end

local function finishLoading()
	vape.Init = nil
	vape:Load()
	task.spawn(function()
		repeat
			vape:Save()
			task.wait(10)
		until not vape.Loaded
	end)

	local teleportedServers
	vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function(state)
		if (not teleportedServers) and (not shared.VapeIndependent) then
			teleportedServers = true
			local teleportScript = [[
				shared.vapereload = true
				if shared.VapeDeveloper then
					loadstring(readfile('crimsonware/main.lua'), 'main')(_scriptconfig)
				else
					loadstring(readfile('crimsonware/main.lua'), 'main')(_scriptconfig)
				end
			]]
			local teleportConfig = httpService:JSONEncode(license)
			teleportConfig = teleportConfig:gsub('":true', "=true"):gsub('{"', '{')
			teleportConfig = teleportConfig:gsub(',"', ','):gsub('":', '=')
			teleportConfig = teleportConfig:gsub('%[', '{'):gsub('%]', '}')
			teleportScript = teleportScript:gsub('_key', tostring(license.Key or '_key'))
			teleportScript = teleportScript:gsub('_scriptconfig', teleportConfig)
			if identifyexecutor() == 'Potassium' then
				teleportScript = 'task.wait(12)\n'.. teleportScript
			end
			if shared.VapeDeveloper then
				teleportScript = 'shared.VapeDeveloper = true\n'..teleportScript
			end
			if shared.VapeCustomProfile then
				teleportScript = 'shared.VapeCustomProfile = "'..shared.VapeCustomProfile..'"\n'..teleportScript
			end
			queue_on_teleport(teleportScript)
		end
	end))

	if not vape.Categories then return end
	if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
		if getgenv().catrole == 'HWID MISMATCH' then
			vape:CreateNotification('Cat', 'HWID MISMATCH, Go to the script panel to reset hwid', 25, 'alert')
			getgenv().catrole = ''
			task.wait(0.1)
		end
		if not shared.vapereload then
			vape:CreateNotification('Finished Loading', (getgenv().catname and `Authenticated as {getgenv().catname} with {getgenv().catrole}, ` or '').. (vape.VapeButton and 'Press the button in the top right' or 'Press '..table.concat(vape.Keybind, ' + '):upper())..' to open GUI', 5)
			task.delay(0.05 + cloneref(game:GetService('RunService')).PostSimulation:Wait(), function()
				if shared.updated then
					vape:CreateNotification('Cat', `Script has updated from {shared.updated} to {readfile('crimsonware/profiles/commit.txt')}`, 10, 'info')
				end
			end)
		end
	end
end

if not isfile('crimsonware/profiles/gui.txt') then
	writefile('crimsonware/profiles/gui.txt', 'new')
end

local guilist = {new = true, classic = true, old = true, rise = true}
local gui
do
	local forced = (typeof(shared.VapeGUI) == 'string' and shared.VapeGUI)
		or (getgenv and typeof(getgenv().VapeGUI) == 'string' and getgenv().VapeGUI)
	if forced and guilist[forced] then
		-- explicit override (shared.VapeGUI / getgenv().VapeGUI)
		gui = forced
	elseif shared.vapereload and isfile('crimsonware/profiles/gui.txt') and guilist[readfile('crimsonware/profiles/gui.txt')] then
		-- teleport / in-GUI theme switch: keep the chosen interface, no prompt
		gui = readfile('crimsonware/profiles/gui.txt')
	else
		-- fresh manual load: let the user pick their interface
		local choice
		local holder = Instance.new('ScreenGui')
		holder.Name = 'CrimsonwarePicker'
		holder.DisplayOrder = 999999999
		holder.IgnoreGuiInset = true
		holder.ResetOnSpawn = false
		holder.Parent = (gethui and gethui()) or cloneref(game:GetService('CoreGui'))

		local backdrop = Instance.new('TextButton')
		backdrop.Size = UDim2.fromScale(1, 1)
		backdrop.BackgroundColor3 = Color3.new()
		backdrop.BackgroundTransparency = 0.35
		backdrop.AutoButtonColor = false
		backdrop.Modal = true
		backdrop.Text = ''
		backdrop.Parent = holder

		local panel = Instance.new('Frame')
		panel.AnchorPoint = Vector2.new(0.5, 0.5)
		panel.Position = UDim2.fromScale(0.5, 0.5)
		panel.Size = UDim2.fromOffset(480, 300)
		panel.BackgroundColor3 = Color3.fromRGB(18, 12, 12)
		panel.BorderSizePixel = 0
		panel.Parent = backdrop
		Instance.new('UICorner', panel).CornerRadius = UDim.new(0, 10)
		local pstroke = Instance.new('UIStroke', panel)
		pstroke.Color = Color3.fromRGB(120, 20, 20)
		pstroke.Thickness = 1.5
		pstroke.Transparency = 0.2

		local title = Instance.new('TextLabel')
		title.BackgroundTransparency = 1
		title.Position = UDim2.fromOffset(0, 26)
		title.Size = UDim2.new(1, 0, 0, 34)
		title.Font = Enum.Font.GothamBold
		title.Text = 'CRIMSONWARE'
		title.TextSize = 30
		title.TextColor3 = Color3.fromRGB(220, 60, 60)
		title.Parent = panel

		local subtitle = Instance.new('TextLabel')
		subtitle.BackgroundTransparency = 1
		subtitle.Position = UDim2.fromOffset(0, 64)
		subtitle.Size = UDim2.new(1, 0, 0, 18)
		subtitle.Font = Enum.Font.Gotham
		subtitle.Text = 'SELECT YOUR INTERFACE'
		subtitle.TextSize = 12
		subtitle.TextColor3 = Color3.fromRGB(150, 130, 130)
		subtitle.Parent = panel

		local function makeCard(x, name, sub, accent, value)
			local card = Instance.new('TextButton')
			card.AnchorPoint = Vector2.new(0.5, 0)
			card.Position = UDim2.new(x, 0, 0, 112)
			card.Size = UDim2.fromOffset(200, 150)
			card.BackgroundColor3 = Color3.fromRGB(28, 20, 20)
			card.AutoButtonColor = false
			card.Text = ''
			card.Parent = panel
			Instance.new('UICorner', card).CornerRadius = UDim.new(0, 8)
			local cstroke = Instance.new('UIStroke', card)
			cstroke.Color = accent
			cstroke.Thickness = 1
			cstroke.Transparency = 0.45

			local dot = Instance.new('Frame')
			dot.Position = UDim2.fromOffset(16, 16)
			dot.Size = UDim2.fromOffset(38, 38)
			dot.BackgroundColor3 = accent
			dot.BorderSizePixel = 0
			dot.Parent = card
			Instance.new('UICorner', dot).CornerRadius = UDim.new(1, 0)

			local cname = Instance.new('TextLabel')
			cname.BackgroundTransparency = 1
			cname.Position = UDim2.fromOffset(16, 64)
			cname.Size = UDim2.new(1, -32, 0, 44)
			cname.Font = Enum.Font.GothamBold
			cname.Text = name
			cname.TextSize = 17
			cname.TextWrapped = true
			cname.TextXAlignment = Enum.TextXAlignment.Left
			cname.TextYAlignment = Enum.TextYAlignment.Top
			cname.TextColor3 = Color3.fromRGB(235, 225, 225)
			cname.Parent = card

			local csub = Instance.new('TextLabel')
			csub.BackgroundTransparency = 1
			csub.Position = UDim2.fromOffset(16, 118)
			csub.Size = UDim2.new(1, -32, 0, 16)
			csub.Font = Enum.Font.Gotham
			csub.Text = sub
			csub.TextSize = 12
			csub.TextXAlignment = Enum.TextXAlignment.Left
			csub.TextColor3 = Color3.fromRGB(150, 135, 135)
			csub.Parent = card

			card.MouseEnter:Connect(function()
				card.BackgroundColor3 = Color3.fromRGB(42, 29, 29)
				cstroke.Transparency = 0
			end)
			card.MouseLeave:Connect(function()
				card.BackgroundColor3 = Color3.fromRGB(28, 20, 20)
				cstroke.Transparency = 0.45
			end)
			card.MouseButton1Click:Connect(function()
				choice = value
			end)
		end

		makeCard(0.28, 'VAPE', 'Clean interface', Color3.fromRGB(0, 170, 130), 'new')
		makeCard(0.72, 'CRIMSONWARE\nCLASSIC', 'Hellfire · Blood-red', Color3.fromRGB(180, 25, 25), 'classic')

		repeat task.wait() until choice
		holder:Destroy()
		gui = choice
		pcall(writefile, 'crimsonware/profiles/gui.txt', gui)
	end
	if not guilist[gui] then gui = 'new' end
end

if not isfolder('crimsonware/assets/'..gui) then
	makefolder('crimsonware/assets/'..gui)
end
if not isfile('crimsonware/profiles/commit.txt') then
	writefile('crimsonware/profiles/commit.txt', 'main')
end

getgenv().used_init = true
vape = loadstring(downloadFile('crimsonware/guis/'..gui..'.lua'), 'gui')(license)
_G.vape = vape
shared.vape = vape

if not shared.VapeIndependent then
	loadstring(downloadFile('crimsonware/games/universal.lua'), 'universal')(license)
	if isfile('crimsonware/games/'..game.PlaceId..'.lua') then
		loadstring(readfile('crimsonware/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(license)
	else
		if not shared.VapeDeveloper then
			local suc, res = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/papawhomaomao-rgb/Crimsonware-V1/'..readfile('crimsonware/profiles/commit.txt')..'/games/'..game.PlaceId..'.lua', true)
			end)
			if suc and res ~= '404: Not Found' then
				loadstring(downloadFile('crimsonware/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(license)
			end
		end
	end
	loadstring(downloadFile('crimsonware/libraries/premium.lua'), 'premium')(license)
	finishLoading()
else
	vape.Init = finishLoading
	return vape
end
