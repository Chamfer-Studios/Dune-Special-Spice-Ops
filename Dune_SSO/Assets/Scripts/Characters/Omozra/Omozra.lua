------------------- Player events --------------------
Movement = {
	IDLE = 1,
	WALK = 2,
	RUN = 3,
	CROUCH = 4,
}
Action = {
	IDLE = 1,
	ATTACK = 2,
	AIM_PRIMARY = 3,
	AIM_SECONDARY = 4,
	AIM_ULTIMATE = 5,
}
------------------------------------------------------

------------------- Variables setter --------------------
target = nil
currentMovement = Movement.IDLE
currentAction = Action.IDLE

-- Globals --
characterID = 3
speed = 500.0

-- Primary ability --

-- Secondary ability --
�amCastRange = 30.0
�amCooldown = 10.0
draw�am = false;

-- Ultimate ability --

----------------------------------------------------------

------------------- Inspector setter --------------------
-- Globals --
local characterIDIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
characterIDIV = InspectorVariable.new("characterID", characterIDIVT, characterID)
NewVariable(characterIDIV)

-- Primary ability --

-- Secondary ability --
local speedIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_FLOAT
speedIV = InspectorVariable.new("speed", speedIVT, speed)
NewVariable(speedIV)

local �amCastRangeIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_FLOAT
�amCastRangeIV = InspectorVariable.new("�amCastRange", �amCastRangeIVT, �amCastRange)
NewVariable(�amCastRangeIV)

local �amCooldownIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_FLOAT
�amCooldownIV = InspectorVariable.new("�amCooldown", �amCooldownIVT, �amCooldown)
NewVariable(�amCooldownIV)

local draw�amIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_BOOL
draw�amIV = InspectorVariable.new("draw�am", draw�amIVT, draw�am)
NewVariable(draw�amIV)

-- Ultimate ability --

--------------------------------------------------------

------------------- Animation setter --------------------
componentAnimator = gameObject:GetComponentAnimator()
if (componentAnimator ~= nil) then
	componentAnimator:SetSelectedClip("Idle")
end
animationDuration = 0.8
animationTimer = 0.0
isAttacking = false -- This should go, just here for animations
---------------------------------------------------------

------------------- Audio setter --------------------
componentSwitch = gameObject:GetAudioSwitch()
-----------------------------------------------------

------------------- Physics setter --------------------
componentRigidBody = gameObject:GetRigidBody()
rigidBodyFlag = true
-------------------------------------------------------

------------------- Particles setter --------------------
mouseParticles = Find("Mouse Particles")
if (mouseParticles ~= nil) then
	mouseParticles:GetComponentParticle():StopParticleSpawn()
end
-------------------------------------------------------

------------------- Movement logic --------------------
doubleClickDuration = 0.5
doubleClickTimer = 0.0
isDoubleClicking = false
-------------------------------------------------------

-------------------- Methods ---------------------
function Update(dt)
	-- Set Starting Position
	if (rigidBodyFlag == true) then 
		if (componentRigidBody ~= nil) then
			rigidBodyFlag = false
			componentRigidBody:SetRigidBodyPos(float3.new(componentTransform:GetPosition().x, 10, componentTransform:GetPosition().z))
		end
	end

	-- Animation timer
	if (isAttacking == true and componentAnimator ~= nil) then
		animationTimer = animationTimer + dt
		if (animationTimer >= animationDuration) then
			componentAnimator:SetSelectedClip("Idle")
			isAttacking = false
			animationTimer = 0.0
		end
	end

	-- Running state logic
	if (isDoubleClicking == true) then
		if (doubleClickTimer < doubleClickDuration) then
			doubleClickTimer = doubleClickTimer + dt
		else 
			isDoubleClicking = false
			doubleClickTimer = 0.0
		end
	end

	-- Click particles logic
	if (mouseParticles ~= nil) then
		mouseParticles:GetComponentParticle():StopParticleSpawn()
	end

	-- Actions
	if (destination ~= nil)	then
		--MoveToDestination(dt)
		DispatchEvent("Pathfinder_FollowPath", { speed, dt, false })
		DispatchGlobalEvent("Player_Position", { componentTransform:GetPosition(), gameObject })
	end

	-- Primary ability cooldown

	-- Secondary ability cooldown
	if (�amTimer ~= nil) then
		�amTimer = �amTimer + dt
		if (�amTimer >= �amCooldown) then
			�amTimer = nil
		end
	end

	-- Ultimate ability cooldown

	--Gather Inputs
	if (IsSelected() == true) then 
		-- Left Click
		if (GetInput(1) == KEY_STATE.KEY_DOWN) then
			-- Primary ability (Seeq Sadiq)
			if (currentAction == Action.AIM_PRIMARY) then

			-- Secondary ability (�am �am)
			elseif (currentAction == Action.AIM_SECONDARY) then
				if (�amTimer == nil) then
					target = GetGameObjectHovered()
					if (target.tag == Tag.ENEMY) then
						if (Distance3D(target:GetTransform():GetPosition(), componentTransform:GetPosition()) <= �amCastRange) then
							�am�am()
						else
							print("Out of range (�am �am - Omozra)")
						end
					else
						print("You have to select an enemy first!!! (�am �am - Omozra)")
					end
				else
					print("Ability in cooldown!!! (�am �am - Omozra")
				end
			-- Ultimate ability (Let's go Sadiq)
			elseif (currentAction == Action.AIM_ULTIMATE) then
				
			end
		end
	
		-- Right Click
		if (GetInput(3) == KEY_STATE.KEY_DOWN) then -- Right Click
			goHit = GetGameObjectHovered()
			if (goHit ~= gameObject) then
				destination = GetLastMouseClick()
				if (currentMovement == Movement.WALK and isDoubleClicking == true) then
					currentMovement = Movement.RUN
				else
					currentMovement = Movement.WALK
					isDoubleClicking = true
				end
				if (mouseParticles ~= nil) then
					mouseParticles:GetComponentParticle():ResumeParticleSpawn()
					mouseParticles:GetTransform():SetPosition(destination)
				end
			end
		end
	
		-- H
		if (GetInput(5) == KEY_STATE.KEY_DOWN) then 
			currentAction = Action.IDLE
		end

		-- K
		if (GetInput(6) == KEY_STATE.KEY_DOWN) then 
			currentAction = Action.AIM_PRIMARY
		end	

		-- D
		if (GetInput(12) == KEY_STATE.KEY_DOWN) then 
			currentAction = Action.AIM_SECONDARY
		end	

		-- SPACE
		if (GetInput(4) == KEY_STATE.KEY_DOWN) then 
			currentAction = Action.AIM_ULTIMATE
		end

		-- C -> Toggle crouch
		if (GetInput(9) == KEY_STATE.KEY_DOWN) then 
			if (currentMovement == Movement.CROUCH) then
				currentMovement = Movement.WALK
				if (componentSwitch ~= nil) then
					componentSwitch:StopTrack(2)
					componentSwitch:PlayAudio(1)
				end
			else
				currentMovement = Movement.CROUCH
				if (componentSwitch ~= nil) then
					componentSwitch:StopTrack(1)
					componentSwitch:PlayAudio(2)
				end
			end
		end
	end

	-- Draw primary ability range

	-- Draw secondary ability range
	if (draw�am == true) then

	end

	-- Draw ultimate ability range

end
--------------------------------------------------


----------------- Functions -----------------
function MoveToDestination(dt)
	local targetPos2D = { destination.x, destination.z }
	local pos2D = { componentTransform:GetPosition().x, componentTransform:GetPosition().z }
	local d = Distance2D(pos2D, targetPos2D)
	local vec2 = { targetPos2D[1] - pos2D[1], targetPos2D[2] - pos2D[2] }

	if (d > 5.0) then

		if (currentMovement ~= Movement.IDLE) then
			if (currentMovement == Movement.WALK) then
				if (componentSwitch ~= nil) then
					componentSwitch:PlayTrack(1)
				end
				if (componentAnimator ~= nil) then
					componentAnimator:SetSelectedClip("Walk")
				end
			elseif (currentMovement == Movement.CROUCH) then
				if (componentSwitch ~= nil) then
					componentSwitch:PlayTrack(2)
				end
				if (componentAnimator ~= nil) then
					componentAnimator:SetSelectedClip("Crouch")
				end
			elseif (currentMovement == Movement.RUN) then
				if (componentSwitch ~= nil) then
					componentSwitch:PlayTrack(1)
				end
				if (componentAnimator ~= nil) then
					componentAnimator:SetSelectedClip("Run")
				end
			end
		end
		
		-- Adapt speed
		local s = speed
		if (currentMovement == Movement.CROUCH) then
			s = speed * 0.66
		elseif (currentMovement == Movement.RUN) then
			s = speed * 1.5
		end

		-- Adapt speed on arrive
		if (d < 10) then
			s = s * 0.5
		end

		-- Movement
		vec2 = Normalize(vec2, d)
		if (componentRigidBody ~= nil) then
			componentRigidBody:SetLinearVelocity(float3.new(vec2[1] * s * dt, 0, vec2[2] * s * dt))
		end

		-- Rotation
		local rad = math.acos(vec2[2])
		if (vec2[1] < 0) then
			rad = rad * (-1)
		end
		componentTransform:SetRotation(float3.new(componentTransform:GetRotation().x, componentTransform:GetRotation().y, rad))
	else
		StopMovement()
	end
	-- Add ChangeAnimation() to check the speed of the rigid body
end

function IsSelected()
	
	id = GetVariable("GameState.lua", "characterSelected", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)

	if (id == characterID) then	
		return true
	end

	return false
end

function StopMovement()
	currentMovement = Movement.IDLE -- Stops aimings and all actions

	destination = nil
	if (componentRigidBody ~= nil) then
		componentRigidBody:SetLinearVelocity(float3.new(0,0,0))
	end
	if (componentSwitch ~= nil) then
		componentSwitch:StopTrack(1)
	end
	--if (componentAnimator ~= nil) then
	--	componentAnimator:SetSelectedClip("Idle")
	--end
end

-- Secondary ability
function �am�am()
	-- InstantiatePrefab("Dart") -- This should instance the prefab
	�amTimer = 0.0
	print("�am �am done")
end

--------------------------------------------------

----------------- Collisions -----------------
function OnTriggerEnter(go)

end
--------------------------------------------------

----------------- Math Functions -----------------
function Normalize(vec, distance)
	vec[1] = vec[1] / distance
	vec[2] = vec[2] / distance
	return vec
end

function Distance2D(a, b)
    local dx, dy = a[1] - b[1], a[2] - b[2]
	local sqrt = math.sqrt(dx * dx + dy * dy)
    return sqrt
end

function Distance3D(a, b)
    diff = { x = b.x - a.x, y = b.y - a.y, z = b.z - a.z }
	local sqrt = math.sqrt(diff.x * diff.x + diff.y * diff.y + diff.z * diff.z)
    return sqrt
end
--------------------------------------------------

print("Omozra.lua compiled succesfully")