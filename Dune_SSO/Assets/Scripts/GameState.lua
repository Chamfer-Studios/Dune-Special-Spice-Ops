------------------- Variables --------------------
characterSelected = 1
spiceAmount = 1000
particleActive = false
gameOverTime = 5

nerala_primary_level = 0
nerala_secondary_level = 0
nerala_ultimate_level = 0

zhib_primary_level = 0
zhib_secondary_level = 0
zhib_ultimate_level = 0

omozra_primary_level = 0
omozra_secondary_level = 0
omozra_ultimate_level = 0

-------------------- Methods ---------------------
function Start()
    characters = {Find("Zhib"), Find("Nerala"), Find("Omozra")}
    characterSelectedParticle = Find("Selected Character")
    staminaBar = Find("Stamina Bar")

    LoadGameState()
    spiceAmount = GetGameJsonInt("spice")

    nerala_primary_level = GetGameJsonInt("nerala_primary_level")
    nerala_secondary_level = GetGameJsonInt("nerala_secondary_level")
    nerala_ultimate_level = GetGameJsonInt("nerala_ultimate_level")

    zhib_primary_level = GetGameJsonInt("zhib_primary_level")
    zhib_secondary_level = GetGameJsonInt("zhib_secondary_level")
    zhib_ultimate_level = GetGameJsonInt("zhib_ultimate_level")

    omozra_primary_level = GetGameJsonInt("omozra_primary_level")
    omozra_secondary_level = GetGameJsonInt("omozra_secondary_level")
    omozra_ultimate_level = GetGameJsonInt("omozra_ultimate_level")

    str = "Spice Amount " .. spiceAmount .. "\n"
    Log(str)
end

-- Called each loop iteration
function Update(dt)
    if (gameOverTimer ~= nil) then
        if (gameOverTimer < gameOverTime) then
            gameOverTimer = gameOverTimer + dt
        else
            SetGameJsonInt("spice", spiceAmount)

            SetGameJsonInt("nerala_primary_level", nerala_primary_level)
            SetGameJsonInt("nerala_secondary_level", nerala_secondary_level)
            SetGameJsonInt("nerala_ultimate_level", nerala_ultimate_level)
    
            SetGameJsonInt("zhib_primary_level", zhib_primary_level)
            SetGameJsonInt("zhib_secondary_level", zhib_secondary_level)
            SetGameJsonInt("zhib_ultimate_level", zhib_ultimate_level)
    
            SetGameJsonInt("omozra_primary_level", omozra_primary_level)
            SetGameJsonInt("omozra_secondary_level", omozra_secondary_level)
            SetGameJsonInt("omozra_ultimate_level", omozra_ultimate_level)
    
            SaveGameState()

            gameObject:ChangeScene(true, "SceneGameOver")
        end
    end

    currentState = GetRuntimeState()
    if (currentState == RuntimeState.PLAYING) then
        if (GetInput(1) == KEY_STATE.KEY_DOWN and omozraUltimate == false) then
            local goHovered = GetGameObjectHovered()
            if (goHovered.tag == Tag.PLAYER) then
                if (goHovered:GetName() == "Zhib") then
                    characterSelected = 1
                elseif (goHovered:GetName() == "Nerala") then
                    characterSelected = 2
                elseif (goHovered:GetName() == "Omozra") then
                    characterSelected = 3
                end
            end
            -- Z
        elseif (GetInput(6) == KEY_STATE.KEY_DOWN) then
            if (characterSelected == 1) then
                characterSelected = 0
            else
                characterSelected = 1
            end
            -- X
        elseif (GetInput(8) == KEY_STATE.KEY_DOWN) then
            if (characterSelected == 2) then
                characterSelected = 0
            else
                characterSelected = 2
            end
            -- C
        elseif (GetInput(9) == KEY_STATE.KEY_DOWN) then
            if (characterSelected == 3) then
                characterSelected = 0
            else
                characterSelected = 3
            end
        end
        if (characterSelected ~= 0) then
            playerPos = characters[characterSelected]:GetTransform():GetPosition()
            staminaBar:GetTransform():SetPosition(float3.new(playerPos.x, playerPos.y + 30, playerPos.z))
            if (characterSelectedParticle ~= nil) then
                characterSelectedParticle:GetTransform():SetPosition(
                    float3.new(playerPos.x, playerPos.y + 1, playerPos.z))
                if (particleActive == false) then
                    particleActive = true
                    characterSelectedParticle:GetComponentParticle():ResumeParticleSpawn()
                    characterSelectedParticle:GetComponentParticle():SetLoop(true)
                end
            end
        else
            staminaBar:GetTransform():SetPosition(float3.new(staminaBar:GetTransform():GetPosition().x, -20,
                staminaBar:GetTransform():GetPosition().z))
            characterSelectedParticle:GetTransform():SetPosition(float3.new(
                characterSelectedParticle:GetTransform():GetPosition().x, -20,
                characterSelectedParticle:GetTransform():GetPosition().z))
        end
    else
        characterSelected = 0
    end
    omozraUltimate = false
end

function EventHandler(key, fields)
    if key == "Character_Selected" then -- fields[1] -> characterSelected;
        characterSelected = fields[1]
        -- characterSelected = 1
    elseif (key == "Spice_Reward") then
        spiceAmount = spiceAmount + fields[1]
        str = "Spice Amount " .. spiceAmount .. "\n"
        Log(str)
    elseif (key == "Spice_Spawn") then
        deadEnemyPos = fields[1]
        deadEnemyType = fields[2]
    elseif (key == "Spice_Has_Spawned") then
        DispatchGlobalEvent("Spice_Drop", {deadEnemyPos.x, deadEnemyPos.y, deadEnemyPos.z, deadEnemyType})
    elseif (key == "Omozra_Ultimate") then
        omozraUltimate = true
    elseif (key == "Player_Death") then
        if (gameOverTimer == nil) then
            gameOverTimer = 0
        end
    end
end
--------------------------------------------------

print("GameState.lua compiled succesfully")
