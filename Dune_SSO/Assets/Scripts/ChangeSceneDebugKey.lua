isHolding = false
name = "noScene"

local nameIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_STRING
nameIV = InspectorVariable.new("name", nameIVT, name)
NewVariable(nameIV)

-- Called each loop iteration
function Update(dt)
	if (GetInput(12) == KEY_STATE.KEY_DOWN) then
        isHolding = true
    else if (GetInput(12) == KEY_STATE.KEY_UP) then
        isHolding = false
	end
    if (GetInput(21) == KEY_STATE.KEY_DOWN) then
        gameObject:ChangeScene(true, "SceneTutorial")
        isHolding = false
    elseif (GetInput(22) == KEY_STATE.KEY_DOWN) then
        gameObject:ChangeScene(true, "ScenNewMainMenu")
        isHolding = false
    elseif (GetInput(23) == KEY_STATE.KEY_DOWN) then
        gameObject:ChangeScene(true, "SceneTransitionScreen")
        isHolding = false
    elseif (GetInput(24) == KEY_STATE.KEY_DOWN) then
        gameObject:ChangeScene(true, "SceneGameOver")
        isHolding = false
    elseif (GetInput(45) == KEY_STATE.KEY_DOWN) then
        gameObject:ChangeScene(true, "CutsceneIntro")
        isHolding = false
    elseif (GetInput(46) == KEY_STATE.KEY_DOWN) then
        gameObject:ChangeScene(true, "CutsceneLevel1Level2")
        isHolding = false
    elseif (GetInput(47) == KEY_STATE.KEY_DOWN) then
        gameObject:ChangeScene(true, "CutsceneNeralasDeath")
        isHolding = false
    elseif (GetInput(48) == KEY_STATE.KEY_DOWN) then
        gameObject:ChangeScene(true, "CutsceneRabbansDeath")
        isHolding = false
    elseif (GetInput(49) == KEY_STATE.KEY_DOWN) then
        gameObject:ChangeScene(true, "CutsceneFinal")
        isHolding = false
    end
end

print("UI_ChangeSceneDebugKey.lua compiled succesfully")