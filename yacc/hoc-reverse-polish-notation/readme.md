# Notación Polaca Inversa

El conjunto de símbolos validos es:

    + Símbolo de suma:
            Uso: expr1 expr2 +
            Resultado: expr1 + expr2

    - Símbolo de resta:
            Uso: expr1 expr2 -
            Resultado: expr1 - expr2

    * Símbolo de producto:
            Uso: expr1 expr2 *
            Resultado: expr1 * expr2

    / Símbolo de division:
            Uso: expr1 expr2 /
            Resultado: expr1 / expr2

    ^ Símbolo de potencia:
            Uso: expr1 expr2 ^
            Resultado: expr1 ^ expr2

    m Símbolo de cambio de signo:         
            Uso: expr1 m
            Resultado: - expr

La gramática que describe este conjunto de operaciones es:

    expr -> NUMERO |
            | expr expr + | expr expr -
            | expr expr * | expr expr /
            | expr expr ^ | expr m

Estructura del código:
    Un programa escrito en yacc se divide en tres partes, definiciones, analizador sintáctico y código. En este caso el analizador sintáctico está dentro del propio código C ya que es muy simple (solo tiene que localizar numeros, que pueden ser fraccionarios)
