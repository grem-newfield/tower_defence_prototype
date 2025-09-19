// Grok:
// sRGB to Oklab tone mapping
// Simple perceptual tone mapping using Oklab space

// Oklab conversion functions
vec3 linear_srgb(vec3 c) {
    vec3 lo = vec3(0.4124, 0.2126, 0.0193);
    vec3 m1 = vec3(0.4124564, 0.3575761, 0.1804375);
    vec3 m2 = vec3(0.2126729, 0.7151522, 0.0721750);
    vec3 m3 = vec3(0.0193339, 0.1191920, 0.9503041);
    
    vec3 X = dot(c, m1);
    vec3 Y = dot(c, m2);
    vec3 Z = dot(c, m3);
    
    X = X * X * X;
    Y = Y * Y * Y;
    Z = Z * Z * Z;
    
    return vec3(X, Y, Z);
}

vec3 oklab(vec3 c) {
    vec3 lms = linear_srgb(c);
    
    float l_ = cbrt(lms.x);
    float m_ = cbrt(lms.y);
    float s_ = cbrt(lms.z);
    
    float l = 0.2104542553*l_ + 0.7936177850*m_ - 0.0040720468*s_;
    float a = 1.9779984951*l_ - 2.4285922050*m_ + 0.4505937099*s_;
    float b = 0.0259040371*l_ + 0.7827717662*m_ - 0.8086757660*s_;
    
    return vec3(l, a, b);
}

vec3 oklab_to_linear_srgb(vec3 lab) {
    float l_ = lab.x + 0.3963377774 * lab.y + 0.2158037573 * lab.z;
    float m_ = lab.x - 0.1055613458 * lab.y - 0.0638541728 * lab.z;
    float s_ = lab.x - 0.0894841775 * lab.y - 1.2914855480 * lab.z;
    
    float l = l_ * l_ * l_;
    float m = m_ * m_ * m_;
    float s = s_ * s_ * s_;
    
    float r = +4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s;
    float g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s;
    float b = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s;
    
    return vec3(r, g, b);
}

// Simple Oklab-based tone mapping
vec3 tone_map_oklab(vec3 color, float exposure) {
    // Convert to Oklab
    vec3 lab = oklab(color);
    
    // Tone map L channel (perceptual brightness)
    lab.x = exposure * lab.x;
    
    // Simple filmic curve on L channel
    lab.x = lab.x * (6.2 * lab.x + 0.5) / (lab.x * (6.2 * lab.x + 1.7) + 0.06);
    
    // Clamp L channel
    lab.x = clamp(lab.x, 0.0, 1.0);
    
    // Optional: soft clip ab channels to prevent oversaturation
    float max_chroma = 0.15;
    float chroma = length(lab.yz);
    if (chroma > max_chroma) {
	lab.yz = (lab.yz / chroma) * max_chroma;
    }
    
    // Convert back to sRGB
    vec3 linear = oklab_to_linear_srgb(lab);
    vec3 srgb = pow(linear, vec3(1.0/2.2));
    
    return clamp(srgb, 0.0, 1.0);
}

// Gamma correction for sRGB
vec3 srgb_to_linear(vec3 c) {
    return pow(c, vec3(2.2));
}

vec3 linear_to_srgb(vec3 c) {
    return pow(c, vec3(1.0/2.2));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    // Sample HDR input
    vec4 color = texture(iChannel0, uv);
    
    // Convert sRGB to linear
    vec3 linear_color = srgb_to_linear(color.rgb);
    
    // Apply Oklab tone mapping with exposure
    float exposure = 1.0; // Adjust this value
    vec3 tone_mapped = tone_map_oklab(linear_color, exposure);
    
    // Apply simple vignette for extra polish
    vec2 vig_uv = uv * 2.0 - 1.0;
    float vig = 1.0 - dot(vig_uv, vig_uv) * 0.3;
    tone_mapped *= vig;
    
    fragColor = vec4(tone_mapped, color.a);
}
