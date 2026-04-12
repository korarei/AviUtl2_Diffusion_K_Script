--@GaussianBlur

--requires:${PROJECT_REQUIRES_AVIUTL2}
--information:GaussianBlur@${SCRIPT_NAME} v${PROJECT_VERSION} by ${PROJECT_AUTHOR}
--label:${LABEL}
--filter

local blurriness = 0.0 --track@blurriness:Blurriness,0,8192,25,0.01,0.00,0.01
local dimensions = 0 --select@dimensions:Dimensions=2,Horizontal=0,Vertical=1,Horizontal and Vertical=2
local should_resize = true --check@should_resize:Resize,true
--group:Additional Options,false
local _0 = {} --value@_0:PI,{}
--[[computeshader@map:
--#include <map.hlsl>
]]
--[[pixelshader@blur:
--#include <gaussian_blur.hlsl>
]]

do
    local pixelshader, clearbuffer = obj.pixelshader, obj.clearbuffer
    local w, h = obj.w, obj.h

    if w * h < 1 then
        return
    end

    if next(_0) then
        for k, v in pairs(_0) do
            if k == "Blurriness" and type(v) == "number" then
                blurriness = v
            elseif k == "Dimensions" and type(v) == "number" then
                dimensions = v
            elseif k == "Resize" and type(v) == "boolean" then
                should_resize = v
            end
        end
    end

    local sigma = blurriness / 3.0
    local radius = math.ceil(blurriness)
    local params = { sigma, radius, 0.0, 0.0 }

    if radius < 1 then
        return
    end

    if not obj.getinfo("filter") and should_resize and obj.copybuffer("tempbuffer", "object") then
        local floor = math.floor

        local x = dimensions ~= 1 and radius or 0
        local y = dimensions ~= 0 and radius or 0
        local cx, cy = floor((w + 15) * 0.0625), floor((h + 15) * 0.0625)
        w, h = w + 2 * x, h + 2 * y

        clearbuffer("object", w, h)
        obj.computeshader("map", "object", "tempbuffer", { x, y }, cx, cy)
    end

    if dimensions == 0 then
        params[3] = 1.0
        pixelshader("blur", "object", "object", params, "copy", "clamp")
    elseif dimensions == 1 then
        params[4] = 1.0
        pixelshader("blur", "object", "object", params, "copy", "clamp")
    else
        clearbuffer("tempbuffer", w, h)
        params[3] = 1.0
        pixelshader("blur", "tempbuffer", "object", params, "copy", "clamp")
        params[3], params[4] = 0.0, 1.0
        pixelshader("blur", "object", "tempbuffer", params, "copy", "clamp")
    end
end
