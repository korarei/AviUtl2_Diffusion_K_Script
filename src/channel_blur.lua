--@ChannelBlur

--requires:${PROJECT_REQUIRES_AVIUTL2}
--information:ChannelBlur@${SCRIPT_NAME} v${PROJECT_VERSION} by ${PROJECT_AUTHOR}
--label:${LABEL}
--filter

--group:Blurriness,true
local blurriness_r = 0.0 --track@blurriness_r:Blurriness::R,0,8192,0,0.01,0.00,0.01
local blurriness_g = 0.0 --track@blurriness_g:Blurriness::G,0,8192,0,0.01,0.00,0.01
local blurriness_b = 0.0 --track@blurriness_b:Blurriness::B,0,8192,0,0.01,0.00,0.01
local blurriness_a = 0.0 --track@blurriness_a:Blurriness::A,0,8192,0,0.01,0.00,0.01
--group
local dimensions = 0 --select@dimensions:Dimensions=2,Horizontal=0,Vertical=1,Horizontal and Vertical=2
local should_resize = true --check@should_resize:Resize,true
--[[pixelshader@horizontal:
--#include <channel_blur_h.hlsl>
]]
--[[pixelshader@vertical:
--#include <channel_blur_v.hlsl>
]]

do
    local ceil = math.ceil
    local pixelshader, clearbuffer = obj.pixelshader, obj.clearbuffer
    local w, h = obj.w, obj.h

    if w * h < 1 then
        return
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

        clearbuffer("object", w + 2 * x, h + 2 * y)
        obj.computeshader(
            "map@GaussianBlur@${SCRIPT_NAME}",
            "object",
            "tempbuffer",
            { x, y },
            floor((w + 15) * 0.0625),
            floor((h + 15) * 0.0625)
        )
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
