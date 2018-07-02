using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EffectHandler : MonoBehaviour {
	public Shader m_Shader;
	public Texture m_LogoOverride;
    public float m_Duration;

    Material m_Material;
	AudioSource m_AudioSource;
	AudioClip m_AudioClip;
	bool m_AudioStarted;

	const int kAudioTexSize = 1024;  
    
	void Start () {
		m_Material = new Material(m_Shader);
        
		if (m_LogoOverride == null)
			m_LogoOverride = Resources.GetBuiltinResource<Texture2D>("UnitySplash-cube.png");

		if (m_Duration > 0.0f)
			m_Material.SetFloat("_Duration", m_Duration);
        
		if (m_AudioClip == null) // Using 4 channels for easy match with the commonly supported RGBAFloat
		    m_AudioClip = AudioClip.Create("SoundShader", kAudioTexSize * kAudioTexSize, 4, 48000, false);

        // Pre-render the 21.8s sound clip
		// TODO: Buffering solution for longer demos
		RenderTexture soundRT = RenderTexture.GetTemporary(kAudioTexSize, kAudioTexSize, 0, RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear, 1);
		Graphics.Blit(m_LogoOverride, soundRT, m_Material, 1);

		Texture2D readbackTex = new Texture2D(kAudioTexSize, kAudioTexSize, TextureFormat.RGBAFloat, false);
		RenderTexture.active = soundRT;
		readbackTex.ReadPixels(new Rect(0, 0, kAudioTexSize, kAudioTexSize), 0, 0);
		readbackTex.Apply();
        RenderTexture.active = null;
		soundRT.Release();

		var audioData = readbackTex.GetRawTextureData<float>();
		m_AudioClip.SetData(audioData.ToArray(), 0);

		m_AudioStarted = false;
	}

	private void OnDisable()
	{
		if (m_AudioClip != null)
		{
			Destroy(m_AudioClip);
			m_AudioClip = null;
		}
	}

	// Update is called once per frame
	void Update () {
		if (m_Duration > 0.0f && Time.time >= m_Duration)
		{
			Application.Quit();
#if UNITY_EDITOR
			UnityEditor.EditorApplication.isPlaying = false;
#endif
		}
	}

	private void OnRenderImage(RenderTexture src, RenderTexture dst)
	{
		Graphics.Blit(m_LogoOverride, dst, m_Material, 0);

        // Start audio playback on the first frame for sync
		if (!m_AudioStarted)
		{
			m_AudioSource = GetComponent<AudioSource>();
            m_AudioSource.PlayOneShot(m_AudioClip);
			m_AudioStarted = true;
		}
	}
}
