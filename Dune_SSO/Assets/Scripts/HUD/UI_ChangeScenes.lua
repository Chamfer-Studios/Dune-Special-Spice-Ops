name = "Level_1"

local nameIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_STRING
nameIV = InspectorVariable.new("name", nameIVT, name)
NewVariable(nameIV)

-- Called each loop iteration
function Update(dt)
	if (gameObject.active == true) then
		if (gameObject:GetButton():IsPressed() == true) then
			gameObject:ChangeScene(true, name)
		end
	end
end

function UpdateUI(dt)
    if (gameObject.active == true) then
        if (gameObject:GetButton():IsPressed() == true) then
            gameObject:ChangeScene(true, name)
            if (GetRuntimeState() == RuntimeState.PAUSED) then
                ToggleRuntime()
            end
        end
    end
end

print("UI_ChangeScenes.lua compiled succesfully")