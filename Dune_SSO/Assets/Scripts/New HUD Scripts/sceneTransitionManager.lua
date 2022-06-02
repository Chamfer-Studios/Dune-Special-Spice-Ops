
local id = -1
local src = " "
local description = " "
local spice = 0;

local changedCharacter = false

local upgradeButton0 = { state = false, object = Find("Skill 1 - Upgrade 1") }
local upgradeButton1 = { state = false, object = Find("Skill 1 - Upgrade 2") }
local upgradeButton2 = { state = false, object = Find("Skill 1 - Upgrade 3") }
local upgradeButton3 = { state = false, object = Find("Skill 2 - Upgrade 1") }
local upgradeButton4 = { state = false, object = Find("Skill 2 - Upgrade 2") }
local upgradeButton5 = { state = false, object = Find("Skill 2 - Upgrade 3") }
local upgradeButton6 = { state = false, object = Find("Skill 3 - Upgrade 1") }
local upgradeButton7 = { state = false, object = Find("Skill 3 - Upgrade 2") }
local upgradeButton8 = { state = false, object = Find("Skill 3 - Upgrade 3") }
local upgradeButton9 = { state = false, object = Find("Passive - Upgrade 1") }
local upgradeButton10 = { state = false, object = Find("Passive - Upgrade 2") }
local upgradeButton11 = { state = false, object = Find("Passive - Upgrade 3") }



local upgradeArray = {upgradeButton0, upgradeButton1, upgradeButton2, upgradeButton3, 
upgradeButton4, upgradeButton5, upgradeButton6, upgradeButton7, upgradeButton8, 
upgradeButton9, upgradeButton10, upgradeButton11}
local path = "Assets/Scenes/SceneTransitionUI/sceneTransition.json"

------------ Dialogue Manager ------------
function Start()
    SpiceAmountText = Find("SpiceAmount")
    --Log(upgradeButton.object:GetName())
    LoadJsonFile(path)
    skillUiArray = {1,2,3, 101}
    dialogueGo = Find("Dialogue")
    id = 0
    UpdateUI()

    SetSpiceValue()
end

function Update(dt)

    if(Find("Button") == nil) then
        Log("No button")
    end
    
    if(Find("Button"):GetButton():IsIdle() == false and Find("Button"):GetButton():IsPressed() == false) then
        SetDialogValue(1)
    elseif(Find("Button (1)"):GetButton():IsIdle() == false and Find("Button (1)"):GetButton():IsPressed() == false) then
        SetDialogValue(2)
    elseif(Find("Button (2)"):GetButton():IsIdle() == false and Find("Button (2)"):GetButton():IsPressed() == false) then
        SetDialogValue(3)
    elseif(Find("Button (3)"):GetButton():IsIdle() == false and Find("Button (3)"):GetButton():IsPressed() == false) then
        SetDialogValue(4)
    else 
        SetDialogValue(0)
    end



    --for narnia
    if(upgradeArray[1].object:GetButton():IsPressed())then
        
    if(upgradeArray[1].state == false) then
        Log("state 1")
        upgradeArray[1].state = true
        upgradeArray[1].object:GetChildren()[1]:Active(true)
    else
        Log("state 0")
        upgradeArray[1].state = false
        upgradeArray[1].object:GetChildren()[1]:Active(false)
    end

        SpiceCost(20)
        str = "Name of the button" .. upgradeArray[1].object:GetName() .. "\n"
        Log(str)
    elseif(upgradeArray[2].object:GetButton():IsPressed()) then
        if(upgradeArray[2].state == false) then
            Log("state 1")
            upgradeArray[2].state = true
            upgradeArray[2].object:GetChildren()[1]:Active(true)
        else
            Log("state 0")
            upgradeArray[2].state = false
            upgradeArray[2].object:GetChildren()[1]:Active(false)
        end
        
        str = "Name of the button" .. upgradeArray[2].object:GetName() .. "\n"
        Log(str)
    elseif(upgradeArray[3].object:GetButton():IsPressed()) then
        if(upgradeArray[3].state == false) then
            Log("state 1")
            upgradeArray[3].state = true
            upgradeArray[3].object:GetChildren()[1]:Active(true)
        else
            Log("state 0")
            upgradeArray[3].state = false
            upgradeArray[3].object:GetChildren()[1]:Active(false)
        end
    elseif(upgradeArray[4].object:GetButton():IsPressed()) then
        if(upgradeArray[4].state == false) then
            Log("state 1")
            upgradeArray[4].state = true
            upgradeArray[4].object:GetChildren()[1]:Active(true)
        else
            Log("state 0")
            upgradeArray[4].state = false
            upgradeArray[4].object:GetChildren()[1]:Active(false)
        end
    elseif(upgradeArray[5].object:GetButton():IsPressed()) then
        if(upgradeArray[5].state == false) then
            Log("state 1")
            upgradeArray[5].state = true
            upgradeArray[5].object:GetChildren()[1]:Active(true)
        else
            Log("state 0")
            upgradeArray[5].state = false
            upgradeArray[5].object:GetChildren()[1]:Active(false)
        end
    elseif(upgradeArray[6].object:GetButton():IsPressed()) then
        if(upgradeArray[6].state == false) then
            Log("state 1")
            upgradeArray[6].state = true
            upgradeArray[6].object:GetChildren()[1]:Active(true)
        else
            Log("state 0")
            upgradeArray[6].state = false
            upgradeArray[6].object:GetChildren()[1]:Active(false)
        end
    elseif(upgradeArray[7].object:GetButton():IsPressed()) then
        if(upgradeArray[7].state == false) then
            Log("state 1")
            upgradeArray[7].state = true
            upgradeArray[7].object:GetChildren()[1]:Active(true)
        else
            Log("state 0")
            upgradeArray[7].state = false
            upgradeArray[7].object:GetChildren()[1]:Active(false)
        end
    elseif(upgradeArray[8].object:GetButton():IsPressed()) then
        if(upgradeArray[8].state == false) then
            Log("state 1")
            upgradeArray[8].state = true
            upgradeArray[8].object:GetChildren()[1]:Active(true)
        else
            Log("state 0")
            upgradeArray[8].state = false
            upgradeArray[8].object:GetChildren()[1]:Active(false)
        end
    elseif(upgradeArray[9].object:GetButton():IsPressed()) then
        if(upgradeArray[9].state == false) then
            Log("state 1")
            upgradeArray[9].state = true
            upgradeArray[9].object:GetChildren()[1]:Active(true)
        else
            Log("state 0")
            upgradeArray[9].state = false
            upgradeArray[9].object:GetChildren()[1]:Active(false)
        end
    elseif(upgradeArray[10].object:GetButton():IsPressed()) then
        if(upgradeArray[10].state == false) then
            Log("state 1")
            upgradeArray[10].state = true
            upgradeArray[10].object:GetChildren()[1]:Active(true)
        else
            Log("state 0")
            upgradeArray[10].state = false
            upgradeArray[10].object:GetChildren()[1]:Active(false)
        end
    elseif(upgradeArray[11].object:GetButton():IsPressed()) then
        if(upgradeArray[11].state == false) then
            Log("state 1")
            upgradeArray[11].state = true
            upgradeArray[11].object:GetChildren()[1]:Active(true)
        else
            Log("state 0")
            upgradeArray[11].state = false
            upgradeArray[11].object:GetChildren()[1]:Active(false)
        end
    elseif(upgradeArray[12].object:GetButton():IsPressed()) then
        if(upgradeArray[12].state == false) then
            Log("state 1")
            upgradeArray[12].state = true
            upgradeArray[12].object:GetChildren()[1]:Active(true)
        else
            Log("state 0")
            upgradeArray[12].state = false
            upgradeArray[12].object:GetChildren()[1]:Active(false)
        end
    end
    


end

function EventHandler(key, fields)
    if (key == "TransitionedFromLastCharacter") then -- fields[1] -> go;
        id = fields[1]
        changedCharacter = true
        UpdateUI()
    end
end
------------ END Dialogue Manager ------------

------------ Dialogue ------------

function UpdateUI()
    
    if(changedCharacter == true) then
        if(id == 0)then
            skillUiArray = {1,2,3, 101}
        elseif(id == 1) then
            skillUiArray = {4,5,6, 102}
        elseif(id == 2) then
            skillUiArray = {7,8,9, 103}
        end

        SetSkillsValue()
    end
end

function SetSkillsValue()
    -- Get Dialogue Values From JSON
    -- print("setting Values")

    src = GetTransString("src", skillUiArray[1])
    src2 = GetTransString("src", skillUiArray[2])
    src3 = GetTransString("src", skillUiArray[3])
    src4 = GetTransString("src", skillUiArray[4])
    
    -- Set Values To The Prefab
    Find("SkillOneUI"):GetImage():SetTexture(src)
    Find("feedbackOne"):GetImage():SetTexture(src)
    Find("SkillTwoUI"):GetImage():SetTexture(src2)
    Find("feedbackTwo"):GetImage():SetTexture(src2)
    Find("SkillThreeUI"):GetImage():SetTexture(src3)
    Find("feedbackThree"):GetImage():SetTexture(src3)
    Find("PassiveUI"):GetImage():SetTexture(src4)

    changedCharacter = false;
end

function SetDialogValue(index)
    -- Get Dialogue Values From JSON
    -- print("setting Values")
    if(index == 1) then
        dialogueGo:Active(true)
        dialog = GetTransString("description1", skillUiArray[1])
        dialog1 = GetTransString("description2", skillUiArray[1])
        dialog2 = GetTransString("description3", skillUiArray[1])
        dialog3 = GetTransString("description4", skillUiArray[1])
        dialog4 = GetTransString("description5", skillUiArray[1])
        dialog5 = GetTransString("description6", skillUiArray[1])
    elseif(index == 2) then
        dialogueGo:Active(true)
        dialog = GetTransString("description1", skillUiArray[2])
        dialog1 = GetTransString("description2", skillUiArray[2])
        dialog2 = GetTransString("description3", skillUiArray[2])
        dialog3 = GetTransString("description4", skillUiArray[2])
        dialog4 = GetTransString("description5", skillUiArray[2])
        dialog5 = GetTransString("description6", skillUiArray[2])
    elseif(index == 3) then
        dialogueGo:Active(true)
        dialog = GetTransString("description1", skillUiArray[3])
        dialog1 = GetTransString("description2", skillUiArray[3])
        dialog2 = GetTransString("description3", skillUiArray[3])
        dialog3 = GetTransString("description4", skillUiArray[3])
        dialog4 = GetTransString("description5", skillUiArray[3])
        dialog5 = GetTransString("description6", skillUiArray[3])
    elseif(index == 4) then
        dialogueGo:Active(true)
        dialog = GetTransString("description1", skillUiArray[4])
        dialog1 = GetTransString("description2", skillUiArray[4])
        dialog2 = GetTransString("description3", skillUiArray[4])
        dialog3 = GetTransString("description4", skillUiArray[4])
        dialog4 = GetTransString("description5", skillUiArray[4])
        dialog5 = GetTransString("description6", skillUiArray[4])
    else
        dialogueGo:Active(false)
        dialog = " "
        dialog1 = " "
        dialog2 = " "
        dialog3 = " "
        dialog4 = " "
        dialog5 = " "
    end
    
     -- Set Values To The Dialogue
     Find("Text"):GetText():SetTextValue(dialog)
     Find("Text (1)"):GetText():SetTextValue(dialog1)
     Find("Text (2)"):GetText():SetTextValue(dialog2)
     Find("Text (3)"):GetText():SetTextValue(dialog3)
     Find("Text (4)"):GetText():SetTextValue(dialog4)
     Find("Text (5)"):GetText():SetTextValue(dialog5)
    

end

function SetSpiceValue()
    SpiceAmountText:GetText():SetTextValue(GetVariable("UI_GameState.lua", "spice", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT) .. " Spice");
end

function SpiceCost(amount)
    newSpice = GetVariable("UI_GameState.lua", "spice", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT) - amount
    SpiceAmountText:GetText():SetTextValue(newSpice)
    str = "New Spice value" .. newSpice ..  "\n"
    Log(str)
    SetVariable(newSpice, "UI_GameState.lua", "spice", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)
end


------------ END Dialogue ------------
print("Scene Transition Script Load Success")
