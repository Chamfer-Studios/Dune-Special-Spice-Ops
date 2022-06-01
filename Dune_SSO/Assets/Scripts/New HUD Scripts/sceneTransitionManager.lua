
local id = -1
local src = " "
local description = " "

local changedCharacter = false

local path = "Assets/Scenes/SceneTransitionUI/sceneTransition.json"

------------ Dialogue Manager ------------
function Start()
    LoadJsonFile(path)
    skillUiArray = {1,2,3}
    id = 0
    UpdateUI()
end

function Update(dt)
    if(Find("Button") == nil) then
        Log("No button")
    end
    
    if(Find("Button"):GetButton():IsHovered()) then
        Log("First One")
        SetDialogValue(1)
    elseif(Find("Button (1)"):GetButton():IsHovered()) then
        SetDialogValue(2)
    elseif(Find("Button (2)"):GetButton():IsHovered()) then
        SetDialogValue(3)
    end

end

function EventHandler(key, fields)
    if (key == "TransitionedFromLastCharacter") then -- fields[1] -> go;
        id = fields[1]
        changedCharacter = true
        UpdateUI()
    end

    if(key == "FirstHovered") then
        SetDialogValue(1)
    elseif(key == "SecondHovered") then
        SetDialogValue(2)
    elseif(key == "ThirdHovered") then
        SetDialogValue(3)
    end
end
------------ END Dialogue Manager ------------

------------ Dialogue ------------

function UpdateUI()
    
    if(changedCharacter == true) then
        if(id == 0)then
            skillUiArray = {1,2,3}
        elseif(id == 1) then
            skillUiArray = {4,5,6}
        elseif(id == 2) then
            skillUiArray = {7,8,9}
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
    
    -- Set Values To The Prefab
    Find("SkillOneUI"):GetImage():SetTexture(src)
    Find("SkillTwoUI"):GetImage():SetTexture(src2)
    Find("SkillThreeUI"):GetImage():SetTexture(src3)

    changedCharacter = false;
end

function SetDialogValue(index)
    -- Get Dialogue Values From JSON
    -- print("setting Values")
    if(index == 1) then
        dialog = GetTransString("description1", skillUiArray[1])
        dialog1 = GetTransString("description2", skillUiArray[1])
        dialog2 = GetTransString("description3", skillUiArray[1])
        dialog3 = GetTransString("description4", skillUiArray[1])
        dialog4 = GetTransString("description5", skillUiArray[1])
        dialog5 = GetTransString("description6", skillUiArray[1])
    elseif(index == 2) then
        dialog = GetTransString("description1", skillUiArray[2])
        dialog1 = GetTransString("description2", skillUiArray[2])
        dialog2 = GetTransString("description3", skillUiArray[2])
        dialog3 = GetTransString("description4", skillUiArray[2])
        dialog4 = GetTransString("description5", skillUiArray[2])
        dialog5 = GetTransString("description6", skillUiArray[2])
    elseif(index == 3) then
        dialog = GetTransString("description1", skillUiArray[3])
        dialog1 = GetTransString("description2", skillUiArray[3])
        dialog2 = GetTransString("description3", skillUiArray[3])
        dialog3 = GetTransString("description4", skillUiArray[3])
        dialog4 = GetTransString("description5", skillUiArray[3])
        dialog5 = GetTransString("description6", skillUiArray[3])
    end
    
     -- Set Values To The Dialogue
     Find("Text"):GetText():SetTextValue(dialog)
     Find("Text (1)"):GetText():SetTextValue(dialog1)
     Find("Text (2)"):GetText():SetTextValue(dialog2)
     Find("Text (3)"):GetText():SetTextValue(dialog3)
     Find("Text (4)"):GetText():SetTextValue(dialog4)
     Find("Text (5)"):GetText():SetTextValue(dialog5)
    

end



------------ END Dialogue ------------
print("Scene Transition Script Load Success")
