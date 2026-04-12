#include "input.hlsli"
#include "hash.hlsli"

Texture2D tex : register(t0);
SamplerState smp : register(s0);
cbuffer params : register(b0) {
    float2 weight;
    float2 seed;
    float sigma;
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
    float2 size;
    tex.GetDimensions(size.x, size.y);

    const float2 offset = box_muller(input.pos.xy) * rcp(size);
    return tex.Sample(smp, mad(weight, offset, input.uv));
}
