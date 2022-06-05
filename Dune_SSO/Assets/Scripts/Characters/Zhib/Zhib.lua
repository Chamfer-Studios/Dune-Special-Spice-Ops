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
    ATTACK = 2,
    AIM_PRIMARY = 3,
    AIM_SECONDARY = 4,
    AIM_ULTIMATE = 5,
    DEAD = 6,
    WORM = 7
}

Ability = {
    Primary = 1,
    Secondary = 2,
    Ultimate = 3
}

AbilityStatus = {
    Normal = 1,
    Active = 2,
    Cooldown = 3,
    Using = 4,
    Pickable = 5,
    Disabled = 6,
    Casting = 7 -- Casting is for intern code
}
abilities = {
    AbilityPrimary = AbilityStatus.Normal,
    AbilitySecondary = AbilityStatus.Normal,
    AbilityUltimate = AbilityStatus.Normal
}
---------------------------------------------------------

------------------- Variables setter --------------------
target = nil
currentMovement = Movement.IDLE
currentState = State.IDLE
maxHP = 4
currentHP = maxHP
iFrames = 1.5
iFramesTimer = nil

-- Globals --
characterID = 1
speed = 2000
crouchMultiplierPercentage = 66
runMultiplierPercentage = 150
staminaSeconds = 5
recoveryTime = 5
staminaTimer = staminaSeconds
standingStaminaMultiplier = 1.5
isTired = false
isUsingQ = false
isUsingW = false
isUsingE = false

-- Basic Attack --
attackRange = 25.0
attackTime = 2.5

-- Primary ability --
primaryCastRange = 100
maxKnives = 1
knifeSpeed = 10000
unawareChanceHarkKnife = 100
awareChanceHarkKnife = 80
aggroChanceHarkKnife = 20
unawareChanceSardKnife = 75
awareChanceSardKnife = 25
aggroChanceSardKnife = 0

-- Secondary ability --
maxDecoy = 1
secondaryCastRange = 225 -- 75
secondaryCooldown = 10

-- Ultimate ability --
ultimateCastRange = 100
ultimateCooldown = 30.0
ultimateCastRangeExtension = ultimateCastRange * 0.5
ultimateSpiceCost = 2000
---------------------------------------------------------

-------------------- Movement logic ---------------------
doubleClickDuration = 0.5
doubleClickTimer = 0.0
isDoubleClicking = false
isDialogueOpen = false
hasToMove = false
---------------------------------------------------------

------------------- Detection logic ---------------------
smokebombFlag = false
---------------------------------------------------------
--------------------Game Flow----------------------------
unlocked = false;

------------------- Inspector setter --------------------
-- -- Globals --
-- maxHPIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
-- maxHPIV = InspectorVariable.new("maxHP", maxHPIVT, maxHP)
-- NewVariable(maxHPIV)

-- speedIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
-- speedIV = InspectorVariable.new("speed", speedIVT, speed)
-- NewVariable(speedIV)

-- crouchMultiplierPercentageIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
-- crouchMultiplierPercentageIV = InspectorVariable.new("crouchMultiplierPercentage", crouchMultiplierPercentageIVT,
--     crouchMultiplierPercentage)
-- NewVariable(crouchMultiplierPercentageIV)

-- runMultiplierPercentageIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
-- runMultiplierPercentageIV = InspectorVariable.new("runMultiplierPercentage", runMultiplierPercentageIVT,
--     runMultiplierPercentage)
-- NewVariable(runMultiplierPercentageIV)

-- staminaSecondsIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
-- staminaSecondsIV = InspectorVariable.new("staminaSeconds", staminaSecondsIVT, staminaSeconds)
-- NewVariable(staminaSecondsIV)

-- recoveryTimeIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
-- recoveryTimeIV = InspectorVariable.new("recoveryTime", recoveryTimeIVT, recoveryTime)
-- NewVariable(recoveryTimeIV)

---- Primary ability --
-- primaryCastRangeIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
-- primaryCastRangeIV = InspectorVariable.new("primaryCastRange", primaryCastRangeIVT, primaryCastRange)
-- NewVariable(primaryCastRangeIV)

-- maxKnivesIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
-- maxKnivesIV = InspectorVariable.new("maxKnives", maxKnivesIVT, maxKnives)
-- NewVariable(maxKnivesIV)

-- knifeSpeedIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
-- knifeSpeedIV = InspectorVariable.new("knifeSpeed", knifeSpeedIVT, knifeSpeed)
-- NewVariable(knifeSpeedIV)

---- Secondary ability --
-- secondaryCastRangeIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
-- secondaryCastRangeIV = InspectorVariable.new("secondaryCastRange", secondaryCastRangeIVT, secondaryCastRange)
-- NewVariable(secondaryCastRangeIV)

-- maxDecoyIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
-- maxDecoyIV = InspectorVariable.new("maxDecoy", maxDecoyIVT, maxDecoy)
-- NewVariable(maxDecoyIV)

---- Ultimate ability --
-- ultimateCastRangeIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
-- ultimateCastRangeIV = InspectorVariable.new("ultimateCastRange", ultimateCastRangeIVT, ultimateCastRange)
-- NewVariable(ultimateCastRangeIV)

-- ultimateSpiceCostIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
-- ultimateSpiceCostIV = InspectorVariable.new("ultimateSpiceCost", ultimateSpiceCostIVT, ultimateSpiceCost)
-- NewVariable(ultimateSpiceCostIV)
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
    mouseParticles = Find("Mouse Particle")
    if (mouseParticles ~= nil) then
        mouseParticles:GetComponentParticle():StopParticleSpawn()
    end
    choosingTargetParticle = Find("Target Particle")
    bloodParticle = Find("Zhib Blood Particle")
    if (bloodParticle ~= nil) then
        bloodParticle:GetComponentParticle():StopParticleSpawn()
    end
    impactParticle = Find("Zhib Impact Particle") -- not used currently
    swooshParticle = Find("Zhib Swoosh Particle") -- not used currently
    footstepsParticle = Find("Zhib Footstep Particle")

    -- Audio
    currentTrackID = -1

    -- HP
    currentHP = maxHP
    DispatchGlobalEvent("Player_Health", {characterID, currentHP, maxHP})

    -- Abilities
    knifeCount = maxKnives
    decoyCount = maxDecoy
end

-- Called each loop iteration
function Update(dt)

    DrawActiveAbilities()
    DrawHoverParticle()

    if staminaBarBlue == nil then
        ConfigStaminaBars()
    else
        UpdateStaminaBar()
    end

    if (bloodParticle ~= nil) then
        bloodParticle:GetTransform():SetPosition(float3.new(componentTransform:GetPosition().x,
            componentTransform:GetPosition().y + 23, componentTransform:GetPosition().z + 12))
    end

    if GetVariable("GameState.lua", "zhibAvailable", INSPECTOR_VARIABLE_TYPE.INSPECTOR_BOOL) == true then
        if (smokebombPosition == nil) then
            DispatchGlobalEvent("Player_Position", {componentTransform:GetPosition(), gameObject})
        elseif (Distance3D(componentTransform:GetPosition(), smokebombPosition) > smokebombRadius) then
            DispatchGlobalEvent("Player_Position", {componentTransform:GetPosition(), gameObject})
        end
    end

    if (lastRotation ~= nil) then
        componentTransform:LookAt(lastRotation, float3.new(0, 1, 0))
    end

    if (ManageTimers(dt) == false) then
        do
            return
        end
    end

    -- States
    if (currentState == State.ATTACK) then

        if (Distance3D(componentTransform:GetPosition(), target:GetTransform():GetPosition()) <= attackRange) then
            Attack()
        else
            destination = target:GetTransform():GetPosition()
            hasToMove = true
        end
    elseif (currentState == State.AIM_PRIMARY or currentState == State.AIM_SECONDARY or currentState ==
        State.AIM_ULTIMATE) then
        StopMovement()
        componentAnimator:SetSelectedClip("Idle")
    elseif (destination ~= nil) then
        hasToMove = true
    end

    -- Gather Inputs
    if (IsSelected() == true) then

        -- Left Click
        if (GetInput(1) == KEY_STATE.KEY_DOWN) then

            -- Primary ability (Knife)
            if (currentState == State.AIM_PRIMARY) then
                if (knifeCount <= 0) then
                    Log("[FAIL] Ability Primary: You don't have enough knives!\n")
                else
                    target = GetGameObjectHovered()
                    if (target.tag ~= Tag.ENEMY) then
                        Log("[FAIL] Ability Primary: You have to select an enemy first!\n")
                        target = nil
                    else
                        if (Distance3D(target:GetTransform():GetPosition(), componentTransform:GetPosition()) >
                            primaryCastRange) then
                            Log("[FAIL] Ability Primary: Ability out of range!\n")
                            target = nil
                        else
                            if (componentAnimator ~= nil) then
                                CastPrimary(target:GetTransform():GetPosition())
                            end
                        end
                    end
                end

                -- Secondary ability (Decoy)
            elseif (currentState == State.AIM_SECONDARY) then
                if (secondaryTimer ~= nil) then
                    Log("[FAIL] Ability Secondary: Ability in cooldown!\n")
                else
                    if (decoyCount <= 0) then
                        Log("[FAIL] Ability Secondary: You don't have enough decoy!\n")
                    else
                        -- GetGameObjectHovered updates the last mouse click
                        target = GetGameObjectHovered()
                        local mouse = GetLastMouseClick()
                        if (Distance3D(mouse, componentTransform:GetPosition()) > secondaryCastRange) then
                            Log("[FAIL] Ability Secondary: Ability out of range!\n")
                            target = nil
                        else
                            if (target.tag ~= Tag.FLOOR) then
                                Log("[FAIL] Ability Secondary: You have to select floor!\n")
                                target = nil
                            else
                                target = mouse
                                if (componentAnimator ~= nil) then
                                    CastSecondary(mouse)
                                end
                            end
                        end
                    end
                end

                -- Ultimate ability (master yi)
            elseif (currentState == State.AIM_ULTIMATE) then
                if (ultimateTimer ~= nil) then
                    Log("[FAIL] Ability Ultimate: Ability in cooldown!\n")
                else
                    target = GetGameObjectHovered()
                    if (target.tag ~= Tag.ENEMY) then
                        Log("[FAIL] Ability Ultimate: You have to select an enemy first!\n")
                        target = nil
                    else
                        if (Distance3D(target:GetTransform():GetPosition(), componentTransform:GetPosition()) >
                            ultimateCastRange) then
                            Log("[FAIL] Ability Ultimate: Ability out of range!\n")
                            target = nil
                        else
                            if (componentAnimator ~= nil) then
                                CastUltimate(target:GetTransform():GetPosition())
                            end
                        end
                    end
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
                    isMoving = true
                    if (goHit.tag == Tag.ENEMY and attackTimer == nil) then
                        SetState(State.ATTACK)
                        target = goHit
                        if (Distance3D(componentTransform:GetPosition(), goHit:GetTransform():GetPosition()) <=
                            attackRange) then
                            isMoving = false
                            Attack()
                        else
                            if (footstepsParticle ~= nil) then
                                feetTimer = 0.5
                                FootstepMovement()
                            end
                            destination = target:GetTransform():GetPosition()
                            if (currentMovement == Movement.IDLE and isMoving == true) then
                                SetMovement(Movement.WALK)
                            end
                            DispatchEvent("Pathfinder_UpdatePath",
                                {{destination}, false, componentTransform:GetPosition()})
                        end
                    elseif (goHit.tag == Tag.PICKUP or goHit.tag == Tag.CORPSE) then
                        target = nil
                        currentState = State.IDLE
                        if (footstepsParticle ~= nil) then
                            feetTimer = 0.5
                            FootstepMovement()
                        end
                        destination = goHit:GetTransform():GetPosition()
                        DispatchEvent("Pathfinder_UpdatePath", {{destination}, false, componentTransform:GetPosition()})
                    elseif (goHit.tag == Tag.FLOOR) then
                        target = nil
                        currentState = State.IDLE
                        if (footstepsParticle ~= nil) then
                            feetTimer = 0.5
                            FootstepMovement()
                        end
                        destination = GetLastMouseClick()
                        DispatchEvent("Pathfinder_UpdatePath", {{destination}, false, componentTransform:GetPosition()})
                    else
                        if (isMoving == true) then
                            Log("No possible path\n")
                            do
                                return
                            end
                        else
                            Log("No possible path\n")
                            target = nil
                            if (footstepsParticle ~= nil) then
                                footstepsParticle:GetComponentParticle():StopParticleSpawn()
                            end
                            destination = nil
                            if (currentState ~= State.IDLE) then
                                SetState(State.IDLE)
                            end
                            isMoving = false
                            DispatchEvent("Pathfinder_UpdatePath",
                                {{destination}, false, componentTransform:GetPosition()})
                        end

                    end
                    if (currentMovement == Movement.WALK and isDoubleClicking == true and isMoving == true and
                        not isTired) then
                        SetMovement(Movement.RUN)
                    else
                        if (currentMovement == Movement.IDLE and isMoving == true) then
                            SetMovement(Movement.WALK)
                        end
                        isDoubleClicking = true
                    end
                    if (mouseParticles ~= nil and destination ~= nil) then
                        mouseParticles:GetComponentParticle():SetLoop(true)
                        mouseParticles:GetComponentParticle():ResumeParticleSpawn()
                        mouseParticles:GetTransform():SetPosition(destination)
                    end
                end
            end
        end

        -- 1
        if (GetInput(21) == KEY_STATE.KEY_DOWN) then
            ActivePrimary()
        end

        -- 2
        if (GetInput(22) == KEY_STATE.KEY_DOWN) then
            ActiveSecondary()
        end

        -- 3
        if (GetInput(23) == KEY_STATE.KEY_DOWN) then
            ActiveUltimate()
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
        -- CancelAbilities()
    end

    if (hasToMove == true and destination ~= nil) then
        MoveToDestination(dt)
        hasToMove = false
    end

    if abilities.AbilityPrimary == AbilityStatus.Using then
        isUsingQ = true
    else
        isUsingQ = false
    end
    if abilities.AbilitySecondary == AbilityStatus.Using then
        isUsingW = true
    else
        isUsingW = false
    end
    if abilities.AbilityUltimate == AbilityStatus.Using then
        isUsingE = true
    else
        isUsingE = false
    end
end
--------------------------------------------------

------------------- Functions --------------------
function SetState(newState)
    if (newState == State.IDLE) then
        currentState = State.IDLE
    elseif (newState == State.ATTACK) then
        currentState = State.ATTACK
        StopMovement(false)
    elseif (newState == State.AIM_PRIMARY) then
        currentState = State.AIM_PRIMARY
        StopMovement(false)
    elseif (newState == State.AIM_SECONDARY) then
        currentState = State.AIM_SECONDARY
        StopMovement(false)
    elseif (newState == State.AIM_ULTIMATE) then
        currentState = State.AIM_ULTIMATE
        StopMovement(false)
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
        if (componentSwitch ~= nil) then
            if (currentTrackID ~= -1) then
                componentSwitch:StopTrack(currentTrackID)
                currentTrackID = -1
            end
        end
    elseif (newMovement == Movement.WALK) then
        currentMovement = Movement.WALK
        if (componentAnimator ~= nil) then
            componentAnimator:SetSelectedClip("Walk")
        end
        trackList = {0}
        ChangeTrack(trackList)
    elseif (newMovement == Movement.RUN) then
        currentMovement = Movement.RUN
        if (componentAnimator ~= nil) then
            componentAnimator:SetSelectedClip("Run")
        end
        trackList = {1}
        ChangeTrack(trackList)
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
        if (currentMovement ~= Movement.IDLE and componentSwitch ~= nil) then
            trackList = {0}
            ChangeTrack(trackList)
        end
        if (componentAnimator ~= nil) then
            componentAnimator:SetSelectedClip("Crouch")
        end
    end
end

function CancelAbilities(onlyAbilities)
    if (currentState == State.AIM_PRIMARY and abilities.AbilityPrimary == AbilityStatus.Active) then
        abilities.AbilityPrimary = AbilityStatus.Normal
        DispatchGlobalEvent("Player_Ability", {characterID, Ability.Primary, abilities.AbilityPrimary})
    elseif (currentState == State.AIM_SECONDARY and abilities.AbilitySecondary == AbilityStatus.Active) then
        abilities.AbilitySecondary = AbilityStatus.Normal
        DispatchGlobalEvent("Player_Ability", {characterID, Ability.Secondary, abilities.AbilitySecondary})
    elseif (currentState == State.AIM_ULTIMATE and abilities.AbilityUltimate == AbilityStatus.Active) then
        abilities.AbilityUltimate = AbilityStatus.Normal
        DispatchGlobalEvent("Player_Ability", {characterID, Ability.Ultimate, abilities.AbilityUltimate})
    end

    if (currentMovement == Movement.IDLE and componentAnimator ~= nil) then
        componentAnimator:SetSelectedClip("Idle")
    elseif (currentMovement == Movement.IDLE_CROUCH and componentAnimator ~= nil) then
        componentAnimator:SetSelectedClip("IdleCrouch")
    end

    if (onlyAbilities == nil) then
        if (currentState ~= State.WORM) then
            SetState(State.IDLE)
        end
    end
end

function DrawHoverParticle()
    if (choosingTargetParticle == nil) then
        do
            return
        end
    end

    if (IsSelected() == true) then
        local drawingTarget = GetGameObjectHovered()
        local finalPosition
        if ((currentState == State.ATTACK or currentState == State.AIM_PRIMARY or currentState == State.AIM_SECONDARY or
            currentState == State.AIM_ULTIMATE) and target ~= nil) then
            if (target.x == nil) then
                t = target:GetTransform():GetPosition()
            else
                t = target
            end
            choosingTargetParticle:GetComponentParticle():SetColor(255, 0, 255, 255)
            finalPosition = float3.new(t.x, t.y + 1, t.z)
        elseif ((currentState == State.AIM_PRIMARY or currentState == State.AIM_ULTIMATE) and
            (drawingTarget.tag == Tag.ENEMY)) then
            local dist = Distance3D(drawingTarget:GetTransform():GetPosition(), componentTransform:GetPosition())
            if ((currentState == State.AIM_PRIMARY and dist <= primaryCastRange) or
                (currentState == State.AIM_ULTIMATE and dist <= ultimateCastRange)) then
                choosingTargetParticle:GetComponentParticle():SetColor(0, 255, 0, 255)
            else
                choosingTargetParticle:GetComponentParticle():SetColor(255, 0, 0, 255)
            end
            finalPosition = drawingTarget:GetTransform():GetPosition()
            finalPosition.y = finalPosition.y + 1
        elseif (currentState == State.AIM_SECONDARY and drawingTarget.tag == Tag.FLOOR) then
            local mouseClick = GetLastMouseClick()
            if (Distance3D(mouseClick, componentTransform:GetPosition()) <= secondaryCastRange) then
                choosingTargetParticle:GetComponentParticle():SetColor(0, 255, 0, 255)
            else
                choosingTargetParticle:GetComponentParticle():SetColor(255, 0, 0, 255)
            end
            -- This is only 1 instead of mouseClick.y + 1 because if hovering game objects with height like characters, the hovering particle will go up
            finalPosition = float3.new(mouseClick.x, 1, mouseClick.z)
        else
            choosingTargetParticle:GetComponentParticle():StopParticleSpawn()
            do
                return
            end
        end
        choosingTargetParticle:GetComponentParticle():ResumeParticleSpawn()
        choosingTargetParticle:GetTransform():SetPosition(finalPosition)
    end
end

function DrawActiveAbilities()
    if componentLight == nil then
        componentLight = gameObject:GetLight()
    end
    if (componentLight ~= nil) then
        if (IsSelected() == true) then
            if (abilities.AbilityPrimary == AbilityStatus.Active) then
                componentLight:SetRange(primaryCastRange)
                componentLight:SetAngle(360 / 2)
                componentLight:SetDiffuse(0.2)
            elseif (abilities.AbilitySecondary == AbilityStatus.Active) then
                componentLight:SetRange(secondaryCastRange)
                componentLight:SetAngle(360 / 2)
                componentLight:SetDiffuse(0.2)
            elseif (abilities.AbilityUltimate == AbilityStatus.Active) then
                componentLight:SetRange(ultimateCastRange)
                componentLight:SetAngle(360 / 2)
                componentLight:SetDiffuse(0.2)
            else
                componentLight:SetAngle(0)
            end
        else
            componentLight:SetAngle(0)
        end
    end
end

function UpdateStaminaBar()
    local pos = componentTransform:GetPosition()
    if IsSelected() == true then
        local proportion = staminaTimer / staminaSeconds
        local recoveryProportion = staminaTimer / recoveryTime

        staminaBarGreen:GetTransform():SetPosition(float3.new(pos.x, pos.y + 30, pos.z))
        staminaBarYellow:GetTransform():SetPosition(float3.new(pos.x, pos.y + 30, pos.z))
        staminaBarRed:GetTransform():SetPosition(float3.new(pos.x, pos.y + 30, pos.z))
        staminaBarBlue:GetTransform():SetPosition(float3.new(pos.x, pos.y + 30, pos.z))

        -- NEW
        if isTired == false then
            if proportion >= 0.66 then
                staminaBarGreen:GetTransform():SetScale(float3.new(staminaBarSizeX, staminaBarSizeY * (proportion),
                    staminaBarSizeZ))
                staminaBarYellow:GetTransform():SetScale(float3.new(0, 0, 0))
                staminaBarRed:GetTransform():SetScale(float3.new(0, 0, 0))
                staminaBarBlue:GetTransform():SetScale(float3.new(0, 0, 0))
            elseif proportion >= 0.33 and proportion < 0.66 then
                staminaBarGreen:GetTransform():SetScale(float3.new(0, 0, 0))
                staminaBarYellow:GetTransform():SetScale(float3.new(staminaBarSizeX, staminaBarSizeY * (proportion),
                    staminaBarSizeZ))
                staminaBarRed:GetTransform():SetScale(float3.new(0, 0, 0))
                staminaBarBlue:GetTransform():SetScale(float3.new(0, 0, 0))
            else
                staminaBarGreen:GetTransform():SetScale(float3.new(0, 0, 0))
                staminaBarYellow:GetTransform():SetScale(float3.new(0, 0, 0))
                staminaBarRed:GetTransform():SetScale(float3.new(staminaBarSizeX, staminaBarSizeY * (proportion),
                    staminaBarSizeZ))
                staminaBarBlue:GetTransform():SetScale(float3.new(0, 0, 0))
            end
        else
            staminaBarGreen:GetTransform():SetScale(float3.new(0, 0, 0))
            staminaBarYellow:GetTransform():SetScale(float3.new(0, 0, 0))
            staminaBarRed:GetTransform():SetScale(float3.new(0, 0, 0))
            staminaBarBlue:GetTransform():SetScale(float3.new(staminaBarSizeX, staminaBarSizeY * (recoveryProportion),
                staminaBarSizeZ))
        end
    else
        if GetVariable("GameState.lua", "anyCharacterSelected", INSPECTOR_VARIABLE_TYPE.INSPECTOR_BOOL) == false then
            staminaBarGreen:GetTransform():SetPosition(float3.new(pos.x, pos.y - 30, pos.z))
            staminaBarYellow:GetTransform():SetPosition(float3.new(pos.x, pos.y - 30, pos.z))
            staminaBarRed:GetTransform():SetPosition(float3.new(pos.x, pos.y - 30, pos.z))
            staminaBarBlue:GetTransform():SetPosition(float3.new(pos.x, pos.y - 30, pos.z))
        end
    end
end

function ManageTimers(dt)
    local ret = true

    if (isDialogueOpen == true) then
        ret = false
    end
    if (currentMovement == Movement.RUN and
        GetVariable("GameState.lua", "GodMode", INSPECTOR_VARIABLE_TYPE.INSPECTOR_BOOL) == false) then
        staminaTimer = staminaTimer - dt
        if (staminaTimer < 0.0) then
            staminaTimer = 0.0
            isTired = true

            SetMovement(Movement.WALK)
        else
            -- Log("Stamina timer: " .. staminaTimer .. "\n")
        end
    else
        if (currentMovement == Movement.IDLE or currentMovement == Movement.IDLE_CROUCH) then
            staminaTimer = staminaTimer + dt * standingStaminaMultiplier
        else
            staminaTimer = staminaTimer + dt
        end
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
            bloodParticle:GetComponentParticle():StopParticleSpawn()
        end
    end

    -- Basic attack cooldown
    if (attackTimer ~= nil) then
        attackTimer = attackTimer + dt
        if (attackTimer >= attackTime) then
            attackTimer = nil
        end
    end

    -- Secondary ability cooldown
    if (secondaryTimer ~= nil) then
        secondaryTimer = secondaryTimer + dt
        if (secondaryTimer >= secondaryCooldown) then
            Log("Decoy available!\n")
            secondaryTimer = nil
            abilities.AbilitySecondary = AbilityStatus.Normal
            DispatchGlobalEvent("Player_Ability", {characterID, Ability.Secondary, abilities.AbilitySecondary})
        end
    end

    -- Ultimate ability cooldown
    if (ultimateTimer ~= nil) then
        ultimateTimer = ultimateTimer + dt
        if (ultimateTimer >= ultimateCooldown) then
            ultimateTimer = nil
            abilities.AbilityUltimate = AbilityStatus.Normal
            DispatchGlobalEvent("Player_Ability", {characterID, Ability.Ultimate, abilities.AbilityUltimate})

        end
    end

    -- Invisible logic
    if (invisibilityDuration ~= nil) then -- While invis he shouldn't be able to do anything
        invisibilityTimer = invisibilityTimer + dt
        if (invisibilityTimer >= invisibilityDuration) then
            -- Reappear
            invisibilityDuration = nil
            gameObject.active = true
            if (componentRigidBody ~= nil) then
                if (componentBoxCollider ~= nil) then
                    componentBoxCollider:SetTrigger(false)
                    componentBoxCollider:UpdateIsTrigger()
                end

                trackList = {8, 13}
                ChangeTrack(trackList)

                componentRigidBody:SetUseGravity(true)
                componentRigidBody:UpdateEnableGravity()
            end
            if (componentAnimator ~= nil) then
                componentAnimator:SetSelectedClip("UltimateEnd")
            end
        end
        ret = false
    end

    -- Animation timer
    if (componentAnimator ~= nil) then
        if (componentAnimator:IsCurrentClipLooping() == false) then
            if (componentAnimator:IsCurrentClipPlaying() == true) then
                ret = false
            else
                if (currentState == State.ATTACK) then
                    DoAttack()
                elseif (currentState == State.AIM_PRIMARY) then
                    DoPrimary()
                elseif (currentState == State.AIM_SECONDARY) then
                    DoSecondary()
                elseif (currentState == State.AIM_ULTIMATE) then
                    DoUltimate()
                elseif (currentState ~= State.DEAD) then
                    if (currentMovement == Movement.IDLE_CROUCH) then
                        componentAnimator:SetSelectedClip("IdleCrouch")
                    else
                        componentAnimator:SetSelectedClip("Idle")
                    end
                end
            end
        end
    end

    -- If he's dead he can't do anything
    if (currentState == State.DEAD or currentState == State.WORM) then
        ret = false
    end

    return ret
end

feetTimer = 0.0
leftFoot = true
function FootstepMovement()
    if (footstepsParticle ~= nil) then
        if (feetTimer > 0.5) then
            feetTimer = 0.0
            leftFoot = not leftFoot
            footstepsParticle:GetComponentParticle():ResumeParticleSpawn()
        end

        if (leftFoot == true) then
            footstepsParticle:GetTransform():SetPosition(float3.new(componentTransform:GetPosition().x - 2,
                componentTransform:GetPosition().y + 1, componentTransform:GetPosition().z))
        else
            footstepsParticle:GetTransform():SetPosition(float3.new(componentTransform:GetPosition().x + 2,
                componentTransform:GetPosition().y + 1, componentTransform:GetPosition().z))
        end

    end
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

        if (footstepsParticle ~= nil) then
            feetTimer = feetTimer + dt
            FootstepMovement()
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

function StopMovement(resetTarget)

    if (currentMovement == Movement.CROUCH) then
        SetMovement(Movement.IDLE_CROUCH)
    elseif (currentMovement ~= Movement.IDLE_CROUCH) then
        SetMovement(Movement.IDLE)
    end

    destination = nil

    if (resetTarget == nil) then -- Default case
        target = nil
    end
    if (componentRigidBody ~= nil) then
        componentRigidBody:SetLinearVelocity(float3.new(0, 0, 0))
    end
    if (footstepsParticle ~= nil) then
        footstepsParticle:GetComponentParticle():StopParticleSpawn()
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

-- Basic Attack
function Attack()

    SetState(State.ATTACK)

    componentAnimator:SetSelectedClip("Attack")
    impactParticle:GetComponentParticle():SetLoop(true)
    impactParticle:GetTransform():SetPosition(float3.new(target:GetTransform():GetPosition().x,
        target:GetTransform():GetPosition().y + 17, target:GetTransform():GetPosition().z + 5))
    LookAtTarget(target:GetTransform():GetPosition())
end

function DoAttack()

    componentAnimator:SetSelectedClip("AttackToIdle")

    DispatchGlobalEvent("Player_Attack", {target, characterID})
    DispatchGlobalEvent("Auditory_Trigger", {componentTransform:GetPosition(), 100, "single", gameObject})

    LookAtTarget(target:GetTransform():GetPosition())

    trackList = {4, 10}
    ChangeTrack(trackList)

    attackTimer = 0.0

    target = nil
    impactParticle:GetComponentParticle():SetLoop(false)

    SetState(State.IDLE)
end

-- Primary ability
function ActivePrimary()
    if (knifeCount > 0) then
        if (currentState == State.AIM_PRIMARY) then
            CancelAbilities()
        else
            CancelAbilities()
            SetState(State.AIM_PRIMARY)
            abilities.AbilityPrimary = AbilityStatus.Active
            DispatchGlobalEvent("Player_Ability", {characterID, Ability.Primary, abilities.AbilityPrimary})
        end
    end
end

function CastPrimary(position)
    abilities.AbilityPrimary = AbilityStatus.Using
    DispatchGlobalEvent("Player_Ability", {characterID, Ability.Primary, abilities.AbilityPrimary})

    componentAnimator:SetSelectedClip("Knife")
    StopMovement(false)

    LookAtTarget(position)
end

function DoPrimary()
    InstantiatePrefab("Knife")
    knifeCount = knifeCount - 1

    if (knifeCount > 0) then
        -- abilities.AbilityPrimary = AbilityStatus.Normal
        -- DispatchGlobalEvent("Player_Ability", {characterID, Ability.Primary, abilities.AbilityPrimary})
    else
        -- abilities.AbilityPrimary = AbilityStatus.Disabled -- Should be state disabled 
        -- DispatchGlobalEvent("Player_Ability", {characterID, Ability.Primary, abilities.AbilityPrimary})
    end

    trackList = {5, 11}
    ChangeTrack(trackList)

    componentAnimator:SetSelectedClip("KnifeToIdle")
    SetState(State.IDLE)
end

-- Secondary ability
function ActiveSecondary()
    if (decoyCount > 0 and secondaryTimer == nil) then
        if (currentState == State.AIM_SECONDARY) then
            CancelAbilities()
        else
            CancelAbilities()
            SetState(State.AIM_SECONDARY)
            abilities.AbilitySecondary = AbilityStatus.Active
            DispatchGlobalEvent("Player_Ability", {characterID, Ability.Secondary, abilities.AbilitySecondary})
        end
    end
end

function CastSecondary(position)
    abilities.AbilitySecondary = AbilityStatus.Using
    DispatchGlobalEvent("Player_Ability", {characterID, Ability.Secondary, abilities.AbilitySecondary})

    componentAnimator:SetSelectedClip("Decoy")
    StopMovement(false)

    LookAtTarget(position)

end

function DoSecondary()
    InstantiatePrefab("Decoy")

    decoyCount = decoyCount - 1

    trackList = {6}
    ChangeTrack(trackList)

    componentAnimator:SetSelectedClip("DecoyToIdle")
    SetState(State.IDLE)
end

-- Ultimate ability
function ActiveUltimate()
    if (ultimateTimer == nil and
        (GetVariable("GameState.lua", "spiceAmount", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT) >= ultimateSpiceCost or
            GetVariable("GameState.lua", "GodMode", INSPECTOR_VARIABLE_TYPE.INSPECTOR_BOOL) == true)) then
        if (currentState == State.AIM_ULTIMATE) then
            CancelAbilities()
        else
            CancelAbilities()
            SetState(State.AIM_ULTIMATE)
            abilities.AbilityUltimate = AbilityStatus.Active
            DispatchGlobalEvent("Player_Ability", {characterID, Ability.Ultimate, abilities.AbilityUltimate})
        end
    elseif (GetVariable("GameState.lua", "spiceAmount", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT) < ultimateSpiceCost) then
        DispatchGlobalEvent("Not_Enough_Spice", {"tonto"})
    end
end

function CastUltimate(position)
    abilities.AbilityUltimate = AbilityStatus.Using
    DispatchGlobalEvent("Player_Ability", {characterID, Ability.Ultimate, abilities.AbilityUltimate})

    componentAnimator:SetSelectedClip("UltimateStart")
    ultimateTimer = 0.0
    iFramesTimer = 0.0
    StopMovement(false)

    trackList = {7, 12}
    ChangeTrack(trackList)

    LookAtTarget(position)
end

function DoUltimate()
    abilities.AbilityUltimate = AbilityStatus.Cooldown
    DispatchGlobalEvent("Player_Ability", {characterID, Ability.Ultimate, abilities.AbilityUltimate, ultimateCooldown})

    DispatchGlobalEvent("Used_Ultimate", {ultimateSpiceCost})

    if (GetVariable("GameState.lua", "GodMode", INSPECTOR_VARIABLE_TYPE.INSPECTOR_BOOL) == false) then
        -- Subtracts spice cost when using ultimate ability
        OGSpice = GetVariable("GameState.lua", "spiceAmount", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)
        NewSpice = OGSpice - ultimateSpiceCost
        SetVariable(NewSpice, "GameState.lua", "spiceAmount", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)

        str = "Spice Amount " .. NewSpice .. "\n"
        Log(str)
    end

    -- Get all enemies in range of the Mouse
    enemiesInRange = {target}
    enemies = GetObjectsByTag(Tag.ENEMY)
    for i = 1, #enemies do
        if (enemies[i] ~= target and
            Distance3D(enemies[i]:GetTransform():GetPosition(), target:GetTransform():GetPosition()) <=
            ultimateCastRange) and #enemiesInRange < 3 then
            enemiesInRange[#enemiesInRange + 1] = enemies[i]
        end
    end

    -- Check them all for adjacent enemies, different than the ones on the list and add them if there are anyway
    for i = 1, #enemiesInRange do

        for j = 1, #enemies do
            if (enemiesInRange[i] ~= enemies[j] and #enemiesInRange < 3) then
                if (Distance3D(enemiesInRange[i]:GetTransform():GetPosition(), enemies[j]:GetTransform():GetPosition()) <=
                    ultimateCastRangeExtension) then

                    isAlreadyInArray = false
                    for k = 1, #enemiesInRange do
                        if (enemiesInRange[k] == enemies[j]) then
                            isAlreadyInArray = true
                        end
                    end

                    if (not isAlreadyInArray) then
                        enemiesInRange[#enemiesInRange + 1] = enemies[j]
                    end
                end
            end
        end
    end

    deathMarkDuration = 1
    -- Set IN ORDER the death mark
    for i = 1, #enemiesInRange do
        DispatchGlobalEvent("Death_Mark", {enemiesInRange[i], deathMarkDuration})
        deathMarkDuration = deathMarkDuration + 1
    end

    -- final pos = final target pos + Normalized(final target pos - initial pos) * d
    local targetPos2D = {enemiesInRange[#enemiesInRange]:GetTransform():GetPosition().x,
                         enemiesInRange[#enemiesInRange]:GetTransform():GetPosition().z}
    local pos2D = {componentTransform:GetPosition().x, componentTransform:GetPosition().z}
    local d = Distance2D(pos2D, targetPos2D)
    local vec2 = {targetPos2D[1] - pos2D[1], targetPos2D[2] - pos2D[2]}
    vec2 = Normalize(vec2, d)

    trackList = {9, 14}
    ChangeTrack(trackList)

    -- Add as reappear position the position from the last enemy who's gonna die
    local dist = 15
    reappearPosition = float3.new(enemiesInRange[#enemiesInRange]:GetTransform():GetPosition().x + vec2[1] * dist,
        componentTransform:GetPosition().y,
        enemiesInRange[#enemiesInRange]:GetTransform():GetPosition().z + vec2[2] * dist)

    -- Set timer equal to the longest dath mark timer to reappear
    gameObject.active = false
    invisibilityTimer = 0
    invisibilityDuration = deathMarkDuration * 0.3

    if (componentRigidBody ~= nil) then
        if (componentBoxCollider ~= nil) then
            componentBoxCollider:SetTrigger(true)
            componentBoxCollider:UpdateIsTrigger()
        end
        componentRigidBody:SetRigidBodyPos(reappearPosition)
        componentRigidBody:SetUseGravity(false)
        componentRigidBody:UpdateEnableGravity()
    end

    SetState(State.IDLE)
end

function TakeDamage(damage)
    if (iFramesTimer ~= nil or currentHP == 0 or
        GetVariable("GameState.lua", "GodMode", INSPECTOR_VARIABLE_TYPE.INSPECTOR_BOOL) == true) then
        do
            return
        end
    end

    iFramesTimer = 0
    bloodParticle:GetComponentParticle():ResumeParticleSpawn()

    if (damage == nil) then
        damage = 1
    end

    currentHP = currentHP - damage
    if (currentHP > 0) then
        Log("Zhib: Taking " .. damage .. " damage, current HP = " .. currentHP .. "\n")

        DispatchGlobalEvent("Player_Health", {characterID, currentHP, maxHP})

        trackList = {2}
        ChangeTrack(trackList)
    else
        currentHP = 0
        Log("Zhib: Dying\n")
        DispatchGlobalEvent("Player_Health", {characterID, currentHP, maxHP})
        Die()
    end
end

function Die()
    SetState(State.DEAD)
    currentHP = 0

    if (componentAnimator ~= nil) then
        componentAnimator:SetSelectedClip("Death")
    end

    if (currentTrackID ~= 3) then
        trackList = {3}
        ChangeTrack(trackList)
    end

    DispatchGlobalEvent("Player_Death", {characterID})
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
            if (fields[2] == "Harkonnen") then
                TakeDamage(1)
            elseif (fields[2] == "Sardaukar") then
                TakeDamage(2)
            elseif (fields[2] == "Rabban") then
                TakeDamage(666)
            end
        end
    elseif (key == "Active_Primary") then
        if fields[1] == characterID then
            ActivePrimary()
        end
    elseif (key == "Active_Secondary") then
        if fields[1] == characterID then
            ActiveSecondary()
        end
    elseif (key == "Active_Ultimate") then
        if (fields[1] == characterID) then
            ActiveUltimate()
        end
    elseif (key == "Changed_Character") then -- fields[1] -> From ////// fields[2] -> To
        if (fields[1] == characterID) then
            -- If zhib is being changed
            CancelAbilities(true)
        end
        if (fields[2] == characterID) then
            DispatchGlobalEvent("Player_Health", {characterID, currentHP, maxHP})
            -- If game changed to Zhib, update HUD events depending on Abilities
            DispatchGlobalEvent("Player_Ability", {characterID, Ability.Primary, abilities.AbilityPrimary})
            -- Log("Zhib: Primary = " .. abilities.AbilityPrimary .. "\n")
            DispatchGlobalEvent("Player_Ability",
                {characterID, Ability.Secondary, abilities.AbilitySecondary, secondaryTimer})
            -- Log("Zhib: Secondary = " .. abilities.AbilitySecondary .. "\n")
            DispatchGlobalEvent("Player_Ability",
                {characterID, Ability.Ultimate, abilities.AbilityUltimate, ultimateTimer})
            -- Log("Zhib: Ultimate = " .. abilities.AbilityUltimate .. "\n")
        end
    elseif (key == "Knife_Grabbable") then
        abilities.AbilityPrimary = AbilityStatus.Pickable
        DispatchGlobalEvent("Player_Ability", {characterID, Ability.Primary, abilities.AbilityPrimary})
    elseif (key == "Decoy_Grabbable") then
        abilities.AbilitySecondary = AbilityStatus.Pickable
        DispatchGlobalEvent("Player_Ability", {characterID, Ability.Secondary, abilities.AbilitySecondary})
    elseif (key == "Decoy_Grabbed") then
        Log("I have grabbed the decoy! \n")
        trackList = {15}
        ChangeTrack(trackList)
        secondaryTimer = 0.0
        abilities.AbilitySecondary = AbilityStatus.Cooldown
        DispatchGlobalEvent("Player_Ability",
            {characterID, Ability.Secondary, abilities.AbilitySecondary, secondaryCooldown})
        decoyCount = decoyCount + 1
    elseif (key == "Knife_Grabbed") then
        trackList = {15}
        ChangeTrack(trackList)
        Log("I have grabbed a knife! \n")
        abilities.AbilityPrimary = AbilityStatus.Normal
        DispatchGlobalEvent("Player_Ability", {characterID, Ability.Primary, abilities.AbilityPrimary})
        knifeCount = knifeCount + 1
    elseif (key == "Sadiq_Update_Target") then -- fields[1] -> target; targeted for (1 -> warning; 2 -> eat; 3 -> spit)
        if (fields[1] == gameObject) then
            if (fields[2] == 1) then
                SetState(State.WORM)
                if (componentAnimator ~= nil) then
                    componentAnimator:SetSelectedClip("Idle")
                end
            elseif (fields[2] == 2) then
                if (componentRigidBody ~= nil) then
                    componentRigidBody:SetRigidBodyPos(float3.new(componentTransform:GetPosition().x, -50,
                        componentTransform:GetPosition().z))
                end
                gameObject.active = false
                DispatchGlobalEvent("Disable_Character", {characterID})
            end
        elseif (currentState == State.WORM and fields[2] == nil) then

            if (componentRigidBody ~= nil) then
                componentRigidBody:SetRigidBodyPos(fields[1])
            end
            gameObject.active = true
            SetState(State.IDLE)
            DispatchGlobalEvent("Enable_Character", {characterID})
        end
    elseif (key == "Dialogue_Opened") then
        isDialogueOpen = true
        StopMovement()
        SetState(State.IDLE)
        componentAnimator:SetSelectedClip("Idle")
    elseif (key == "Dialogue_Closed") then
        isDialogueOpen = false
    elseif (key == "Spice_Reward") then
        trackList = {15}
        ChangeTrack(trackList)
    elseif (key == "Spit_Heal_Hit") then
        if (fields[1] == gameObject) then
            if (currentHP < maxHP) then
                currentHP = currentHP + fields[2]
                DispatchGlobalEvent("Player_Health", {characterID, currentHP, maxHP})
                Log("Sadiq has healed Zhib. Current HP = " .. currentHP .. "\n")
            else
                Log("Sadiq tried to heal Zhib but he was already full HP\n")
            end
        end
    elseif (key == "Smokebomb_Start") then
        smokebombPosition = fields[1]
        smokebombRadius = fields[2]
    elseif (key == "Smokebomb_End") then
        smokebombPosition = nil
        smokebombRadius = nil
    elseif (key == "Update_Zhib_Position") then
        Log("Receiving Zhib Position \n")
        componentRigidBody:SetRigidBodyPos(float3.new(fields[1], fields[2], fields[3]))
    elseif (key == "Zhib_Primary_Bugged") then
        abilities.AbilityPrimary = AbilityStatus.Normal
        DispatchGlobalEvent("Player_Ability", {characterID, Ability.Primary, abilities.AbilityPrimary})
        knifeCount = knifeCount + 1
        Log("Knife bugged, correction applied.\n")
    elseif (key == "Zhib_Secondary_Bugged") then
        secondaryTimer = nil
        abilities.AbilitySecondary = AbilityStatus.Normal
        DispatchGlobalEvent("Player_Ability", {characterID, Ability.Secondary, abilities.AbilitySecondary})
        decoyCount = decoyCount + 1
        Log("Decoy bugged, correction applied.\n")
    end
end

function ConfigStaminaBars()
    Log("Configuring stamina bars\n")
    staminaBarYellow = Find("Stamina Bar Yellow")
    staminaBarGreen = Find("Stamina Bar Green")
    staminaBarRed = Find("Stamina Bar Red")
    staminaBarBlue = Find("Stamina Bar Blue")

    staminaBarSizeX = staminaBarGreen:GetTransform():GetScale().x
    staminaBarSizeY = staminaBarGreen:GetTransform():GetScale().y
    staminaBarSizeZ = staminaBarGreen:GetTransform():GetScale().z
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
        do
            return
        end
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

function ChangeTrack(_trackList)
    size = 0
    for i in pairs(_trackList) do
        size = size + 1
    end

    index = math.random(size)

    if (componentSwitch ~= nil) then
        if (currentTrackID ~= -1) then
            componentSwitch:StopTrack(currentTrackID)
        end
        currentTrackID = _trackList[index]
        componentSwitch:PlayTrack(currentTrackID)
    end
end

print("Zhib.lua compiled succesfully!\n")
Log("Zhib.lua compiled succesfully!\n")
