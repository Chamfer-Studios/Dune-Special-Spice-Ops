knifeHitChance = 100
dartHitChance = 100

function EventHandler(key, fields)
    if key == "Change_State" then -- fields[1] -> oldState; fields[2] -> newState;
        if (fields[1] ~= STATE.DEAD and fields[1] ~= fields[2]) then
            currentState = fields[2]
        end
    elseif key == "Target_Update" then
        target = fields[1] -- fields[1] -> new Target;
    elseif key == "DeathMark_Death" then
        Die()
        if (componentParticle ~= nil) then
            componentParticle:SetLoop(true)
            componentParticle:ResumeParticleSpawn()
        end
    elseif key == "Player_Attack" then
        if (fields[1] == gameObject) then
            Die()
        end
    elseif key == "Sadiq_Update_Target" then -- fields[1] -> target; targeted for (1 -> warning; 2 -> eat; 3 -> spit)
        if (fields[1] == gameObject) then
            if (fields[2] == 2) then
                if (currentState == STATE.DEAD) then
                    DeleteGameObject()
                else
                    Die(false)
                end
            end
        end
    elseif key == "Mosquito_Hit" then
        if (fields[1] == gameObject) then
            Die()
        end
    elseif key == "Knife_Hit" then
        if (fields[1] == gameObject) then
            if (currentState == STATE.UNAWARE or currentState == STATE.AWARE) then
                knifeHitChance =
                    GetVariable("Zhib.lua", "unawareChanceHarkKnife", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)
                math.randomseed(os.time())
                rng = math.random(100)
                if (rng <= knifeHitChance) then
                    Log("Knife's D100 roll has been " .. rng .. " so the UNAWARE enemy is dead! \n")
                    Die()
                else
                    Log("Knife's D100 roll has been " .. rng .. " so the UNAWARE enemy has dodged the knife :( \n")
                    trackList = {1}
                    ChangeTrack(trackList)
                end
            elseif (currentState == STATE.SUS) then
                knifeHitChance = GetVariable("Zhib.lua", "awareChanceHarkKnife", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)
                math.randomseed(os.time())
                rng = math.random(100)
                if (rng <= knifeHitChance) then
                    Log("Knife's D100 roll has been " .. rng .. " so the AWARE enemy is dead! \n")
                    Die()
                else
                    Log("Knife's D100 roll has been " .. rng .. " so the AWARE enemy has dodged the knife :( \n")
                    trackList = {1}
                    ChangeTrack(trackList)
                end
            elseif (currentState == STATE.AGGRO) then
                knifeHitChance = GetVariable("Zhib.lua", "aggroChanceHarkKnife", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)
                math.randomseed(os.time())
                rng = math.random(100)
                if (rng <= knifeHitChance) then
                    Log("Knife's D100 roll has been " .. rng .. " so the AGGRO enemy is dead! \n")
                    Die()
                else
                    Log("Knife's D100 roll has been " .. rng .. " so the AGGRO enemy has dodged the knife :( \n")
                    trackList = {1}
                    ChangeTrack(trackList)
                end
            end
        end
    elseif key == "Dart_Hit" then
        if (fields[1] == gameObject) then
            if (currentState == STATE.UNAWARE or currentState == STATE.AWARE) then
                dartHitChance =
                    GetVariable("Nerala.lua", "unawareChanceHarkDart", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)
                math.randomseed(os.time())
                rng = math.random(100)
                if (rng <= dartHitChance) then
                    Log("Dart's D100 roll has been " .. rng .. " so the UNAWARE enemy is stunned! \n")
                    -- TODO: STUN NOT DIE
                    Die()
                else
                    Log("Dart's D100 roll has been " .. rng .. " so the UNAWARE enemy has dodged the dart :( \n")
                    trackList = {1}
                    ChangeTrack(trackList)
                end
            elseif (currentState == STATE.SUS) then
                dartHitChance = GetVariable("Nerala.lua", "awareChanceHarkDart", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)
                math.randomseed(os.time())
                rng = math.random(100)
                if (rng <= dartHitChance) then
                    Log("Dart's D100 roll has been " .. rng .. " so the AWARE enemy is stunned! \n")
                    -- TODO: STUN NOT DIE
                    Die()
                else
                    Log("Dart's D100 roll has been " .. rng .. " so the AWARE enemy has dodged the dart :( \n")
                    trackList = {1}
                    ChangeTrack(trackList)
                end
            elseif (currentState == STATE.AGGRO) then
                dartHitChance = GetVariable("Nerala.lua", "aggroChanceHarkDart", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)
                math.randomseed(os.time())
                rng = math.random(100)
                if (rng <= dartHitChance) then
                    Log("Dart's D100 roll has been " .. rng .. " so the AGGRO enemy is stunned! \n")
                    -- TODO: STUN NOT DIE
                    Die()
                else
                    Log("Dart's D100 roll has been " .. rng .. " so the AGGRO enemy has dodged the dart :( \n")
                    trackList = {1}
                    ChangeTrack(trackList)
                end
            end
        end
    end
end

function Die(leaveBody)
    if (leaveBody == nil) then
        leaveBody = true
        if(currentTrackID ~= 2) then
            trackList = {2}
            ChangeTrack(trackList)
        end
    elseif (leaveBody == false) then
        -- Chance to spawn, if spawn dispatch event
            math.randomseed(os.time())
            rng = math.random(100)
            if (rng >= 101) then
                InstantiatePrefab("SpiceLoot")
                str = "Harkonnen"
                DispatchGlobalEvent("Spice_Spawn", {componentTransform:GetPosition(), str})
                Log("Enemy has dropped a spice loot :) " .. rng .. "\n")
            else
                Log("The drop rate has not been good :( " .. rng .. "\n")
            end
            if(currentTrackID ~= 2) then
                trackList = {2}
                ChangeTrack(trackList)
            end
    end

    gameObject.tag = Tag.CORPSE
    DispatchEvent("Die", {leaveBody})
    currentState = STATE.DEAD
    if (componentAnimator ~= nil) then
        componentAnimator:SetSelectedClip("Death")
    end
    if (componentBoxCollider ~= nil) then
        gameObject:DeleteComponent(componentBoxCollider)
        componentBoxCollider = nil
    end
    if (componentLight ~= nil) then
        gameObject:DeleteComponent(componentLight)
        componentLight = nil
    end
end