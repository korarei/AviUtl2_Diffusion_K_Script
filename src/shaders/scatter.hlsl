#include "input.hlsli"
#include "hash.hlsli"

Texture2D tex : register(t0);
SamplerState smp : register(s0);
cbuffer params : register(b0) {
    float2 sigma;
    float2 seed;
}

static const float eps = 1.0e-4;

float2
box_muller(float2 p) {
    const float4 h = hash4d(p, seed);
    const float r = sqrt(-2.0 * log(max(h.x, eps)));
    const float t = 6.28318530718 * h.y;
    return r * float2(cos(t), sin(t)) * sigma;
}

float4
scatter(PS_Input input) : SV_Target {
    return tex.Sample(smp, input.uv + box_muller(input.pos.xy));
}
