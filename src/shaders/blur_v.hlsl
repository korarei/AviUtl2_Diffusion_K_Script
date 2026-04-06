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
vertical(PS_Input input) : SV_Target {
    float2 size;
    tex.GetDimensions(size.x, size.y);

    const float texel = rcp(size.y);
    const int r = int(radius);

    float4 color = tex.Sample(smp, input.uv);
    float weight = 1.0;

    for (int i = 1; i <= r; i += 2) {
        float w0 = gaussian(float(i));
        float w1 = gaussian(float(i + 1));
        float w = w0 + w1;

        float2 offset = float2(0.0, mad(w1, rcp(w), float(i)) * texel);
        color += (tex.Sample(smp, input.uv + offset) + tex.Sample(smp, input.uv - offset)) * w;
        weight += w * 2.0;
    }

    return color * rcp(weight);
}
