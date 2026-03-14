Shader "Unlit/SnowRoll"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
                //store coordinate
                float2 uv = i.uv;
                //rolling motion 
                float roll = frac(uv.y - _Time.y);
                //new coordinates on y
                float2 uvRoll = float2(uv.x, roll);
                //texture with new coordinates
                fixed4 col = tex2D(_MainTex, uvRoll);
                //create noise with coordinate
                float noise = frac(sin(dot(uvRoll, float2(12.9898,78.233))) * 43758.5453);
                //color channel noise 
                col.rgb += noise * 0.25;
                //saturate color
                col.rgb = saturate(col.rgb);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
