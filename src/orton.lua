--@Orton

--requires:${PROJECT_REQUIRES_AVIUTL2}
--information:Orton@${SCRIPT_NAME} v${SCRIPT_VERSION} by ${SCRIPT_AUTHOR}
--label:${LABEL}
--filter

local intensity = 100.0 --track@intensity:Intensity,0,100,100,0.01
local blurriness = 0.0 --track@blurriness:Blurriness,0,8192,25,0.01,0.00,0.01
--group:Mask,true
local low = 50.0 --track@low:Low,-1000,1000,50,0.01,0.00,0.05
local high = 100.0 --track@high:High,-1000,1000,100,0.01,0.00,0.05
local softness = 25.0 --track@softness:Softness,0,100,25,0.01
local invert = 0 --check@invert:Invert,0
--group:Compositing,false
local blend_mode = 7 --select@blend_mode:Blend Mode=7,Normal=0,Darken=1,Multiply=2,Color Burn=3,Linear Burn=4,Darker Color=5,Lighten=6,Screen=7,Color Dodge=8,Linear Dodge (Add)=9,Lighter Color=10
local clamp = 0 --check@clamp:Clamp,0
--[[pixelshader@mask:
--#include <mask.hlsl>
]]
--[[pixelshader@blend:
--#include <blend.hlsl>
]]

do
    local max, ceil = math.max, math.ceil
    local clearbuffer, pixelshader = obj.clearbuffer, obj.pixelshader
    local w, h = obj.w, obj.h

    local eps = 1.0e-4

    if w * h < 1 then
        return
    end

    intensity = intensity * 0.01
    low = low * 0.01
    high = high * 0.01
    softness = max(softness * 0.005, 0.001)

    if intensity < eps then
        return
    end

    clearbuffer("tempbuffer", w, h)
    pixelshader("mask", "tempbuffer", "object", { low, high, softness, invert })

    local sigma = blurriness / 3.0
    local radius = ceil(blurriness)

    if radius > 0.5 then
        pixelshader(
            "horizontal@GaussianBlur@${SCRIPT_NAME}",
            "tempbuffer",
            "tempbuffer",
            { 1.0 / w, sigma, radius },
            "copy",
            "clamp"
        )
        pixelshader(
            "vertical@GaussianBlur@${SCRIPT_NAME}",
            "tempbuffer",
            "tempbuffer",
            { 1.0 / h, sigma, radius },
            "copy",
            "clamp"
        )
    end

    pixelshader("blend", "object", { "tempbuffer", "object" }, { intensity, blend_mode, clamp })
end
