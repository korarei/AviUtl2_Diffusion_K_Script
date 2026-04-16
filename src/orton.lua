--@Orton

--requires:${PROJECT_REQUIRES_AVIUTL2}
--information:Orton@${SCRIPT_NAME} v${PROJECT_VERSION} by ${PROJECT_AUTHOR}
--label:${LABEL}
--filter

local intensity = 100.0 --track@intensity:Intensity,0,100,100,0.01
local blurriness = 0.0 --track@blurriness:Blurriness,0,8192,25,0.01,0.00,0.01
local exposure = 0.0 --track@exposure:Exposure,-10,10,1,0.001
--group:Mask,true
local should_invert = 0 --check@should_invert:Invert,0
--separator:Luminance Mask
local low = 30.0 --track@low:Low,0,1000,30,0.01,0.00,0.01
local high = 100.0 --track@high:High,0,1000,100,0.01,0.00,0.01
local softness = 25.0 --track@softness:Softness,0,100,25,0.01
--separator:Texture Mask
local mask_source = 0 --select@mask_source:Mask::Source,Image=0,Layer=1
local mask_image = "" --file@mask_image:Mask::Image,
local mask_layer = 0 --track@mask_layer:Mask::Layer,-100,100,0,1
--group:Brightness & Contrast,false
local brightness = 0.0 --track@brightness:Brightness,-1000,1000,0,0.01
local contrast = 0.0 --track@contrast:Contrast,-1000,1000,0,0.01
--group:Anisotropy,false
local rotation = 0.0 --track@rotation:Rotation,-3600,3600,0,0.01
--separator:Scale
local scale_x = 100.0 --track@scale_x:Scale::X,0,1000,100,0.01
local scale_y = 100.0 --track@scale_y:Scale::Y,0,1000,100,0.01
--group:Chromatic Aberration,false
local channels = 0 --select@channels:Aberration::Channels,Red & Green=-1,Red & Blue=0,Green & Blue=1
local offset = 0.0 --track@offset:Aberration::Offset,-1000,1000,0,0.01
--separator:LoCA
local should_enable_loca = false --check@should_enable_loca:LoCA::Enable,false
local loca_r = 120.0 --track@loca_r:LoCA::Red,0,1000,120,0.01
local loca_g = 100.0 --track@loca_g:LoCA::Green,0,1000,100,0.01
local loca_b = 80.0 --track@loca_b:LoCA::Blue,0,1000,80,0.01
--separator:LaCA
local should_enable_laca = 0 --check@should_enable_laca:LaCA::Enable,0
local laca_r = 102.0 --track@laca_r:LaCA::Red,0,1000,102,0.01
local laca_g = 100.0 --track@laca_g:LaCA::Green,0,1000,100,0.01
local laca_b = 98.0 --track@laca_b:LaCA::Blue,0,1000,98,0.01
--group:Compositing,false
--#define BLEND_MODE_NORMAL Replace=-1,Normal=0
--#define BLEND_MODE_DARKEN Darken=1,Multiply=2,Color Burn=3,Linear Burn=4,Darker Color=5
--#define BLEND_MODE_LIGHTEN Lighten=6,Screen=7,Color Dodge=8,Linear Dodge (Add)=9,Lighter Color=10
local blend_mode = 7 --select@blend_mode:Blend Mode=7,${BLEND_MODE_NORMAL},${BLEND_MODE_DARKEN},${BLEND_MODE_LIGHTEN}
local alpha_mode = 0 --select@alpha_mode:Alpha Mode,Alpha Blending=0,Alpha Hashed=1
local should_clamp = 0 --check@should_clamp:Clamp,0
local should_isolate_glow = 0 --check@should_isolate_glow:Glow Only,0
--group:Additional Options,false
local gamma = 2.2 --track@gamma:Gamma,0,10,2.2,0.001
local layer_reference = 0 --select@layer_reference:Layer Reference,Absolute=0,Relative=1
local _0 = {} --value@_0:PI,{}
--[[pixelshader@mask:
--#include <orton_mask.hlsl>
]]
--[[pixelshader@rotate:
--#include <rotation.hlsl>
]]
--[[pixelshader@shift:
--#include <chromatic_aberration.hlsl>
]]
--[[pixelshader@blend:
--#include <orton_blend.hlsl>
]]

do
    local max, ceil, abs, cos, sin, rad = math.max, math.ceil, math.abs, math.cos, math.sin, math.rad
    local copybuffer, clearbuffer, pixelshader = obj.copybuffer, obj.clearbuffer, obj.pixelshader
    local W, H, LAYER = obj.w, obj.h, obj.layer

    local eps = 1.0e-4

    if W * H < 1 then
        return
    end

    if next(_0) then
        for k, v in pairs(_0) do
            if k == "Intensity" and type(v) == "number" then
                intensity = v
            elseif k == "Blurriness" and type(v) == "number" then
                blurriness = v
            elseif k == "Exposure" and type(v) == "number" then
                exposure = v
            elseif k == "Invert" and type(v) == "boolean" then
                should_invert = v and 1 or 0
            elseif k == "Low" and type(v) == "number" then
                low = v
            elseif k == "High" and type(v) == "number" then
                high = v
            elseif k == "Softness" and type(v) == "number" then
                softness = v
            elseif k == "Mask::Source" and type(v) == "string" then
                if v == "Image" then
                    mask_source = 0
                elseif v == "Layer" then
                    mask_source = 1
                end
            elseif k == "Mask::Image" and type(v) == "string" then
                mask_image = v
            elseif k == "Mask::Layer" and type(v) == "number" then
                mask_layer = v
            elseif k == "Brightness" and type(v) == "number" then
                brightness = v
            elseif k == "Contrast" and type(v) == "number" then
                contrast = v
            elseif k == "Rotation" and type(v) == "number" then
                rotation = v
            elseif k == "Scale::X" and type(v) == "number" then
                scale_x = v
            elseif k == "Scale::Y" and type(v) == "number" then
                scale_y = v
            elseif k == "Aberration::Channels" and type(v) == "string" then
                if v == "Red & Green" then
                    channels = -1
                elseif v == "Red & Blue" then
                    channels = 0
                elseif v == "Green & Blue" then
                    channels = 1
                end
            elseif k == "Aberration::Offset" and type(v) == "number" then
                offset = v
            elseif k == "LoCA::Enable" and type(v) == "boolean" then
                should_enable_loca = v
            elseif k == "LoCA::Red" and type(v) == "number" then
                loca_r = v
            elseif k == "LoCA::Green" and type(v) == "number" then
                loca_g = v
            elseif k == "LoCA::Blue" and type(v) == "number" then
                loca_b = v
            elseif k == "LaCA::Enable" and type(v) == "boolean" then
                should_enable_laca = v and 1 or 0
            elseif k == "LaCA::Red" and type(v) == "number" then
                laca_r = v
            elseif k == "LaCA::Green" and type(v) == "number" then
                laca_g = v
            elseif k == "LaCA::Blue" and type(v) == "number" then
                laca_b = v
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
                elseif v == "Replace" then
                    blend_mode = -1
                end
            elseif k == "Alpha Mode" and type(v) == "string" then
                if v == "Alpha Blending" then
                    alpha_mode = 0
                elseif v == "Alpha Hashed" then
                    alpha_mode = 1
                end
            elseif k == "Clamp" and type(v) == "boolean" then
                should_clamp = v and 1 or 0
            elseif k == "Glow Only" and type(v) == "boolean" then
                should_isolate_glow = v and 1 or 0
            elseif k == "Gamma" and type(v) == "number" then
                gamma = v
            elseif k == "Layer Reference" and type(v) == "string" then
                if v == "Absolute" then
                    layer_reference = 0
                elseif v == "Relative" then
                    layer_reference = 1
                end
            end
        end
    end

    if intensity < eps then
        return
    end

    local copyxform

    do
        copyxform = function(dst, src)
            dst.ox, dst.oy, dst.oz = src.ox, src.oy, src.oz
            dst.cx, dst.cy, dst.cz = src.cx, src.cy, src.cz
            dst.rx, dst.ry, dst.rz = src.rx, src.ry, src.rz
            dst.sx, dst.sy, dst.sz = src.sx, src.sy, src.sz
            dst.alpha = src.alpha
        end
    end

    intensity = intensity * 0.01

    low = low * 0.01
    high = high * 0.01
    softness = max(softness * 0.005, 0.001)
    mask_layer = max(layer_reference == 0 and mask_layer or mask_layer + LAYER, 0)
    local xform = {}
    local should_load_mask
    if mask_source == 0 then
        should_load_mask = mask_image ~= ""
    else
        should_load_mask = mask_layer > 0 and mask_layer ~= LAYER
    end

    brightness = brightness * 0.01
    contrast = contrast * 0.01

    rotation = rad(rotation)
    scale_x = scale_x * 0.01
    scale_y = scale_y * 0.01

    loca_r = loca_r * 0.01
    loca_g = loca_g * 0.01
    loca_b = loca_b * 0.01
    laca_r = laca_r * 0.01
    laca_g = laca_g * 0.01
    laca_b = laca_b * 0.01

    local blurriness_x, blurriness_y = blurriness * scale_x, blurriness * scale_y
    local sigma_x, sigma_y = blurriness_x / 3.0, blurriness_y / 3.0
    local radius_x, radius_y = ceil(blurriness_x), ceil(blurriness_y)

    local c, s = cos(rotation), sin(rotation)
    local abs_c, abs_s = abs(c), abs(s)
    local bw, bh = ceil(W * abs_c + H * abs_s), ceil(W * abs_s + H * abs_c)
    clearbuffer("tempbuffer", bw, bh)
    pixelshader("rotate", "tempbuffer", "object", { c, s, 0.0, 0.0, -s, c, bw, bh }, "copy", "clamp")

    if should_load_mask then
        copyxform(xform, obj)
        clearbuffer("cache:img", W, H)
        if not copybuffer("cache:img", "object") then
            print("@error", "Failed to copy buffer")
            return
        end

        if mask_source == 0 and not obj.load("image", mask_image) then
            print("@error", "Failed to load mask image")
            return
        elseif not obj.load("layer", mask_layer, true) then
            print("@error", "Failed to load mask layer")
            return
        end
    end

    clearbuffer("cache:mask", bw, bh)
    pixelshader("mask", "cache:mask", { "tempbuffer", "object" }, {
        low,
        high,
        softness,
        should_invert,
        should_load_mask and 1 or 0,
        exposure,
        brightness,
        contrast,
        gamma,
    }, "copy", "clip")

    if should_load_mask then
        copyxform(obj, xform)
        if not copybuffer("object", "cache:img") then
            print("@error", "Failed to copy buffer")
            return
        end
    end

    pixelshader(
        "shift",
        "tempbuffer",
        "cache:mask",
        { laca_r, laca_g, laca_b, should_enable_laca, offset * c / W, offset * s / H, channels },
        "copy",
        "clamp"
    )

    if should_enable_loca then
        local sigma_r = sigma_x * loca_r
        local sigma_g = sigma_x * loca_g
        local sigma_b = sigma_x * loca_b
        local sigma_a = max(sigma_r, sigma_g, sigma_b)
        local radius_r = ceil(sigma_r * 3.0)
        local radius_g = ceil(sigma_g * 3.0)
        local radius_b = ceil(sigma_b * 3.0)
        local radius_a = ceil(sigma_a * 3.0)

        if radius_r + radius_g + radius_b + radius_a > 0 then
            local params = { sigma_r, sigma_g, sigma_b, sigma_a, radius_r, radius_g, radius_b, radius_a, 1.0 / bw, 0.0 }
            pixelshader("blur@ChannelBlur@${SCRIPT_NAME}", "cache:mask", "tempbuffer", params, "copy", "clamp")
        elseif not copybuffer("cache:mask", "tempbuffer") then
            print("@error", "Failed to copy buffer")
            return
        end

        sigma_r = sigma_y * loca_r
        sigma_g = sigma_y * loca_g
        sigma_b = sigma_y * loca_b
        sigma_a = max(sigma_r, sigma_g, sigma_b)
        radius_r = ceil(sigma_r * 3.0)
        radius_g = ceil(sigma_g * 3.0)
        radius_b = ceil(sigma_b * 3.0)
        radius_a = ceil(sigma_a * 3.0)

        if radius_r + radius_g + radius_b + radius_a > 0 then
            local params = { sigma_r, sigma_g, sigma_b, sigma_a, radius_r, radius_g, radius_b, radius_a, 0.0, 1.0 / bh }
            pixelshader("blur@ChannelBlur@${SCRIPT_NAME}", "tempbuffer", "cache:mask", params, "copy", "clamp")
        elseif not copybuffer("tempbuffer", "cache:mask") then
            print("@error", "Failed to copy buffer")
            return
        end
    else
        if radius_x > 0 then
            local params = { sigma_x, radius_x, 1.0 / bw, 0.0 }
            pixelshader("blur@GaussianBlur@${SCRIPT_NAME}", "cache:mask", "tempbuffer", params, "copy", "clamp")
        elseif not copybuffer("cache:mask", "tempbuffer") then
            print("@error", "Failed to copy buffer")
            return
        end

        if radius_y > 0 then
            local params = { sigma_y, radius_y, 0.0, 1.0 / bh }
            pixelshader("blur@GaussianBlur@${SCRIPT_NAME}", "tempbuffer", "cache:mask", params, "copy", "clamp")
        elseif not copybuffer("tempbuffer", "cache:mask") then
            print("@error", "Failed to copy buffer")
            return
        end
    end

    clearbuffer("cache:mask", W, H)
    pixelshader("rotate", "cache:mask", "tempbuffer", { c, -s, 0.0, 0.0, s, c, W, H }, "copy", "clamp")

    pixelshader(
        "blend",
        "object",
        { "cache:mask", "object" },
        { intensity, blend_mode, alpha_mode, gamma, should_clamp, should_isolate_glow, W * H }
    )
end
