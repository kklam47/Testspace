Shader "Unlit/FloatingBar"
{
    Properties
    {
        _MainTex         ("Texture",        2D)          = "white"{}
        _GridTex0        ("GridTexture0",   2D)          = "white"{}
        _GridTex1        ("GridTexture1",   2D)          = "white"{}
        _GridResoultion  ("GridResoultion", Integer)     = 0
        _CellCountX      ("CellCount X",    Float)       = 1
        _CellCountY      ("CellCount Y",    Float)       = 1
        _SizeX           ("Size X",         Float)       = 1
        _SizeY           ("Size Y",         Float)       = 1
        _Border          ("Texture Border", Vector)      = (0,0,0,0)
        _GridColor       ("GridColor",      Color)       = (0,0,0,0)
        _BarColor1       ("BarColor1",      Color)       = (0,0,0,0)
        _BarColor2       ("BarColor2",      Color)       = (0,0,0,0)
        _BarColor3       ("BarColor3",      Color)       = (0,0,0,0)
        _BarColor4       ("BarColor4",      Color)       = (0,0,0,0)

        _BarPct1         ("BarPercentage1", Range(0, 1)) = 0
        _BarPct2         ("BarPercentage2", Range(0, 1)) = 0
        _BarPct3         ("BarPercentage3", Range(0, 1)) = 0
        _BarPct4         ("BarPercentage4", Range(0, 1)) = 0

        _StencilComp     ("Stencil Comparison", Float) = 8
        _Stencil         ("Stencil ID",         Float) = 0
        _StencilOp       ("Stencil Operation",  Float) = 0
        _StencilWriteMask("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask",  Float) = 255

        _ColorMask       ("Color Mask", Float) = 15
    }
    SubShader
    {
        Tags {
            "RenderType" = "Transparent"
            "Queue"      = "Transparent"
        }
//      LOD 100

        Stencil
        {
            Ref[_Stencil]
            Comp[_StencilComp]
            Pass[_StencilOp]
            ReadMask[_StencilReadMask]
            WriteMask[_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest[unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask[_ColorMask]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            struct appdata
            {
                float3 vertex : POSITION;
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                float2 uv       : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _GridTex0;
            float4 _GridTex0_ST;

            sampler2D _GridTex1;
            float4 _GridTex1_ST;

            float  _CellCountX;
            float  _CellCountY;

            float  _SizeX;
            float  _SizeY;

            float4 _Border;
            float4 _BarColor1;
            float4 _BarColor2;
            float4 _BarColor3;
            float4 _BarColor4;
            float4 _GridColor;

            float  _BarPct1;
            float  _BarPct2;
            float  _BarPct3;
            float  _BarPct4;
            float  _GridResoultion;


            v2f vert(appdata v)
            {
                v2f o;
                o.vertex  = UnityObjectToClipPos(v.vertex);
                o.uv      = v.uv;
                return o;
            }

            // https://www.shadertoy.com/view/WldSDX
            // borders in pixels, x = left, y = bottom, z = right, w = top
            float2 uv9slice(float2 uv, float2 s, float4 b)
            {
                float2 t = saturate((s * uv - b.xy) / (s - b.xy - b.zw));
                return lerp(uv * s, 1.0 - s * (1.0 - uv), t);
            }

            float range(float x, float p0, float p1) {
                return x >= p0 && x <= p1;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv      = i.uv;
                float2 size    = float2(_SizeX, _SizeY);
                float2 cellCnt = float2(_CellCountX, _CellCountY);

                uv = frac(uv * cellCnt);

                float4 b = min(_Border, float4(1,1,1,1) * 0.499);
                float2 s = max(size, float2(_Border.x + _Border.z, _Border.y + _Border.w));

                uv = uv9slice(uv, s, b);

                fixed4 grid0  = tex2D(_GridTex0, uv);
                fixed4 grid1  = tex2D(_GridTex1, uv);
                float  g1mask = uint(floor(i.uv.x * cellCnt.x)) % (_GridResoultion + 1);

//              return g1mask * fixed4(1,1,1,1);

//              return g1mask * fixed4(1,1,1,1);
//              return grid1.w * fixed4(1,1,1,1);

                grid1.w *= g1mask;
                grid0.w *= 1 - g1mask;

                float4 grid   = fixed4(1, 1, 1, grid0.w + grid1.w) * _GridColor;

                grid.w = grid.w != 0;


                float  c1mask = range(i.uv.x, 0,                                      _BarPct1);
                float  c2mask = range(i.uv.x, _BarPct1,                               _BarPct2);
                float  c3mask = range(i.uv.x, max(_BarPct1, _BarPct2),                _BarPct3);
                float  c4mask = range(i.uv.x, max(max(_BarPct1, _BarPct2), _BarPct3), _BarPct4);

                float4 bar    = _BarColor1 * c1mask + _BarColor2 * c2mask + _BarColor3 * c3mask + _BarColor4 * c4mask;

                return (1 - grid.w) * bar + grid;
                return grid;

            }
            ENDCG
        }
    }
}