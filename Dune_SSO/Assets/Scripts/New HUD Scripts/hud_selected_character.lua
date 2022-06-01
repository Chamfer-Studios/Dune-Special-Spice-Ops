function Start()
    currentCharacterId = GetVariable("GameState.lua", "characterSelected", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)
    neralaImage = Find("Nerala Image")
    zhibImage = Find("Zhib Image")
    omozraImage = Find("Omozra Image")
    zhibSkills = Find("Zhib Skills")
    neralaSkills = Find("Nerala Skills")
    omozraSkills = Find("Omozra Skills")
    cooldownMaskQ = Find("Skill Mask CD Q")
    cooldownMaskW = Find("Skill Mask CD W")
    cooldownMaskE = Find("Skill Mask CD E")
    activeMaskQ = Find("Skill Mask Active Q")
    activeMaskW = Find("Skill Mask Active W")
    activeMaskE = Find("Skill Mask Active E")
    disabledMaskQ = Find("Skill Mask Disabled Q")
    disabledMaskW = Find("Skill Mask Disabled W")
    disabledMaskE = Find("Skill Mask Disabled E")
    hpFill1 = Find("HP Fill 1")
    hpFill2 = Find("HP Fill 2")
    hpFill3 = Find("HP Fill 3")

    zhibTimer2 = nil
    zhibTimer2aux = nil
    zhibCooldown2 = GetVariable("Zhib.lua", "secondaryCooldown", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)
    zhibTimer3 = nil
    zhibTimer3aux = nil
    zhibCooldown3 = GetVariable("Zhib.lua", "ultimateCooldown", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)

    neralaTimer1 = nil
    neralaTimer1aux = nil
    neralaCooldown1 = GetVariable("Nerala.lua", "primaryCooldown", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)
    neralaTimer3 = nil
    neralaTimer3aux = nil
    neralaCooldown3 = GetVariable("Nerala.lua", "ultimateCooldown", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)

    omozraTimer2 = nil
    omozraTimer2aux = nil
    omozraCooldown2 = GetVariable("Omozra.lua", "secondaryCooldown", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)
    omozraTimer3 = nil
    omozraTimer3aux = nil
    omozraCooldown3 = GetVariable("Omozra.lua", "ultimateCooldown", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)

    maskSize = cooldownMaskQ:GetTransform2D():GetMask()
end
function Update(dt)
    currentCharacterId = GetVariable("GameState.lua", "characterSelected", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)

    if currentCharacterId == 1 then -- zhib
        zhibImage:GetTransform2D():SetPosition(float2.new(210, 158)) -- center position
        zhibImage:GetTransform2D():SetSize(float2.new(156.25, 156.25)) -- big size
        neralaImage:GetTransform2D():SetPosition(float2.new(70, 120)) -- left position
        neralaImage:GetTransform2D():SetSize(float2.new(76.25, 76.25)) -- small size
        omozraImage:GetTransform2D():SetPosition(float2.new(350, 120)) -- right position
        omozraImage:GetTransform2D():SetSize(float2.new(76.25, 76.25)) -- small size
        zhibSkills:SetIsActiveToChildren(zhibSkills:GetChildren(), true) -- activate the skill slots to be visible
        neralaSkills:SetIsActiveToChildren(neralaSkills:GetChildren(), false) -- deactivate the skill slots to be invisible
        omozraSkills:SetIsActiveToChildren(omozraSkills:GetChildren(), false) -- deactivate the skill slots to be invisible

    elseif currentCharacterId == 2 then -- nerala
        neralaImage:GetTransform2D():SetPosition(float2.new(210, 158)) -- center position
        neralaImage:GetTransform2D():SetSize(float2.new(156.25, 156.25)) -- big size
        omozraImage:GetTransform2D():SetPosition(float2.new(70, 120)) -- left position
        omozraImage:GetTransform2D():SetSize(float2.new(76.25, 76.25)) -- small size
        zhibImage:GetTransform2D():SetPosition(float2.new(350, 120)) -- right position
        zhibImage:GetTransform2D():SetSize(float2.new(76.25, 76.25)) -- small size
        zhibSkills:SetIsActiveToChildren(zhibSkills:GetChildren(), false) -- deactivate the skill slots to be invisible
        neralaSkills:SetIsActiveToChildren(neralaSkills:GetChildren(), true) -- activate the skill slots to be visible
        omozraSkills:SetIsActiveToChildren(omozraSkills:GetChildren(), false) -- deactivate the skill slots to be invisible
    elseif currentCharacterId == 3 then -- omozra
        omozraImage:GetTransform2D():SetPosition(float2.new(210, 158)) -- center position
        omozraImage:GetTransform2D():SetSize(float2.new(156.25, 156.25)) -- big size
        zhibImage:GetTransform2D():SetPosition(float2.new(70, 120)) -- left position
        zhibImage:GetTransform2D():SetSize(float2.new(76.25, 76.25)) -- small size
        neralaImage:GetTransform2D():SetPosition(float2.new(350, 120)) -- right position
        neralaImage:GetTransform2D():SetSize(float2.new(76.25, 76.25)) -- small size
        zhibSkills:SetIsActiveToChildren(zhibSkills:GetChildren(), false) -- deactivate the skill slots to be invisible
        neralaSkills:SetIsActiveToChildren(neralaSkills:GetChildren(), false) -- deactivate the skill slots to be invisible
        omozraSkills:SetIsActiveToChildren(omozraSkills:GetChildren(), true) -- activate the skill slots to be visible
    end

    ManageTimers(dt)
end

function EventHandler(key, fields)

    if key == "Player_Ability" then -- fields[1] -> characterID; fields[2] -> ability n; fields[3] -> ability state
        characterID = fields[1] -- 1: zhib, 2: Nerala, 3: Omozra
        ability = fields[2] -- 0: canceled, 1: Q, 2: W, 3: E
        abilityState = fields[3] -- 1: normal, 2: active, 3: cooldown, 4: Using, 5: Pickable, 6: Disabled
        HandleMasks()
        HandleCooldowns()
        if ability == 1 then
            if abilityState == 1 then

            elseif abilityState == 2 then

            elseif abilityState == 3 then
                -- Manage CDs
                if characterID == 2 then
                    neralaTimer1 = fields[4]
                    if neralaTimer1aux == nil then
                        neralaTimer1aux = neralaCooldown1
                    end
                end
            elseif abilityState == 4 then
                -- TODO: State Using. Zhib Q gets using when the knife is in the way.
            elseif abilityState == 6 then
                -- TODO: State disabled. Zhib Q gets disabled when count = 0. Omozra Q gets disabled when count = 0.
            end
        elseif ability == 2 then
            if abilityState == 1 then
                cooldownMaskW.active = false
                activeMaskW.active = false
            elseif abilityState == 2 then
                cooldownMaskW.active = false
                activeMaskW.active = true
            elseif abilityState == 3 then
                cooldownMaskW.active = true
                activeMaskW.active = false

                -- Manage CDs
                if characterID == 1 then
                    zhibTimer2 = fields[4]
                    if zhibTimer2aux == nil then
                        zhibTimer2aux = zhibCooldown2
                    end
                elseif characterID == 3 then
                    omozraTimer2 = fields[4]
                    if omozraTimer2aux == nil then
                        omozraTimer2aux = omozraCooldown2
                    end
                end
            elseif abilityState == 4 then
                -- TODO: State Using. Zhib W gets using when the decoy is in the floor.
            elseif abilityState == 6 then
                -- TODO: State disabled. Nerala W gets disabled when count = 0.
            end
        elseif ability == 3 then
            if abilityState == 1 then
                cooldownMaskE.active = false
                activeMaskE.active = false
            elseif abilityState == 2 then
                cooldownMaskE.active = false
                activeMaskE.active = true
            elseif abilityState == 3 then
                cooldownMaskE.active = true
                activeMaskE.active = false

                -- Manage CDs
                if characterID == 1 then
                    zhibTimer3 = fields[4]
                    if zhibTimer3aux == nil then
                        zhibTimer3aux = zhibCooldown3
                    end
                elseif characterID == 2 then
                    neralaTimer3 = fields[4]
                    if neralaTimer3aux == nil then
                        neralaTimer3aux = neralaCooldown3
                    end
                elseif characterID == 3 then
                    omozraTimer3 = fields[4]
                    if omozraTimer3aux == nil then
                        omozraTimer3aux = omozraCooldown3
                    end
                end
            elseif abilityState == 4 then
                -- TODO: State Using. Nerala ult gets using when the mosquito is being used. Omozra ult gets using when the recast is being done
            elseif abilityState == 6 then
                -- State disabled. All 3 ults should be disabled if they don't have enough spice. Currently, event not sent in code
            end
        end
    elseif key == "Player_Health" then -- fields[1] = characterID, fields[2] = currentHP
        ManageHealth(fields[1], fields[2])
    end
end

function HandleMasks()
    if ability == 1 then
        if abilityState == 1 then -- Normal
            activeMaskQ.active = false
            cooldownMaskQ.active = false
            disabledMaskQ.active = false
        elseif abilityState == 2 then -- Active
            activeMaskQ.active = true
            cooldownMaskQ.active = false
            disabledMaskQ.active = false
        elseif abilityState == 3 then -- CD
            activeMaskQ.active = false
            cooldownMaskQ.active = true
            disabledMaskQ.active = false
        elseif abilityState == 4 then -- Using
        elseif abilityState == 5 then -- Pickable
        elseif abilityState == 6 then -- Disabled
            activeMaskQ.active = false
            cooldownMaskQ.active = false
            disabledMaskQ.active = true
        end
    elseif ability == 2 then
        if abilityState == 1 then -- Normal
            activeMaskW.active = false
            cooldownMaskW.active = false
            disabledMaskW.active = false
        elseif abilityState == 2 then -- Active
            activeMaskW.active = true
            cooldownMaskW.active = false
            disabledMaskW.active = false
        elseif abilityState == 3 then -- CD
            activeMaskW.active = false
            cooldownMaskW.active = true
            disabledMaskW.active = false
        elseif abilityState == 4 then -- Using
        elseif abilityState == 5 then -- Pickable
        elseif abilityState == 6 then -- Disabled
            activeMaskW.active = false
            cooldownMaskW.active = false
            disabledMaskW.active = true
        end
    elseif ability == 3 then
        if abilityState == 1 then -- Normal
            activeMaskE.active = false
            cooldownMaskE.active = false
            disabledMaskE.active = false
        elseif abilityState == 2 then -- Active
            activeMaskE.active = true
            cooldownMaskE.active = false
            disabledMaskE.active = false
        elseif abilityState == 3 then -- CD
            activeMaskE.active = false
            cooldownMaskE.active = true
            disabledMaskE.active = false
        elseif abilityState == 4 then -- Using
        elseif abilityState == 5 then -- Pickable
        elseif abilityState == 6 then -- Disabled
            activeMaskE.active = false
            cooldownMaskE.active = false
            disabledMaskE.active = true
        end
    end
end

function HandleCooldowns()

end

function ManageHealth(characterId, HP)
    if currentCharacterId == characterId then
        if HP == 0 then
            hpFill1.active = false
            hpFill2.active = false
            hpFill3.active = false
        elseif HP == 1 then
            hpFill1.active = true
            hpFill2.active = false
            hpFill3.active = false
        elseif HP == 2 then
            hpFill1.active = true
            hpFill2.active = true
            hpFill3.active = false
        elseif HP == 3 then
            hpFill1.active = true
            hpFill2.active = true
            hpFill3.active = true
        end
    end
end

function ManageTimers(dt)

    if (zhibTimer2 ~= nil) then
        zhibTimer2 = zhibTimer2 - dt
        zhibTimer2aux = zhibTimer2aux - dt
        if (zhibTimer2 <= 0) then
            zhibTimerW = nil
            zhibTimer2aux = nil
            cooldownMaskW:GetTransform2D():SetMask(float2.new(maskSize.x, maskSize.y))
        end
        cooldownMaskW:GetTransform2D():SetMask(float2.new(maskSize.x, zhibTimer2aux / zhibCooldown2))
    end
    if (zhibTimer3 ~= nil) then
        zhibTimer3 = zhibTimer3 - dt
        zhibTimer3aux = zhibTimer3aux - dt
        if (zhibTimer3 <= 0) then
            zhibTimer3 = nil
            zhibTimer3aux = nil
            cooldownMaskE:GetTransform2D():SetMask(float2.new(maskSize.x, maskSize.y))
        end
        cooldownMaskE:GetTransform2D():SetMask(float2.new(maskSize.x, zhibTimer3aux / zhibCooldown3))
    end
    if (neralaTimer1 ~= nil) then
        neralaTimer1 = neralaTimer1 - dt
        neralaTimer1aux = neralaTimer1aux - dt
        if (neralaTimer1 <= 0.0) then
            neralaTimer1 = nil
            neralaTimer1aux = nil
            cooldownMaskQ:GetTransform2D():SetMask(float2.new(maskSize.x, maskSize.y))
        else
            cooldownMaskQ:GetTransform2D():SetMask(float2.new(maskSize.x, neralaTimer1aux / neralaCooldown1))
        end

    end
    if (neralaTimer3 ~= nil) then
        neralaTimer3 = neralaTimer3 - dt
        neralaTimer3aux = neralaTimer3aux - dt
        if (neralaTimer3 <= 0) then
            neralaTimer3 = nil
            neralaTimer3aux = nil
            cooldownMaskE:GetTransform2D():SetMask(float2.new(maskSize.x, maskSize.y))
        end
        cooldownMaskE:GetTransform2D():SetMask(float2.new(maskSize.x, neralaTimer3aux / neralaCooldown3))
    end
    if (omozraTimer2 ~= nil) then
        omozraTimer2 = omozraTimer2 - dt
        omozraTimer2aux = omozraTimer2aux - dt
        if (omozraTimer2 <= 0) then
            omozraTimer2 = nil
            omozraTimer2aux = nil
            cooldownMaskW:GetTransform2D():SetMask(float2.new(maskSize.x, maskSize.y))
        end
        cooldownMaskW:GetTransform2D():SetMask(float2.new(maskSize.x, omozraTimer2aux / omozraCooldown2))
    end
    if (omozraTimer3 ~= nil) then
        omozraTimer3 = omozraTimer3 - dt
        omozraTimer3aux = omozraTimer3aux - dt
        if (omozraTimer3 <= 0) then
            omozraTimer3 = nil
            omozraTimer3aux = nil
            cooldownMaskE:GetTransform2D():SetMask(float2.new(maskSize.x, maskSize.y))
        end
        cooldownMaskE:GetTransform2D():SetMask(float2.new(maskSize.x, omozraTimer3aux / omozraCooldown3))
    end
end

print("UI_AbilitySlot_1.lua compiled succesfully")
