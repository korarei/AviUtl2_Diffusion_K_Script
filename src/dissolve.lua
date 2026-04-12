--@Dissolve

--requires:${PROJECT_REQUIRES_AVIUTL2}
--information:Dissolve@${SCRIPT_NAME} v${PROJECT_VERSION} by ${PROJECT_AUTHOR}
--label:${LABEL}
--filter

local mode = 0 --select@mode:Mode,Dissolve=0,Dancing Dissolve=1
--group:Additional Options,false
local _0 = {} --value@_0:PI,{}
--[[pixelshader@dissolve:
--#include <dissolve.hlsl>
]]

do
    local w, h = obj.w, obj.h

    if w * h < 1 then
        return
    end

    if next(_0) then
        for k, v in pairs(_0) do
            if k == "Mode" and type(v) == "string" then
                if v == "Dissolve" then
                    mode = 0
                elseif v == "Dancing Dissolve" then
                    mode = 1
                end
            end
        end
    end

    obj.pixelshader("dissolve", "object", "object", { w * h, mode == 1 and obj.time * obj.framerate * 100.0 or 0.0 })
end
