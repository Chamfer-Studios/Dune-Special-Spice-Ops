-- player = Find("Character")
lives = 0
path =  "Assets/HUD/slider_segments_hp3_v1.0.png"

local livesIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
livesIV = InspectorVariable.new("lives", livesIVT, lives)
NewVariable(livesIV)

local pathIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_STRING
pathIV = InspectorVariable.new("path", pathIVT, path)
NewVariable(pathIV)

-- Called each loop iteration
function Update(dt)
	currentLives = GetVariable("Player.lua", "lives", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)
	if (currentLives == lives) then
		gameObject:GetImage():SetTexture(path) -- It would be nice if it worked with events instead of every frame
	end
end

print("UI_Lives.lua compiled succesfully")