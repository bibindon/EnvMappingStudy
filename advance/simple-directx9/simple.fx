// �s��
float4x4 g_matWorldViewProj;
float4x4 g_matWorld;
float4x4 g_matView;
float3 g_eyePosW;

// ���L���[�u�}�b�v
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

// VS�F���[���h�ʒu�ƃ��[���h�@����n��
void VertexShader1(float4 inPos    : POSITION,
                   float3 inNormal : NORMAL0,
                   float2 inUV     : TEXCOORD0,

                   out float4 outPos       : POSITION,
                   out float3 outPosWorld  : TEXCOORD0,
                   out float3 outNormWorld : TEXCOORD1)
{
    outPos = mul(inPos, g_matWorldViewProj);
    outPosWorld = mul(inPos, g_matWorld).xyz;
    outNormWorld = normalize(mul(inNormal, (float3x3) g_matWorld));
}

// PS�FWorld ��ԂŔ��˂��v�Z���ăL���[�u���T���v��
float4 PixelShader1(float3 posWorld  : TEXCOORD0,
                    float3 normWorld : TEXCOORD1) : COLOR
{
    // �s�N�Z�����J����
    float3 viewWorld = normalize(g_eyePosW - posWorld);

    // ���ˁiWorld�j
    float3 reflectWorld = reflect(-viewWorld, normalize(normWorld));

    return float4(texCUBE(EnvSamp, reflectWorld).rgb, 1.0);
}

technique Technique1
{
    pass P0
    {
        VertexShader = compile vs_3_0 VertexShader1();
        PixelShader = compile ps_3_0 PixelShader1();
    }
}
