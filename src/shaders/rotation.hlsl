#include "input.hlsli"

Texture2D tex : register(t0);
SamplerState smp : register(s0);
cbuffer params : register(b0) {
    column_major float2x2 mat;
    float2 output_size;
}

float4
rotate(PS_Input input) : SV_Target {
    float2 input_size;
    tex.GetDimensions(input_size.x, input_size.y);

    return tex.Sample(smp, mad(mul(mat, (input.uv - 0.5) * output_size), rcp(input_size), 0.5));
}
