vec4 nami_nami(vec2 uv, float rate){
 float PI = 3.14;
 float num_wave = 5.0*rate;
 float num_wave_r = 2.0;
 float r = length(uv);
 float theta = atan(uv.y,uv.x);
 
 vec4 nami_theta = vec4((sin(num_wave*theta + iTime)));
 
 vec4 nami_r = vec4(sin(num_wave_r*sin(iTime*.05)*r*2.*PI + iTime*2.));
 
 return .01/mix(abs(nami_theta), abs(nami_r), .5);

}

vec2 rotate(float theta, vec2 uv)
{
    mat2 mul = mat2(cos(theta), -sin(theta),
                    sin(theta),cos(theta));
    return mul * uv;
    
}

vec4 randomContinuousColor(float value) {
  vec3 rand = vec3(12.9898, 78.233, 45.164);
  float r = fract(sin(dot(rand, vec3(value, floor(iTime), 1.0))) * 43758.5453);
  float g = fract(sin(dot(rand, vec3(value, floor(2.*iTime), 2.0))) * 43758.5453);
  float b = fract(sin(dot(rand, vec3(value, floor(.3*iTime), 3.0))) * 43758.5453);
  return vec4(r, g, b, 1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec2 uv = (fragCoord.xy * 2.0 - iResolution.xy) / iResolution.x;
    float r = fract(length(uv)+.02*iTime);
    float displace = sin(.1*iTime)*( step(0.,uv.y) - .5);
    displace = 0.;
    vec2 st = uv+displace;
    st = rotate(.005*iTime, st);
    float timesx = 1.;
    vec2 sampleuv = fract(abs(timesx*st));
    vec4 spect = texture(iChannel0, sampleuv.xx);
    vec4 spectr = texture(iChannel0, vec2(r,r));
    float rate = 1.;
    vec4 tex = texture(iChannel1, st);
    fragColor = 10.*tex;
    fragColor *= 5.*vec4(spect.x*randomContinuousColor(1.));
    fragColor *= 5.*vec4(spectr.x*randomContinuousColor(1.));
    fragColor *= 5.*nami_nami(uv, rate);
}