State = {
	EAT = 1,
	AWAIT = 2,
	SPIT = 3,
}

------------------- Variables --------------------

target = nil
currentState = State.EAT

-------------------- Methods ---------------------

function Start()

	target = GetVariable("Omozra.lua", "target", INSPECTOR_VARIABLE_TYPE.INSPECTOR_GAMEOBJECT)
	componentTransform:SetPosition(float3.new(target:GetTransform():GetPosition().x, target:GetTransform():GetPosition().y - 20, target:GetTransform():GetPosition().z))

    particles = gameObject:GetComponentParticle()
    --particles:StopParticleSpawn()

    componentAnimator = gameObject:GetComponentAnimator()
    if (componentAnimator ~= nil) then
		componentAnimator:SetSelectedClip("Eat")
	end
end

-- Called each loop iteration
function Update(dt)
	
	-- Animation timer
	if (componentAnimator ~= nil) then
		if (componentAnimator:IsCurrentClipLooping() == false) then
			if (componentAnimator:IsCurrentClipPlaying() == false) then
                if (currentState == State.EAT) then
                    currentState = State.AWAIT
				elseif (currentState == State.SPIT) then
					DeleteGameObject()
                end
			end
		end
	end
end

-------------------- Events ----------------------
function EventHandler(key, fields)
	
	if (key == "Omozra_Ultimate_Recast") then -- fields[1] -> go;
		
        componentTransform:SetPosition(fields[1])
        currentState = State.SPIT
        componentAnimator:SetSelectedClip("Spit")
    end
end
--------------------------------------------------

print("Worm.lua compiled succesfully")