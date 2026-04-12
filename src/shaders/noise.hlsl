#include "hash.hlsli"

Texture2D tex : register(t0);
cbuffer params : register(b0) {
    float2 seed;
    float amount;
    float color;
    float should_clamp;
}

static const float eps = 1.0e-4;

float4
noise(float4 pos : SV_Position) : SV_Target {
    float4 src = tex.Load(int3(pos.xy, 0));
    src.rgb *= rcp(max(src.a, eps));

    const float4 r = (hash4d(pos.xy, seed) - 0.5) * amount;
    [forcecase]
    switch (int(color)) {
        case 0:
            src.rgb += r.rrr;
            break;
        case 1:
            src.rgb += r.rgb;
            break;
        case 2:
            src += r;
            src.a = saturate(src.a);
            break;
        default:
            break;
    }

    const float4 output = float4(max(src.rgb * src.a, 0.0), src.a);
    return lerp(output, saturate(output), should_clamp);
}
