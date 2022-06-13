
triggered = false

function Start()
    -- gameobjUID = gameObject:GetUID()
end

function Update(dt)
    if (GetInput(10) == KEY_STATE.KEY_DOWN) then -- R
        DispatchGlobalEvent("Eagle_View_Camera", {}) 
    end
end


