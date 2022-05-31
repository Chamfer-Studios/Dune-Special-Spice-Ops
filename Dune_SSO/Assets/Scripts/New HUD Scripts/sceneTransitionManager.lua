
local id = -1
local src = " "
local description = " "

local changedCharacter = false

local path = "Assets/Scenes/SceneTransitionUI/sceneTransition.json"

------------ Dialogue Manager ------------
function Start()
    LoadJsonFile(path)
    skillUiArray = {1,2,3}
end

function Update(dt)
    

end

function EventHandler(key, fields)
    if (key == "CharacterChanged") then -- fields[1] -> go;
        id = fields[1]
        changedCharacter = true
        UpdateUI(id)
    end
end
------------ END Dialogue Manager ------------

------------ Dialogue ------------

function UpdateUI(id)
    
    if(changedCharacter == true) then
        if(id == 0)then
            skillUiArray = {1,2,3}
        elseif(id == 1) then
            skillUiArray = {4,5,6}
        elseif(id == 2) then
            skillUiArray = {6,7,8}
        end

        SetSkillsValue()
    end
end

function SetSkillsValue()
    -- Get Dialogue Values From JSON
    -- print("setting Values")


    src = GetDialogueString("src", skillUiArray[1])
    src2 = GetDialogueString("src", skillUiArray[2])
    src3 = GetDialogueString("src", skillUiArray[3])
    

    -- Set Values To The Prefab
    Find("SkillOneUI"):GetImage():SetTexture(src)
    Find("SkillTwoUI"):GetImage():SetTexture(src2)
    Find("SkillThreeUI"):GetImage():SetTexture(src3)

    changedCharacter = false;
end

------------ END Dialogue ------------
print("Scene Transition Script Load Success")
