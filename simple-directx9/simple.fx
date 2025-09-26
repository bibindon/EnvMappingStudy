// 行列
float4x4 g_matWorldViewProj;
float4x4 g_matWorld;
float4x4 g_matView;

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
};

// VS：構造体を使わず out で渡す
void VertexShader1(
    float4 inPos : POSITION,
    float3 inNormal : NORMAL0,
    float2 inUV : TEXCOORD0,
    out float4 outPos : POSITION,
    out float3 outReflVS : TEXCOORD0
)
{
    // まず射影
    outPos = mul(inPos, g_matWorldViewProj);

    // World 空間
    float3 Nw = normalize(mul(inNormal, (float3x3) g_matWorld));
    float3 Pw = mul(inPos, g_matWorld).xyz;

    // View 空間
    float3 Nv = normalize(mul(Nw, (float3x3) g_matView));
    float3 Pv = mul(float4(Pw, 1.0f), g_matView).xyz;

    // 視線ベクトル（点→カメラ）
    float3 V = normalize(-Pv);

    // 反射方向（View 空間）
    outReflVS = reflect(-V, Nv);
}

// PS：反射方向でキューブをサンプル
float4 PixelShader1(
    float3 inReflVS : TEXCOORD0
) : COLOR
{
    float3 env = texCUBE(EnvSamp, inReflVS).rgb;
    return float4(env, 1.0f);
}

technique Technique1
{
    pass P0
    {
        VertexShader = compile vs_2_0 VertexShader1();
        PixelShader = compile ps_2_0 PixelShader1();
    }
}
