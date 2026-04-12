--@Orton

--requires:${PROJECT_REQUIRES_AVIUTL2}
--information:Orton@${SCRIPT_NAME} v${PROJECT_VERSION} by ${PROJECT_AUTHOR}
--label:${LABEL}
--filter

local intensity = 100.0 --track@intensity:Intensity,0,100,100,0.01
local blurriness = 0.0 --track@blurriness:Blurriness,0,8192,25,0.01,0.00,0.01
--group:Mask,true
local low = 50.0 --track@low:Low,-1000,1000,50,0.01,0.00,0.05
local high = 100.0 --track@high:High,-1000,1000,100,0.01,0.00,0.05
local softness = 25.0 --track@softness:Softness,0,100,25,0.01
local should_invert = 0 --check@should_invert:Invert,0
--group:Brightness & Contrast,false
local brightness = 0.0 --track@brightness:Brightness,-1000,1000,0,0.01
local contrast = 0.0 --track@contrast:Contrast,-1000,1000,0,0.01
--group:Compositing,false
--#define BLEND_MODE_NORMAL Normal=0
--#define BLEND_MODE_DARKEN Darken=1,Multiply=2,Color Burn=3,Linear Burn=4,Darker Color=5
--#define BLEND_MODE_LIGHTEN Lighten=6,Screen=7,Color Dodge=8,Linear Dodge (Add)=9,Lighter Color=10
local blend_mode = 7 --select@blend_mode:Blend Mode=7,${BLEND_MODE_NORMAL},${BLEND_MODE_DARKEN},${BLEND_MODE_LIGHTEN}
local alpha_mode = 0 --select@alpha_mode:Alpha Mode,Alpha Blending=0,Alpha Hashed=1
local should_clamp = 0 --check@should_clamp:Clamp,0
--[[pixelshader@mask:
--#include <orton_mask.hlsl>
]]
--[[pixelshader@blend:
--#include <orton_blend.hlsl>
]]

do
    local clearbuffer, pixelshader = obj.clearbuffer, obj.pixelshader
    local w, h = obj.w, obj.h

    local eps = 1.0e-4

    if w * h < 1 then
        return
    end

    intensity = intensity * 0.01

    low = low * 0.01
    high = high * 0.01
    softness = math.max(softness * 0.005, 0.001)

    brightness = brightness * 0.01
    contrast = contrast * 0.01

    if intensity < eps then
        return
    end

    clearbuffer("cache:mask", w, h)
    pixelshader("mask", "cache:mask", "object", { low, high, softness, should_invert, brightness, contrast })

    local sigma = blurriness / 3.0
    local radius = math.ceil(blurriness)

    if radius > 0 then
        local params = { sigma, radius, 0.0, 0.0 }

        clearbuffer("tempbuffer", w, h)
        params[3] = 1.0
        pixelshader("blur@GaussianBlur@${SCRIPT_NAME}", "tempbuffer", "cache:mask", params, "copy", "clamp")
        params[3], params[4] = 0.0, 1.0
        pixelshader("blur@GaussianBlur@${SCRIPT_NAME}", "cache:mask", "tempbuffer", params, "copy", "clamp")
    end

    pixelshader(
        "blend",
        "object",
        { "cache:mask", "object" },
        { intensity, blend_mode, alpha_mode, should_clamp, w * h }
    )
end
