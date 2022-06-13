function OnTriggerEnter()
    if GetVariable("QuestsManagerLvl2.lua", "terminalCount", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT) >= 3 then
        gameObject:ChangeScene(true, "CursceneFinal")
    end
end

print("FinalTrigger.lua compiled succesfully")
