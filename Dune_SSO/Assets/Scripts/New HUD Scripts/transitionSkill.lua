function Update(dt)
    if gameObject:GetButton():IsHovered() == true then
        DispatchGlobalEvent("FirstHovered")
    end
end
