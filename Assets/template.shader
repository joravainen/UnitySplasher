Shader "Demo/template"
{

    Properties {  
        _MainTex ("Texture", any) = "" {} 
        _Duration ("Duration", Float) = 2
        }


    SubShader {

	Pass
	{

	Name "Graphics"
	
    CGPROGRAM
    #pragma vertex vert
    #pragma fragment frag
    #pragma target 3.0

    #include "UnityCG.cginc"

    struct appdata_t {
        float4 vertex : POSITION;
        fixed4 color : COLOR;
        float2 uv : TEXCOORD0;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f {
        float4 vertex : SV_POSITION;
        fixed4 color : COLOR;
        float2 uv : TEXCOORD0;
        UNITY_VERTEX_OUTPUT_STEREO
    };

    sampler2D _MainTex;
    float _Duration;

    uniform float4 _MainTex_ST;

    v2f vert (appdata_t v)
    {
        v2f o;
        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.color = v.color;
        o.uv = v.uv;
        return o;
    }

    float4 frag (v2f i) : SV_Target
    {
        return tex2D(_MainTex, i.uv).a * sin(_Time.y/_Duration*3.14159);
    }
    ENDCG

	}


	Pass
	{

	Name "Sound"
	
    CGPROGRAM
    #pragma vertex vert
    #pragma fragment frag
    #pragma target 3.0

    #include "UnityCG.cginc"

    struct appdata_t {
        float4 vertex : POSITION;
    };
  
    sampler2D _MainTex;
    float _Duration;

    uniform float4 _MainTex_ST;
    float4 vert (appdata_t v) : SV_POSITION
    {
        return UnityObjectToClipPos(v.vertex);
    }

    float4 frag(UNITY_VPOS_TYPE screenPos : VPOS) : SV_Target
    {
        int sample = screenPos.y*1024+screenPos.x;
        float t = float(sample) / 48000.f;
        
        float r = sin(t*440*2.f*3.1415926f) * sin(t/_Duration*3.14159);
        return float4(r,r,0,0);
    }
    ENDCG

	}
	
	
	
    }

    Fallback off
}
