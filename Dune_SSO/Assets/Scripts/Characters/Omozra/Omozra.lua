----------------------------------------------------------------------------------------------------------------------------------
--																																--
--		*** Disclamer! ***																										--
--																																--
--		This script has several dependencies to work:																			--
--		1. The game object has to have a rigidBody																				--
--		2. There has to be a GameState.lua script somewhere in the scene in order to receive inputs								--
--		3. The game object has to have a Pathfinder.lua script in order to move													--
--		4. The animator, particles and audioSwitch components will be accessed if they exist but they are not a requirement		--
--																																--
----------------------------------------------------------------------------------------------------------------------------------
--------------------- Player events ---------------------
Movement = {
    IDLE = 1,
    WALK = 2,
    RUN = 3,
    IDLE_CROUCH = 4,
    CROUCH = 5
}
State = {
    IDLE = 1,
    AIM_PRIMARY = 2,
    AIM_SECONDARY = 3,
    AIM_ULTIMATE = 4,
    AIM_ULTIMATE_RECAST = 5,
    WORM = 6,
    DEAD = 7
}
---------------------------------------------------------

------------------- Variables setter --------------------
target = nil
currentMovement = Movement.IDLE
currentState = State.IDLE
maxHP = 3
currentHP = maxHP
iFrames = 1.5
iFramesTimer = nil

-- Globals --
characterID = 3
speed = 2000
crouchMultiplierPercentage = 66
runMultiplierPercentage = 150
staminaSeconds = 5
recoveryTime = 3
staminaTimer = staminaSeconds
isTired = false

-- Primary ability --
primaryCastRange = 100
primaryCooldown = 10.0
drawPrimary = false

-- Secondary ability --
secondaryCastRange = 75
secondaryCooldown = 10.0
drawSecondary = false

-- Ultimate ability --
ultimateCastRange = 50
ultimateCooldown = 30.0
drawUltimate = false
ultimateRecastRange = 100.0
drawUltimateRecast = false

---------------------------------------------------------

-------------------- Movement logic ---------------------
doubleClickDuration = 0.5
doubleClickTimer = 0.0
isDoubleClicking = false
---------------------------------------------------------

------------------- Inspector setter --------------------
-- Globals --
maxHPIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
maxHPIV = InspectorVariable.new("maxHP", maxHPIVT, maxHP)
NewVariable(maxHPIV)

speedIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
speedIV = InspectorVariable.new("speed", speedIVT, speed)
NewVariable(speedIV)

crouchMultiplierPercentageIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
crouchMultiplierPercentageIV = InspectorVariable.new("crouchMultiplierPercentage", crouchMultiplierPercentageIVT,
    crouchMultiplierPercentage)
NewVariable(crouchMultiplierPercentageIV)

runMultiplierPercentageIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
runMultiplierPercentageIV = InspectorVariable.new("runMultiplierPercentage", runMultiplierPercentageIVT,
    runMultiplierPercentage)
NewVariable(runMultiplierPercentageIV)

staminaSecondsIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
staminaSecondsIV = InspectorVariable.new("staminaSeconds", staminaSecondsIVT, staminaSeconds)
NewVariable(staminaSecondsIV)

recoveryTimeIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
recoveryTimeIV = InspectorVariable.new("recoveryTime", recoveryTimeIVT, recoveryTime)
NewVariable(recoveryTimeIV)

---- Primary ability --
primaryCastRangeIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
primaryCastRangeIV = InspectorVariable.new("primaryCastRange", primaryCastRangeIVT, primaryCastRange)
NewVariable(primaryCastRangeIV)

---- Secondary ability --
secondaryCastRangeIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
secondaryCastRangeIV = InspectorVariable.new("secondaryCastRange", secondaryCastRangeIVT, secondaryCastRange)
NewVariable(secondaryCastRangeIV)

---- Ultimate ability --
ultimateCastRangeIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
ultimateCastRangeIV = InspectorVariable.new("ultimateCastRange", ultimateCastRangeIVT, ultimateCastRange)
NewVariable(ultimateCastRangeIV)
---------------------------------------------------------

----------------------- Methods -------------------------

function Start()

    -- Components
    componentRigidBody = gameObject:GetRigidBody()
    componentBoxCollider = gameObject:GetBoxCollider()
    componentSwitch = gameObject:GetAudioSwitch()
    componentAnimator = gameObject:GetParent():GetComponentAnimator()
    componentLight = gameObject:GetLight()

    -- Animation
    if (componentAnimator ~= nil) then
        componentAnimator:SetSelectedClip("Idle")
    else
        Log("[ERROR] Component Animator not found!\n")
    end

    -- Particles
    mouseParticles = Find("Mouse Particles")
    if (mouseParticles ~= nil) then
        mouseParticles:GetComponentParticle():StopParticleSpawn()
    end
    choosingTargetParticle = Find("Choosing Target")

    -- Audio
    currentTrackID = -1

    -- HP
    currentHP = maxHP
    DispatchGlobalEvent("Player_Health", {characterID, currentHP, maxHP})

    -- Stamina
    staminaBar = Find("Stamina Bar")
    staminaBarSizeY = staminaBar:GetTransform():GetScale().y

    -- Abilities
    InstantiatePrefab("Worm")
end

-- Called each loop iteration
function Update(dt)

    if (ultimateTimer ~= nil and currentState == State.AIM_ULTIMATE_RECAST) then
        StopMovement()
    end
    DrawActiveAbilities()

    DrawHoverParticle()

    DispatchGlobalEvent("Player_Position", {componentTransform:GetPosition(), gameObject})

    if (lastRotation ~= nil) then
        componentTransform:LookAt(lastRotation, float3.new(0, 1, 0))
    end

    if (ManageTimers(dt) == false) then
        return
    end

    -- Manage States
    if (currentState == State.AIM_PRIMARY or currentState == State.AIM_SECONDARY or currentState == State.AIM_ULTIMATE) then
        StopMovement()
        componentAnimator:SetSelectedClip("Idle")
    elseif (destination ~= nil) then
        MoveToDestination(dt)
    end

    -- Gather Inputs
    if (IsSelected() == true) then

        UpdateStaminaBar()

        -- Left Click
        if (GetInput(1) == KEY_STATE.KEY_DOWN) then

            -- Primary ability (ª)
            if (currentState == State.AIM_PRIMARY) then

                -- Secondary ability
            elseif (currentState == State.AIM_SECONDARY) then
                if (secondaryTimer ~= nil) then
                    Log("[FAIL] Ability Secondary: Ability in cooldown!\n")
                else
                    target = GetGameObjectHovered()
                    if (target.tag ~= Tag.ENEMY) then
                        Log("[FAIL] Ability Primary: You have to select an enemy first!\n")
                    else
                        if (Distance3D(target:GetTransform():GetPosition(), componentTransform:GetPosition()) >
                            secondaryCastRange) then
                            Log("[FAIL] Ability Secondary: Ability out of range!\n")
                        else
                            if (componentAnimator ~= nil) then
                                CastSecondary(target:GetTransform():GetPosition())
                            end
                        end
                    end
                end

                -- Ultimate ability (needs to be refactored a bit :D)
            elseif (ultimateTimer == nil and currentState == State.AIM_ULTIMATE) then
                target = GetGameObjectHovered()
                if (target.tag ~= Tag.PLAYER) then
                    Log("[FAIL] Ability Primary: You have to select an ally first!\n")
                else
                    if (Distance3D(target:GetTransform():GetPosition(), componentTransform:GetPosition()) >
                        ultimateCastRange) then
                        Log("[FAIL] Ability Secondary: Ability out of range!\n")
                    else
                        if (componentAnimator ~= nil) then
                            CastUltimate(target:GetTransform():GetPosition())
                        end
                    end
                end
            elseif (currentState == State.AIM_ULTIMATE_RECAST) then
                GetGameObjectHovered() -- This is for the ability to go to the mouse Pos (it uses the target var)
                local mouse = GetLastMouseClick()
                if (Distance3D(mouse, componentTransform:GetPosition()) <= ultimateRecastRange) then
                    target = mouse
                    if (componentAnimator ~= nil) then
                        RecastUltimate(mouse) -- Ult step 6
                    end
                else
                    print("Out of range")
                end
            end
        end

        -- Right Click
        if (GetInput(3) == KEY_STATE.KEY_DOWN) then
            goHit = GetGameObjectHovered()
            if (goHit ~= gameObject) then -- Check you are not right-clicking yourself
                if (currentState == State.AIM_PRIMARY or currentState == State.AIM_SECONDARY or currentState ==
                    State.AIM_ULTIMATE) then
                    CancelAbilities()
                else
                    local isMoving = true
                    if (Distance3D(componentTransform:GetPosition(), GetLastMouseClick()) > 10) then
                        destination = GetLastMouseClick()
                        DispatchEvent("Pathfinder_UpdatePath", {{destination}, false, componentTransform:GetPosition()})
                    else
                        isMoving = false
                    end

                    if (currentMovement == Movement.WALK and isDoubleClicking == true and isMoving == true and isTired ==
                        false) then
                        SetMovement(Movement.RUN)
                    else
                        if (currentMovement == Movement.IDLE and isMoving == true) then
                            SetMovement(Movement.WALK)
                        end
                        isDoubleClicking = true
                    end
                    if (mouseParticles ~= nil) then
                        mouseParticles:GetComponentParticle():SetLoop(true)
                        mouseParticles:GetComponentParticle():ResumeParticleSpawn()
                        mouseParticles:GetTransform():SetPosition(destination)
                    end
                end
            end
        end

        -- 1
        if (GetInput(21) == KEY_STATE.KEY_DOWN and currentState ~= State.AIM_ULTIMATE_RECAST) then
            if (currentState == State.AIM_PRIMARY) then
                CancelAbilities()
            else
                CancelAbilities()
                SetState(State.AIM_PRIMARY)
                DispatchGlobalEvent("Player_Ability", {characterID, 1, 1})
                drawPrimary = true
            end
        end

        -- 2
        if (GetInput(22) == KEY_STATE.KEY_DOWN and currentState ~= State.AIM_ULTIMATE_RECAST) then
            if (currentState == State.AIM_SECONDARY) then
                CancelAbilities()
            else
                CancelAbilities()
                SetState(State.AIM_SECONDARY)
                DispatchGlobalEvent("Player_Ability", {characterID, 2, 1})
                drawSecondary = true
            end
        end

        -- 3
        if (GetInput(23) == KEY_STATE.KEY_DOWN and currentState ~= State.AIM_ULTIMATE_RECAST) then
            if (currentState == State.AIM_ULTIMATE) then
                CancelAbilities()
            else
                CancelAbilities()
                SetState(State.AIM_ULTIMATE)
                DispatchGlobalEvent("Player_Ability", {characterID, 3, 1})
                drawUltimate = true
            end
        end

        -- LSHIFT -> Toggle crouch
        if (GetInput(12) == KEY_STATE.KEY_DOWN) then

            if (currentMovement == Movement.CROUCH) then
                SetMovement(Movement.WALK)
            elseif (currentMovement == Movement.WALK or currentMovement == Movement.RUN) then
                SetMovement(Movement.CROUCH)
            elseif (destination == nil) then
                if (currentMovement == Movement.IDLE) then
                    SetMovement(Movement.IDLE_CROUCH)
                elseif (currentMovement == Movement.IDLE_CROUCH) then
                    SetMovement(Movement.IDLE)
                    if (componentAnimator ~= nil) then
                        componentAnimator:SetSelectedClip("Idle")
                    end
                end
            end
        end
    else
        CancelAbilities()
    end
end

--------------------------------------------------

------------------- Functions --------------------
function SetState(newState)
    if (newState == State.IDLE) then
        currentState = State.IDLE
    elseif (newState == State.AIM_PRIMARY) then
        currentState = State.AIM_PRIMARY
        drawPrimary = true
        StopMovement()
    elseif (newState == State.AIM_SECONDARY) then
        currentState = State.AIM_SECONDARY
        drawSecondary = true
        StopMovement()
    elseif (newState == State.AIM_ULTIMATE) then
        currentState = State.AIM_ULTIMATE
        drawUltimate = true
        StopMovement()
    elseif (newState == State.AIM_ULTIMATE_RECAST) then
        currentState = State.AIM_ULTIMATE_RECAST
        drawUltimateRecast = true
        StopMovement()
    elseif (newState == State.DEAD) then
        currentState = State.DEAD
        StopMovement()
    elseif (newState == State.WORM) then
        currentState = State.WORM
        StopMovement()
    end
end

function SetMovement(newMovement)
    if (newMovement == Movement.IDLE) then
        currentMovement = Movement.IDLE
        if (currentTrackID ~= -1) then
            componentSwitch:StopTrack(currentTrackID)
            currentTrackID = -1
        end
    elseif (newMovement == Movement.WALK) then
        currentMovement = Movement.WALK
        if (componentAnimator ~= nil) then
            componentAnimator:SetSelectedClip("Walk")
        end
        ChangeTrack(0)
    elseif (newMovement == Movement.RUN) then
        currentMovement = Movement.RUN
        if (componentAnimator ~= nil) then
            componentAnimator:SetSelectedClip("Run")
        end
        ChangeTrack(1)
    elseif (newMovement == Movement.IDLE_CROUCH) then
        currentMovement = Movement.IDLE_CROUCH
        if (componentAnimator ~= nil) then
            componentAnimator:SetSelectedClip("IdleCrouch")
        end
        if (componentSwitch ~= nil) then
            if (currentTrackID ~= -1) then
                componentSwitch:StopTrack(currentTrackID)
                currentTrackID = -1
            end
        end
    elseif (newMovement == Movement.CROUCH) then
        currentMovement = Movement.CROUCH
        ChangeTrack(0)
        if (componentAnimator ~= nil) then
            componentAnimator:SetSelectedClip("Crouch")
        end
    end
end

function CancelAbilities()
    if (currentState ~= State.AIM_ULTIMATE_RECAST) then
        SetState(State.IDLE)
    end
    DispatchGlobalEvent("Player_Ability", {characterID, 0, 0})
    drawPrimary = false
    drawSecondary = false
    drawUltimate = false
    drawUltimateRecast = false
end

function DrawHoverParticle()
    if (IsSelected() == true and
        (currentState == State.AIM_PRIMARY or currentState == State.AIM_SECONDARY or currentState == State.AIM_ULTIMATE)) then
        local drawingTarget = GetGameObjectHovered()
        if (drawingTarget.tag == Tag.ENEMY) then
            local dist = Distance3D(drawingTarget:GetTransform():GetPosition(), componentTransform:GetPosition())
            if ((currentState == State.AIM_PRIMARY and dist <= primaryCastRange) or
                (currentState == State.AIM_SECONDARY and dist <= secondaryCastRange) or
                (currentState == State.AIM_ULTIMATE and dist <= ultimateCastRange)) then
                choosingTargetParticle:GetComponentParticle():SetColor(255, 255, 0, 255)
            else
                choosingTargetParticle:GetComponentParticle():SetColor(255, 0, 0, 255)
            end
            choosingTargetParticle:GetComponentParticle():ResumeParticleSpawn()
            choosingTargetParticle:GetTransform():SetPosition(
                float3.new(drawingTarget:GetTransform():GetPosition().x,
                    drawingTarget:GetTransform():GetPosition().y + 1, drawingTarget:GetTransform():GetPosition().z))
        else
            choosingTargetParticle:GetComponentParticle():StopParticleSpawn()

        end
    else
        choosingTargetParticle:GetComponentParticle():StopParticleSpawn()

    end
end

function DrawActiveAbilities()
    if componentLight == nil then
        componentLight = gameObject:GetLight()
    end
    if componentLight ~= nil then
        if (drawPrimary == true) then
            componentLight:SetRange(primaryCastRange)
            componentLight:SetAngle(360 / 2)
        elseif (drawSecondary == true) then
            componentLight:SetRange(secondaryCastRange)
            componentLight:SetAngle(360 / 2)
        elseif (drawUltimate == true) then
            componentLight:SetRange(ultimateCastRange)
            componentLight:SetAngle(360 / 2)
        elseif (drawUltimateRecast == true) then
            componentLight:SetRange(ultimateRecastRange)
            componentLight:SetAngle(360 / 2)
        else
            componentLight:SetAngle(0)
        end
    end
end

function UpdateStaminaBar()
    staminaBar:GetTransform():SetScale(float3.new(staminaBar:GetTransform():GetScale().x,
        staminaBarSizeY * (staminaTimer / staminaSeconds), staminaBar:GetTransform():GetScale().z))
end

function ManageTimers(dt)
    local ret = true

    if (currentMovement == Movement.RUN) then
        staminaTimer = staminaTimer - dt
        if (staminaTimer < 0.0) then
            staminaTimer = 0.0
            isTired = true

            SetMovement(Movement.WALK)
        else
            -- Log("Stamina timer: " .. staminaTimer .. "\n")
        end
    else
        staminaTimer = staminaTimer + dt
        if (staminaTimer > recoveryTime) then
            staminaTimer = staminaSeconds
            isTired = false
            -- Log("I am recovered! :) \n")
        else
            -- Log("Stamina timer: " .. staminaTimer .. "\n")
        end
    end

    -- Running state logic
    if (isDoubleClicking == true) then
        if (doubleClickTimer < doubleClickDuration) then
            doubleClickTimer = doubleClickTimer + dt
        else
            isDoubleClicking = false
            doubleClickTimer = 0.0
        end
    end

    -- Invencibility timer
    if (iFramesTimer ~= nil) then
        iFramesTimer = iFramesTimer + dt
        if (iFramesTimer >= iFrames) then
            iFramesTimer = nil
        end
    end

    -- Primary ability cooldown

    -- Secondary ability cooldown
    if (secondaryTimer ~= nil) then
        secondaryTimer = secondaryTimer + dt
        if (secondaryTimer >= secondaryCooldown) then
            secondaryTimer = nil
            DispatchGlobalEvent("Player_Ability", {characterID, 2, 0})
        end
    end

    -- Ultimate ability cooldown
    if (ultimateTimer ~= nil) then
        ultimateTimer = ultimateTimer + dt
        if (ultimateTimer >= ultimateCooldown) then
            ultimateTimer = nil
            DispatchGlobalEvent("Player_Ability", {characterID, 3, 0})
        end
    end
    if (currentState == State.AIM_ULTIMATE) then
        DispatchGlobalEvent("Omozra_Ultimate", {})
    end

    -- Animation timer
    if (componentAnimator ~= nil) then
        if (componentAnimator:IsCurrentClipLooping() == false) then
            if (componentAnimator:IsCurrentClipPlaying() == true) then
                ret = false
            else
                if (currentState == State.AIM_PRIMARY) then

                elseif (currentState == State.AIM_SECONDARY) then
                    DoSecondary()
                elseif (currentState == State.AIM_ULTIMATE) then
                    DoUltimate()
                elseif (currentState == State.AIM_ULTIMATE_RECAST) then
                    if (ultimateTimer ~= nil) then -- Second pass will get in here
                        DoUltimateRecast()
                    end
                elseif (currentState ~= State.DEAD) then
                    componentAnimator:SetSelectedClip("Idle") -- Comment this line to test animations in-game
                end
            end
        end
    end

    -- If he's dead he can't do anything
    if (currentState == State.DEAD) then
        ret = false
    end

    return ret
end

function MoveToDestination(dt)
    local targetPos2D = {destination.x, destination.z}
    local pos2D = {componentTransform:GetPosition().x, componentTransform:GetPosition().z}
    local d = Distance2D(pos2D, targetPos2D)
    local vec2 = {targetPos2D[1] - pos2D[1], targetPos2D[2] - pos2D[2]}

    if (d > 5.0) then

        -- Adapt speed
        local s = speed
        if (currentMovement == Movement.IDLE_CROUCH) then
            SetMovement(Movement.CROUCH)
            s = speed * crouchMultiplierPercentage / 100
            DispatchGlobalEvent("Auditory_Trigger", {componentTransform:GetPosition(),
                                                     100 * crouchMultiplierPercentage / 100, "repeated", gameObject})
        elseif (currentMovement == Movement.CROUCH) then
            s = speed * crouchMultiplierPercentage / 100
            DispatchGlobalEvent("Auditory_Trigger", {componentTransform:GetPosition(),
                                                     100 * crouchMultiplierPercentage / 100, "repeated", gameObject})
        elseif (currentMovement == Movement.RUN) then
            s = speed * runMultiplierPercentage / 100
            DispatchGlobalEvent("Auditory_Trigger", {componentTransform:GetPosition(),
                                                     100 * runMultiplierPercentage / 100, "repeated", gameObject})
        elseif (currentMovement == Movement.WALK) then
            DispatchGlobalEvent("Auditory_Trigger", {componentTransform:GetPosition(), 100, "repeated", gameObject})
        end

        -- Adapt speed on arrive
        if (d < 2) then
            s = s * 0.5
        end

        -- Movement
        vec2 = Normalize(vec2, d)
        if (componentRigidBody ~= nil) then
            -- componentRigidBody:SetLinearVelocity(float3.new(vec2[1] * s * dt, 0, vec2[2] * s * dt))
            DispatchEvent("Pathfinder_FollowPath", {s, dt, false})
        end

        -- Rotation
        lastRotation = float3.new(vec2[1], 0, vec2[2])
        componentTransform:LookAt(lastRotation, float3.new(0, 1, 0))
    else
        if (componentAnimator ~= nil) then
            componentAnimator:SetSelectedClip("Idle")
        end
        StopMovement()
    end
end

function StopMovement()

    if (currentMovement == Movement.CROUCH) then
        SetMovement(Movement.IDLE_CROUCH)
    else
        SetMovement(Movement.IDLE)
    end

    destination = nil

    if (componentRigidBody ~= nil) then
        componentRigidBody:SetLinearVelocity(float3.new(0, 0, 0))
    end
end

function LookAtTarget(lookAt)
    local targetPos2D = {lookAt.x, lookAt.z}
    local pos2D = {componentTransform:GetPosition().x, componentTransform:GetPosition().z}
    local d = Distance2D(pos2D, targetPos2D)
    local vec2 = {targetPos2D[1] - pos2D[1], targetPos2D[2] - pos2D[2]}
    lastRotation = float3.new(vec2[1], 0, vec2[2])
    componentTransform:LookAt(lastRotation, float3.new(0, 1, 0))
end

function IsSelected()

    local id = GetVariable("GameState.lua", "characterSelected", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)

    if (id == characterID) then
        return true
    end

    return false
end

-- Primary ability
function CastPrimary(position)
    drawPrimary = false
    drawSecondary = false
    drawUltimate = false
    drawUltimateRecast = false
end

-- Secondary ability
function CastSecondary(position)

    componentAnimator:SetSelectedClip("Point")
    secondaryTimer = 0.0
    StopMovement()

    DispatchGlobalEvent("Player_Ability", {characterID, 2, 2})
    if (position == nil) then
        Log("Position Null")
    else
        LookAtTarget(position)
    end

    ChangeTrack(4)

    drawPrimary = false
    drawSecondary = false
    drawUltimate = false
    drawUltimateRecast = false
end

function DoSecondary()

    DispatchGlobalEvent("Sadiq_Update_Target", {target, 1}) -- fields[1] -> target; targeted for (1 -> warning; 2 -> eat; 3 -> spit)

    componentAnimator:SetSelectedClip("PointToIdle")

    SetState(State.IDLE)
end

-- Ultimate ability
function CastUltimate() -- Ult step 3

    componentAnimator:SetSelectedClip("Point")
    -- CD will start when recasting
    StopMovement()

    DispatchGlobalEvent("Player_Ability", {characterID, 3, 2})
    LookAtTarget(target:GetTransform():GetPosition())

    ChangeTrack(4)

    drawPrimary = false
    drawSecondary = false
    drawUltimate = false
    drawUltimateRecast = false
end

function DoUltimate() -- Ult step 4

    DispatchGlobalEvent("Sadiq_Update_Target", {target, 1}) -- fields[1] -> target; fields[2] -> targeted for (1 -> warning; 2 -> eat; 3 -> spit)

    componentAnimator:SetSelectedClip("PointToIdle")

    SetState(State.AIM_ULTIMATE_RECAST)
end

function RecastUltimate(position)

    componentAnimator:SetSelectedClip("Point")
    ultimateTimer = 0.0
    StopMovement()

    LookAtTarget(position)

    ChangeTrack(4)

    drawPrimary = false
    drawSecondary = false
    drawUltimate = false
    drawUltimateRecast = false
end

function DoUltimateRecast() -- Ult step 7

    DispatchGlobalEvent("Sadiq_Update_Target", {target, 3}) -- fields[1] -> target; fields[2] -> targeted for (1 -> warning; 2 -> eat; 3 -> spit)
    StopMovement()
    componentAnimator:SetSelectedClip("PointToIdle")
    SetState(State.IDLE)
end

function TakeDamage(damage)
    if (iFramesTimer ~= nil or currentHP == 0) then
        return
    end

    iFramesTimer = 0

    if (damage == nil) then
        damage = 1
    end

    if (currentHP > 1) then
        currentHP = currentHP - damage
        DispatchGlobalEvent("Player_Health", {characterID, currentHP, maxHP})

        ChangeTrack(2)
    else
        currentHP = 0
        DispatchGlobalEvent("Player_Health", {characterID, currentHP, maxHP})
        Die()
    end
end

function Die()
    SetState(State.DEAD)
    currentHP = 0
    DispatchGlobalEvent("Player_Death", {characterID})

    if (componentRigidBody ~= nil) then
        componentRigidBody:SetRigidBodyPos(float3.new(componentTransform:GetPosition().x, 3,
            componentTransform:GetPosition().z))
    end
    if (componentAnimator ~= nil) then
        componentAnimator:SetSelectedClip("Death")
    end
    ChangeTrack(3)
end
--------------------------------------------------

-------------------- Events ----------------------
function EventHandler(key, fields)

    if (key == "Stop_Movement") then
        StopMovement()
        if (componentAnimator ~= nil) then
            componentAnimator:SetSelectedClip("Idle")
        end
    elseif (key == "Enemy_Attack") then
        if (fields[1] == gameObject) then
            if (fields[2] == "Harkonnen" and
                GetVariable("GameState.lua", "GodMode", INSPECTOR_VARIABLE_TYPE.INSPECTOR_BOOL) == false) then
                TakeDamage()
            end
        end
    end
end
--------------------------------------------------

------------------ Collisions --------------------
function OnTriggerEnter(go)
    if (go.tag == Tag.ENEMY and iFramesTimer == nil) then
        -- TakeDamage(1)
    end
end

function OnCollisionEnter(go)
    if (currentState == State.DEAD) then
        return
    end
    if (go.tag == Tag.ENEMY and iFramesTimer == nil) then
        -- TakeDamage(1)
    end
end

--------------------------------------------------

----------------- Math Functions -----------------
function Normalize(vec, distance)
    vec[1] = vec[1] / distance
    vec[2] = vec[2] / distance
    return vec
end

function Distance2D(a, b)
    local dx, dy = a[1] - b[1], a[2] - b[2]
    local sqrt = math.sqrt(dx * dx + dy * dy)
    return sqrt
end

function Distance3D(a, b)
    diff = {
        x = b.x - a.x,
        y = b.y - a.y,
        z = b.z - a.z
    }
    return math.sqrt(diff.x * diff.x + diff.y * diff.y + diff.z * diff.z)
end

--------------------------------------------------

function ChangeTrack(index)
    if (componentSwitch ~= nil) then
        if (currentTrackID ~= -1) then
            componentSwitch:StopTrack(currentTrackID)
        end
        currentTrackID = index
        componentSwitch:PlayTrack(currentTrackID)
    end
end

print("Omozra.lua compiled succesfully!\n")
Log("Nerala.lua compiled succesfully!\n")
