rightPos = 500
leftPos = 0
isActive = false
masterVolume = 0
isStarting = true

local rightPosIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
rightPosIV = InspectorVariable.new("rightPos", rightPosIVT, rightPos)
NewVariable(rightPosIV)

local leftPosIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
leftPosIV = InspectorVariable.new("leftPos", leftPosIVT, leftPos)
NewVariable(leftPosIV)

-- Called each loop iteration
function Update(dt)
	if (gameObject.active == true) then
		if (isStarting == true) then
			print("here")
			masterVolume = GetAudio().GetListenerVolume()
			print("masterVolume: " .. masterVolume)
			isStarting = false
		end
		mouseX = gameObject:GetButton():GetMouseX()
		mouseX = mouseX * 5.3
		onePart = (rightPos - leftPos) / 4
		if (gameObject:GetButton():IsPressed() == true) then
			isActive = true
		end
		if (GetInput(1) == KEY_STATE.KEY_UP) then
			isActive = false
		end
		if (isActive == true) then
			if (mouseX < leftPos) then
				mouseX = leftPos
				gameObject:GetTransform2D():SetPositionX(mouseX)
			elseif (mouseX >= (leftPos + onePart) and mouseX <= (leftPos + (onePart * 2))) then
				mouseX = leftPos + onePart
				gameObject:GetTransform2D():SetPositionX(mouseX)
			elseif (mouseX >= (leftPos + (onePart * 2)) and (mouseX <= (leftPos + (onePart * 3)))) then
				mouseX = leftPos + (onePart * 2)
				gameObject:GetTransform2D():SetPositionX(mouseX)
			elseif (mouseX >= (leftPos + (onePart * 3)) and (mouseX < rightPos)) then
				mouseX = leftPos + (onePart * 3)
				gameObject:GetTransform2D():SetPositionX(mouseX)
			elseif (mouseX > rightPos) then
				mouseX = rightPos
				gameObject:GetTransform2D():SetPositionX(mouseX)
			end
		end
	end
end

print("UI_MasterAudio.lua compiled succesfully")