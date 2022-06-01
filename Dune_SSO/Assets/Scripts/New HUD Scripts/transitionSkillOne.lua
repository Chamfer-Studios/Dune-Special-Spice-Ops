
function Update(dt)
    if(gameObject == nil)  then
        Log("GameObjectWasNil")
    end
	if (gameObject:GetButton():IsHovered() == true) then
        Log("Hovering")
    end
end