

function SetStateToDEAD()
    local oldState = state
    state = STATE.DEAD
    DispatchEvent("Change_State", {oldState, state}) -- fields[1] -> fromState; fields[2] -> toState;
end

function SetStateToWORM()
    local oldState = state
    state = STATE.WORM
    DispatchEvent("Change_State", {oldState, state}) -- fields[1] -> fromState; fields[2] -> toState;
    if (componentAnimator ~= nil) then
        componentAnimator:SetSelectedClip("Idle")
    end
end

wasWalking = false

function EventHandler(key, fields)

    do return end

    if key == "Auditory_Trigger" then -- fields[1] -> position; fields[2] -> range; fields[3] -> type ("single", "repeated"); fields[4] -> source ("GameObject");
        ProcessAuditoryTrigger(fields[1], fields[2], fields[3], fields[4])
    elseif key == "State_Suspicious" then
        SetStateToSUS(fields[1])
    elseif key == "State_Aggressive" then
        SetStateToAGGRO(fields[1])
    elseif key == "Walking_Direction" then
        LookAtDirection(fields[1])
    elseif key == "Player_Position" then
        ProcessVisualTrigger(fields[1], fields[2])
    elseif key == "IsWalking" then
        if fields[1] == true and wasWalking == false then
            wasWalking = true
        elseif fields[1] == false and wasWalking == true and state ~= STATE.AGGRO then
            wasWalking = false
        end
    elseif key == "Death_Mark" then
        if (fields[1] == gameObject) then
            deathMarkTime = fields[2] * 0.3
            deathMarkTimer = 0.0
        end
    elseif key == "Die" then
        Die(fields[1])
    elseif key == "Sadiq_Update_Target" then -- fields[1] -> target; targeted for (1 -> warning; 2 -> eat; 3 -> spit)
        if (fields[1] == gameObject and state ~= STATE.DEAD) then
            if (fields[2] == 1) then
                StopMovement()
            end
        end
    elseif (key == "Dialogue_Opened") then
        isDialogueOpen = true
        oldSpeed = speed
        speed = 0
        oldChaseSpeed = chaseSpeed
        chaseSpeed = 0
    elseif (key == "Dialogue_Closed") then
        isDialogueOpen = false
        speed = oldSpeed
        chaseSpeed = oldChaseSpeed
    end
end

function StopMovement()
    if (componentRigidbody ~= nil) then
        componentRigidbody:SetLinearVelocity(float3.new(0, 0, 0))
    end
    SetStateToWORM()
end

function ConfigAwarenessBars()
    awareness_green = Find(awareness_green_name)
    awareness_yellow = Find(awareness_yellow_name)
    awareness_red = Find(awareness_red_name)
end

function UpdateAwarenessBars()
    position = componentTransform:GetPosition()
    awareness_green:GetTransform():SetPosition(float3.new(position.x + awarenessOffset.x,
        position.y + awarenessOffset.y, position.z + awarenessOffset.z))
    awareness_yellow:GetTransform():SetPosition(float3.new(position.x + awarenessOffset.x,
        position.y + awarenessOffset.y, position.z + awarenessOffset.z))
    awareness_red:GetTransform():SetPosition(float3.new(position.x + awarenessOffset.x, position.y + awarenessOffset.y,
        position.z + awarenessOffset.z))

    if awareness < 1 then
        awareness_green:GetTransform():SetScale(
            float3.new(awarenessSize.x, awarenessSize.y * awareness, awarenessSize.z))
        awareness_yellow:GetTransform():SetScale(float3.new(0, 0, 0))
        awareness_red:GetTransform():SetScale(float3.new(0, 0, 0))
    end

    if awareness >= 1 and awareness < 2 then
        awareness_green:GetTransform():SetScale(float3.new(0, 0, 0))
        awareness_yellow:GetTransform():SetScale(float3.new(awarenessSize.x, awarenessSize.y * (awareness - 1),
            awarenessSize.z))
        awareness_red:GetTransform():SetScale(float3.new(0, 0, 0))
    end

    if awareness == 2 then
        awareness_green:GetTransform():SetScale(float3.new(0, 0, 0))
        awareness_yellow:GetTransform():SetScale(float3.new(0, 0, 0))
        awareness_red:GetTransform():SetScale(float3.new(awarenessSize.x, awarenessSize.y, awarenessSize.z))
    end
end

function Start()
    
    do return end

    CheckAndRecalculatePath(true)
    InstantiateNamedPrefab("awareness_green", awareness_green_name)
    InstantiateNamedPrefab("awareness_yellow", awareness_yellow_name)
    InstantiateNamedPrefab("awareness_red", awareness_red_name)

    componentRigidbody = gameObject:GetRigidBody()
    componentAnimator = gameObject:GetParent():GetComponentAnimator()

    if (componentAnimator ~= nil) then
        if (static == true) then
            componentAnimator:SetSelectedClip("Idle")
        else
            componentAnimator:SetSelectedClip("Walk")
        end
    end
end

oldSourcePos = nil

coneLight = gameObject:GetLight()

function Update(dt)

    do return end

    if (state == STATE.DEAD) then
        return
    end

    isAnyPlayerInConeThisFrame = false

    if coneLight == nil then
        coneLight = gameObject:GetLight()
    end

    if coneLight ~= nil then
        coneLight:SetDirection(float3.new(-componentTransform:GetFront().x, -componentTransform:GetFront().y,
            -componentTransform:GetFront().z))
        coneLight:SetRange(visionConeRadius)
        coneLight:SetAngle(visionConeAngle / 2)
    end

    -- Death Mark (Weirding way)
    if (deathMarkTimer ~= nil) then
        deathMarkTimer = deathMarkTimer + dt
        if (deathMarkTimer >= deathMarkTime) then
            -- Audio here
            DispatchEvent("DeathMark_Death", {})
            deathMarkTimer = nil
            return
        end
    end

    if awareness_green == nil then
        ConfigAwarenessBars()
    else
        UpdateAwarenessBars()
    end

    if awareness < targetAwareness and isSeeingPlayer == true then
        awareness = awareness + awarenessVisualSpeed * dt
    elseif awareness < targetAwareness and isSeeingPlayer == false then
        awareness = awareness + awarenessSpeed * dt
    elseif awareness > targetAwareness then
        awareness = awareness - awarenessSpeed * dt
    end

    if awareness < 1.1 and awareness > 0.9 and state ~= STATE.SUS then
        if seeingPosition ~= nil then
            DispatchEvent("State_Suspicious", {seeingPosition})
        else
            DispatchEvent("State_Suspicious", {awarenessPosition})
        end
    end

    if state == STATE.SUS then
        if seeingPosition ~= nil then
            DispatchEvent(pathfinderUpdateKey, {{seeingPosition}, false, componentTransform:GetPosition()})
        else
            DispatchEvent(pathfinderUpdateKey, {{awarenessPosition}, false, componentTransform:GetPosition()})
        end
    end

    if awareness < 0 then
        SetStateToUNAWARE()
    elseif awareness > 2 then
        if seeingSource ~= nil then
            DispatchEvent("State_Aggressive", {seeingSource})
        else
            DispatchEvent("State_Aggressive", {awarenessSource})
        end
    end

    if state == STATE.UNAWARE then
        CheckAndRecalculatePath(false)
    end

    if hadRepeatedAuditoryTriggerLastFrame == true then
        auditoryTriggerIsRepeating = true
        hadRepeatedAuditoryTriggerLastFrame = false
    else
        if auditoryTriggerIsRepeating == true then
            auditoryTriggerIsRepeating = false
            SetTargetStateToUNAWARE()
        end
    end

    if state == STATE.AGGRO then
        s = nil
        if seeingSource ~= nil then
            s = seeingSource
        elseif awarenessSource ~= nil then
            s = awarenessSource
        end

        -- if s ~= nil and (oldSourcePos == nil or Float3Distance(oldSourcePos, s:GetTransform():GetPosition()) > 10) then
        if s ~= nil then
            if static == true then
                DispatchEvent(pathfinderUpdateKey, {{}, false, componentTransform:GetPosition()})
                LookAtDirection(Float3Difference(componentTransform:GetPosition(), s:GetTransform():GetPosition()))
            else
                DispatchEvent(pathfinderUpdateKey,
                    {{s:GetTransform():GetPosition()}, false, componentTransform:GetPosition()})
            end
            DispatchEvent("Target_Update", {s})
            -- oldSourcePos = s:GetTransform():GetPosition()
        end

    end

    _loop = loop
    if state == STATE.SUS or state == STATE.AGGRO then
        _loop = false
    end
    if (state ~= STATE.WORM) then
        if (state ~= STATE.AGGRO) then
            DispatchEvent(pathfinderFollowKey, {speed, dt, _loop, false})
        else
            DispatchEvent(pathfinderFollowKey, {chaseSpeed, dt, _loop, false})
        end
    end
end

------------------- Functions --------------------

function Die(leaveBody)
    if (leaveBody == nil) then
        leaveBody = true
    end
    SetStateToDEAD()
    if (awareness_green ~= nil) then
        DeleteGameObjectByUID(awareness_green:GetUID())
        awareness_green = nil
    end
    if (awareness_red ~= nil) then
        DeleteGameObjectByUID(awareness_red:GetUID())
        awareness_red = nil
    end
    if (awareness_yellow ~= nil) then
        DeleteGameObjectByUID(awareness_yellow:GetUID())
        awareness_yellow = nil
    end
    if (leaveBody == false) then
        DeleteGameObject()
    end
end

--------------------------------------------------

print("EnemyController.lua compiled successfully!")
