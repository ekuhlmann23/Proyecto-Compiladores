/* lexical grammar */
%lex
%%

\s+                   /* skip whitespace */
[Ss]ume|[Rr]este|[Mm]ultiplique|[Dd]ivida|[Cc]onjuncion|[Dd]isyuncion|[Ii]guales return 'operador'
[Nn]egar return 'operador_unario'
[Dd]eclare return 'comando_declaracion'
[Aa]signe return 'comando_asignacion'
[Ii]mprima return 'comando_impresion'
[Rr]etorne return 'comando_retorno'
[Ii]nvoque return 'comando_invocacion'
[Cc]omentario return 'comando_comentario'
"Nueva linea"|"nueva linea" return 'comando_nueva_linea'
"a" return 'keyword_asignacion'
"con" return 'keyword_parametros'
"que" return 'keyword_funcion'
"de" return 'keyword_miembro_objeto'
"objeto" return 'keyword_objeto'
"lambda" return 'keyword_lambda'
"terminar hilera" return 'terminador_hilera'
"terminar arreglo" return 'terminador_arreglo'
"terminar funcion"|"Terminar funcion" return 'terminador_funcion'
"terminar condicional"|"Terminar condicional" return 'terminador_condicional'
"terminar comentario"|"Terminar comentario" return 'terminador_comentario'
"terminar parametros"|"Terminar parametros" return 'terminador_parametros'
"terminar lambda"|"Terminar lambda" return 'terminador_lambda'
[Vv]ariable|[Ff]uncion|[Pp]arametros? return 'tipo'
"hilera" return 'keyword_hilera'
"arreglo" return 'keyword_arreglo'
[Ss]on return 'keyword_igualdad'
[Ss]i return 'control_si'
[Ee]ntonces return 'control_entonces'
[Ss]ino return 'control_sino'
","|"y" return 'separador'
"." return 'terminador'
[0-9]+(.[0-9]+)? return 'literal_num'
"verdadero"|"falso" return 'literal_bool';
[a-zA-Z_]+[0-9]* return 'id'
<<EOF>> return 'EOF'
/lex

%start S

%% /* language grammar */

S: PROGRAMA;

PROGRAMA: SENTENCIAS EOF {
    typeof console !== 'undefined' ? console.log($1) : print($1);
    return $1;
};

SENTENCIAS:
SENTENCIA
| SENTENCIAS SENTENCIA {
    $$ = $1 + '\n' + $2;
};

LISTA_PARAMETROS:
PARAMETRO
| PARAMETRO separador LISTA_PARAMETROS {
    $$ = $1 + ", " + $3;
};

PARAMETRO: id;

EXPRESIONES:
EXPRESION
| EXPRESION separador EXPRESIONES {
    $$ = $1 + ", " + $3;
};

DECLARACION:
comando_declaracion tipo id terminador {
    $$ = "let " + $3 + ";";
};

RETORNO:
comando_retorno EXPRESION terminador {
    $$ = "return " + $2 + ";";
};

ASIGNACION:
comando_asignacion EXPRESION keyword_asignacion id terminador {
    $$ = $4 + " = " + $2 + ";";
}
| comando_asignacion EXPRESION keyword_asignacion id keyword_miembro_objeto id terminador {
    $$ = $6 + "." + $4 + " = " + $2 + ";";
};

IMPRESION:
comando_impresion EXPRESION terminador {
    $$ = "console.log(" + $2 + ");";
};

FUNCION:
comando_declaracion tipo id keyword_funcion SENTENCIAS terminador_funcion terminador {
    $$ = "function " + $3 + "() {\n"
            + $5  + "\n" +
        "}";
}
| comando_declaracion tipo id keyword_parametros tipo LISTA_PARAMETROS keyword_funcion SENTENCIAS terminador_funcion terminador {
    $$ = "function " + $3 + "(" + $6 + ") {\n"
            + $8  + "\n" +
        "}";
};

CLAUSULA_SI:
control_si EXPRESION control_entonces SENTENCIAS {
    $$ = "if (" + $2 + ") {\n"
            + $4 + "\n"
        + "}";
};

CLAUSULA_SINO:
control_sino SENTENCIAS {
    $$ = "else {\n"
            + $2 + "\n" 
        + "}";
};

CONDICIONAL:
CLAUSULA_SI terminador_condicional terminador
| CLAUSULA_SI CLAUSULA_SINO terminador_condicional terminador {
    $$ = $1 + '\n' + $2;
};

COMENTARIO:
comando_comentario COMENTARIOS terminador {
    $$ = "// " + $2;
};

NUEVA_LINEA:
comando_nueva_linea terminador {
    $$ = "\n";
};

COMENTARIOS:
STR terminador_comentario
| STR COMENTARIOS {
    $$ = $1 + ' ' + $2;
};

SENTENCIA:
DECLARACION
| ASIGNACION
| IMPRESION
| FUNCION
| CONDICIONAL
| COMENTARIO
| RETORNO
| NUEVA_LINEA
| SENTENCIA_EXPRESION;

SENTENCIA_EXPRESION:
EXPRESION terminador {
    $$ = $1 + ";";
};

EXPRESION_FUNCION_LAMBDA:
keyword_lambda keyword_funcion SENTENCIAS terminador_lambda {
    $$ = "() => {\n"
        + $3 + "\n"
    + "}";
}
| keyword_lambda keyword_parametros tipo LISTA_PARAMETROS keyword_funcion SENTENCIAS terminador_lambda {
    $$ = "(" + $4 + ") => {\n"
        + $6 + "\n"
    + "}";
};

EXPRESION_INVOCACION:
comando_invocacion id {
    $$ = $2 + "()";
}
| comando_invocacion id keyword_parametros tipo EXPRESIONES terminador_parametros {
    $$ = $2 + "(" + $5 + ")";
};

EXPRESION_INVOCACION_OBJETO:
comando_invocacion id keyword_miembro_objeto id {
    $$ = $4 + "." + $2 + "()";
}
| comando_invocacion id keyword_miembro_objeto id keyword_parametros tipo EXPRESIONES terminador_parametros {
    $$ = $4 + "." + $2 + "(" + $7 + ")";
};

EXPRESION_OPERADOR_UNARIO:
operador_unario EXPRESION {
    $$ = "!" + $2;
};

EXPRESION_OPERADOR: 
operador EXPRESION separador EXPRESION {
    if ($1 == "sume" || $1 == "Sume") {
        $$ = $2 + " + " + $4;
    }
    else if ($1 == "reste" || $1 == "Reste") {
        $$ = $2 + " - " + $4;
    }
    else if ($1 == "multiplique" || $1 == "Multiplique") {
        $$ = $2 + " * " + $4;
    }
    else if ($1 == "divida" || $1 == "Divida") {
        $$ = $2 + " / " + $4;
    }
    else if ($1 == "conjuncion" || $1 == "Conjuncion") {
        $$ = $2 + " && " + $4;
    }
    else if ($1 == "disyuncion" || $1 == "Disyuncion") {
        $$ = $2 + " || " + $4;
    }
}
| keyword_igualdad operador EXPRESION separador EXPRESION {
    $$ = $3 + " === " + $5;
};

EXPRESION_MIEMBRO_VARIABLE:
id keyword_miembro_objeto id {
    $$ = $3 + '.' + $1;
};

EXPRESION:
EXPRESION_OPERADOR_UNARIO
| EXPRESION_OPERADOR
| EXPRESION_FUNCION_LAMBDA
| EXPRESION_INVOCACION
| EXPRESION_INVOCACION_OBJETO
| EXPRESION_MIEMBRO_VARIABLE
| LITERAL
| VAR;

VAR: id;

LITERAL: LITERAL_BOOL | literal_num | LITERAL_HILERA | LITERAL_ARREGLO | LITERAL_OBJETO;

LITERAL_BOOL: literal_bool {
    if ($1 == "verdadero") {
        $$ = "true";
    }
    else {
        $$ = "false";
    }
};

LITERAL_OBJETO: keyword_objeto {
    $$ = "{}";
};

LITERAL_ARREGLO:
keyword_arreglo terminador_arreglo {
    $$ = "[]";
}
| keyword_arreglo MIEMBROS_ARREGLO {
    $$ = "[" + $2;
};

MIEMBROS_ARREGLO:
EXPRESION terminador_arreglo {
    $$ = $1 + "]";
}
| EXPRESION separador MIEMBROS_ARREGLO {
    $$ = $1 + ", " + $3;
};

LITERAL_HILERA:
keyword_hilera terminador_hilera {
    $$ = '""';
}
| keyword_hilera HILERAS {
    $$ = '"' + $2;
};

HILERAS: STR terminador_hilera {
    $$ = $1 + '"';
}
| STR HILERAS {
    $$ = $1 + ' ' + $2;
};

STR:
id
| operador
| operador_unario
| comando_declaracion
| comando_asignacion
| comando_impresion
| comando_retorno
| comando_invocacion
| comando_comentario
| tipo
| keyword_asignacion
| keyword_parametros
| keyword_funcion
| keyword_hilera
| keyword_arreglo
| terminador_funcion
| terminador_condicional
| terminador_arreglo
| keyword_igualdad
| control_si
| control_entonces
| control_sino
| separador
| terminador
| literal_num
| literal_bool
| terminador_lambda
| keyword_lambda
| objeto;
