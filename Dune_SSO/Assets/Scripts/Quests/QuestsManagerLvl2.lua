function Start()
    terminalCount = 0

    questHolders = {gameObject:GetChild("Quest 1"), gameObject:GetChild("Quest 1.5"), gameObject:GetChild("Quest 2"),
                    gameObject:GetChild("Quest 2.5")}

    local str1 = "Find and turn off the terminals:"
    local str2 = "0/3"
    local str3 = "Go to the throne room and"
    local str4 = "face RABBAN!"
    questHolders[1]:GetText():SetTextValue(str1)
    questHolders[2]:GetText():SetTextValue(str2)
    questHolders[3]:GetText():SetTextValue(str3)
    questHolders[4]:GetText():SetTextValue(str4)
end

function EventHandler(key, fields)
    if key == "Panel_Activated" then
        Log(terminalCount .. "\n")
        terminalCount = terminalCount + 1
        questHolders[2]:GetText():SetTextValue(terminalCount .. "/3")
    end
end

