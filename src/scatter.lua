--@Scatter

--requires:${PROJECT_REQUIRES_AVIUTL2}
--information:Scatter@${SCRIPT_NAME} v${PROJECT_VERSION} by ${PROJECT_AUTHOR}
--label:${LABEL}
--filter

local amount = 0.0 --track@amount:Amount,0,1000,0,0.01
local grain = 2 --select@grain:Grain=2,Horizontal=0,Vertical=1,Both=2
local should_resize = true --check@should_resize:Resize,true
--group:Additional Options,false
local seed = 0 --track@seed:Seed,-1000,1000,-1,1
local _0 = {} --value@_0:PI,{}
--[[pixelshader@scatter:
--#include <scatter.hlsl>
]]

do
    local w, h = obj.w, obj.h

    local eps = 1.0e-4

    if w * h < 1 then
        return
    end

    if next(_0) then
        for k, v in pairs(_0) do
            if k == "Amount" and type(v) == "number" then
                amount = v
            elseif k == "Grain" and type(v) == "string" then
                if v == "Horizontal" then
                    grain = 0
                elseif v == "Vertical" then
                    grain = 1
                elseif v == "Both" then
                    grain = 2
                end
            elseif k == "Resize" and type(v) == "boolean" then
                should_resize = v
            elseif k == "Seed" and type(v) == "number" then
                seed = v
            end
        end
    end

    if amount < eps then
        return
    end

    seed = seed < 0 and -seed or obj.layer + seed

    local sigma = amount * 0.05
    local sigma_x = grain ~= 1 and sigma / w or 0.0
    local sigma_y = grain ~= 0 and sigma / h or 0.0

    if not obj.getinfo("filter") and should_resize and obj.copybuffer("tempbuffer", "object") then
        local floor = math.floor

        local d = math.ceil(sigma * 3.0)
        local x = grain ~= 1 and d or 0
        local y = grain ~= 0 and d or 0
        local cx, cy = floor((w + 15) * 0.0625), floor((h + 15) * 0.0625)
        w, h = w + 2 * x, h + 2 * y

        obj.clearbuffer("object", w, h)
        obj.computeshader("blit@GaussianBlur@${SCRIPT_NAME}", "object", "tempbuffer", { x, y }, cx, cy)
    end

    obj.pixelshader("scatter", "object", "object", { sigma_x, sigma_y, seed, w * h }, "copy", "clip")
end
