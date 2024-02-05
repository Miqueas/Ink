[![License][LicenseBadge]][licenseURL]

# Ink

Colorea la salidad de tus scripts en Lua con Ink! Tan simple como:

```lua
local ink = require("Ink")
local my_string = "Hello, #{FG(Green)}world!#{None}"

ink:print(my_string)
```

Y obtienes una salida así:

![Capture 1](cap1.png)

Puedes formar salidas mas complejas como:

```lua
local ink = require("Ink")
local my_string = "#{Bold}Estes#{None} #{Blink; Italic}es#{None} #{Reverse; FG(RGB(167, 110, 78))}un#{None} #{DobleU; Strike}ejemplo#{None} #{BG(146)}mas#{None} %s"
local my_format = "complejo."

ink:print(my_string, my_format)
```

Salida:

![Capture 2](cap2_esp.png)

### Uso

Usar Ink es muy simple; Coloca las propiedades de salida que deseas dentro de `#{}`, separa cada una con puntos y coma (;) y Ink hace lo demás. Ink soporta las siguientes propiedades:

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

Ink es sensible a mayúsculas y minúsculas, sabe que `FG` es una función para el color del texto en sí, pero `fg` es otra cosa. También, Ink provee 2 funciones/métodos:

  1. `compile()`: toma un string, convierte todos los grupos `#{}` en una secuencia de escape ANSI y retorna el resultado.
  2. `print()`: toma un string, lo `format()`ea con los demas argumentos, se lo pasa a `compile()` e imprime el resultado directamente (no retorna).

Por supuesto, si deseas usar códigos ANSI manualmente, Ink provee:

  - `Ink.Cache`: De proposito interno, contiene todas las strings cacheadas.
  - `Ink.DisableCache`: Desactiva el cache si es `true`, `false` por defecto.
  - `Ink.ESC`: El caracter utilizado para esto (`0x1b`).
  - `Ink.Attr`: Puede que el nombre no sea correcto, pero básicamente contiene los números/códigos para los "efectos".
  - `Ink.FG`: Contiene colores predefinidos (los que se ven en la primera lista). Puedes usarlos así:
    ```lua
    local ink = require("Ink")
    local my_string = ink.ESC .. "[" .. ink.FG.Green .. "mTesting!" .. ink.ESC .. "[" .. ink.Attr.None
    print(my_string)
    ```
  - `Ink.BG`: Igual que `FG`, pero para colores de fondo.

__Es muy importante separar las propiedades con puntos y comas (por favor lee "Limitaciones" a continuación).__

### Limitaciones

Si no se usan los puntos y comas apropiadamente, la salida podría ser errónea debido a que el código de Ink actualmente es simple y no analiza estos detalles. Es lo mismo en el caso cuando se colocan varios puntos y comas vacíos (sin propiedades entre ellos). Puede ser que hay otras limitaciones, pero por ahora estas son las que conozco

Por supuesto, estas cosas están en "TODO" ("Por Hacer") y quiero mejorar Ink.

### Fuentes

Hice esta librería con la información provista por [este artículo][4] de Wikipedia

[1]: https://en.wikipedia.org/wiki/ANSI_escape_code#3/4_bit
[2]: https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
[3]: https://en.wikipedia.org/wiki/ANSI_escape_code#24-bit
[4]: https://en.wikipedia.org/wiki/ANSI_escape_code
[LicenseBadge]: https://img.shields.io/badge/Licencia-Zlib-brightgreen?style=for-the-badge
[LicenseURL]: https://opensource.org/licenses/Zlib
