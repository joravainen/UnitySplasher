Shader "Demo/juhoo/n00bBalls"
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

    static const int numBalls = 3;
    static const float ballRadius = 1.8;
    static const float4 ballData[numBalls] = {float4(0.1, 0.1, 0.7, 1.0), float4(0.4, 0.3, 0.2, 0.8), float4(0.7, 0.3, 0.01, 0.5)};

    float ballDist(float3 v, int i, out float3 n)
    {
        float3 pos = float3(0,10,0) + sin(_Time.z * ballData[i].w) * 5.0 * ballData[i].xyz;
        n = -(pos - v);
        float d = length(n) - ballRadius;
        return d;
    }

    float smin( float a, float b, float k )
    {
        float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
        return lerp( b, a, h ) - k*h*(1.0-h);
    }

    static const float minStep = 0.01;
    static const float sminK = 1.5;

    float ballsDist(inout float3 v, out float3 n)
    {
        n = float3(0,0,0);
        float d = 2e10;
        float dvec;
        for (int s=0; s < 20 && d > 0.001; s++)
        {
            float da[numBalls];
            float3 navg = 0;
            float davg = 0;
            for (int i=0; i < numBalls; i++)
            {
                float3 bvec = 0;
                float dist = ballDist(v, i, bvec);
                
                if (i == 0)
                {
                    davg = dist;
                    navg = bvec;
                }
                else
                {
                    davg = smin(dist, davg, sminK);
                    navg.x = smin(bvec.x, navg.x, sminK);
                    navg.y = smin(bvec.y, navg.y, sminK);
                    navg.z = smin(bvec.z, navg.z, sminK);
                    
                }
            }
            if (davg < d)
            {
                n = normalize(navg);
                d = davg;
            }

            v += normalize(v) * max(d, minStep);
        }
        return d;
    }

    float3 lightPos = float3(0.0, 0, 0.0);

    float4 frag (v2f i) : SV_Target
    {
        float ratio = _ScreenParams.x / _ScreenParams.y;
        float3 ray = normalize(float3((i.uv.x-0.5f)*ratio, 1.0f, i.uv.y-0.5f));

        float4 fragColor = float4(0,0,0,1);

        float3 n;
        if (ballsDist(ray, n) < 0.01)
        {
            float3 lightVec = normalize(lightPos - ray);
            float diff = dot(lightVec, n);
            fragColor = float4(diff, diff, diff,1);
            float2 tc = (1.0+n.xz)/1.5;
            fragColor.r += tex2D(_MainTex, tc).a * diff;
            fragColor.g -= tex2D(_MainTex, tc).a * diff;
        }

        return fragColor * clamp(2*sin(_Time.y/(_Duration-0.5)*UNITY_PI), 0, 1);
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

    float square(float t, float note)
    {
        return float(step((0.5 + 0.1*sin(t*1.0))/note, t % (1.0/note)));
    }

    float sine(float t, float note)
    {
        return sin(UNITY_TWO_PI*t*note);
    }

    float trem(float t, float note)
    {
        return 0.1*sine(t, note - 0.5 * note * ceil(sin(t*80)));
    }

    float pad( float t, float note)
    {
        return 0.12* (square(t, note) + square(t, note+0.2));
    }

    float kick(float t)
    {
        return sin(200.0/(1+t*10));
    }

    float snare(float t)
    {
        return frac(pow(200.0*t,4)) - 1.0;
    }

    float hihat(float t)
    {
        return frac(pow(200.0*t,4)) - 1.0;
    }

    static const float kKickMod = UNITY_PI / 8;

    static const float kickVol = 0.5;
    static const float snareVol = 0.5;
    static const float hihatVol = 0.5;

    float4 frag(UNITY_VPOS_TYPE screenPos : VPOS) : SV_Target
    {
        int sample = screenPos.y*1024+screenPos.x;
        float t = float(sample) / 48000.f;

        float r = hihatVol * step(0.97,sin(t*UNITY_PI*4 - 1.5)) * hihat(t % 0.25);
        r += snareVol * step(0.97,cos(t*UNITY_PI*2 + UNITY_PI)) * snare(t % 0.25);
        r += kickVol * kick(t % 0.5);

        if (t < 0.75)
        {   
            r += pad(t, 523.25/8);
            r += trem(t, 698.46/1);
        }
        else if (t < 1.5)
        {
            r += pad(t, 392.00/8);
            r += trem(t, 659.25/1);
        }
        else
        {  
            r += pad(t, 587.33/8);
            r += trem(t, 587.33/1);
        }
        
        return r * clamp(2*sin(t/(_Duration-0.5)*UNITY_PI), 0, 1);
    }
    ENDCG

    }
	
	
	
    }

    Fallback off
}
