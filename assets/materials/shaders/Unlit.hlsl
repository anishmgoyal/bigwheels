// Copyright 2022 Google LLC
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

#include "Config.hlsli"

ConstantBuffer<MaterialData> Material : register(MATERIAL_CONSTANTS_REGISTER, MATERIAL_DATA_SPACE);

Texture2D AlbedoTex : register(ALBEDO_TEXTURE_REGISTER, MATERIAL_RESOURCES_SPACE);

float4 psmain(VSOutput input) : SV_TARGET
{
    float3 albedo = Material.albedo;
    // If there is a texture applied for the albedo, 
    if (Material.albedoSelect == 1) {
        albedo = albedo * AlbedoTex.Sample(ClampedSampler, input.texCoord).rgb;
    }

    return float4(albedo, 1);
}
