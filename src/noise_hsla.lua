--@Noise(HSLA)

--requires:${PROJECT_REQUIRES_AVIUTL2}
--information:Noise(HSLA)${SCRIPT_NAME} v${PROJECT_VERSION} by ${PROJECT_AUTHOR}
--label:${LABEL}
--filter

--group:Amount,true
local amount_h = 0.0 --track@amount_h:Amount::H,0,1000,0,0.01
local amount_s = 0.0 --track@amount_s:Amount::S,0,1000,0,0.01
local amount_l = 0.0 --track@amount_l:Amount::L,0,1000,0,0.01
local amount_a = 0.0 --track@amount_a:Amount::A,0,1000,0,0.01
--group
local seed = 0 --track@seed:Seed,-1000,1000,-1,1
--[[pixelshader@noise_hsla:
--#include <noise_hsla.hlsl>
]]

do
    local w, h = obj.w, obj.h

    if w * h < 1 then
        return
    end

    amount_h = amount_h * 0.01
    amount_s = amount_s * 0.01
    amount_l = amount_l * 0.01
    amount_a = amount_a * 0.01

    obj.pixelshader(
        "noise_hsla",
        "object",
        "object",
        { amount_h, amount_s, amount_l, amount_a, seed < 0 and -seed or obj.layer + seed, w * h }
    )
end
