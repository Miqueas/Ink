# TermColors

Colorea la salidad de tus scripts en Lua con TermColors! Tan simple como:

```lua
local tc = require("TermColors")
local my_string = "Hello, #{FG(Green)}world!#{None}"

tc:print(my_string)
```

Y obtienes una salidad así:

![Capture 1](cap1.png)

Sin embargo eso es solo una muestra simple, puedes hacer cosas más complejas como:

```lua
local tc = require("TermColors")
local my_string = "#{Bold}This#{None} #{Blink; Italic}is#{None} #{Reverse; FG(RGB(167, 110, 78))}a#{None} #{DobleU; Strike}more#{None} #{BG(146)}complex#{None} example."

tc:print(my_string)
```

Salida:

![Capture 2](cap2.png)

La palabra "is" aquí tiene el efecto "Blink", es por eso que no se puede apreciar en la captura.

### Uso

Usar TermColors es realmente simple, solamente coloca las propiedades de salida que deseas dentro de `#{}`, separa cada una con puntos y coma (;) y TermColors hace lo demás. TermColors permite las siguientes propiedades:

  - "Efectos":
    * None (reinicia/deshabilita todas las propiedades)
    * Bold
    * Dim
    * Italic
    * Underline
    * Blink
    * Reverse
    * Hidden
    * Strike
    * DobleU ("Doble Underline")
  - Colores: los colores solo se pueden usar con las funciones `FG()` (Foreground) y `BG()` (Background).
    * Black
    * Red
    * Green
    * Yellow
    * Blue
    * Magenta
    * Cyan
    * White

Las funciones `FG()` y `BG()` toman 3 tipos de argumentos y solo 1 de estos a la vez:
  1. Un color predefinido (de los que se ven en la lista anterior). [Lee esto][1] para detalles.
  2. Un número del 0 al 255. [Lee esto][2]
  3. Un valor RGB usando la función `RGB()`. [Lee esto][3]

TermColors es sensible a mayúsculas y minúsculas, sabe que `FG` es una función para el color del texto en sí, pero `fg` es otra cosa. También, TermColors provee 2 funciones/métodos:

  1. `compile()`: toma un string, convierte todos los grupos `#{}` en una secuencia de escape ANSI y retorna el resultado.
  2. `print()`: toma un string, se lo pasa a `compile()` e imprime el resultado directamente (no retorna).

Por supuesto, si deseas usar códigos ANSI manualmente, TermColors provee:

  - `TermColors.ESC`: el caracter utilizado para esto (`0x1b`).
  - `TermColors.Attr`: puede que el nombre no sea correcto, pero básicamente contiene los números/códigos para los "efectos".
  - `TermColors.FG`: contiene colores predefinidos (los que se ven en la primera lista). Puedes usarlos así:
    ```lua
    local tc = require("TermColors")
    local my_string = tc.ESC .. "[" .. tc.FG.Green .. "mTesting!" .. tc.ESC .. "[" .. tc.Attr.None
    print(my_string)
    ```
  - `TermColors.BG`: igual que `FG`, pero para colores de fondo.

__Es muy importante separar las propiedades con puntos y comas (por favor lee "Limitaciones" a continuación).__

### Limitaciones

Si no se usan los puntos y comas apropiadamente, la salida podría ser errónea debido a que el código de TermColors actualmente es simple y no analiza estos detalles. Es lo mismo en el caso cuando se colocan varios puntos y comas vacíos (sin propiedades entre ellos). Puede ser que hay otras limitaciones, pero por ahora estas son las que conozco

Por supuesto, estas cosas están en "TODO" ("Por Hacer") y quiero mejorar TermColors.

### Fuentes

Hice esta librería con la información provista por [este artículo][4] de Wikipedia

[1]: https://en.wikipedia.org/wiki/ANSI_escape_code#3/4_bit
[2]: https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
[3]: https://en.wikipedia.org/wiki/ANSI_escape_code#24-bit
[4]: https://en.wikipedia.org/wiki/ANSI_escape_code