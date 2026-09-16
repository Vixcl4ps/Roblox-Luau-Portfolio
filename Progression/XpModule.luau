local PlayerData = require(game.ServerScriptService.ModuleScripts.PlayerGameData)


local XpModule = {}


local function AddXP(plr, amount)
	local Playerinfo = plr:WaitForChild("Playerinfo")
	local Xp = Playerinfo:WaitForChild("Xp")
	local leaderstats = plr:WaitForChild("leaderstats")
	local Level = leaderstats:WaitForChild("Level")
	Xp.Value += amount

	while Xp.Value >= Level.Value * 100 do
		Xp.Value -= Level.Value * 100
		Level.Value += 1
		print("Level up")
	end

end





function XpModule.GiveXp(plr, amount)
	AddXP(plr, amount)
end



return XpModule
