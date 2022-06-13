name = "Level_1"

local nameIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_STRING
nameIV = InspectorVariable.new("name", nameIVT, name)
NewVariable(nameIV)

function Update()
    if (gameObject.active == true) then
        if (gameObject:GetButton():IsPressed() == true) then
            LoadGameState()
            SetGameJsonBool("reset", true)
            SaveGameState()
            gameObject:ChangeScene(true, name)
        end
    end
end

print("GameState.lua compiled successfully!")