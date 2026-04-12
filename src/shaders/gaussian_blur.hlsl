#include "gaussian.hlsli"
#include "input.hlsli"

Texture2D tex : register(t0);
SamplerState smp : register(s0);
cbuffer params : register(b0) {
    float sigma;
    float radius;
    float2 axis;
}

static const float eps = 1.0e-4;

float4
blur(PS_Input input) : SV_Target {
    float2 size;
    tex.GetDimensions(size.x, size.y);

    const int r = int(radius);
    const float2 texel = rcp(size) * axis;
    const float f = rcp(-2.0 * sigma * sigma);

    float4 color = tex.Sample(smp, input.uv);
    float weight = 1.0;

    for (int i = 1; i <= r; i += 2) {
        const float x = float(i);

        const float w0 = gaussian(x, f);
        const float w1 = gaussian(x + 1.0, f);
        const float w = w0 + w1;

        const float2 offset = mad(w1, rcp(max(w, eps)), x) * texel;
        color += (tex.Sample(smp, input.uv + offset) + tex.Sample(smp, input.uv - offset)) * w;
        weight += w * 2.0;
    }

    return color * rcp(weight);
}
