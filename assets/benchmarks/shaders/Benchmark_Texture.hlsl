// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include "VsOutput.hlsli"

RWStructuredBuffer<float> dataBuffer : register(u0);
SamplerState pointsampler : register(s1);

Texture2D Tex0 : register(t2);
Texture2D Tex1 : register(t3);
Texture2D Tex2 : register(t4);
Texture2D Tex3 : register(t5);
Texture2D Tex4 : register(t6);
Texture2D Tex5 : register(t7);
Texture2D Tex6 : register(t8);
Texture2D Tex7 : register(t9);
Texture2D Tex8 : register(t10);
Texture2D Tex9 : register(t11);

[[vk::combinedImageSampler]]
Texture2D YUVTex0 : register(t12);
[[vk::combinedImageSampler]]
SamplerState yuvsampler0 : register(s12);
[[vk::combinedImageSampler]]
Texture2D YUVTex1 : register(t13);
[[vk::combinedImageSampler]]
SamplerState yuvsampler1 : register(s13);
[[vk::combinedImageSampler]]
Texture2D YUVTex2 : register(t14);
[[vk::combinedImageSampler]]
SamplerState yuvsampler2 : register(s14);
[[vk::combinedImageSampler]]
Texture2D YUVTex3 : register(t15);
[[vk::combinedImageSampler]]
SamplerState yuvsampler3 : register(s15);
[[vk::combinedImageSampler]]
Texture2D YUVTex4 : register(t16);
[[vk::combinedImageSampler]]
SamplerState yuvsampler4 : register(s16);
[[vk::combinedImageSampler]]
Texture2D YUVTex5 : register(t17);
[[vk::combinedImageSampler]]
SamplerState yuvsampler5 : register(s17);
[[vk::combinedImageSampler]]
Texture2D YUVTex6 : register(t18);
[[vk::combinedImageSampler]]
SamplerState yuvsampler6 : register(s18);
[[vk::combinedImageSampler]]
Texture2D YUVTex7 : register(t19);
[[vk::combinedImageSampler]]
SamplerState yuvsampler7 : register(s19);
[[vk::combinedImageSampler]]
Texture2D YUVTex8 : register(t20);
[[vk::combinedImageSampler]]
SamplerState yuvsampler8 : register(s20);
[[vk::combinedImageSampler]]
Texture2D YUVTex9 : register(t21);
[[vk::combinedImageSampler]]
SamplerState yuvsampler9 : register(s21);

float rand_float(uint seed)
{
    const uint state = seed * 747796405u + 2891336453u;
    const uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    //#define FAKE_HASH
    #if defined(FAKE_HASH)
    return ((word >> 22u) ^ word) * (1.0 / 4.0);
    #else
    return ((word >> 22u) ^ word) * (1.0 / 4294967296.0);
    #endif
}


float4 psmain(VSOutputPos input) : SV_TARGET
{
    float4 c0 = Tex0.SampleLevel(pointsampler, input.texcoord, 0);
    float4 c1 = Tex1.SampleLevel(pointsampler, input.texcoord, 0);
    float4 c2 = Tex2.SampleLevel(pointsampler, input.texcoord, 0);
    float4 c3 = Tex3.SampleLevel(pointsampler, input.texcoord, 0);
    float4 c4 = Tex4.SampleLevel(pointsampler, input.texcoord, 0);
    float4 c5 = Tex5.SampleLevel(pointsampler, input.texcoord, 0);
    float4 c6 = Tex6.SampleLevel(pointsampler, input.texcoord, 0);
    float4 c7 = Tex7.SampleLevel(pointsampler, input.texcoord, 0);
    float4 c8 = Tex8.SampleLevel(pointsampler, input.texcoord, 0);
    float4 c9 = Tex9.SampleLevel(pointsampler, input.texcoord, 0);

    float4 sum_c = (c0 + c1  + c2  + c3/* + c4 + c5 + c6+ c7 + c8 + c9*/)/6.f ;

    float4 cYUV0 = YUVTex0.SampleLevel(yuvsampler0, input.texcoord, 0);
    float4 cYUV1 = YUVTex1.SampleLevel(yuvsampler1, input.texcoord, 0);
    float4 cYUV2 = YUVTex2.SampleLevel(yuvsampler2, input.texcoord, 0);
    float4 cYUV3 = YUVTex3.SampleLevel(yuvsampler3, input.texcoord, 0);
    float4 cYUV4 = YUVTex4.SampleLevel(yuvsampler4, input.texcoord, 0);
    float4 cYUV5 = YUVTex5.SampleLevel(yuvsampler5, input.texcoord, 0);
    float4 cYUV6 = YUVTex6.SampleLevel(yuvsampler6, input.texcoord, 0);
    float4 cYUV7 = YUVTex7.SampleLevel(yuvsampler7, input.texcoord, 0);
    float4 cYUV8 = YUVTex8.SampleLevel(yuvsampler8, input.texcoord, 0);
    float4 cYUV9 = YUVTex9.SampleLevel(yuvsampler9, input.texcoord, 0);

    float4 sum_c_yuv = (cYUV0/* + cYUV1  + cYUV2  + cYUV3  + cYUV4 + cYUV5 + cYUV6  + cYUV7  + cYUV8  + cYUV9*/)/1.f ;

    const uint rd_w = 2664;
    const uint pixel_id = uint(input.position.y * rd_w + input.position.x);
    const float red = rand_float(pixel_id);
    const float green = rand_float(pixel_id + 1);
    const float blue = rand_float(pixel_id - 1);
    float4 noise = float4(red, green, blue, 1.0f);

    sum_c = sum_c;// * 0.5f + sum_c_yuv *0.5f;// * 0.1f + noise*0.8f;

    if (!any(sum_c))
        dataBuffer[0] = sum_c.r;
    return sum_c;
}