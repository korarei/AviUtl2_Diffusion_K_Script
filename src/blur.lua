--@GaussianBlur

--requires:${PROJECT_REQUIRES_AVIUTL2}
--information:GaussianBlur@${SCRIPT_NAME} v${SCRIPT_VERSION} by ${SCRIPT_AUTHOR}
--label:${LABEL}
--filter

local blurriness = 0.0 --track@blurriness:Blurriness,0,8192,25,0.01,0.00,0.01
local dimension = 0 --select@dimension:Dimensions=2,Horizontal=0,Vertical=1,Horizontal and Vertical=2
local resize = true --check@resize:Resize,true
--[[computeshader@map:
--#include <map.hlsl>
]]
--[[pixelshader@horizontal:
--#include <blur_h.hlsl>
]]
--[[pixelshader@vertical:
--#include <blur_v.hlsl>
]]

do
    local ceil, floor = math.ceil, math.floor
    local getinfo, copybuffer, clearbuffer = obj.getinfo, obj.copybuffer, obj.clearbuffer
    local pixelshader, computeshader = obj.pixelshader, obj.computeshader
    local w, h = obj.w, obj.h

    if w * h < 1 then
        return
    end

    local sigma = blurriness / 3.0
    local radius = ceil(blurriness)

    if radius < 0.5 then
        return
    end

    if not getinfo("filter") and resize and copybuffer("tempbuffer", "object") then
        local d = 2.0 * radius
        clearbuffer("object", w + d, h + d)
        computeshader(
            "map",
            "object",
            "tempbuffer",
            { radius, radius },
            floor((w + 15) * 0.0625),
            floor((h + 15) * 0.0625)
        )
    end

    if dimension == 0 then
        pixelshader("horizontal", "object", "object", { 1.0 / w, sigma, radius }, "copy", "clamp")
    elseif dimension == 1 then
        pixelshader("vertical", "object", "object", { 1.0 / h, sigma, radius }, "copy", "clamp")
    else
        clearbuffer("tempbuffer", w, h)
        pixelshader("horizontal", "tempbuffer", "object", { 1.0 / w, sigma, radius }, "copy", "clamp")
        pixelshader("vertical", "object", "tempbuffer", { 1.0 / h, sigma, radius }, "copy", "clamp")
    end
end
