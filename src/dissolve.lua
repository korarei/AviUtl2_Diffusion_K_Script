--@Dissolve

--requires:${PROJECT_REQUIRES_AVIUTL2}
--information:Dissolve@${SCRIPT_NAME} v${PROJECT_VERSION} by ${PROJECT_AUTHOR}
--label:${LABEL}
--filter

local mode = 0 --select@mode:Mode,Dissolve=0,Dancing Dissolve=1
--[[pixelshader@dissolve:
--#include <dissolve.hlsl>
]]

do
    local w, h = obj.w, obj.h

    if w * h < 1 then
        return
    end

    obj.pixelshader("dissolve", "object", "object", { w * h, mode == 1 and obj.time * obj.framerate * 100.0 or 0.0 })
end
