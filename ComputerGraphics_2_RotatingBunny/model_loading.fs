#version 430 core
in vec2 TexCoords;
in vec4 color;
out vec4 FragColor;



void main()
{
    FragColor = color;
   //FragColor = texture(texture_diffuse1,TexCoords);
}