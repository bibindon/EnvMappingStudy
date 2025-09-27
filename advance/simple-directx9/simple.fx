// 行列
float4x4 g_matWorldViewProj;
float4x4 g_matWorld;
float4x4 g_matView;
float3 g_eyePosW;

// ブレンド係数
// 0 はアルベドのみ、1 は反射のみ
float g_reflectAmount = 0.0;

// 環境キューブマップ
textureCUBE EnvMap;

samplerCUBE EnvSamp =
sampler_state
{
    Texture = <EnvMap>;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
    MaxMipLevel = 7;
};

// メッシュのアルベドテクスチャ
texture2D AlbedoTex;

sampler2D AlbedoSamp =
sampler_state
{
    Texture = <AlbedoTex>;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP;
};

// VS：ワールド位置、法線、UV を渡す
void VertexShader1(float4 inPos : POSITION,
                   float3 inNormal : NORMAL0,
                   float2 inUV : TEXCOORD0,

                   out float4 outPos : POSITION,
                   out float3 outPosWorld : TEXCOORD0,
                   out float3 outNormWorld : TEXCOORD1,
                   out float2 outUV : TEXCOORD2)
{
    outPos = mul(inPos, g_matWorldViewProj);
    outPosWorld = mul(inPos, g_matWorld).xyz;
    outNormWorld = normalize(mul(inNormal, (float3x3) g_matWorld));
    outUV = inUV;
}

// PS：反射色とアルベドを合成
float4 PixelShader1(float3 posWorld : TEXCOORD0,
                    float3 normWorld : TEXCOORD1,
                    float2 uv : TEXCOORD2) : COLOR
{
    float3 viewDir = normalize(g_eyePosW - posWorld);
    float3 normalW = normalize(normWorld);
    float3 reflDir = reflect(-viewDir, normalW);

    float3 envColor = texCUBE(EnvSamp, reflDir).rgb;
    float3 albedo = tex2D(AlbedoSamp, uv).rgb;

    float nv = saturate(dot(normalW, viewDir));
    float fresnel = pow(1.0 - nv, 5.0);

    float reflectFactor = saturate(g_reflectAmount + 0.5 * fresnel);

    float3 outRgb = lerp(albedo, envColor, reflectFactor);
    return float4(outRgb, 1.0);
}

technique Technique1
{
    pass P0
    {
        VertexShader = compile vs_3_0 VertexShader1();
        PixelShader = compile ps_3_0 PixelShader1();
    }
}
