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
void VertexShader1(
    float4 inPos : POSITION,
    float3 inNormal : NORMAL0,
    float2 inUV : TEXCOORD0,
    out float4 outPos : POSITION,
    out float3 outPw : TEXCOORD0,
    out float3 outNw : TEXCOORD1
)
{
    outPos = mul(inPos, g_matWorldViewProj);
    outPw = mul(inPos, g_matWorld).xyz;
    outNw = normalize(mul(inNormal, (float3x3) g_matWorld)); // �t�]�u���K�v�Ȃ炻�����
}

// PS�FWorld ��ԂŔ��˂��v�Z���ăL���[�u���T���v��
float4 PixelShader1(float3 Pw : TEXCOORD0, float3 Nw : TEXCOORD1) : COLOR
{
    float3 Vw = normalize(g_eyePosW - Pw); // �s�N�Z�����J����
    float3 Rw = reflect(-Vw, normalize(Nw)); // ���ˁiWorld�j
    return float4(texCUBE(EnvSamp, Rw).rgb, 1.0);
}

technique Technique1
{
    pass P0
    {
        VertexShader = compile vs_3_0 VertexShader1();
        PixelShader = compile ps_3_0 PixelShader1();
    }
}
