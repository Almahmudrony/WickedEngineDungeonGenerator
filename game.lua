-- Lua Wicked Engine Game script

local print = backlog_post
backlog_fontsize(-5)
backlog_fontrowspacing(-2)
local sleep = waitSeconds

dofile("player.lua")
dofile("tpCamera.lua")

local envMapFileName = "instanceBenchmark2/env.dds"
local colorGradingFileName = "instanceBenchmark2/colorGrading.dds"

HairParticleSettings(20,50,200)
SetDirectionalLightShadowProps(1024,2)
SetPointLightShadowProps(3,512)
SetSpotLightShadowProps(3,512)

local gamecomponent = DeferredRenderableComponent()
gamecomponent.Initialize()
gamecomponent.SetReflectionsEnabled(true)
gamecomponent.SetSSREnabled(false)
gamecomponent.SetShadowsEnabled(true)
gamecomponent.SetSSSEnabled(false)
gamecomponent.SetMotionBlurEnabled(true)
gamecomponent.SetLightShaftsEnabled(false)
gamecomponent.SetLensFlareEnabled(false)
gamecomponent.SetDepthOfFieldEnabled(false)
gamecomponent.SetDepthOfFieldFocus(10)
gamecomponent.SetDepthOfFieldStrength(1.5)
gamecomponent.SetSSAOEnabled(false)
gamecomponent.SetFXAAEnabled(false)
gamecomponent.GetContent().Add(envMapFileName)
gamecomponent.GetContent().Add(colorGradingFileName)
main.SetActiveComponent(gamecomponent)
main.SetInfoDisplay(true)
main.SetWatermarkDisplay(true)
main.SetFPSDisplay(true)
main.SetCPUDisplay(true)

-- Player Controller (player.lua)
local player = playerController

-- Third Person camera (tpCamera.lua)
local camera = tpCamera

local function ResetGame()
	ClearWorld()
	player:Load("girl/","girl","player","omino_player","Armature_player","testa")
	player:Reset()
	--player:Reposition(Vector(0,4,-20))
	camera:Reset()
	camera:Follow(player)
	
	-- LoadModel("instanceBenchmark2/","instanceBenchmark2","level")
	dofile("dungeon.lua")
	dungeon.Generate(10,80,40)  -- defined in dungeon.lua!
	--LoadWorldInfo("instanceBenchmark2/","instanceBenchmark2.wiw")
	FinishLoading()
	
	SetEnvironmentMap(gamecomponent.GetContent().Get(envMapFileName))
	SetColorGrading(gamecomponent.GetContent().Get(colorGradingFileName))
end

local GameLogic = function()
	
	ResetGame()
	
	while true do
		
		while( backlog_isactive() ) do
			sleep(1)
		end
		
		if(input.Press(VK_RETURN)) then
			ResetGame()
		end
		if(input.Press(string.byte('R'))) then
			camera:Reset()
		end
		if(input.Press(string.byte('U'))) then
			camera:UnFollow()
		end
		if(input.Press(string.byte('F'))) then
			camera:Follow(player)
		end
		
		player:Input()
		
		camera:Update()
		
		player:Update()
		
		
		
		update()
	end
end

-- Update
runProcess(GameLogic)



-- Draw Helpers
local DrawAxis = function(point,f)
	DrawLine(point,point:Add(Vector(f,0,0)),Vector(1,0,0,0))
	DrawLine(point,point:Add(Vector(0,f,0)),Vector(0,1,0,0))
	DrawLine(point,point:Add(Vector(0,0,f)),Vector(0,0,1,0))
end
local DrawAxisTransformed = function(point,f,transform)
	DrawLine(point,point:Add( Vector(f,0,0).Transform(transform) ),Vector(1,0,0,0))
	DrawLine(point,point:Add( Vector(0,f,0).Transform(transform) ),Vector(0,1,0,0))
	DrawLine(point,point:Add( Vector(0,0,f).Transform(transform) ),Vector(0,0,1,0))
end

-- Draw
runProcess(function()
	while true do
	
		while( backlog_isactive() ) do
			sleep(1)
		end
		
		--velocity
		DrawLine(player.skeleton.GetPosition():Add(Vector(0,4)),player.skeleton.GetPosition():Add(Vector(0,4)):Add(player.velocity))
		--face
		DrawLine(player.skeleton.GetPosition():Add(Vector(0,4)),player.skeleton.GetPosition():Add(Vector(0,4)):Add(player.face:Normalize()),Vector(1,0,0,1))
		--intersection
		DrawAxis(player.p,0.5)
		
		render()
	end
end)