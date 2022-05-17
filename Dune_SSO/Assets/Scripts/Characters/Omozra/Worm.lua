State = {
    IDLE = 1,
    EAT = 2,
    AWAIT = 3,
    SPIT = 4,
    DEVOUR = 5
}

------------------- Variables --------------------

target = nil
currentState = State.IDLE

-------------------- Methods ---------------------

function Start()

    omozra = GetVariable("Omozra.lua", "gameObject", INSPECTOR_VARIABLE_TYPE.INSPECTOR_GAMEOBJECT)
    componentTransform:SetPosition(float3.new(omozra:GetTransform():GetPosition().x, -20,
        omozra:GetTransform():GetPosition().z))

    if (particles ~= null) then
        particles = gameObject:GetComponentParticle()
        particles:StopParticleSpawn()
    end

    componentAnimator = gameObject:GetComponentAnimator()
    if (componentAnimator ~= nil) then
        componentAnimator:SetSelectedClip("Idle") -- Doesn't exists but I need it to be different
    end
end

-- Called each loop iteration
function Update(dt)

    -- Animation timer
    if (componentAnimator ~= nil) then
        if (componentAnimator:IsCurrentClipLooping() == false) then
            if (componentAnimator:IsCurrentClipPlaying() == false) then
                if (currentState == State.DEVOUR) then
                    DoDevour()
                elseif (currentState == State.EAT) then
                    currentState = State.AWAIT
                elseif (currentState == State.SPIT) then
                    DeleteGameObject()
                end
            end
        end
    end
end

-- Devour
function CastDevour(castedOn)

    target = castedOn

    local targetPos = target:GetTransform():GetPosition()
    componentTransform:SetPosition(float3.new(targetPos.x, -20, targetPos.z))

    if (componentAnimator ~= nil) then
        componentAnimator:SetSelectedClip("Devour")
    end

    currentState = State.DEVOUR

    DispatchGlobalEvent("Sadiq_Devour", {target, 0}) -- fields[1] -> target; fields[2] -> step of devour ability (0 -> warning; 1 -> devour)
end

function DoDevour()
    Log("Event\n")
    DispatchGlobalEvent("Sadiq_Devour", {target, 1}) -- fields[1] -> target; fields[2] -> step of devour ability (0 -> warning; 1 -> devour)

    if (componentAnimator ~= nil) then
        componentAnimator:SetSelectedClip("DevourToIdle")
    end

    -- TODO: Add particles, audio, etc.

    currentState = State.IDLE
end

-------------------- Events ----------------------
function EventHandler(key, fields)

    if (key == "Worm_Update_Target") then -- fields[1] -> state, fields[2] -> target;
        CastDevour(fields[1])
    elseif (key == "Omozra_Ultimate_Recast") then -- fields[1] -> go;

        componentTransform:SetPosition(fields[1])
        currentState = State.SPIT
        componentAnimator:SetSelectedClip("Spit")
    end
end
--------------------------------------------------

print("Worm.lua compiled succesfully")
