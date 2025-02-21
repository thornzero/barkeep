#version 460 core

precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform sampler2D uTexture;       // Input channel
uniform vec3      iResolution;    // Viewport resolution (in pixels)
uniform float     iTime;          // Shader playback time (in seconds)

out vec4 fragColor;

float random (vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}

float blend(const in float x, const in float y) {
	return (x < 0.5) ? (2.0 * x * y) : (1.0 - 2.0 * (1.0 - x) * (1.0 - y));
}

vec3 blend(const in vec3 x, const in vec3 y, const in float opacity) {
	vec3 z = vec3(blend(x.r, y.r), blend(x.g, y.g), blend(x.b, y.b));
	return z * opacity + x * (1.0 - opacity);
}

void main() {
    float opacityScanline = 0.1;
    float opacityNoise = 0.7;
    float flickering = 0.5;
    float scanlineCount = iResolution.y * 1.2;

    vec2 uv = FlutterFragCoord().xy / iResolution.xy;
    vec3 col = texture(uTexture, uv).rgb;
    
    // Calculate density based on desired scanline count and resolution
    float density = scanlineCount / iResolution.y;

    // Apply calculated density to create scanlines
    vec2 sl = vec2(sin(uv.y * iResolution.y * density), cos(uv.y * iResolution.y * density));
    vec3 scanlines = vec3(sl.x, sl.y, sl.x);

    col += col * scanlines * opacityScanline;
    col += col * vec3(random(uv * iTime)) * opacityNoise;
    col += col * sin(110.0 * iTime) * flickering;

    fragColor = vec4(col, 1.0);
}
