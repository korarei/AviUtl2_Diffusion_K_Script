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

    float4 weight = 1.0;
    float4 color = tex.Sample(smp, input.uv);
    color.rgb *= rcp(max(color.a, eps));

    for (int i = 0; i < 3; ++i) {
        const int r = int(radius[i]);
        for (int j = 1; j <= r; j += 2) {
            const float x = float(j);

            const float w0 = gaussian(x, f[i]);
            const float w1 = gaussian(x + 1.0, f[i]);
            const float w = w0 + w1;

            const float2 offset = mad(w1, rcp(max(w, eps)), x) * texel;
            const float4 c0 = tex.Sample(smp, input.uv + offset);
            const float4 c1 = tex.Sample(smp, input.uv - offset);
            color[i] += (c0[i] * rcp(max(c0.a, eps)) + c1[i] * rcp(max(c1.a, eps))) * w;
            weight[i] += w * 2.0;
        }
    }

    const int r = int(radius.a);
    for (int k = 1; k <= r; k += 2) {
        const float x = float(k);

        const float w0 = gaussian(x, f.a);
        const float w1 = gaussian(x + 1.0, f.a);
        const float w = w0 + w1;

        const float2 offset = mad(w1, rcp(max(w, eps)), x) * texel;
        color.a += (tex.Sample(smp, input.uv + offset).a + tex.Sample(smp, input.uv - offset).a) * w;
        weight.a += w * 2.0;
    }

    color *= rcp(weight);

    return float4(color.rgb * color.a, color.a);
}
