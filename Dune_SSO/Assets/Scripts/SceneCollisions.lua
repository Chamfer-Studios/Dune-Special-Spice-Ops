filter = "terrain"

function Start()
    children = gameObject:GetChildren()
    for i = 1, #children do
        if (children[i]:GetBoxCollider() == nil) then
            children[i]:AddComponentByType(ComponentType.BOX_COLLIDER)
        end
    end
end

Log("SceneCollisions.lua\n")
