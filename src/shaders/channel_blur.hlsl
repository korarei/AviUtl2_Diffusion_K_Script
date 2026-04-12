#include "gaussian.hlsli"
#include "input.hlsli"

Texture2D tex : register(t0);
SamplerState smp : register(s0);
cbuffer params : register(b0) {
    float4 sigma;
    float4 radius;
    float2 texel;
}

static const float eps = 1.0e-4;

float4
blur(PS_Input input) : SV_Target {
    const float4 f = rcp(-2.0 * sigma * sigma);

    float4 color = tex.Sample(smp, input.uv);
    float4 weight = 1.0;

    for (int i = 0; i < 4; ++i) {
        const int r = int(radius[i]);
        for (int j = 1; j <= r; j += 2) {
            const float x = float(j);

            const float w0 = gaussian(x, f[i]);
            const float w1 = gaussian(x + 1.0, f[i]);
            const float w = w0 + w1;

            const float2 offset = mad(w1, rcp(max(w, eps)), x) * texel;
            color[i] += (tex.Sample(smp, input.uv + offset)[i] + tex.Sample(smp, input.uv - offset)[i]) * w;
            weight[i] += w * 2.0;
        }
    }

    return color * rcp(weight);
}
