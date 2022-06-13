sceneName = "default_level"

local sceneNameIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_STRING
sceneNameIV = InspectorVariable.new("sceneName", sceneNameIVT, sceneName)
NewVariable(sceneNameIV)

neralaMust = true
local neralaMustIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_BOOL
neralaMustIV = InspectorVariable.new("neralaMust", neralaMustIVT, neralaMust)
NewVariable(neralaMustIV)

omozraMust = true
local omozraMustIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_BOOL
omozraMustIV = InspectorVariable.new("omozraMust", omozraMustIVT, omozraMust)
NewVariable(omozraMustIV)

------------------ Collisions --------------------
function OnTriggerEnter(go)
    local currentLevel = GetVariable("Gamestate.lua", "levelNumber", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)
    if currentLevel == 1 then
        local neralaAvailable = GetVariable("GameState.lua", "neralaAvailable", INSPECTOR_VARIABLE_TYPE.INSPECTOR_BOOL)
        local omozraAvailable = GetVariable("GameState.lua", "omozraAvailable", INSPECTOR_VARIABLE_TYPE.INSPECTOR_BOOL)
        if neralaAvailable == true and omozraAvailable == true then
            if (go.tag == Tag.PLAYER) then
                gameObject:ChangeScene(true, sceneName);
            end
        end
    end
end
--------------------------------------------------

print("WinTrigger.lua compiled succesfully")
