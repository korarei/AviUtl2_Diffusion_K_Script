--@GaussianBlur

--requires:${PROJECT_REQUIRES_AVIUTL2}
--information:GaussianBlur@${SCRIPT_NAME} v${PROJECT_VERSION} by ${PROJECT_AUTHOR}
--label:${LABEL}
--filter

local blurriness = 0.0 --track@blurriness:Blurriness,0,8192,25,0.01,0.00,0.01
local dimensions = 0 --select@dimensions:Dimensions=2,Horizontal=0,Vertical=1,Horizontal and Vertical=2
local should_resize = true --check@should_resize:Resize,true
--[[computeshader@map:
--#include <map.hlsl>
]]
--[[pixelshader@horizontal:
--#include <gaussian_blur_h.hlsl>
]]
--[[pixelshader@vertical:
--#include <gaussian_blur_v.hlsl>
]]

do
    local pixelshader, clearbuffer = obj.pixelshader, obj.clearbuffer
    local w, h = obj.w, obj.h

    if w * h < 1 then
        return
    end

    local sigma = blurriness / 3.0
    local radius = math.ceil(blurriness)
    local params = { sigma, radius }

    if radius < 1 then
        return
    end

    if not obj.getinfo("filter") and should_resize and obj.copybuffer("tempbuffer", "object") then
        local floor = math.floor

        local x = dimensions ~= 1 and radius or 0
        local y = dimensions ~= 0 and radius or 0

        clearbuffer("object", w + 2 * x, h + 2 * y)
        obj.computeshader("map", "object", "tempbuffer", { x, y }, floor((w + 15) * 0.0625), floor((h + 15) * 0.0625))
    end

    if dimensions == 0 then
        pixelshader("horizontal", "object", "object", params, "copy", "clamp")
    elseif dimensions == 1 then
        pixelshader("vertical", "object", "object", params, "copy", "clamp")
    else
        clearbuffer("tempbuffer", obj.w, obj.h)
        pixelshader("horizontal", "tempbuffer", "object", params, "copy", "clamp")
        pixelshader("vertical", "object", "tempbuffer", params, "copy", "clamp")
    end
end
