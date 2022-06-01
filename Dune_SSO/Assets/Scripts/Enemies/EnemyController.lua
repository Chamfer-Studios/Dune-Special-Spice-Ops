static = false
local staticIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_BOOL
staticIV = InspectorVariable.new("static", staticIVT, static)
NewVariable(staticIV)

speed = 20
local speedIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
speedIV = InspectorVariable.new("speed", speedIVT, speed)
NewVariable(speedIV)

chaseSpeed = 30
local chaseSpeedIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
chaseSpeedIV = InspectorVariable.new("chaseSpeed", chaseSpeedIVT, chaseSpeed)
NewVariable(chaseSpeedIV)

attackRange = 20
local attackRangeIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
attackRangeIV = InspectorVariable.new("attackRange", attackRangeIVT, attackRange)
NewVariable(attackRangeIV)

attackSpeed = 1.5

visionConeAngle = 90
local visionConeAngleIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
visionConeAngleIV = InspectorVariable.new("visionConeAngle", visionConeAngleIVT, visionConeAngle)
NewVariable(visionConeAngleIV)

visionConeRadius = 50
local visionConeRadiusIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
visionConeRadiusIV = InspectorVariable.new("visionConeRadius", visionConeRadiusIVT, visionConeRadius)
NewVariable(visionConeRadiusIV)

hearingRange = 30
local hearingRangeIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
hearingRangeIV = InspectorVariable.new("hearingRange", hearingRangeIVT, hearingRange)
NewVariable(hearingRangeIV)

awarenessOffset = float3.new(0, 50, 0)
local awarenessOffsetIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_FLOAT3
awarenessOffsetIV = InspectorVariable.new("awarenessOffset", awarenessOffsetIVT, awarenessOffset)
NewVariable(awarenessOffsetIV)

awarenessSize = float3.new(0.15, 0.3, 0.15)
local awarenessSizeIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_FLOAT3
awarenessSizeIV = InspectorVariable.new("awarenessSize", awarenessSizeIVT, awarenessSize)
NewVariable(awarenessSizeIV)

awarenessSoundSpeed = 0.3
awarenessVisualSpeed = 1.0
awarenessDecaySpeed = 0.5

pingpong = false
local pingpongIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_BOOL
pingpongIV = InspectorVariable.new("pingpong", pingpongIVT, pingpong)
NewVariable(pingpongIV)

loop = false
local loopIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_BOOL
loopIV = InspectorVariable.new("loop", loopIVT, loop)
NewVariable(loopIV)

patrolOldWaypoints = {}
patrolWaypoints = {}
local patrolWaypointsIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_FLOAT3_ARRAY
patrolWaypointsIV = InspectorVariable.new("patrolWaypoints", patrolWaypointsIVT, patrolWaypoints)
NewVariable(patrolWaypointsIV)

componentAnimator = nil

awareness_green = nil
awareness_yellow = nil
awareness_red = nil

awareness_green_name = "awareness_green_" .. gameObject:GetUID()
awareness_yellow_name = "awareness_yellow_" .. gameObject:GetUID()
awareness_red_name = "awareness_red_" .. gameObject:GetUID()

pathfinderUpdateKey = "Pathfinder_UpdatePath"
pathfinderFollowKey = "Pathfinder_FollowPath"

EnemyDeath = {
    PLAYER_ATTACK = 1,
    KNIFE = 2,
    WEIRDING_WAY = 3,
    MOSQUITO = 4,
    WORM_KILL = 5
}
STATE = {
    UNAWARE = 1,
    SUS = 2,
    AGGRO = 3,
    DEAD = 4,
    VICTORY = 5,
    CORPSE = 6
}

state = STATE.UNAWARE

isWalking = false

awareness = 0
targetAwareness = 0

nRepeating = 1
nSingle = 1
nVisual = 1

-- {
--        "position": float3
--        "source": gameObject
---       "valid": bool
-- }
repeatingAuditoryTriggers = {}
singleAuditoryTriggers = {}
visualTriggers = {}

target = nil

targetDirection = nil

function Float3Length(v)
    return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
end

function Float3Normalized(v)
    len = Float3Length(v)
    return {
        x = v.x / len,
        y = v.y / len,
        z = v.z / len
    }
end

function Float3Difference(a, b)
    return float3.new(b.x - a.x, b.y - a.y, b.z - a.z)
end

function Float3Sum(a, b)
    return float3.new(b.x + a.x, b.y + a.y, b.z + a.z)
end

function Float3Distance(a, b)
    diff = Float3Difference(a, b)
    return Float3Length(diff)
end

function Float3Dot(a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z
end

function Float3Angle(a, b)
    lenA = Float3Length(a)
    lenB = Float3Length(b)

    return math.acos(Float3Dot(a, b) / (lenA * lenB))
end

function CheckAndRecalculatePath(force)
    -- We check whether the waypoint list has been updated, if it has, we recalculate the path.

    eq = true

    if #patrolWaypoints ~= #patrolOldWaypoints then
        eq = false
    end

    if eq == false then
        for i = 1, #patrolWaypoints do
            for j = 1, 3 do
                patrolOldWaypoints[i] = {}
                patrolOldWaypoints[i][j] = patrolWaypoints[i][j]
            end
        end
    else
        for i = 1, #patrolWaypoints do
            if patrolWaypoints[i].x ~= patrolOldWaypoints[i].x then
                eq = false
                patrolOldWaypoints[i].x = patrolWaypoints[i].x
            end
            if patrolWaypoints[i].y ~= patrolOldWaypoints[i].y then
                eq = false
                patrolOldWaypoints[i].y = patrolWaypoints[i].y
            end
            if patrolWaypoints[i].z ~= patrolOldWaypoints[i].z then
                eq = false
                patrolOldWaypoints[i].z = patrolWaypoints[i].z
            end
        end
    end

    if eq == false or force then
        DispatchEvent(pathfinderUpdateKey, {patrolWaypoints, pingpong, componentTransform:GetPosition()})
        currentPathIndex = 1
    end
end

function SetTargetDirection(direction)
    targetDirection = direction
end

rotationSpeed = 4

function RotateToTargetDirection(dt)
    if targetDirection ~= nil then
        deltaDirection = Float3Difference(componentTransform:GetFront(), targetDirection)
        if rotationSpeed * dt > Float3Length(deltaDirection) then
            componentTransform:LookAt(targetDirection, float3.new(0, 1, 0))
            do
                return
            end
        end
        deltaDirection = Float3Normalized(deltaDirection)
        newDirection = float3.new(deltaDirection.x * dt * rotationSpeed, deltaDirection.y * dt * rotationSpeed,
            deltaDirection.z * dt * rotationSpeed)
        newDirection = Float3Sum(componentTransform:GetFront(), newDirection)
        componentTransform:LookAt(newDirection, float3.new(0, 1, 0))
    end
end

function CheckIfPointInCone(position)
    if Float3Distance(position, componentTransform:GetPosition()) > visionConeRadius then
        do
            return (false)
        end
    end

    diff = Float3Difference(componentTransform:GetPosition(), position)

    diff.y = 0

    angle = Float3Angle(diff, componentTransform:GetFront())

    angle = math.abs(math.deg(angle))

    if angle < visionConeAngle / 2 then
        do
            return (true)
        end
    end

    do
        return (false)
    end
end

function ProcessVisualTrigger(position, source)
    if not CheckIfPointInCone(position) then
        do
            return
        end
    end

    visualTriggers[nVisual] = {}
    visualTriggers[nVisual]["position"] = position
    visualTriggers[nVisual]["source"] = source
    visualTriggers[nVisual]["valid"] = true

    lambda = function(uid)
        Log("Hello\n")
        -- visualTriggers[nVisual]["valid"] = false
    end

    src = float3.new(componentTransform:GetPosition().x, componentTransform:GetPosition().y + 10,
        componentTransform:GetPosition().z)
    dst = float3.new(position.x, position.y + 10, position.z)

    RayCastLambda(src, dst, "terrain", gameObject, RNG(), lambda)
    DrawLine(src, dst)

    nVisual = nVisual + 1
end

function CheckAuditoryTriggerInRange(position, range)
    mypos = componentTransform:GetPosition()

    distance = Float3Distance(mypos, position)

    if distance < hearingRange + range then
        do
            return (true)
        end
    end

    do
        return (false)
    end
end

function ProcessSingleAuditoryTrigger(position, source)
    singleAuditoryTriggers[nSingle] = {}
    singleAuditoryTriggers[nSingle]["position"] = position
    singleAuditoryTriggers[nSingle]["source"] = source

    nSingle = nSingle + 1
end

function ProcessRepeatedAuditoryTrigger(position, source)
    repeatingAuditoryTriggers[nRepeating] = {}
    repeatingAuditoryTriggers[nRepeating]["position"] = position
    repeatingAuditoryTriggers[nRepeating]["source"] = source

    nRepeating = nRepeating + 1
end

function ProcessAuditoryTrigger(position, range, type, source)
    if not CheckAuditoryTriggerInRange(position, range) then
        do
            return
        end
    end

    if type == "single" then
        ProcessSingleAuditoryTrigger(position, source)
    elseif type == "repeated" then
        ProcessRepeatedAuditoryTrigger(position, source)
    end
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

    if math.abs(awareness - 2) < 0.05 then
        awareness_green:GetTransform():SetScale(float3.new(0, 0, 0))
        awareness_yellow:GetTransform():SetScale(float3.new(0, 0, 0))
        awareness_red:GetTransform():SetScale(float3.new(awarenessSize.x, awarenessSize.y, awarenessSize.z))
    end
end

function UpdateSecondaryObjects()
    if coneLight == nil then
        coneLight = gameObject:GetLight()
    end

    if coneLight ~= nil then
        coneLight:SetDirection(float3.new(-componentTransform:GetFront().x, -componentTransform:GetFront().y,
            -componentTransform:GetFront().z))
        coneLight:SetRange(visionConeRadius)
        coneLight:SetAngle(visionConeAngle / 2)
    end

    if awareness_green == nil then
        ConfigAwarenessBars()
    else
        UpdateAwarenessBars()
    end
end

function Start()
    CheckAndRecalculatePath(true)
    InstantiateNamedPrefab("awareness_green", awareness_green_name)
    InstantiateNamedPrefab("awareness_yellow", awareness_yellow_name)
    InstantiateNamedPrefab("awareness_red", awareness_red_name)

    componentRigidbody = gameObject:GetRigidBody()
    componentAnimator = gameObject:GetParent():GetComponentAnimator()
    coneLight = gameObject:GetLight()
    componentBoxCollider = gameObject:GetBoxCollider()

    debuffParticle = gameObject:GetChildren()[1]
    if (debuffParticle ~= nil) then
        debuffParticle:GetComponentParticle():StopParticleSpawn()
    end
    bloodParticle = gameObject:GetChildren()[2]
    if (bloodParticle ~= nil) then
        bloodParticle:GetComponentParticle():StopParticleSpawn()
    end
    slashParticle = gameObject:GetChildren()[3]
    if (slashParticle ~= nil) then
        slashParticle:GetComponentParticle():StopParticleSpawn()
    end

    if (componentAnimator ~= nil) then
        if (static == true) then
            componentAnimator:SetSelectedClip("Idle")
        else
            componentAnimator:SetSelectedClip("Walk")
        end
    end

    targetDirection = componentTransform:GetFront()

    auditoryDebuffMultiplier = 1
    visualDebuffMultiplier = 1
end

function UpdateTargetAwareness()

    awarenessSpeed = awarenessDecaySpeed

    closestTarget = GetClosestTarget()
    closestTargetPosition = componentTransform:GetPosition()
    if (closestTarget ~= nil) then
        closestTargetPosition = closestTarget["source"]:GetTransform():GetPosition()
    end

    distance = Float3Distance(componentTransform:GetPosition(), closestTargetPosition)

    if #visualTriggers ~= 0 then
        targetAwareness = 2
        prop = 1.2 - (distance / visionConeRadius)
        awarenessSpeed = awarenessVisualSpeed * prop * visualDebuffMultiplier
    elseif #repeatingAuditoryTriggers ~= 0 then
        targetAwareness = 2
        prop = 1.2 - (distance / hearingRange)
        awarenessSpeed = awarenessSoundSpeed * prop * auditoryDebuffMultiplier
    else
        targetAwareness = 0
    end

    do
        return (awarenessSpeed)
    end
end

function UpdateAwareness(dt, awarenessSpeed)
    if #singleAuditoryTriggers ~= 0 then
        if state == STATE.UNAWARE then
            awareness = 1
            targetAwareness = 1
        elseif state == STATE.SUS then
            awareness = 2
            targetAwareness = 2
        end
    end

    if awareness < targetAwareness then
        awareness = awareness + dt * awarenessSpeed
    elseif awareness > targetAwareness then
        awareness = awareness - dt * awarenessSpeed
    end
end

function UpdateStateFromAwareness()
    oldState = state

    if state == STATE.DEAD or state == STATE.CORPSE then
        do
            return (oldState)
        end
    end

    if math.abs(awareness) < 0.05 then
        SwitchState(state, STATE.UNAWARE)
    end

    if math.abs(awareness - 1) < 0.05 then
        SwitchState(state, STATE.SUS)
    end

    if math.abs(awareness - 2) < 0.05 then
        SwitchState(state, STATE.AGGRO)
    end

    do
        return (oldState)
    end
end

function GetClosestTrigger(stateCriteria, triggerTable)
    closestTrigger = nil

    for i = 1, #triggerTable do
        trigger = triggerTable[i]

        if stateCriteria == STATE.SUS or stateCriteria == STATE.UNAWARE then
            position = trigger["position"]

            if closestTrigger == nil then
                closestTrigger = trigger
            elseif Float3Distance(position, componentTransform:GetPosition()) <
                Float3Distance(position, closestTrigger["position"]) then
                closestTrigger = trigger
            end

        elseif stateCriteria == STATE.AGGRO then
            position = trigger["source"]:GetTransform():GetPosition()

            if closestTrigger == nil then
                closestTrigger = trigger
            elseif Float3Distance(position, componentTransform:GetPosition()) <
                Float3Distance(position, closestTrigger["source"]:GetTransform():GetPosition()) then
                closestTrigger = trigger
            end

        end
    end

    do
        return (closestTrigger)
    end
end

function GetClosestTarget()
    closestRepeatingTrigger = GetClosestTrigger(state, repeatingAuditoryTriggers)
    closestSingleTrigger = GetClosestTrigger(state, singleAuditoryTriggers)
    closestVisualTrigger = GetClosestTrigger(state, visualTriggers)

    newTarget = target

    if closestVisualTrigger ~= nil then
        newTarget = closestVisualTrigger
    elseif closestSingleTrigger ~= nil then
        newTarget = closestSingleTrigger
    elseif closestRepeatingTrigger ~= nil then
        newTarget = closestRepeatingTrigger
    end

    do
        return (newTarget)
    end
end

function UpdatePathIfNecessary(oldState, newState)
    if oldState ~= STATE.UNAWARE and newState == STATE.UNAWARE then
        CheckAndRecalculatePath(true)
    elseif newState == STATE.SUS then
        DispatchEvent(pathfinderUpdateKey, {{target["position"]}, pingpong, componentTransform:GetPosition()})
    elseif newState == STATE.AGGRO then
        DispatchEvent(pathfinderUpdateKey,
            {{target["source"]:GetTransform():GetPosition()}, pingpong, componentTransform:GetPosition()})
    end
end

function SwitchState(from, to)
    if from == to or from == STATE.CORPSE then
        do
            return
        end
    end

    state = to

    if to == STATE.UNAWARE then
        targetAwareness = 0
        awareness = 0
        ClearPerceptionMemory()
        target = nil
    end

    if to == STATE.SUS then
        targetAwareness = 1
        awareness = 1
    end

    if to == STATE.AGGRO then
        targetAwareness = 2
        awareness = 2
    end

    DispatchEvent("Change_State", {from, to})
end

function UpdateAnimation(dt, oldState, target)
    if (attackTimer ~= nil) then
        attackTimer = attackTimer + dt
        if (attackTimer >= attackSpeed) then
            attackTimer = nil
        end
    end
    -- Log(tostring(oldState) .. "" .. tostring(state) .. "\n")
    if oldState ~= state and (state == STATE.UNAWARE or state == STATE.SUS) then
        if (componentAnimator ~= nil) then
            if (isWalking == false) then
                componentAnimator:SetSelectedClip("Idle")
            else
                componentAnimator:SetSelectedClip("Walk")
            end
        end
    elseif state == STATE.AGGRO then
        if (componentAnimator ~= nil) then
            currentClip = componentAnimator:GetSelectedClip()
            if Float3Distance(componentTransform:GetPosition(), target["source"]:GetTransform():GetPosition()) <
                attackRange and currentClip ~= "Attack" and currentClip ~= "AttackToIdle" and attackTimer == nil then
                componentAnimator:SetSelectedClip("Attack")
            elseif currentClip == "Attack" then
                if componentAnimator:IsCurrentClipPlaying() == false then
                    DispatchGlobalEvent("Enemy_Attack", {target["source"], "Harkonnen"})
                    componentAnimator:SetSelectedClip("AttackToIdle")
                    attackTimer = 0
                end
            elseif currentClip == "AttackToIdle" then
                if componentAnimator:IsCurrentClipPlaying() == false then
                    componentAnimator:SetSelectedClip("Idle")
                end
            elseif currentClip ~= "Walk" then
                componentAnimator:SetSelectedClip("Walk")
            end
        end
    elseif componentAnimator:GetSelectedClip() ~= "Death" and state == STATE.DEAD then
        componentAnimator:SetSelectedClip("Death")
    elseif componentAnimator:GetSelectedClip() == "Death" and state == STATE.DEAD then
        if componentAnimator:IsCurrentClipPlaying() == false and state ~= STATE.CORPSE then
            Die(deathParameters.LeaveBody, deathParameters.EnemyName)
            componentAnimator:SetSelectedClip("Corpse")
        end
    end
end

function Update(dt)
    if state == STATE.DEAD then
        do
            UpdateAnimation(dt, oldState, target)
            return
        end
    end
    awarenessSpeed = UpdateTargetAwareness()
    UpdateAwareness(dt, awarenessSpeed)
    oldState = UpdateStateFromAwareness()
    target = GetClosestTarget()
    UpdatePathIfNecessary(oldState, state)
    UpdateSecondaryObjects()
    UpdateAnimation(dt, oldState, target)
    RotateToTargetDirection(dt)

    if state == STATE.UNAWARE then
        DispatchEvent(pathfinderFollowKey, {speed, dt, loop, false})
    elseif state == STATE.SUS then
        DispatchEvent(pathfinderFollowKey, {speed, dt, false, false})
    elseif state == STATE.AGGRO then
        DispatchEvent(pathfinderFollowKey, {chaseSpeed, dt, false, false})
    end

    ClearPerceptionMemory()

    DrawDebugger()
end

function ClearPerceptionMemory()
    nSingle = 1
    nRepeating = 1
    nVisual = 1

    singleAuditoryTriggers = {}
    repeatingAuditoryTriggers = {}
    visualTriggers = {}
end

function Die(leaveBody, enemyName)

    DispatchGlobalEvent("Enemy_Defeated", {gameObject:GetUID()})

    if (leaveBody == false) then
        do
            DeleteGameObject()
            return
        end
    end

    SwitchState(state, STATE.CORPSE)

    -- Spice Loot Droprate
    math.randomseed(os.time())
    rng = math.random(100)
    if (rng >= 50) then
        InstantiatePrefab("SpiceLoot")
        DispatchGlobalEvent("Spice_Spawn", {componentTransform:GetPosition(), enemyName})
        Log("Enemy has dropped a spice loot :) " .. rng .. "\n")
    else
        Log("The drop rate has not been good :( " .. rng .. "\n")
    end

    -- Log(apetecan())
end

deathParameters = {
    LeaveBody = true,
    EnemyName = "Harkonnen"
}

function EventHandler(key, fields)
    if key == "Auditory_Trigger" then -- fields[1] -> position; fields[2] -> range; fields[3] -> type ("single", "repeated"); fields[4] -> source ("GameObject");
        ProcessAuditoryTrigger(fields[1], fields[2], fields[3], fields[4])
    elseif key == "Walking_Direction" then
        SetTargetDirection(fields[1])
    elseif key == "Player_Position" then
        ProcessVisualTrigger(fields[1], fields[2])
    elseif key == "IsWalking" then
        isWalking = fields[1]
    elseif key == "Dart_Success" then
        auditoryDebuffMultiplier = fields[1] / 100
        visualDebuffMultiplier = fields[2] / 100
    elseif key == "Enemy_Death" then -- fields[1] = EnemyDeath table --- fields[2] = EnemyTypeString
        if fields[1] == EnemyDeath.PLAYER_ATTACK then
            SwitchState(state, STATE.DEAD)
            deathParameters.LeaveBody = true
            deathParameters.EnemyName = fields[2]
        elseif fields[1] == EnemyDeath.KNIFE then
            SwitchState(state, STATE.DEAD)
            deathParameters.LeaveBody = true
            deathParameters.EnemyName = fields[2]
        elseif fields[1] == EnemyDeath.WEIRDING_WAY then
            SwitchState(state, STATE.DEAD)
            if (slashParticle ~= nil) then
                slashParticle:GetComponentParticle():ResumeParticleSpawn()
                slashParticle:GetComponentParticle():SetLoop(false)
                slashParticle:GetTransform():SetPosition(float3.new(componentTransform:GetPosition().x,
                    componentTransform:GetPosition().y + 12, componentTransform:GetPosition().z)) -- 23,12
            end
            deathParameters.LeaveBody = true
            deathParameters.EnemyName = fields[2]
        elseif fields[1] == EnemyDeath.MOSQUITO then
            SwitchState(state, STATE.DEAD)
            deathParameters.LeaveBody = true
            deathParameters.EnemyName = fields[2]
        elseif fields[1] == EnemyDeath.WORM_KILL then
            SwitchState(state, STATE.DEAD)
            deathParameters.LeaveBody = false
            deathParameters.EnemyName = fields[2]
            Die(deathParameters.LeaveBody, deathParameters.EnemyName)
        end

        gameObject.tag = Tag.CORPSE

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

        if (componentBoxCollider ~= nil) then
            gameObject:DeleteComponent(componentBoxCollider)
            componentBoxCollider = nil
        end
        if (coneLight ~= nil) then
            gameObject:DeleteComponent(coneLight)
            coneLight = nil
        end
    end
end

function DrawDebugger()
    DrawCircle(componentTransform:GetPosition(), hearingRange, float3.new(255.0, 0.0, 0.0), 5.0)
end

print("EnemyController.lua compiled successfully!")
Log("EnemyController.lua compiled successfully!\n")
