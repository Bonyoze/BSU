-- team stuff here



-- added this because we have to get color from db but it's saved as hex
--[[

function HexColor(hex, alpha)
    hex = hex:gsub("#","")
    return Color ( tonumber("0x" .. hex:sub(1,2)), tonumber("0x" .. hex:sub(3,4)), tonumber("0x" .. hex:sub(5,6)), alpha or 255 )
end

]]