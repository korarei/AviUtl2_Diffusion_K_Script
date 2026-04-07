--@Scatter

--requires:${PROJECT_REQUIRES_AVIUTL2}
--information:Scatter@${SCRIPT_NAME} v${PROJECT_VERSION} by ${PROJECT_AUTHOR}
--label:${LABEL}
--filter

local amount = 0.0 --track@amount:Amount,0,1000,0,0.01
local grain = 2 --select@grain:Grain=2,Horizontal=0,Vertical=1,Both=2
local seed = 0 --track@seed:Seed,-1000,1000,-1,1
local should_resize = true --check@should_resize:Resize,true
--[[pixelshader@scatter:
--#include <scatter.hlsl>
]]

do
    local w, h = obj.w, obj.h

    if w * h < 1 then
        return
    end

    local sigma = amount * 0.05

    if not obj.getinfo("filter") and should_resize and obj.copybuffer("tempbuffer", "object") then
        local floor = math.floor

        local d = math.ceil(sigma * 3.0)
        local x = grain ~= 1 and d or 0
        local y = grain ~= 0 and d or 0

        obj.clearbuffer("object", w + 2 * x, h + 2 * y)
        obj.computeshader(
            "map@GaussianBlur@${SCRIPT_NAME}",
            "object",
            "tempbuffer",
            { x, y },
            floor((w + 15) * 0.0625),
            floor((h + 15) * 0.0625)
        )
    end

    obj.pixelshader(
        "scatter",
        "object",
        "object",
        { grain ~= 1 and 1 or 0, grain ~= 0 and 1 or 0, seed < 0 and -seed or obj.layer + seed, obj.w * obj.h, sigma },
        "copy",
        "clip"
    )
end
