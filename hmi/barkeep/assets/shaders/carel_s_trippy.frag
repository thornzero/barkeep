#version 460 core

precision mediump float;

#include <flutter/runtime_effect.glsl>
/*
 Strobing lights effect warning! Discretion is advised.
 This is a (trippy) Audio Visualizer. Reads the audio file from iChannel0, extracts the fft coefficients and use it for the visuals.
 Also, uses the energy for additional effects.
*/

#define SAMPLERATE iSampleRate
// These brackets are required because the preprocessor is dumb
#define MAX_F (0.25 * SAMPLERATE)
// Reference note for the conversions between note/octave and frequency, a good default is C4, aka middle C, 261.63 Hz
#define REF_NOTE 261.63

uniform sampler2D uTexture; // Input channel
uniform vec3 iResolution; // Viewport resolution (in pixels)
out vec4 fragColor;

vec3 pal(float t, vec3 a, vec3 b, vec3 c, vec3 d ) {
    return a + b*cos( 6.28318*(c*t+d) );
}

float cubicInOut(float t) {
    if (t < 0.5) {
        return 4.0 * t * t * t;
    } else {
        float f = ((2.0 * t) - 2.0);
        return 0.5 * f * f * f + 1.0;
    }
}

float progress(float t) {
    return mix(smoothstep(0.0, 1.0, t), cubicInOut(t), t);
}

vec2 fishEyeLens(vec2 uv, float strength) {
    
    float aspectRatio = iResolution.x / iResolution.y;
    
    // Convert UV to polar coordinates
    float radius = length(uv);
    float angle = atan(uv.y, uv.x);

    // Apply fisheye distortion
    radius = sqrt(1.0 - exp(-radius * strength)) / sqrt(1.0 - exp(-strength));
    
    // Convert back to Cartesian coordinates
    uv.x = radius * cos(angle);
    uv.y = radius * sin(angle);
    uv = 0.5 * (uv + 1.0);
    
    // Remap the UV coordinates back to the screen space
    return uv;
}

float sdEquilateralTriangle(vec2 p, float r )
{
    const float k = sqrt(3.0);
    p.x = abs(p.x) - r;
    p.y = p.y + r/k;
    if( p.x+k*p.y>0.0 ) p = vec2(p.x-k*p.y,-k*p.x-p.y)/2.0;
    p.x -= clamp( p.x, -2.0*r, 0.0 );
    return -length(p)*sign(p.y);
}

float sdSnowflakeTriangle(vec2 p, float r, float iterations) {
    float k = sqrt(3.0);
    p.x = abs(p.x) - r;
    p.y = p.y + r / k;
    if (p.x + k * p.y > 0.0) {
        p = vec2(p.x - k * p.y, -k * p.x - p.y) / 2.0;
    }
    p.x -= clamp(p.x, -2.0 * r, 0.0);
    
    // Apply the snowflake fractal
    for (float i = 0.; i < iterations; i++) {
        p = abs(p) - r;
        p *= 0.5;
        p = mat2(cos(3.14159 / 3.0), -sin(3.14159 / 3.0), sin(3.14159 / 3.0), cos(3.14159 / 3.0)) * p;
    }
    
    return -length(p) * sign(p.y);
}

void main() {
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = FlutterFragCoord().xy / iResolution.xy; // Clip space
    vec2 uv0 = uv * 2.0 - 1.0;
    uv0.x *= iResolution.x / iResolution.y; // Normalized clip space + aspect ratio
    vec2 uv1 = uv0;

    //Init color variable
    vec3 finalColor = vec3(1.0);
    
    float buff = 512.0; // Audio buffer size
    float bpm = 78.0; // Tempo in bpm
    float f = bpm / 60.0; // Tempo in Hz
    float T = 1.0 / f;
    float w = 2.0 * 3.14159 * f; // Tempo in rad/s
    
    //Fetch frequency data from audio in iCh0
    //Make it radial
    float rad = pow(length(uv0), 2.0) * 0.24;
    float rad_buff = rad * buff;
    float fft = texelFetch(iChannel0, ivec2(rad_buff,0), 0 ).x;
    
    //fft(freq/MAX_F);
    
    //convert freq to color
    vec3 col = vec3(fft);
    col = smoothstep(0.0,0.7,col);
    col *= pal(rad,vec3(0.520,0.520,0.520),vec3(0.500,0.500,0.500),vec3(1.000,1.000,1.000),vec3(6.067,6.350,6.683) );
    //Compute average energy and energy per band
    float energy = 0.0, lows = 0.0, mids = 0.0, highs = 0.0;
    for (int i = 0; i<int(buff);++i) {
        energy += texelFetch(iChannel0, ivec2(i,0),0).x;
        if (i<int(buff/3.))
            lows += texelFetch(iChannel0, ivec2(i,0),0).x;
        else if (i<int(2.*buff/3.))
            mids += texelFetch(iChannel0, ivec2(i,0),0).x;
        else
            highs += texelFetch(iChannel0, ivec2(i,0),0).x;
    }
    energy /= buff;
    lows /= buff / 3.0;
    mids /= buff / 3.0;
    highs /= buff / 3.0;
    
    //energy will have kind of a sigmoidal shape in the range X(0,1) -> Y(0,1)
    energy = progress(energy);
    lows = progress(lows);
    mids = progress(mids);
    highs = progress(highs);
    float numIterations = energy * 3.0; //same shape scaled X(0,1) -> Y(0,3)
    numIterations = smoothstep(0.0, 1.0, numIterations);
    
    //spherical contour
    float r = 0.3;
    float sph = 1.0;
    sph = length(uv1* lows);
    sph -= 6.0 * r;
    sph = abs(sph);
    sph = smoothstep(0.2, 1.0, sph);
    
    finalColor *= sph;
    finalColor *= col;
    //for (float i = 0.; i<1.;i++){
        float tri= 1.0;
        tri = sdSnowflakeTriangle(uv1, r * energy * T, 3.0);
        tri = abs(tri);
        tri = smoothstep(0.0, 1.0, tri);
        //tri = smoothstep(0.0, 1.0, tri);
        //tri = sdEquilateralTriangle(uv1, r * energy * 1.5);
        tri = sin(100.0 * tri + sin(0.5 * T * iTime) * 2.0 / T) / 100.0;
        tri = abs(tri);
        tri = energy * 0.02 / tri;
        //tri *= 1.0 / numIterations;

        col *= tri;
    //}
    finalColor *= col;
    //HDR
    finalColor = finalColor / (finalColor + vec3(1.0));
    finalColor = pow(finalColor, vec3(1.0 / 2.2));
    fragColor = vec4(finalColor, 1.0);
}
