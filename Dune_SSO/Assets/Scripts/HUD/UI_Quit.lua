-- Called each loop iteration
function Update(dt)
	--if (GetVariable("UI_OpenSkillsPopUp.lua", "popUp", INSPECTOR_VARIABLE_TYPE.INSPECTOR_BOOL) == false) then
		--if (GetVariable("UI_OpenQuestsPopUp.lua", "popUp", INSPECTOR_VARIABLE_TYPE.INSPECTOR_BOOL) == false) then
		if (gameObject.active == true) then
			--print("here")
			if (gameObject:GetButton():IsPressed() == true) then
				--gameObject:OnStoped()
				print("here")
				gameObject:Quit()
			end
		end
	--end
end

print("UI_Quit.lua compiled succesfully")