name = "CutsceneIntro"
isHolding = false
-- Called each loop iteration
function Update(dt)
	if (GetInput(44) == KEY_STATE.KEY_DOWN) then
        isHolding = true
	end
    if (GetInput(44) == KEY_STATE.KEY_UP) then
        isHolding = false
	end
    if (GetInput(43) == KEY_STATE.KEY_DOWN and isHolding == true) then
        gameObject:ChangeScene(true, name)
    end
end

print("UI_ChangeSceneDebugKey.lua compiled succesfully")