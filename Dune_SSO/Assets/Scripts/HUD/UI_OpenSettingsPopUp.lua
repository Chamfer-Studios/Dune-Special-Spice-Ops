name = "Settings Menu"
isStarting = true
popUp = false

local nameIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_STRING
nameIV = InspectorVariable.new("name", nameIVT, name)
NewVariable(nameIV)

-- Called each loop iteration
function UpdateUI(dt)
	if (isStarting == true) then
		child = gameObject:GetParent():GetParent():GetParent():GetChild(name)
		child:Active(false)
		isStarting = false
	end
	if (gameObject:GetButton():IsPressed()) then
		if (popUp == false) then
			popUp = true
			child:Active(true)
			gameObject:GetParent():GetChild("Background"):Active(false)
		end
	end
end

print("UI_OpenSettingsPopUp.lua compiled succesfully")