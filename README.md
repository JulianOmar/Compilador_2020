# Compilador_2020
El presente complilador fue realizado durante el segundo cuatrimentre 2019, el cual cuenta con los siguientes temas asignados:
- Constantes con nombre
- Filter 
- Tercetos

Temas especial asignado en la corriente cursada 2020:
- Asignaciones Especiales

### Comados de uso
Ejecución desde consola de comandos: ``` > GeneraExe.bat ```

###### ASIGNACIONES 
Asignaciones simples  `A=B`
                      `A=2`
###### Tipo de dato
El separador decimal será el punto “.”
Ejemplo:
```C 
a = 99999.99
a = 99.
a = .9999
```                     

###### COMENTARIOS
Deberán estar delimitados por “--/” y “/--” y podrán estar anidados en un solo nivel.
Ejemplo1:

``` c
--/ Realizo una selección /--
IF (a <= 30)
b = ”correcto” --/ asignación string /-- ENDIF
```

Ejemplo2:

``` c
--/ Así son los comentarios en el 2°Cuat de LyC --/ Comentario /-- /--
Los comentarios se ignoran de manera que no generan un componente léxico o token
```


##### DECLARACIONES
Todas las variables deberán ser declaradas dentro de un bloque especial para ese fin, delimitado por las palabras reservadas VAR y ENDVAR, siguiendo el formato:

```
VAR
[ Tipo de Dato ] : [ Lista de Variables]
ENDVAR
```
Ejemplos de formato: VAR
```
[Integer, Float, Integer] : [a, b, c]
ENDVAR
```
En este ejemplo, la variable a será de tipo Integer, b de tipo Float y c de tipo Integer


### TEMAS ESPECIALES
1. **Constantes Con Nombre**

Las constantes con nombre podrán ser reales, enteras, string. El nombre de la constante no debe existir
previamente. Se definen de la forma CONST variable = cte, y tal como indica su definición, no cambiaran
su valor a lo largo de todo el programa.
Las constantes pueden definirse en cualquier parte dentro del cuerpo del programa.
Ejemplo:
```
--/ Constantes con Nombre /--
CONST pivot=30
CONST str =”Ingrese cantidad de días”
```
**Las constantes con nombre pueden guardar su valor en tabla de símbolos.**

2. **Filter**

Esta función del lenguaje tomará como entrada una condición especial y una lista de variables y
devolverá la primera variable que cumpla con la condición especificada
```
FILTER (Condición, [ lista de variables] )
```
Condición es una sentencia de condición simple o múltiple, cuyo lado izquierdo debe ser un guion
bajo que hace referencia a cada elemento de la lista de enteros, y su lado derecho una expresión.
Lista de variables es una lista sin límite de variables
Ej.
```
FILTER ( _>(4 + r) and _<=6.5 , [a,b,c,d])
```

3. **Asignaciones especiales (tema nuevo asignado)**

Se consideran aquellas asignaciones que tienen el siguiente formato:
```
Identificador += Identificador
Identificador -= Identificador
Identificador *= Identificador
Identificador /= Identificador
```
