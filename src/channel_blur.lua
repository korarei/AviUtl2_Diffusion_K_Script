--@ChannelBlur

--requires:${PROJECT_REQUIRES_AVIUTL2}
--information:ChannelBlur@${SCRIPT_NAME} v${PROJECT_VERSION} by ${PROJECT_AUTHOR}
--label:${LABEL}
--filter

--group:Blurriness,true
local blurriness_r = 0.0 --track@blurriness_r:Blurriness::Red,0,8192,0,0.01,0.00,0.01
local blurriness_g = 0.0 --track@blurriness_g:Blurriness::Green,0,8192,0,0.01,0.00,0.01
local blurriness_b = 0.0 --track@blurriness_b:Blurriness::Blue,0,8192,0,0.01,0.00,0.01
local blurriness_a = 0.0 --track@blurriness_a:Blurriness::Alpha,0,8192,0,0.01,0.00,0.01
--group
--separator
local dimensions = 0 --select@dimensions:Dimensions=2,Horizontal=0,Vertical=1,Horizontal and Vertical=2
local should_resize = true --check@should_resize:Resize,true
--group:Additional Options,false
local _0 = {} --value@_0:PI,{}
--[[pixelshader@blur:
--#include <channel_blur.hlsl>
]]

do
    local ceil, move = math.ceil, table.move
    local pixelshader, clearbuffer = obj.pixelshader, obj.clearbuffer
    local w, h = obj.w, obj.h

    if w * h < 1 then
        return
    end

    if next(_0) then
        for k, v in pairs(_0) do
            if k == "Blurriness::Red" and type(v) == "number" then
                blurriness_r = v
            elseif k == "Blurriness::Green" and type(v) == "number" then
                blurriness_g = v
            elseif k == "Blurriness::Blue" and type(v) == "number" then
                blurriness_b = v
            elseif k == "Blurriness::Alpha" and type(v) == "number" then
                blurriness_a = v
            elseif k == "Dimensions" and type(v) == "number" then
                dimensions = v
            elseif k == "Resize" and type(v) == "boolean" then
                should_resize = v
            end
        end
    end

    local sigma_r = blurriness_r / 3.0
    local sigma_g = blurriness_g / 3.0
    local sigma_b = blurriness_b / 3.0
    local sigma_a = blurriness_a / 3.0
    local radius_r = ceil(blurriness_r)
    local radius_g = ceil(blurriness_g)
    local radius_b = ceil(blurriness_b)
    local radius_a = ceil(blurriness_a)
    local params = { sigma_r, sigma_g, sigma_b, sigma_a, radius_r, radius_g, radius_b, radius_a }

    if radius_r + radius_g + radius_b + radius_a < 1 then
        return
    end

    if not obj.getinfo("filter") and should_resize and obj.copybuffer("tempbuffer", "object") then
        local floor = math.floor

        local radius = math.max(radius_r, radius_g, radius_b, radius_a)
        local x = dimensions ~= 1 and radius or 0
        local y = dimensions ~= 0 and radius or 0
        local cx, cy = floor((w + 15) * 0.0625), floor((h + 15) * 0.0625)
        w, h = w + 2 * x, h + 2 * y

        clearbuffer("object", w, h)
        obj.computeshader("blit@GaussianBlur@${SCRIPT_NAME}", "object", "tempbuffer", { x, y }, cx, cy)
    end

    if dimensions == 0 then
        move({ 1.0 / w, 0.0 }, 1, 2, 9, params)
        pixelshader("blur", "object", "object", params, "copy", "clamp")
    elseif dimensions == 1 then
        move({ 0.0, 1.0 / h }, 1, 2, 9, params)
        pixelshader("blur", "object", "object", params, "copy", "clamp")
    else
        clearbuffer("tempbuffer", w, h)
        move({ 1.0 / w, 0.0 }, 1, 2, 9, params)
        pixelshader("blur", "tempbuffer", "object", params, "copy", "clamp")
        move({ 0.0, 1.0 / h }, 1, 2, 9, params)
        pixelshader("blur", "object", "tempbuffer", params, "copy", "clamp")
    end
end
