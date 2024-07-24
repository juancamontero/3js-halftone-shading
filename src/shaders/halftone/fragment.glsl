uniform vec3 uColor;
uniform vec2 uResolution;

varying vec3 vNormal;
varying vec3 vPosition;

#include ../includes/ambientLight.glsl
#include ../includes/directionalLight.glsl

uniform float uShadowRepetitions;
uniform vec3 uShadowColor;
uniform float uLightRepetitions;
uniform vec3 uLightColor;

//* Halftone function
vec3 halfTone(
    vec3 color,
    float repetitions,
    vec3 direction,
    float low,
    float high,
    vec3 pointColor,
    vec3 normal
) {
     //? usando el dot product teniendo definida una dirección del halftone definimo intensidad
    // * Grid
    //? la idea es tener un GRID de puntos que se quede estático 
    //? y que NO siga a los objetos o a las transformaciones de la cámara
    //? similar a "display:fixed;" en ccs
    
    //? se necesitan entonces las coordenadas  UV de todo el RENDER
    //? Existe gl_FragCoord que justo entrega: X y Y para 2D y  Z y W adicionales para 3D
    //? solo vamos a usar 2D
    //? las ccordenadas xy van como en un plano cartesiano siendo cero la esquina izq inferior
    //! los valores de gl_FragCoord varían hasta los valores del "número de pixeles", por eso si divide por 1200.0
    //  vec2 uv = gl_FragCoord.xy / 1200.0; 
    // //? para normalizar se trae la resolución como una uniforme dentro de un vec2
    //  vec2 uv = gl_FragCoord.xy / uResolution.y;  //? solo utilizar Y para escalar igual todos los vectores
    //  //? para crear la grilla se precisa que el UV se vuelva repetitivo 0 a 1, 0 a 1, segun la posición
    //  uv *= 50.0; //? al multiplicar por este valor incrmento la frecuencia de las coordenadas, creo más divisiones
    //  uv = mod(uv, 1.0); //? con el módulo lo hago repetitivo cada 1.0
    // * Points
    //? the uv coord is the left bottom of the cell , so a Distance to a vec2(0.5) returns a circle
    //* Radio e intensidad
    // El radio de cada disco varía como una sombra, si el 0.5 del step lo multiplico por una valor para que dismonuya
    // point = 1.0 - step(0.5 * 0.3, point); 
    //? usando la intensidad podemos variar el radio
    float intensity = dot(normal, direction);
    intensity = smoothstep(low, high, intensity);

    vec2 uv = gl_FragCoord.xy / uResolution.y;
    uv *= repetitions;
    uv = mod(uv, 1.0);

    float point = distance(uv, vec2(0.5));
    point = 1.0 - step(0.5 * intensity, point);

    

    return mix(color, pointColor, point);
}

void main() {
    vec3 viewDirection = normalize(vPosition - cameraPosition);
    vec3 normal = normalize(vNormal);
    vec3 color = uColor;

    // * Lights
    vec3 light = vec3(0.0);

    light += ambientLight(vec3(1.0), // Light color
    1.0        // Light intensity,
    );

    light += directionalLight(vec3(1.0, 1.0, 1.0), // Light color
    1.0,                 // Light intensity
    normal,              // Normal
    vec3(1.0, 1.0, 0.0), // Light position
    viewDirection,       // View direction
    1.0                  // Specular power
    );

    color *= light; //must be black, lights are off

    // * HALF TONE
     // Halftone
    color = halfTone(
        color,                 // Input color
        uShadowRepetitions,                  // Repetitions
        vec3(0.0, - 1.0, 0.0), // Direction
        - 0.8,                 // Low
        1.5,                   // High
        uShadowColor,   // Point color
        normal                 // Normal
    );

       color = halfTone(
        color,               // Input color
        uLightRepetitions,   // Repetitions
        vec3(1.0, 1.0, 0.0), // Direction
        0.5,                 // Low
        1.5,                 // High
        uLightColor,         // Point color
        normal               // Normal
    );

    gl_FragColor = vec4(color, 1.0);
    
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}