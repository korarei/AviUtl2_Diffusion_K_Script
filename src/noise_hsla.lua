--@Noise(HSLA)

--requires:${PROJECT_REQUIRES_AVIUTL2}
--information:Noise(HSLA)${SCRIPT_NAME} v${PROJECT_VERSION} by ${PROJECT_AUTHOR}
--label:${LABEL}
--filter

--group:Amount,true
local amount_h = 0.0 --track@amount_h:Amount::Hue,0,1000,0,0.01
local amount_s = 0.0 --track@amount_s:Amount::Saturation,0,1000,0,0.01
local amount_l = 0.0 --track@amount_l:Amount::Lightness,0,1000,0,0.01
local amount_a = 0.0 --track@amount_a:Amount::Alpha,0,1000,0,0.01
--group:Additional Options,false
local seed = 0 --track@seed:Seed,-1000,1000,-1,1
local _0 = {} --value@_0:PI,{}
--[[pixelshader@noise_hsla:
--#include <noise_hsla.hlsl>
]]

do
    local w, h = obj.w, obj.h

    if w * h < 1 then
        return
    end

    if next(_0) then
        for k, v in pairs(_0) do
            if k == "Amount::Hue" and type(v) == "number" then
                amount_h = v
            elseif k == "Amount::Saturation" and type(v) == "number" then
                amount_s = v
            elseif k == "Amount::Lightness" and type(v) == "number" then
                amount_l = v
            elseif k == "Amount::Alpha" and type(v) == "number" then
                amount_a = v
            elseif k == "Seed" and type(v) == "number" then
                seed = v
            end
        end
    end

    amount_h = amount_h * 0.01
    amount_s = amount_s * 0.01
    amount_l = amount_l * 0.01
    amount_a = amount_a * 0.01
    seed = seed < 0 and -seed or obj.layer + seed

    obj.pixelshader("noise_hsla", "object", "object", { amount_h, amount_s, amount_l, amount_a, seed, w * h })
end
