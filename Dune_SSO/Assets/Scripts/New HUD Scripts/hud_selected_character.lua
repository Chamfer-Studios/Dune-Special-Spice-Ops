function Update(dt) 
    currentCharacterId = GetVariable("GameState.lua","characterSelected",INSPECTOR_VARIABLE_TYPE.INSPECTOR_INT)
    neralaImage = Find("Nerala Image")
    zhibImage = Find("Zhib Image")
    omozraImage = Find("Omozra Image")
    if currentCharacterId == 1 then --zhib
        zhibImage:GetTransform2D():SetPosition(float2.new(210,158))--center position
        zhibImage:GetTransform2D():SetSize(float2.new(156.25,156.25)) --big size
        neralaImage:GetTransform2D():SetPosition(float2.new(70,120))--left position
        neralaImage:GetTransform2D():SetSize(float2.new(76.25,76.25)) --small size
        omozraImage:GetTransform2D():SetPosition(float2.new(350,120))--right position
        omozraImage:GetTransform2D():SetSize(float2.new(76.25,76.25)) --small size
    elseif currentCharacterId == 2 then --nerala
        neralaImage:GetTransform2D():SetPosition(float2.new(210,158))--center position
        neralaImage:GetTransform2D():SetSize(float2.new(156.25,156.25)) --big size
        omozraImage:GetTransform2D():SetPosition(float2.new(70,120))--left position
        omozraImage:GetTransform2D():SetSize(float2.new(76.25,76.25)) --small size
        zhibImage:GetTransform2D():SetPosition(float2.new(350,120))--right position
        zhibImage:GetTransform2D():SetSize(float2.new(76.25,76.25)) --small size
    elseif currentCharacterId == 3 then --omozra
        omozraImage:GetTransform2D():SetPosition(float2.new(210,158))--center position
        omozraImage:GetTransform2D():SetSize(float2.new(156.25,156.25)) --big size
        zhibImage:GetTransform2D():SetPosition(float2.new(70,120))--left position
        zhibImage:GetTransform2D():SetSize(float2.new(76.25,76.25)) --small size
        neralaImage:GetTransform2D():SetPosition(float2.new(350,120))--right position
        neralaImage:GetTransform2D():SetSize(float2.new(76.25,76.25)) --small size
    end
end
