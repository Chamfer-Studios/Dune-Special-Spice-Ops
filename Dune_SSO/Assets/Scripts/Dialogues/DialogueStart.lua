id = -1
local idIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
idIV = InspectorVariable.new("id", idIVT, id)
NewVariable(idIV)

triggered = false

function Start()
    if (GetVariable("GameState.lua", "level_progression", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT) ~= 0) then
        DeleteGameObject()
    elseif (not triggered and GetVariable("GameState.lua", "triggerDialogues", INSPECTOR_VARIABLE_TYPE.INSPECTOR_BOOL) ==
        true) then
        DispatchGlobalEvent("DialogueTriggered", {id, nil, gameObject:GetUID()})
    end
end