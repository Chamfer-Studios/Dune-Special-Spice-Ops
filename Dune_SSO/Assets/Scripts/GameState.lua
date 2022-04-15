------------------- Variables --------------------

characterSelected = -1

-------------------- Methods ---------------------

-- Called each loop iteration
function Update(dt)

-- print(characterSelected)	

	currentState = GetRuntimeState()
	if (currentState == RuntimeState.PLAYING) then
		if (GetInput(21) == KEY_STATE.KEY_DOWN) then
			if (characterSelected == 1) then
				characterSelected = -1
			else
				characterSelected = 1
			end
		elseif (GetInput(22) == KEY_STATE.KEY_DOWN) then
			if (characterSelected == 2) then
				characterSelected = -1
			else
				characterSelected = 2
			end
		elseif (GetInput(23) == KEY_STATE.KEY_DOWN) then
			if (characterSelected == 3) then
				characterSelected = -1
			else
				characterSelected = 3
			end
		elseif (GetInput(24) == KEY_STATE.KEY_DOWN) then
			if (characterSelected == 4) then
				characterSelected = -1
			else
				characterSelected = 4
			end
		end
	else
		characterSelected = -1
	end
end

function PostUpdate(dt)
	--aiming = GetVariable("Zhib.lua", "currentAction", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)
	--if (aiming  ~= 4) then
	--	
	--	if (GetInput(1) == KEY_STATE.KEY_DOWN) then
	--		print("Deselected")
	--		characterSelected = -1
	--	end
	--end
end

--------------------------------------------------

print("GameState.lua compiled succesfully")