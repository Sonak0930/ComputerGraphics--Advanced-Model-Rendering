#version 430 core
layout(location=0) in vec3 aPos;
layout(location=1) in vec3 aNormal;
layout(location=2) in vec2 aTexCoords;

out vec2 TexCoords;
out vec4 color;
uniform mat4 m;
uniform mat4 v;
uniform mat4 p;
uniform mat4 mvp;
uniform mat3 m_3x3_inv_transp;
uniform mat4 v_inv;
uniform sampler2D texture_diffuse1;
uniform sampler2D texture_specular1;

struct lightSource
{
  vec4 position;
  vec4 diffuse;
  vec4 specular;
  float constantAttenuation, linearAttenuation, quadraticAttenuation;
  float spotCutoff, spotExponent;
  vec3 spotDirection;
};
lightSource light0 = lightSource(
  vec4(0.0,  1.0,  2.0, 1.0),
  vec4(1.0,  1.0,  1.0, 1.0),
  vec4(1.0,  1.0,  1.0, 1.0),
  0.0, 1.0, 0.0,
  180.0, 0.0,
  vec3(0.0, 0.0, 0.0)
);

lightSource light1 = lightSource(
	vec4(1.0, 1.5, 1.0, 1.0),
	vec4(1.0, 1.0, 1.0, 1.0),
	vec4(1.0, 1.0, 1.0, 1.0),
	0.0,1.0,0.0,
	130.0 ,0.0,
	vec3(0.0, 0.0, 0.0)
);

lightSource light2 = lightSource(
	vec4(1.0, 1.0, 0.0, 1.0),
	vec4(1.0, 1.0, 1.0, 1.0),
	vec4(1.0, 1.0, 1.0, 1.0),
	0.0,1.0,0.0,
	100.0 ,0.0,
	vec3(0.0, 0.0, 0.0)
);
vec3 scene_ambient = vec3(0.05, 0.05, 0.05);

int numOfLights=3;
lightSource[3] lights;
vec3[3] lightDirections;
vec3[3] ambientLights;
vec3[3] specularReflections;
vec3[3] diffuseReflections;
float[3] attenuations;

struct material
{
  vec4 ambient;
  vec4 diffuse;
  vec4 specular;
  float shininess;
};

material[3] mymaterials;
material mymaterial0 = material(
  vec4(0.2, 0.2, 0.2, 1.0),
  vec4(1.0, 0.8, 0.8, 1.0),
  vec4(1.0, 1.0, 1.0, 1.0),
  5.0
);

material mymaterial1 = material(
  vec4(0.2, 0.2, 0.2, 1.0),
  vec4(1.0, 0.8, 0.8, 1.0),
  vec4(1.0, 1.0, 1.0, 1.0),
  5.0
);

material mymaterial2 = material(
  vec4(0.2, 0.2, 0.2, 1.0),
  vec4(1.0, 0.8, 0.8, 1.0),
  vec4(1.0, 1.0, 1.0, 1.0),
  5.0
);

float specularReflectivity = 0.75;

vec4 v_coord;
vec3 v_normal;
vec3 normalDirection;
vec3 viewDirection;
vec3 customReflect(vec3 I ,vec3 N)
{
	return I-2.0*dot(N,I)*N;
}

void CalculateAttenuations()
{
	for(int i=0; i<numOfLights; i++)
	{
		//calculate attenuation factor
		//directional light

		vec3 h;
		if(lights[i].position.w==0.0)
		{
			//no attenuation
			attenuations[i] = 1.0;
			lightDirections[i] = normalize(vec3(lights[i].position));
		}

		//point or spot light
		else
		{
			vec3 vertexToLightSource = vec3(lights[i].position-m*v_coord);
			float distance = length(vertexToLightSource);
			lightDirections[i] = normalize(vertexToLightSource);
			attenuations[i] = 1.0/(lights[i].constantAttenuation
			+ lights[i].linearAttenuation * distance
			+ lights[i].quadraticAttenuation * distance * distance);
	
			//spot light
			if(lights[i].spotCutoff<=90.0f)
			{
				float clampedCosine=max(0.0,dot(-lightDirections[i],normalize(lights[i].spotDirection)));
				
				
				//outside of spotlight cone
				if(clampedCosine < cos(radians(lights[i].spotCutoff)))
				{
					attenuations[i] =0.0;
				}

				else{
					attenuations[i] = attenuations[i]*pow(clampedCosine,lights[i].spotExponent);
				}

			}
		}
	}
}

vec3 CalculateDiffuseReflection()
{
	vec3 diffuse=vec3(0.0, 0.0, 0.0);
	for(int i=0; i<numOfLights; i++)
	{
		diffuseReflections[i] = attenuations[i]
			* vec3(lights[i].diffuse) * vec3(mymaterials[i].diffuse)
			* max(0.0, dot(normalDirection, lightDirections[i]));
		
		diffuse += diffuseReflections[i];
	}

	return diffuse;
}

vec3 CalculateSpecularReflection()
{
	vec3 specular=vec3(0.0, 0.0, 0.0);
	for(int i=0; i<numOfLights; i++)
	{
		// light source is not visible
		if(dot(normalDirection,lightDirections[i]) < 0.0)
		{
			specularReflections[i]=vec3(0.0, 0.0, 0.0);
		}

		else{

			//h=(lightDirections[i]+viewDirection)/length(lightDirections[i]+viewDirection);
			
			float cosTheta= dot(lightDirections[i],normalDirection);
			float beta = pow(1-cosTheta,5);
			float pSchlick=mix(specularReflectivity,1.0,beta);
			//light source on the right side.
			specularReflections[i] = attenuations[i] * vec3(lights[i].specular)
			* pSchlick
			* vec3(mymaterials[i].specular) 
			* pow(max(0.0, dot(reflect(-lightDirections[i], normalDirection), viewDirection)),
	      mymaterials[i].shininess);
		}
		specular += specularReflections[i];
	}

	return specular;
}

vec3 CalculateAmbientReflection()
{
	vec3 ambient=vec3(0.0, 0.0, 0.0);
	for(int i=0; i<numOfLights; i++)
	{
		ambientLights[i] = vec3(scene_ambient);
		ambient+=ambientLights[i];
	}

	return ambient;
}
void main()
{
	v_coord = vec4(aPos.x,aPos.y,aPos.z,1.0);
	v_normal = aNormal;
	normalDirection = normalize(m_3x3_inv_transp*v_normal);
	viewDirection = normalize(vec3(v_inv*vec4(0.0,0.0,0.0,1.0)-m *v_coord));
	mymaterials[0].diffuse = texture(texture_diffuse1,aTexCoords);
	mymaterials[1].diffuse = texture(texture_diffuse1,aTexCoords);
	mymaterials[2].diffuse = texture(texture_diffuse1,aTexCoords);

	mymaterials[0].specular = texture(texture_specular1,aTexCoords);
	mymaterials[1].specular = texture(texture_specular1,aTexCoords);
	mymaterials[2].specular = texture(texture_specular1,aTexCoords);

	lights[0]=light0;
	lights[1]=light1;
	lights[2]=light2;

	CalculateAttenuations();
	vec3 diffuseColor = CalculateDiffuseReflection();
	vec3 specularColor = CalculateSpecularReflection();
	vec3 ambientColor = CalculateAmbientReflection();
	color= vec4(diffuseColor+ambientColor+specularColor,1.0);
	TexCoords = aTexCoords;
	gl_Position=mvp*vec4(aPos,1.0);
}