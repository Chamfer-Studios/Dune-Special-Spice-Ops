------------------- Variables setter --------------------
spiceLoot = 1000
---------------------------------------------------------

----------------------- Methods -------------------------
function Start()
    boxCollider = gameObject:GetBoxCollider()
	componentRigidBody = gameObject:GetRigidBody()


end

---------------------------------------------------------

-------------------- Events -----------------------------
function EventHandler(key, fields)
    if key == "Spice_Drop" then --fields[1] = enemyType and fields[2] = enemyGameObject
        
    end
end
---------------------------------------------------------

------------------ Collisions ---------------------------
function OnTriggerEnter(go)
    if go.tag == Tag.PLAYER then
        DeleteGameObject()
        DispatchGlobalEvent("Spice_Reward", {spiceLoot})
    end
end
---------------------------------------------------------

print("SpiceSpot.lua compiled succesfully")