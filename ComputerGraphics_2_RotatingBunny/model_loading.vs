#version 430 core
layout(location=0) in vec3 aPos;
layout(location=1) in vec3 aNormal;
layout(location=2) in vec2 aTexCoords;

out vec3 FragPos;
out vec3 Normal;
out vec2 TexCoords;
out vec4 FragPosLightSpace;
out vec4 v_coord;
out vec3 normalDirection;
out vec3 viewDirection;
uniform mat4 model;
uniform mat4 mvp;
uniform mat3 m_3x3_inv_transp;
uniform mat4 v_inv;
uniform mat4 lightSpaceMatrix;





void main()
{

	FragPos= vec3(model*vec4(aPos,1.0));
	Normal=transpose(inverse(mat3(model)))*aNormal;
	TexCoords = aTexCoords;
	FragPosLightSpace= lightSpaceMatrix*vec4(FragPos,1.0);
	v_coord = vec4(aPos.x,aPos.y,aPos.z,1.0);
	normalDirection = normalize(m_3x3_inv_transp*aNormal);
	viewDirection = normalize(vec3(v_inv*vec4(1.0,1.0,1.0,1.0)-model *v_coord));
	gl_Position = mvp*vec4(aPos, 1.0);



}