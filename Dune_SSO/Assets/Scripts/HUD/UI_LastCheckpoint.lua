name = "SceneLoadingLevel1"

local nameIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_STRING
nameIV = InspectorVariable.new("name", nameIVT, name)
NewVariable(nameIV)

-- Called each loop iteration
function UpdateUI(dt)
    if (gameObject.active == true) then
        if (gameObject:GetButton():IsPressed() == true) then
            DispatchGlobalEvent("Last_Checkpoint", {true})
            if (GetRuntimeState() == RuntimeState.PAUSED) then
                ToggleRuntime()
            end
        end
    end
end

print("UI_LastCheckpoint.lua compiled succesfully")