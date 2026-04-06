Texture2D tex : register(t0);
SamplerState smp : register(s0);
cbuffer params : register(b0) {
    float4 sigma;
    float4 radius;
}

static const float4 fac = rcp(-2.0 * sigma * sigma);

struct PS_Input {
    float4 pos : SV_Position;
    float2 uv : TEXCOORD;
};

// 後で合計値除算をするため係数は省略
inline float
gaussian(float x, int i) {
    return exp(x * x * fac[i]);
}

float4
vertical(PS_Input input) : SV_Target {
    float2 size;
    tex.GetDimensions(size.x, size.y);

    const float texel = rcp(size.y);
    const int4 count = int4(radius);

    float4 color = tex.Sample(smp, input.uv);
    float4 weight = 1.0;

    for (int i = 0; i < 4; ++i) {
        const int c = count[i];
        for (int j = 1; j <= c; j += 2) {
            const float x = float(j);

            const float w0 = gaussian(x, i);
            const float w1 = gaussian(x + 1.0, i);
            const float w = w0 + w1;

            const float2 offset = float2(0.0, mad(w1, rcp(w), x) * texel);
            color[i] += (tex.Sample(smp, input.uv + offset)[i] + tex.Sample(smp, input.uv - offset)[i]) * w;
            weight[i] += w * 2.0;
        }
    }

    return color * rcp(weight);
}
