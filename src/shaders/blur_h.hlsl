Texture2D tex : register(t0);
SamplerState smp : register(s0);
cbuffer params : register(b0) {
    float sigma;
    float radius;
}

static const float fac = rcp(-2.0 * sigma * sigma);

struct PS_Input {
    float4 pos : SV_Position;
    float2 uv : TEXCOORD;
};

// 後で合計値除算をするため係数は省略
inline float
gaussian(float x) {
    return exp(x * x * fac);
}

float4
horizontal(PS_Input input) : SV_Target {
    float2 size;
    tex.GetDimensions(size.x, size.y);

    const float texel = rcp(size.x);
    const int count = int(radius);

    float4 color = tex.Sample(smp, input.uv);
    float weight = 1.0;

    for (int i = 1; i <= count; i += 2) {
        const float x = float(i);

        const float w0 = gaussian(x);
        const float w1 = gaussian(x + 1.0);
        const float w = w0 + w1;

        const float2 offset = float2(mad(w1, rcp(w), x) * texel, 0.0);
        color += (tex.Sample(smp, input.uv + offset) + tex.Sample(smp, input.uv - offset)) * w;
        weight += w * 2.0;
    }

    return color * rcp(weight);
}
