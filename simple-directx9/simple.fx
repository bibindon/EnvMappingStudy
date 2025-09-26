// �s��
float4x4 g_matWorldViewProj;
float4x4 g_matWorld;
float4x4 g_matView;

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

// VS�F�\���̂��g�킸 out �œn��
void VertexShader1(
    float4 inPos : POSITION,
    float3 inNormal : NORMAL0,
    float2 inUV : TEXCOORD0,
    out float4 outPos : POSITION,
    out float3 outReflVS : TEXCOORD0
)
{
    // �܂��ˉe
    outPos = mul(inPos, g_matWorldViewProj);

    // World ���
    float3 Nw = normalize(mul(inNormal, (float3x3) g_matWorld));
    float3 Pw = mul(inPos, g_matWorld).xyz;

    // View ���
    float3 Nv = normalize(mul(Nw, (float3x3) g_matView));
    float3 Pv = mul(float4(Pw, 1.0f), g_matView).xyz;

    // �����x�N�g���i�_���J�����j
    float3 V = normalize(-Pv);

    // ���˕����iView ��ԁj
    outReflVS = reflect(-V, Nv);
}

// PS�F���˕����ŃL���[�u���T���v��
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
