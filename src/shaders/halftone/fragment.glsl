uniform vec3 uColor;
uniform vec2 uResolution;

varying vec3 vNormal;
varying vec3 vPosition;

#include ../includes/ambientLight.glsl
#include ../includes/directionalLight.glsl

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

    float repetitions = 50.0;

    vec2 uv = gl_FragCoord.xy / uResolution.y;
    uv *= repetitions;
    uv = mod(uv, 1.0);

    // * Points
    //? the uv coord is the left bottom of the cell , so a Distance to a vec2(0.5) returns a circle
    float point = distance(uv, vec2(0.5));

    // Final color
    // gl_FragColor = vec4(uv, 1.0, 1.0);
    gl_FragColor = vec4(point, point, point, 1.0);
    // gl_FragColor = vec4(color, 1.0);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}