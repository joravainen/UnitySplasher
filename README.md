# UnitySplasher

At Unity Hackweek 2018 we had a demoscene oriented project trying out replacing Unity splash screen with single shader Shadertoy-like demos/effects (Check out shadertoy.com, it's awesome!). No promises of the feature ever landing in the mainline product though :P
This repository provides an environment to try out the splash shaders we created with public Unity releases. Won't be played as a splash screen but plenty of fun still.

Editor usage:
- Open the project in Unity
- Open DemoScene.unity
- Main camera contains script component called Effect Handler
  * Assign the shader file to Shader field
  * Unity splash image is used as default texture input but you can override that with Logo Override field
  * Duration field sets the duration of the effect in seconds (use zero for endless playback)
- Press play and you'll see/hear the effect in the game view
- The playmode will automatically stop after the set duration

Shader API (check template.shader for easy starting point):
- The shader file should have two passes, first for graphics and second for audio
- The graphics shader has only single texture (_MainTex) as input which is the Unity splash image by default. The actual image data on the default case can be found in the alpha channel.
- One can use regular unity builtin variables like _Time etc. to control the effect
- The audio shader pre-generates 1k/1k texture of audio data, which gives ~21.8s of playback (plenty for a splash screen)
- Do not use _Time in audio shader but instead the sample time calculated from pixel position (see template shader)

Enjoy hacking!