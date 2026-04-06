--@Scatter

--requires:${PROJECT_REQUIRES_AVIUTL2}
--information:Scatter@${SCRIPT_NAME} v${PROJECT_VERSION} by ${PROJECT_AUTHOR}
--label:${LABEL}
--filter

local amount = 0.0 --track@amount:Amount,0,1000,0,0.01
local grain = 2 --select@grain:Grain=2,Horizontal=0,Vertical=1,Both=2
local seed = 0 --track@seed:Seed,-1000,1000,-1,1
--[[pixelshader@scatter:
--#include <scatter.hlsl>
]]

local w, h = obj.w, obj.h
if w * h < 1 then
    return
end

obj.pixelshader(
    "scatter",
    "object",
    "object",
    { grain ~= 1 and 1 or 0, grain ~= 0 and 1 or 0, seed < 0 and -seed or obj.layer + seed, w * h, amount },
    "copy",
    "clip"
)
