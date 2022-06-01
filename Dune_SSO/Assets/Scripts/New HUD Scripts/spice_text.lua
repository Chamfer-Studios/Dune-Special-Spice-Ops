function Start()
    spiceAmount = GetVariable("GameState.lua", "spiceAmount", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)

    gameObject:GetText():SetTextValue(spiceAmount)
end

function Update(dt)

    spiceAmount = GetVariable("GameState.lua", "spiceAmount", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)

    gameObject:GetText():SetTextValue(spiceAmount)
end
