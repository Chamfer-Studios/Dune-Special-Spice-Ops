
triggered = false

function Start()
    -- gameobjUID = gameObject:GetUID()
end

function OnTriggerEnter(go)
    -- Only nerala
    if(triggered == false) then
       triggered = true
       DispatchGlobalEvent("Eagle_View_Camera", {}) 
    end

    if(go.tag ~= Tag.PLAYER) then
        Log("Not Player")
    end

end



