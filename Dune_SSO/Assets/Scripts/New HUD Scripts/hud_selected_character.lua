function Update(dt)
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
end

function EventHandler(key, fields)
    if key == "Player_Ability" then -- fields[1] -> characterID; fields[2] -> ability n; fields[3] -> ability state
        characterID = fields[1] -- 1: zhib, 2: Nerala, 3: Omozra
        ability = fields[2] -- 0: canceled, 1: Q, 2: W, 3: E
        abilityState = fields[3] -- 1: normal, 2: active, 3: cooldown
        Log("characterID " .. tostring(fields[1]) .. "\n")
        Log("ability " .. tostring(fields[2]) .. "\n")
        Log("state " .. tostring(fields[3]) .. "\n")
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
            end
        end
    end
end

print("UI_AbilitySlot_1.lua compiled succesfully")
