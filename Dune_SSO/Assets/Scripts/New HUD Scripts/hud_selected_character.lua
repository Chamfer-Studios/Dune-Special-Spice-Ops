function Update(dt) 
    currentCharacterId = GetVariable("GameState.lua","characterSelected",INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)
    neralaImage = Find("Nerala Image")
    zhibImage = Find("Nerala Image")
    omozraImage = Find("Nerala Image")
    if currentCharacterId == 1 then --zhib
    elseif currentCharacterId == 2 then --nerala
    elseif currentCharacterId == 3 then --omozra
    end
end
