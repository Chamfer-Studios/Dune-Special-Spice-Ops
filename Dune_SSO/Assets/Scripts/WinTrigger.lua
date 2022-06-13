sceneName = "default_level"

local sceneNameIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_STRING
sceneNameIV = InspectorVariable.new("sceneName", sceneNameIVT, sceneName)
NewVariable(sceneNameIV)

------------------ Collisions --------------------
function OnTriggerEnter(go)
    local currentLevel = GetVariable("Gamestate.lua", "levelNumber", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)
    if currentLevel == 1 then
        local neralaAvailable = GetVariable("Gamestate.lua", "neralaAvailable", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)
        local omozraAvailable = GetVariable("Gamestate.lua", "omozraAvailable", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)
        if neralaAvailable == true and omozraAvailable == true then
            if (go.tag == Tag.PLAYER) then
                gameObject:ChangeScene(true, sceneName);
            end
        end
    end
end
--------------------------------------------------

print("WinTrigger.lua compiled succesfully")
