function Update(dt)
    currentCharacterId = GetVariable("GameState.lua", "characterSelected", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)
    if gameObject:GetButton():IsPressed() == true then
        DispatchGlobalEvent("Cast_Secondary", {currentCharacterId})
    end
end
