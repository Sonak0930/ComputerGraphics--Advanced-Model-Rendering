# Introduction
This project is to practice several techniques to render a model in computer graphics. <br>
It is based on OpenGL and Assimp Library is included for convenience. <br>
The techniques include model loading, lighting(Phong, Blinn-Phong), shadowing(Phong, Gouraud), and texture mapping. <be>

# Snap shots
This includes snapshots for each features. <br>

##  Basic Texture Mapping with Model Loading

https://github.com/user-attachments/assets/10616cc9-12bd-4cc9-9458-4690579fdad0 

this shows how to render a model with texture. <br>
no lighting and shadowing have not been applied yet. <br>

## Orbiting camera

https://github.com/user-attachments/assets/36ebd295-cd76-4dd9-9edc-9f5a509b2fc9

You can move around the model using WASD  <br>
W: Zoom in <br>
A: Rotate around in a counter-clockwise direction <br>
S: Zoom out <br>
D: Rotate around in a clockwise direction <br>

# Phong Lighting 

## Phong Lighting without texture

https://github.com/user-attachments/assets/5d9e39ec-e812-4298-a0ca-9d873e0b2244

To visualize the shading effectively, the texture is turned off. <br>

## Phong Lighting with multiple lights

https://github.com/user-attachments/assets/cd9b7623-f241-43e7-b397-ef06c14c8b7a

3 additional Lights are positioned in the same scene. <br>
Each light has different colors (R,G, and B) <br>

## Diffuse + Specular + Ambient Reflection

https://github.com/user-attachments/assets/679e97b8-76a6-4f78-b0fb-7157f77e4785

Basic Reflections are introduced to visualize the model well. <br>

# Schlick's Fresnel Term

## Fresnel without texture

https://github.com/user-attachments/assets/01b46c84-ebc5-48f5-bd58-e924e7b9ddce

The texture is turned off to visualize the Fresnel well. <br>

## Fresnel with texture

https://github.com/user-attachments/assets/a00d8443-b072-46b5-ae98-6ceda89d0fed

Texture is applied. <br>
You can check if the axe shines when it reflects the light
