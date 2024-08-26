#version 430 core
in vec3 FragPos;
in vec3 Normal;
in vec2 TexCoords;
in vec4 FragPosLightSpace;
in vec4 v_coord;
in vec3 normalDirection;
in vec3 viewDirection;


float specularReflectivity = 0.75;
vec3 scene_ambient = vec3(0.3, 0.3, 0.3);

struct lightSource
{
  vec4 position;
  vec3 direction;
  vec4 diffuse;
  vec4 specular;
  float attenuation;
  float constantAttenuation, linearAttenuation, quadraticAttenuation;
  float spotCutoff, spotExponent;
  vec3 spotDirection;
} light;

struct material
{
  vec4 ambient;
  vec4 diffuse;
  vec4 specular;
  float shininess;
} mat;
out vec4 FragColor;


uniform mat4 model;
uniform vec3 lightPos;
uniform vec3 viewPos;
uniform sampler2D texture_diffuse1;
uniform sampler2D texture_specular1;
uniform sampler2D shadowMap;

float attenuation;

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


//from learn opengl
float ShadowCalculation(vec4 fragPosLightSpace)
{
    //perform perspective divide
    vec3 projCoords = fragPosLightSpace.xyz/fragPosLightSpace.w;
    //transform to [0,1] range
    projCoords=projCoords*0.5+0.5;

    //keep the shadow at 0.0 when outside the far_plane region of the light frustum
    if(projCoords.z > 1.0)
    {
        return 0.0;
    }

   
    //get closest depth value from the light's perspective
    //(using [0,1] range fragPosLight as coords)
    float closestDepth=texture(shadowMap,projCoords.xy).r;
    //get depth of current fragment from light's perspective
    float currentDepth = projCoords.z;


    
    //calculate bias (based on depth map resolution and slope)
    vec3 normal = normalize(Normal);
    vec3 lightDir = normalize(lightPos-FragPos);
    float bias = max(0.05*(1.0-dot(normal,lightDir)),0.005);

    //check whether current frag pos is in shadow
    //PCF
    float shadow=0.0;
    vec2 texelSize=1.0/textureSize(shadowMap,0);
    for(int x=-1; x<=1; ++x)
    {
        for(int y=-1; y<=1; ++y)
        {
            float pcfDepth = texture(shadowMap,projCoords.xy+vec2(x,y)*texelSize).r;
            //shadow +=(projCoords.z - 0.005 > pcfDepth? 1.0:0.0);
            shadow+= currentDepth-bias > pcfDepth ? 1.0:0.0;
        }
    }

    shadow /= 9.0;

    
    return shadow;

}


void CalculateAttenuations()
{
   
    //calculate attenuation factor
    //directional light

    vec3 h;
    if(light.position.w==0.0)
    {
        //no attenuation
        light.attenuation = 1.0;
        light.direction = normalize(vec3(light.position));
    }

    //point or spot light
    else
    {
        vec3 vertexToLightSource = vec3(light.position-vec4(FragPos,1.0));
        float distance = length(vertexToLightSource);
        light.direction = normalize(vertexToLightSource);
        attenuation = 1.0/(light.constantAttenuation
        + light.linearAttenuation * distance
        + light.quadraticAttenuation * distance * distance);
    
        //spot light
        if(light.spotCutoff<=90.0f)
        {
            float clampedCosine=max(0.0,dot(-light.direction,normalize(light.spotDirection)));
                
                
            //outside of spotlight cone
            if(clampedCosine < cos(radians(light.spotCutoff)))
            {
                attenuation =0.0;
            }

            else{
                attenuation =  attenuation*pow(clampedCosine,light.spotExponent);
            }
        }
    }
    
}

vec3 CalculateDiffuseReflection()
{
    float diff = max(dot(normalDirection,light.direction),0.0);
    return vec3(light.diffuse*diff);
}

vec3 CalculateSpecularReflection()
{
    vec3 specular=vec3(0.0, 0.0, 0.0);
    
    // light source is not visible
    if(dot(normalDirection,light.direction) < 0.0)
    {
        specular=vec3(0.0, 0.0, 0.0);
    }
    else{

        //h=(lightDirections[i]+viewDirection)/length(lightDirections[i]+viewDirection);
        
        vec3 reflectDir = reflect(-light.direction,normalDirection);
        float cosTheta= dot(light.direction,normalDirection);
        float beta = pow(1-cosTheta,5);
        float pSchlick=mix(specularReflectivity,1.0,beta);
        //light source on the right side.
        specular =  vec3(light.specular)
        *vec3(mat.specular)
        *pSchlick
        *vec3(pow(max(dot(reflectDir, viewDirection),0.0)
        ,mat.shininess));
    }
   
    return specular*vec3(light.specular);
}

vec3 CalculateAmbientReflection()
{
    vec3 ambient=vec3(0.0, 0.0, 0.0);
    
    ambient = vec3(mat.ambient)*vec3(scene_ambient);
  
   

    return ambient;
}

void main()
{
    mat.diffuse = texture(texture_diffuse1,TexCoords);
    mat.specular = texture(texture_specular1,TexCoords);
    mat.ambient = vec4(0.3,0.3,0.3,1.0);
    mat.shininess = 0.5;
    
    light.position = vec4(lightPos,1.0);
    light.direction=normalize(vec3(light.position)-FragPos);    
    light.diffuse = vec4(1.0,  1.0,  1.0, 1.0);
    light.specular = vec4(1.0,  1.0,  1.0, 1.0);
    light.constantAttenuation=0.0;
    light.linearAttenuation=1.0;
    light.quadraticAttenuation=0.0;
    light.spotCutoff=180.0;
    light.spotExponent=0.0;
    light.spotDirection=vec3(0.0, 0.0, 0.0);

    CalculateAttenuations();

    vec3 diffuseColor = CalculateDiffuseReflection();
    vec3 specularColor = CalculateSpecularReflection();
    vec3 ambientColor = CalculateAmbientReflection();

    diffuseColor*=attenuation;
    specularColor*=attenuation;
    float shadow =  1.0-ShadowCalculation(FragPosLightSpace);

    vec4 color = vec4(ambientColor
    + shadow*
    (diffuseColor+specularColor), 1.0)*mat.diffuse;
    FragColor = GammaCorrection(color);

}