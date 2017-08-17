// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "WuLin/PlayerAlphaTest" {
	Properties
	{
		_MainColor("Main color",Color) = (0.94,0.94,0.94,1)
		_MainTex("main tex",2D) = "black"{}

		_skinColor("皮肤颜色",Color) = (0.56,0.48,0.48,1)
		_SkinRimColor("皮肤边光颜色",Color) = (0,0,0,1)
		_SkinRimPower("皮肤边光强度",range(1,10)) = 8

	    _SpecTex("高光贴图(R高光反射G皮肤B边光区域)",2D) = "white"{}
	    _EnvReflection ("反射贴图", Cube) = "" {}
		_Dark ("反射变暗系数", range(0,1)) = 1



		_RimColor("R通道边光颜色",Color) = (0,0,0,1)
		_RimPower("R通道边光强度",range(1,10)) = 8
		_speColor("R通道高光颜色",Color) = (0,0,0,1)
		_Gloss("R通道高光强度",Range(1.0,20)) = 10
		_ReflectionPower ("R通道反射强度", range(0,1)) = 0

		_test("         ！！！！！！！我是可爱的分割线！！！！！！",Range(1.0,20)) = 10

		_RimColor02("B通道边光颜色",Color) = (0,0,0,1)
		_RimPower02("B通道边光强度",range(1,10)) = 8
		_speColor02("B通道高光颜色",Color) = (0,0,0,1)
		_Gloss02("B通道高光强度",Range(1.0,20)) = 10
		_ReflectionPower02 ("B通道反射强度", range(0,1)) = 0



		_ScrollTex("流光效果图", 2D) = "black" {}
	    _ScrollSpeedU("流光速度", Range(-5,5)) = 1
	    _AnisoTex ("各向异性贴图", 2D) = "bump" {}
         _AnisoOffset ("各项高光强度", Range(-1,1)) = -0.2
		_FlashColor("闪白效果",color) = (0,0,0,0)
		_isSelf("是否自己",Range(0,1)) = 0
		_HairColor ("头发颜色", Color) = (1, 0.2, 0.2, 1)
		_ClothingColor ("衣服颜色", Color) = (1, 0.2, 0.2, 1)
		_IsChangeColor("是否开启换色（0关闭,1开启）",float)=0
		_ColorTex ("换色贴图", 2D) = "white" {}
		_HairChangeColor("区域一（红色部分控制）",Color)=(0,0,0,0)
		_ClothesChangeColor("区域二（绿色部分控制）",Color)=(0,0,0,0)
		_ClothesChange1Color("区域三（蓝色部分控制）",Color)=(0,0,0,0)

		_AlphaTest ("AlphaTest", Range(0, 1)) = 0.5

	}

		SubShader
	{
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry+20" }
		Pass

	{
	name "XRAY"
		Blend SrcAlpha One
		ZWrite off

		Lighting off

		ztest greater

		CGPROGRAM
#pragma vertex vert  
#pragma fragment frag  
#include "UnityCG.cginc"  

        fixed _isSelf;
		struct appdata_t {
		float4 vertex : POSITION;
		float2 texcoord : TEXCOORD0;
		float4 color:COLOR;
		float4 normal:NORMAL;
	};

	struct v2f 
	{
		float4  pos : SV_POSITION;
		float4  color:COLOR;
	};
	v2f vert(appdata_t v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		float3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
		float rim = 1 - saturate(dot(viewDir,v.normal));
		o.color = fixed4(0.345,0.345,0.345,_isSelf)*pow(rim,3.5);
		return o;
	}
	float4 frag(v2f i) : COLOR
	{
		return i.color;
	}
		ENDCG
	}
		Pass
	{
		name "Diff"
		Blend One Zero
		Cull Off
		Stencil{
			Ref 2
			Comp always
			Pass replace
		}

		Tags{ "RenderType" = "AlphaTest" "LightMode" = "ForwardBase" }

		CGPROGRAM
		#include "Lighting.cginc"
		#include"UnityCG.cginc"

		#pragma vertex vert
		#pragma fragment frag


		struct v2f
	{
		float4 vertex:POSITION;
		float3 normal:NORMAL;

		float4 uv:TEXCOORD0;
		float4 color:COLOR;
		float2 scrollUv : TEXCOORD1;
		float2 anisouv : TEXCOORD2;
		float2 uvColor	: TEXCOORD3;
		float3 worldPos : TEXCOORD4;
		fixed3 worldNormal : TEXCOORD5;
		fixed3 worldViewDir : TEXCOORD6;
		fixed3 worldRefl : TEXCOORD7;
	};
	uniform sampler2D _SpecTex;
	sampler2D _MainTex;
	float4 _MainColor;

	float4 _RimColor;
	float _RimPower;
	float4 _RimColor02;
	float _RimPower02;
	float4 _SkinRimColor;
	float _SkinRimPower;
	float4 _speColor;
	float4 _speColor02;

	sampler2D _ScrollTex;
	float4 _ScrollTex_ST;
	float _ScrollSpeedU;
	float4 _FlashColor;
	float _Gloss;
	float _Gloss02;
	float4 _skinColor;
	float4 _HairChangeColor;
	float4 _ClothesChangeColor;
	float4 _ClothesChange1Color;
	float _IsChangeColor;
	sampler2D _ColorTex;
	float4 _ColorTex_ST;
	sampler2D _AnisoTex;
	float4 _AnisoTex_ST;
	float _AnisoOffset;
	uniform samplerCUBE _EnvReflection;
	uniform half _Dark;
	uniform fixed _ReflectionPower;
	uniform fixed _ReflectionPower02;

	uniform float _AlphaTest;

	v2f vert(appdata_full v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord;
		float4 V= float4(WorldSpaceViewDir(v.vertex),0);
		float2 scrollUv = v.vertex;
		float2 anisouv = v.vertex;
		scrollUv += _Time.y * fixed2(_ScrollSpeedU, 0.2);
		o.scrollUv = TRANSFORM_TEX(scrollUv, _ScrollTex);
		o.anisouv = TRANSFORM_TEX(anisouv, _AnisoTex);
		o.uvColor = TRANSFORM_TEX(v.texcoord, _ColorTex);
		V = mul(unity_WorldToObject,V);//视方向从世界到模型坐标系的转换
		o.normal = v.normal;
		o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
		
		o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
		
		o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
		
		// Compute the reflect dir in world space
		o.worldRefl = reflect(-o.worldViewDir, o.worldNormal);
		o.color.x = saturate(dot(v.normal,normalize(V.xyz)));//必须在同一坐标系才能正确做点乘运算
		return o;
	}



	half4 frag(v2f IN) : SV_Target
	{
	fixed3 worldNormal02 = normalize(mul(IN.normal,(float3x3)unity_WorldToObject));
	fixed3 worldNormal = normalize(IN.worldNormal);
	fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
	fixed3 reflectDir = normalize(reflect(-worldLight,worldNormal));
	float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - IN.worldPos.xyz);
	fixed halfLambert = dot(worldNormal,worldLight)*0.3 + 0.8;
	half4 tex = tex2D(_MainTex,IN.uv);
	half4 spe = tex2D(_SpecTex,IN.uv);
	float3 viewReflectDirection = reflect( -viewDir, worldNormal);
	half4 c = (tex * halfLambert * _LightColor0 * (abs(1-spe.g)*0.5 + 0.5));
	c += tex*(spe.g*_skinColor);
	fixed3 specular = pow(saturate(dot(reflectDir,viewDir)),_Gloss);
	fixed3 specular02 = pow(saturate(dot(reflectDir,viewDir)),_Gloss02)*5;

	float2 scrollUv = IN.scrollUv;
	fixed4 scrollColor = tex2D(_ScrollTex, scrollUv);
	float3 ref = texCUBE(_EnvReflection,IN.worldRefl).rgb;

//	c.rgb += (pow((1 - IN.color.x) ,_RimPower)*_RimColor.rgb*spe.r) +(pow((1 - IN.color.x) ,_RimPower02)* _RimColor02.rgb*spe.b)+(pow((1 - IN.color.x) ,_SkinRimPower)* _SkinRimColor.rgb * spe.g);
    c.rgb += (pow((1.2- IN.color.x) ,_RimPower)*_RimColor.rgb*spe.r)+(pow((1.2 - IN.color.x) ,_RimPower02)* _RimColor02.rgb*spe.b)+(pow((1.2 - IN.color.x) ,_SkinRimPower)* _SkinRimColor.rgb * spe.g);
	c.rgb += pow((1 - IN.color.x) ,1)*  _FlashColor;

	c.rgb += (pow((1 - IN.color.x) ,2)* float3(1,0,0))*saturate(dot(worldNormal,worldLight))* spe.g ;
	c.rgb *= _MainColor + scrollColor * spe.r * 2;
	c.rgb += (specular *_speColor * spe.r)+(specular02*spe.b*_speColor02*spe.b) ;
	c.rgb += spe.r*ref*3* _ReflectionPower;
	c.rgb += spe.b*ref*3* _ReflectionPower02;
	c*= lerp(1.0,_Dark,saturate(spe.b));
	clip(c.a - _AlphaTest);

//	c = ((c*(1 - _FlashColor.a)) + _FlashColor);


//各项异性高光算法
//	float3 anisoDir = UnpackNormal(tex2D(_AnisoTex,IN.anisouv));
//	fixed3 h = normalize(normalize(worldLight) + normalize(viewDir));
//	float NdotL = saturate(dot(IN.normal, worldLight));
//
//	fixed HdotA = dot(normalize(IN.normal + anisoDir.rgb), h);
//	float aniso = max(0, sin(radians((HdotA + _AnisoOffset) * 180)));
//
//	float spec = saturate(dot(IN.normal, h));
//	spec = saturate(pow(lerp(spec, aniso, anisoDir.r), spe.g * 128) * specular);
//
//	c.rgb = ((c.rgb * _LightColor0.rgb * NdotL) + (_LightColor0.rgb * spec*spe.g)) * (1 * 2);

	
	//各项异性高光结束

		if(_IsChangeColor==1)
	{
		fixed4 col_change=float4(0,0,0,0);
		col_change  = tex2D(_ColorTex, IN.uvColor);
		//清楚所选部分原贴图的颜色
		fixed4 HairChange  =_HairChangeColor*col_change.r*c;
		//取所选部分明暗黑白图
		fixed4 HairChange_gray=dot(HairChange.xyz, float3(0.299, 0.587, 0.114));
		HairChange+=HairChange_gray;
		fixed4 ClothesChange  =_ClothesChangeColor*col_change.g*c;
		fixed4 ClothesChange_gray=dot(ClothesChange.xyz, float3(0.299, 0.587, 0.114));
		ClothesChange+=ClothesChange_gray;
		fixed4 ClothesChange1 = _ClothesChange1Color*col_change.b*c;
		fixed4 ClothesChange1_gray=dot(ClothesChange1.xyz, float3(0.299, 0.587, 0.114));
		ClothesChange1+=ClothesChange1_gray;
		c*=(1-col_change.r-col_change.g-col_change.b);
		//最后将所有换色部分进行叠加
		c+=HairChange+ClothesChange+ClothesChange1;
	}



	return c;
	}
		ENDCG 
	}
	}
		FallBack "Diffuse"
}
