#include "input.hlsli"

Texture2D tex : register(t0);
SamplerState smp : register(s0);
cbuffer params : register(b0) {
    float4 scale;
    float2 offset;
    float channels;
}

static const float eps = 1.0e-4;

float4
shift(PS_Input input) : SV_Target {
    const float2 k = float2(-0.5 * channels, mad(1.5, channels * channels, -1.0));

    const float2 offset_r = offset * (k.x + k.y);
    const float2 offset_g = offset * channels;
    const float2 offset_b = offset * (k.x - k.y);

    const float2 ra = tex.Sample(smp, mad(input.uv - 0.5, lerp(1.0, rcp(scale.r), scale.a), 0.5) + offset_r).ra;
    const float2 ga = tex.Sample(smp, mad(input.uv - 0.5, lerp(1.0, rcp(scale.g), scale.a), 0.5) + offset_g).ga;
    const float2 ba = tex.Sample(smp, mad(input.uv - 0.5, lerp(1.0, rcp(scale.b), scale.a), 0.5) + offset_b).ba;

    return float4(ra.x, ga.x, ba.x, min(ga.y, min(ra.y, ba.y)));
}
