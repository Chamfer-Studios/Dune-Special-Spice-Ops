spiceAmount = 0
spiceMaxLvl1 = 10000
function Start()
    spiceAmount = GetVariable("GameState.lua", "spiceAmount", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)
    spiceMaxLvl1 = GetVariable("GameState.lua", "spiceMaxLvl1", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)
    maskValue = spiceAmount/spiceMaxLvl1
    --str = "Mask Value " .. maskValue .. "\n"
    --Log(str)
    gameObject:GetTransform2D():SetMask(float2.new(maskValue,1))
end


function Update(dt)
    
    spiceAmount = GetVariable("GameState.lua", "spiceAmount", INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)
    --str = "Updated Spice Value " .. spiceAmount .. "\n"
    --Log(str)
    if (spiceAmount > spiceMaxLvl1) then
        --fullfil action / level up / or cap
        spiceAmount = spiceMaxLvl1
        maskValue = spiceAmount/spiceMaxLvl1
        gameObject:GetTransform2D():SetMask(float2.new(maskValue,1))
        --Log("Full of spice! \n")
    end
    maskValue = spiceAmount/spiceMaxLvl1
    gameObject:GetTransform2D():SetMask(float2.new(maskValue,1))
end