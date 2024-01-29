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

[[vk::combinedImageSampler]]
Texture2D YUVTex0 : register(t7);
[[vk::combinedImageSampler]]
SamplerState yuvsampler0 : register(s7);
[[vk::combinedImageSampler]]
Texture2D YUVTex1 : register(t8);
[[vk::combinedImageSampler]]
SamplerState yuvsampler1 : register(s8);
[[vk::combinedImageSampler]]
Texture2D YUVTex2 : register(t9);
[[vk::combinedImageSampler]]
SamplerState yuvsampler2 : register(s9);
[[vk::combinedImageSampler]]
Texture2D YUVTex3 : register(t10);
[[vk::combinedImageSampler]]
SamplerState yuvsampler3 : register(s10);
[[vk::combinedImageSampler]]
Texture2D YUVTex4 : register(t11);
[[vk::combinedImageSampler]]
SamplerState yuvsampler4 : register(s11);

float4 psmain(VSOutputPos input) : SV_TARGET
{
    float4 c0 = Tex0.SampleLevel(pointsampler, input.texcoord, 0);
    float4 c1 = Tex1.SampleLevel(pointsampler, input.texcoord, 0);
    float4 c2 = Tex2.SampleLevel(pointsampler, input.texcoord, 0);
    float4 c3 = Tex3.SampleLevel(pointsampler, input.texcoord, 0);
    //float4 c4 = Tex4.SampleLevel(pointsampler, input.texcoord, 0);

    float4 sum_c = (c0/* + c1  + c2  + c3  + c4*/)/1.f ;

    float4 cYUV0 = YUVTex0.SampleLevel(yuvsampler0, input.texcoord, 0);
    float4 cYUV1 = YUVTex1.SampleLevel(yuvsampler1, input.texcoord, 0);
    float4 cYUV2 = YUVTex2.SampleLevel(yuvsampler2, input.texcoord, 0);
    float4 cYUV3 = YUVTex3.SampleLevel(yuvsampler3, input.texcoord, 0);
    //float4 cYUV4 = YUVTex4.SampleLevel(yuvsampler4, input.texcoord, 0);

    float4 sum_c_yuv = (cYUV0/* + cYUV1  + cYUV2  + cYUV3  + cYUV4*/)/1.f ;
    sum_c = sum_c * 0.5f + sum_c_yuv * 0.5f;

    if (!any(sum_c))
        dataBuffer[0] = sum_c.r;
    return sum_c;
}