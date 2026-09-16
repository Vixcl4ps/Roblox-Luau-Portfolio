local ClassDataHandler = require(game.ServerScriptService.ModuleScripts.ClassDataHandler)
local PlayerData = require(game.ServerScriptService.ModuleScripts.PlayerGameData)

local CombatModule = {}
		
local Cooldown = {}
 
local CreateHitbox = function(player)
	
	local AlreadyHit = {}
	local Character = player.Character
	local root = Character:FindFirstChild("HumanoidRootPart")
	--//HitBox//--
	local hitbox = Instance.new("Part")
	hitbox.Size = Vector3.new(5,5,5)
	hitbox.Transparency = 1
	hitbox.Anchored = true
	hitbox.CanCollide = false
	hitbox.CFrame = root.CFrame * CFrame.new(0,0,-2)
	hitbox.Parent = workspace
	hitbox.Color = Color3.new(1,0,0)
	
	
	local OverlapParams = OverlapParams.new()
	OverlapParams.FilterType = Enum.RaycastFilterType.Exclude
	OverlapParams.FilterDescendantsInstances = {Character}
	local Parts = workspace:GetPartsInPart(hitbox,OverlapParams)
	for _, part in Parts do
		local Humanoid = part.Parent:FindFirstChild("Humanoid")
		if Humanoid and not AlreadyHit[Humanoid] then
			local Creator = Humanoid:FindFirstChild("creator")
			if Creator == nil then
				Creator = Instance.new("ObjectValue")
				Creator.Name = "creator"
				Creator.Parent = Humanoid
			end
			Creator.Value = player
			Humanoid:TakeDamage(25)
			AlreadyHit[Humanoid] = true
			print("Hit")
		end
		
	end
	task.wait(0.5)
	hitbox:Destroy()
end
		
		
		
function CombatModule.M1(player)
	if not Cooldown[player.UserId] then
	Cooldown[player.UserId] = true
	local Humanoid = player.Character:FindFirstChild("Humanoid")
	local Animator = Humanoid:FindFirstChild("Animator")
	local Animation = Instance.new("Animation")
	Animation.AnimationId = "rbxassetid://122601033265124"
	local Track = Animator:LoadAnimation(Animation)
	Track:Play()
	task.wait(0.3)
	CreateHitbox(player)
	
	task.wait(0.5)
	Cooldown[player.UserId] = false
	end
end


return CombatModule
