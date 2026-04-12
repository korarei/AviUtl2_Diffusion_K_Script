--@Orton

--requires:${PROJECT_REQUIRES_AVIUTL2}
--information:Orton@${SCRIPT_NAME} v${PROJECT_VERSION} by ${PROJECT_AUTHOR}
--label:${LABEL}
--filter

local intensity = 100.0 --track@intensity:Intensity,0,100,100,0.01
local blurriness = 0.0 --track@blurriness:Blurriness,0,8192,25,0.01,0.00,0.01
--group:Mask,true
local low = 50.0 --track@low:Low,-1000,1000,50,0.01,0.00,0.01
local high = 100.0 --track@high:High,-1000,1000,100,0.01,0.00,0.01
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
--group:Additional Options,false
local _0 = {} --value@_0:PI,{}
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

    if next(_0) then
        for k, v in pairs(_0) do
            if k == "Intensity" and type(v) == "number" then
                intensity = v
            elseif k == "Blurriness" and type(v) == "number" then
                blurriness = v
            elseif k == "Low" and type(v) == "number" then
                low = v
            elseif k == "High" and type(v) == "number" then
                high = v
            elseif k == "Softness" and type(v) == "number" then
                softness = v
            elseif k == "Invert" and type(v) == "boolean" then
                should_invert = v and 1 or 0
            elseif k == "Brightness" and type(v) == "number" then
                brightness = v
            elseif k == "Contrast" and type(v) == "number" then
                contrast = v
            elseif k == "Blend Mode" and type(v) == "string" then
                if v == "Normal" then
                    blend_mode = 0
                elseif v == "Darken" then
                    blend_mode = 1
                elseif v == "Multiply" then
                    blend_mode = 2
                elseif v == "Color Burn" then
                    blend_mode = 3
                elseif v == "Linear Burn" then
                    blend_mode = 4
                elseif v == "Darker Color" then
                    blend_mode = 5
                elseif v == "Lighten" then
                    blend_mode = 6
                elseif v == "Screen" then
                    blend_mode = 7
                elseif v == "Color Dodge" then
                    blend_mode = 8
                elseif v == "Linear Dodge (Add)" then
                    blend_mode = 9
                elseif v == "Lighter Color" then
                    blend_mode = 10
                end
            elseif k == "Alpha Mode" and type(v) == "string" then
                if v == "Alpha Blending" then
                    alpha_mode = 0
                elseif v == "Alpha Hashed" then
                    alpha_mode = 1
                end
            elseif k == "Clamp" and type(v) == "boolean" then
                should_clamp = v and 1 or 0
            end
        end
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
