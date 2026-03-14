Shader "Unlit/SwirlFade"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SecondTex ("Texture B", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _SecondTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //coordinates shifting
                float2 uv = i.uv - 0.5;
                //angle calculation
                float a = atan2(uv.y, uv.x);
                //distance computation
                float d = length(uv);
                //swirl using built in time
                float twirl = sin(_Time.y) * 3.0;
                //angle offset
                a += (0.5 - d) * twirl;
                //coordinates conversions
                uv.x = cos(a) * d;
                uv.y = sin(a) * d;
                //shift to normal range
                uv += 0.5;
                //texture using coordinates
                fixed4 colA = tex2D(_MainTex, uv);
                fixed4 colB = tex2D(_SecondTex, uv);
                //fade computation
                float fade = (sin(_Time.y) + 1.0) * 0.5;
                //texture blend
                fixed4 col = lerp(colA, colB, fade);
                return col;
            }
            ENDCG
        }
    }
}
