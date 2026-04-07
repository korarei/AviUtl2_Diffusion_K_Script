--@Noise

--requires:${PROJECT_REQUIRES_AVIUTL2}
--information:Noise@${SCRIPT_NAME} v${PROJECT_VERSION} by ${PROJECT_AUTHOR}
--label:${LABEL}
--filter

local amount = 0.0 --track@amount:Amount,0,100,0,0.01
local color = 1 --select@color:Color=1,BW=0,RGB=1,RGBA=2
local seed = 0 --track@seed:Seed,-1000,1000,-1,1
local should_clamp = 1 --check@should_clamp:Clamp,1
--[[pixelshader@noise:
--#include <noise.hlsl>
]]

do
    local w, h = obj.w, obj.h

    if w * h < 1 then
        return
    end

    amount = amount * 0.01

    obj.pixelshader(
        "noise",
        "object",
        "object",
        { seed < 0 and -seed or obj.layer + seed, w * h, amount, color, should_clamp }
    )
end
