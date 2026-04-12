--@Noise

--requires:${PROJECT_REQUIRES_AVIUTL2}
--information:Noise@${SCRIPT_NAME} v${PROJECT_VERSION} by ${PROJECT_AUTHOR}
--label:${LABEL}
--filter

local amount = 0.0 --track@amount:Amount,0,100,0,0.01
local color = 1 --select@color:Color=1,BW=0,RGB=1,RGBA=2
local should_clamp = 1 --check@should_clamp:Clamp,1
--group:Additional Options,false
local seed = 0 --track@seed:Seed,-1000,1000,-1,1
local _0 = {} --value@_0:PI,{}
--[[pixelshader@noise:
--#include <noise.hlsl>
]]

do
    local W, H = obj.w, obj.h

    local eps = 1.0e-4

    if W * H < 1 then
        return
    end

    if next(_0) then
        for k, v in pairs(_0) do
            if k == "Amount" and type(v) == "number" then
                amount = v
            elseif k == "Color" and type(v) == "string" then
                if v == "BW" then
                    color = 0
                elseif v == "RGB" then
                    color = 1
                elseif v == "RGBA" then
                    color = 2
                end
            elseif k == "Clamp" and type(v) == "boolean" then
                should_clamp = v and 1 or 0
            elseif k == "Seed" and type(v) == "number" then
                seed = v
            end
        end
    end

    if amount < eps then
        return
    end

    amount = amount * 0.01
    seed = seed < 0 and -seed or obj.layer + seed

    obj.pixelshader("noise", "object", "object", { seed, W * H, amount, color, should_clamp })
end
