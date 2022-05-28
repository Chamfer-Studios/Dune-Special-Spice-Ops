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
    hpFill1 = Find("HP Fill 1")
    hpFill2 = Find("HP Fill 2")
    hpFill3 = Find("HP Fill 3")

    zhibTimer2 = nil
    zhibCooldown2 = nil
    zhibTimer3 = nil
    zhibCooldown3 = nil

    neralaTimer1 = nil
    neralaCooldown1 = nil
    neralaTimer3 = nil
    neralaCooldown3 = nil

    omozraTimer2 = nil
    omozraCooldown2 = nil
    omozraTimer3 = nil
    omozraCooldown3 = nil
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
        zhibSkills:SetIsActiveToChildren(zhibSkills:GetChildren(), true) -- deactivate the skill slots to be invisible
        neralaSkills:SetIsActiveToChildren(neralaSkills:GetChildren(), true) -- deactivate the skill slots to be invisible
        omozraSkills:SetIsActiveToChildren(omozraSkills:GetChildren(), true) -- activate the skill slots to be visible
    end

    ManageTimers(dt)
end

function EventHandler(key, fields)

    if key == "Player_Ability" then -- fields[1] -> characterID; fields[2] -> ability n; fields[3] -> ability state
        characterID = fields[1] -- 1: zhib, 2: Nerala, 3: Omozra
        ability = fields[2] -- 0: canceled, 1: Q, 2: W, 3: E
        abilityState = fields[3] -- 1: normal, 2: active, 3: cooldown
        if ability == 1 then
            if abilityState == 1 then
                cooldownMaskQ.active = false
                activeMaskQ.active = false
            elseif abilityState == 2 then
                cooldownMaskQ.active = false
                activeMaskQ.active = true
            elseif abilityState == 3 then
                cooldownMaskQ.active = true
                activeMaskQ.active = false
                -- Manage CDs
                if characterID == 2 then
                    neralaCooldown1 = fields[4]
                    neralaTimer1 = neralaCooldown1
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
                    zhibCooldown2 = fields[4]
                    zhibTimer2 = zhibCooldown2
                elseif characterID == 3 then
                    omozraCooldown2 = fields[4]
                    omozraTimer2 = omozraCooldown2
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
                    zhibCooldown3 = fields[4]
                    zhibTimer3 = zhibCooldown3
                elseif characterID == 2 then
                    neralaCooldown3 = fields[4]
                    neralaTimer3 = neralaCooldown3
                elseif characterID == 3 then
                    omozraCooldown3 = fields[4]
                    omozraTimer3 = omozraCooldown3
                end
            elseif abilityState == 4 then
                -- TODO: State Using. Nerala ult gets using when the mosquito is being used. Omozra ult gets using when the recast is being done
            elseif abilityState == 6 then
                -- State disabled. All 3 ults should be disabled if they don't have enough spice. Currently, event not sent in code
            end
        end
    elseif key == "Player_Health" then
        -- fields[1] = characterID
        -- fields[2] = currentHP
        -- fields[3] = maxHP
        -- Log("Fields "..tostring(fields[1]).."\n")
        -- Log("cID "..tostring(currentCharacterId).."\n")
        if currentCharacterId == fields[1] then
            if fields[2] == 0 then
                hpFill1.active = false
                hpFill2.active = false
                hpFill3.active = false
            elseif fields[2] == 1 then
                hpFill1.active = true
                hpFill2.active = false
                hpFill3.active = false
            elseif fields[2] == 2 then
                hpFill1.active = true
                hpFill2.active = true
                hpFill3.active = false
            elseif fields[2] == 3 then
                hpFill1.active = true
                hpFill2.active = true
                hpFill3.active = true
            end
        end
    end
end

function ManageTimers(dt)

    if (zhibTimer2 ~= nil) then
        zhibTimer2 = zhibTimer2 - dt
        if (zhibTimer2 <= 0) then
            zhibTimerW = nil
        end
        cooldownMaskW:GetTransform2D():SetMask(float2.new(cooldownMaskW:GetTransform2D():GetMask().x,
            zhibTimer2 / zhibCooldown2))
    end
    if (zhibTimer3 ~= nil) then
        zhibTimer3 = zhibTimer3 - dt
        if (zhibTimer3 <= 0) then
            zhibTimer3 = nil
        end
        cooldownMaskE:GetTransform2D():SetMask(float2.new(cooldownMaskE:GetTransform2D():GetMask().x,
            zhibTimer3 / zhibCooldown3))
    end
    if (neralaTimer1 ~= nil) then
        neralaTimer1 = neralaTimer1 - dt
        if (neralaTimer1 <= 0) then
            neralaTimer1 = nil
        end
        cooldownMaskQ:GetTransform2D():SetMask(float2.new(cooldownMaskQ:GetTransform2D():GetMask().x,
            neralaTimer1 / neralaCooldown1))
    end
    if (neralaTimer3 ~= nil) then
        neralaTimer3 = neralaTimer3 - dt
        if (neralaTimer3 <= 0) then
            neralaTimer3 = nil
        end
        cooldownMaskE:GetTransform2D():SetMask(float2.new(cooldownMaskE:GetTransform2D():GetMask().x,
            neralaTimer3 / neralaCooldown3))
    end
    if (omozraTimer2 ~= nil) then
        omozraTimer2 = omozraTimer2 - dt
        if (omozraTimer2 <= 0) then
            omozraTimer2 = nil
        end
        cooldownMaskW:GetTransform2D():SetMask(float2.new(cooldownMaskW:GetTransform2D():GetMask().x,
            omozraTimer2 / omozraCooldown2))
    end
    if (omozraTimer3 ~= nil) then
        omozraTimer3 = omozraTimer3 - dt
        if (omozraTimer3 <= 0) then
            omozraTimer3 = nil
        end
        cooldownMaskE:GetTransform2D():SetMask(float2.new(cooldownMaskE:GetTransform2D():GetMask().x,
            omozraTimer3 / omozraCooldown3))
    end
end

print("UI_AbilitySlot_1.lua compiled succesfully")
