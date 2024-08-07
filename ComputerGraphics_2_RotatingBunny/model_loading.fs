#version 430 core
in vec2 TexCoords;
in vec4 color;
out vec4 FragColor;


vec4 GammaCorrection(vec4 color) {
    vec4 correctedColor;
    for(int i = 0; i < 3; i++) {
        if (color[i] <= 0.0031308) {
            correctedColor[i] = 12.92 * color[i];
        } else if (color[i] <= 1.0) {
            correctedColor[i] = 1.055 * pow(color[i], 1.0 / 2.4) - 0.055;
        } else {
            correctedColor[i] = color[i]; // Ensure color stays within valid range
        }
    }
    correctedColor.a = color.a; // Preserve alpha channel
    return correctedColor;
}

void main()
{
    
    FragColor = GammaCorrection(color);
     

    //FragColor = texture(texture_diffuse1,TexCoords);
}