#include "hash.hlsli"

Texture2D tex : register(t0);
cbuffer params : register(b0) {
    float2 seed;
}

static const float eps = 1.0e-4;

float4
dissolve(float4 pos : SV_Position) : SV_Target {
    const float4 src = tex.Load(int3(pos.xy, 0));
    return float4(src.rgb * rcp(max(src.a, eps)), 1.0) * step(hash(pos.xy, seed) + eps, src.a);
}
