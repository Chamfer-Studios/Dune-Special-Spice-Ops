static = false
local staticIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_BOOL
staticIV = InspectorVariable.new("static", staticIVT, static)
NewVariable(staticIV)

speed = 2000
local speedIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
speedIV = InspectorVariable.new("speed", speedIVT, speed)
NewVariable(speedIV)

chaseSpeed = 3000
local chaseSpeedIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
chaseSpeedIV = InspectorVariable.new("chaseSpeed", chaseSpeedIVT, chaseSpeed)
NewVariable(chaseSpeedIV)

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

coneLight = gameObject:GetLight()

awareness_green = nil
awareness_yellow = nil
awareness_red = nil

awareness_green_name = "awareness_green_" .. gameObject:GetUID()
awareness_yellow_name = "awareness_yellow_" .. gameObject:GetUID()
awareness_red_name = "awareness_red_" .. gameObject:GetUID()

pathfinderUpdateKey = "Pathfinder_UpdatePath"
pathfinderFollowKey = "Pathfinder_FollowPath"

STATE = {
    UNAWARE = 1,
    SUS = 2,
    AGGRO = 3,
    DEAD = 4,
    VICTORY = 5
}

state = STATE.UNAWARE

awareness = 0
targetAwareness = 0

nSingle = 1
nRepeating = 1
nVisual = 1

singleAuditoryTriggers = {}
repeatingAuditoryTriggers = {}
visualTriggers = {}

target = nil

function Float3Length(v)
    return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
end

function Float3Difference(a, b)
    return float3.new(b.x - a.x, b.y - a.y, b.z - a.z)
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

function LookAtDirection(direction)
    position = componentTransform:GetPosition()
    target = float3.new(position.x + direction.x, position.y + direction.y, position.z + direction.z)

    componentTransform:LookAt(direction, float3.new(0, 1, 0))
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

function ProcessVisualTrigger(position, gameObject)
    if not CheckIfPointInCone(position) then
        do return end
    end

    visualTriggers[nVisual] = {}
    visualTriggers[nVisual]["position"] = position
    visualTriggers[nVisual]["source"] = gameObject

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
    singleAuditoryTriggers[nSingle]["source"] = gameObject

    nSingle = nSingle + 1
end

function ProcessRepeatedAuditoryTrigger(position, source)
    repeatingAuditoryTriggers[nRepeating] = {}
    repeatingAuditoryTriggers[nRepeating]["position"] = position
    repeatingAuditoryTriggers[nRepeating]["source"] = gameObject

    nRepeating = nRepeating + 1
end

function ProcessAuditoryTrigger(position, range, type, source)
    if not CheckAuditoryTriggerInRange(position, range) then
        do return end
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

    if awareness == 2 then
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

function EventHandler(key, fields)
    if key == "Auditory_Trigger" then -- fields[1] -> position; fields[2] -> range; fields[3] -> type ("single", "repeated"); fields[4] -> source ("GameObject");
        ProcessAuditoryTrigger(fields[1], fields[2], fields[3], fields[4])
    elseif key == "Walking_Direction" then
        LookAtDirection(fields[1])
    elseif key == "Player_Position" then
        ProcessVisualTrigger(fields[1], fields[2])
    end
end

function Start()
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

function UpdateTargetAwareness()
    awarenessSpeed = awarenessDecaySpeed

    if #visualTriggers ~= 0 then
        targetAwareness = 2
        awarenessSpeed = awarenessVisualSpeed
    elseif #repeatingAuditoryTriggers ~= 0 then
        targetAwareness = 2
        awarenessSpeed = awarenessSoundSpeed
    else
        targetAwareness = 0
    end

    do return (awarenessSpeed) end
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

    if math.abs(awareness) < 0.05 then
        SwitchState(state, STATE.UNAWARE)
    end

    if math.abs(awareness - 1) < 0.05 then
        SwitchState(state, STATE.SUS)
    end

    if math.abs(awareness - 2) < 0.05 then
        SwitchState(state, STATE.AGGRO)
    end

    do return (oldState) end
end

function GetClosestTrigger(stateCriteria, triggerTable)
    closestTrigger = nil

    for i=1,#triggerTable do
        trigger = triggerTable[i]

        -- TODO: Here
    end

    do return (closestTrigger) end
end

function UpdateClosestTarget()
    closestRepeatingTrigger = GetClosestTrigger(state, #repeatingAuditoryTriggers)
    closestSingleTrigger = GetClosestTrigger(state, #singleAuditoryTriggers)
    closestVisualTrigger = GetClosestTrigger(state, #visualTriggers)
end

function UpdatePathIfNecessary(oldState, newState)
    if oldState ~= STATE.UNAWARE and newState == STATE.UNAWARE then
        CheckAndRecalculatePath(true)
    elseif newState == STATE.SUS then
        DispatchEvent(pathfinderUpdateKey, { {}, pingpong, componentTransform:GetPosition()})
    elseif newState == STATE.AGGRO then
        DispatchEvent(pathfinderUpdateKey, { {}, pingpong, componentTransform:GetPosition()})
    end
end

function SwitchState(from, to)
    if from == to then
        do return end
    end

    state = to

    if to == STATE.UNAWARE then
        targetAwareness = 0
        awareness = 0
        ClearPerceptionMemory()
    end

    if to == STATE.SUS then
        targetAwareness = 1
        awareness = 1
    end

    if to == STATE.AGGRO then
        targetAwareness = 2
        awareness = 2
    end
end

function Update(dt)
    awarenessSpeed = UpdateTargetAwareness()
    UpdateAwareness(dt, awarenessSpeed)
    oldState = UpdateStateFromAwareness()
    UpdateClosestTarget()
    UpdatePathIfNecessary(oldState, state)
    UpdateSecondaryObjects()

    if state == STATE.UNAWARE then
        DispatchEvent(pathfinderFollowKey, {speed, dt, loop, false})
    elseif state == STATE.SUS then

    end

    ClearPerceptionMemory()
end

function ClearPerceptionMemory()
    nSingle = 1
    nRepeating = 1
    nVisual = 1

    singleAuditoryTriggers = {}
    repeatingAuditoryTriggers = {}
    visualTriggers = {}

    target = nil
end

print("EnemyController.lua compiled successfully!")
