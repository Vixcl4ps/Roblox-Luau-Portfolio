--Module for handling player abilities
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ClassDataHandler = require(game.ServerScriptService.ModuleScripts.ClassDataHandler)
local AbilityHandler = {}

local ActiveDrills = {}

-- Function to update bullet movement
RunService.Heartbeat:Connect(function()
	for UserId, Bullets in pairs(ActiveDrills) do
		local Player = Players:GetPlayerByUserId(UserId)

		if not Player then
			continue
		end

		local Character = Player.Character

		if not Character then
			continue
		end

		local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

		if not HumanoidRootPart then
			continue
		end

		for _, Bullet in ipairs(Bullets) do
			if Bullet and Bullet.Parent then
				local Slot = Bullet:GetAttribute("Slot")
				local XOffset = (Slot - 2) * 3
				local Bob = math.sin(os.clock() * 3 + Slot) * 0.3

				Bullet.CFrame =
					HumanoidRootPart.CFrame
					* CFrame.new(XOffset, 5 + Bob, 3)
					* CFrame.Angles(math.rad(90), 0, 0)
			end
		end
	end
end)

local abilities = {

	["Earth Wall"] = function(plr)
		--Check if player has the correct subclass
		local RequiredSubClass = ClassDataHandler.SubClasses.EarthMage.Name
		local Subclass = plr.Playerinfo:FindFirstChild("SubClass")
		if Subclass.Value ~= RequiredSubClass then
			print("Not Correct SubClass!")
			return
		end
		print("Fired Earth Wall")
		-- Earth Wall Creation
		local Character = plr.Character
		local Humanoid = Character:WaitForChild("Humanoid")
		local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

		local EarthWall = Instance.new("Part")	-- Create the wall
		
		EarthWall.Parent = workspace			
		EarthWall.Anchored = true
		EarthWall.CanCollide = true
		EarthWall.Transparency = 0			-- Set the wall's properties
		EarthWall.Size = Vector3.new(10, 7, 2)
		EarthWall.Material = Enum.Material.Sand
		EarthWall.Color = Color3.new(1, 0.666667, 0.498039)

		local TargetCframe = HumanoidRootPart.CFrame * CFrame.new(0, 0, -4)
		EarthWall.CFrame = TargetCframe * CFrame.new(0, -7, 0)

		local EndCFrame = HumanoidRootPart.CFrame * CFrame.new(0, -9, -4)
		--Tweens Info
		local info = TweenInfo.new(0.5)
		-- Creating Tween
		local Tween = TweenService:Create(EarthWall, info, {CFrame = TargetCframe})
		Tween:Play()

		task.wait(3)

		local EndTween = TweenService:Create(EarthWall, info, {CFrame = EndCFrame})
		EndTween:Play()

		task.wait(2)

		EarthWall:Destroy()
	end,

	["Earth Bullets"] = function(plr, MousePos)
		
		--Check if player has the correct subclass
		local RequiredSubClass = ClassDataHandler.SubClasses.EarthMage.Name
		local Subclass = plr.Playerinfo:FindFirstChild("SubClass")
		if Subclass.Value ~= RequiredSubClass then
			print("Not Correct SubClass")
			return
		end
		
		--Table of players active Bullets/Drills
		if ActiveDrills[plr.UserId] == nil then
			ActiveDrills[plr.UserId] = {}
			
			for i = 1, 3 do
				local Bullet = Instance.new("Part")
				Bullet.Parent = workspace
				Bullet.Anchored = true
				Bullet.CanCollide = false
				Bullet.CanQuery = false
				Bullet.Transparency = 0
				Bullet.Size = Vector3.new(1.5, 3, 1.5)
				Bullet.Material = Enum.Material.Slate
				Bullet.Color = Color3.fromRGB(120, 85, 60)

				Bullet:SetAttribute("Slot", i)

				local Mesh = Instance.new("SpecialMesh")

				Mesh.MeshType = Enum.MeshType.FileMesh
				Mesh.MeshId = "rbxassetid://9756362"
				Mesh.Scale = Vector3.new(1, 1.7, 1)
				Mesh.Parent = Bullet

				Bullet.CFrame =
					plr.Character.HumanoidRootPart.CFrame
					* CFrame.new((i - 2) * 3, 5, 3)
					* CFrame.Angles(math.rad(90), 0, 0)

				table.insert(ActiveDrills[plr.UserId], Bullet)
			end

		else
			-- if player has active drills, remove the first one and fire it and so ON
			local Bullet = table.remove(ActiveDrills[plr.UserId], 1)

			local TargetPos = MousePos
			local StartPos = Bullet.Position
			local Direction = (TargetPos - StartPos).Unit

			Bullet.CFrame =
				CFrame.new(StartPos, StartPos + Direction)
				* CFrame.Angles(math.rad(90), 0, 0)

			local Params = RaycastParams.new()
			Params.FilterType = Enum.RaycastFilterType.Exclude

			local exclusions = {
				plr.Character,
				Bullet
			}

			for _, RemainingBullet in pairs(ActiveDrills[plr.UserId]) do
				table.insert(exclusions, RemainingBullet)
			end

			Params.FilterDescendantsInstances = exclusions

			local Speed = 120
			local MaxDistance = 100
			local DistanceTravelled = 0
			local CurrentPosition = StartPos

			local Connection

			Connection = RunService.Heartbeat:Connect(function(dt)
				if not Bullet.Parent then
					Connection:Disconnect()
					return
				end

				local RemainingDistance = MaxDistance - DistanceTravelled

				if RemainingDistance <= 0 then
					Connection:Disconnect()
					Bullet:Destroy()
					return
				end

				local StepDistance = math.min(Speed * dt, RemainingDistance)
				local Step = Direction * StepDistance

				local Result = workspace:Raycast(CurrentPosition, Step, Params)

				if Result then
					Bullet.Position = Result.Position

					local HitCharacter = Result.Instance:FindFirstAncestorOfClass("Model")

					local Humanoid =
						HitCharacter
						and HitCharacter:FindFirstChildOfClass("Humanoid")

					if Humanoid then
						local Creator = Humanoid:FindFirstChild("creator")

						if Creator == nil then
							Creator = Instance.new("ObjectValue")
							Creator.Name = "creator"
							Creator.Parent = Humanoid
						end

						Creator.Value = plr

						Humanoid:TakeDamage(15)
					end

					Connection:Disconnect()
					Bullet:Destroy()
					return
				end

				CurrentPosition += Step
				DistanceTravelled += StepDistance

				Bullet.Position = CurrentPosition
			end)

			if #ActiveDrills[plr.UserId] == 0 then
				ActiveDrills[plr.UserId] = nil
			end
		end
	end
}


--Actual Ability run Function
local function AbilityUsed(plr, Ability, MousePos)
	local AbilityFunction = abilities[Ability]
	local Character = plr.Character
	
	if not AbilityFunction or not Character then
		return
	end
	
	local ToolEquipped = Character:FindFirstChild("MageStaff")
	
	if ToolEquipped then
		AbilityFunction(plr, MousePos)
	end
	
end

function AbilityHandler.AbilityUsed(plr, Ability, MousePos)
	AbilityUsed(plr, Ability, MousePos)
end

return AbilityHandler
