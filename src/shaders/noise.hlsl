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
            break;
        default:
            break;
    }

    src.a = saturate(src.a);
    src.rgb = max(src.rgb, 0.0);

    const float4 output = lerp(src, saturate(src), should_clamp);
    return float4(output.rgb * output.a, output.a);
}
