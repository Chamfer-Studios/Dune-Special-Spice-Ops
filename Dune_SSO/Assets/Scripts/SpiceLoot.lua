------------------- Variables setter --------------------
spiceLoot = 100
---------------------------------------------------------

------------------- Inspector setter --------------------
spiceLootIVT = INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT
spiceLootIV = InspectorVariable.new("spiceLoot", spiceLootIVT, spiceLoot)
NewVariable(spiceLootIV)
---------------------------------------------------------

----------------------- Methods -------------------------
function Start()
    boxCollider = gameObject:GetBoxCollider()
	componentRigidBody = gameObject:GetRigidBody()


end

---------------------------------------------------------

function Update(dt)

end

-------------------- Events -----------------------------
function EventHandler(key, fields)
    if key == "Spice_Drop" then --fields[1] = enemyGameObject fields[2] = enemyType string
        enemyType = fields[2]
        --enemyGo = fields[1]
        
        if (enemyType == "Harkonnen") then
            math.randomseed()
            rng = math.random(40,80)
            Log("Harkonnen reward with rng = " .. rng .. "\n")
        elseif (enemyType == "Sardaukar") then
            math.randomseed()
            rng = math.random(80,160)
            Log("Sardaukar reward with rng = " .. rng .. "\n")
        elseif (enemyType == "Mentat") then
            math.randomseed()
            rng = math.random(100,200)
            Log("Mentat reward with rng = " .. rng .. "\n")
        else
            Log("There has been an error selecting enemy type :( \n")
        end
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

print("SpiceLoot.lua compiled succesfully")
Log("SpiceLoot.lua compiled succesfully\n")