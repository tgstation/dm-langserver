﻿//This for a preproccessed DM grammar where includes and defines are inlined. Also all blocks are surrounded with {}
grammar DM;

tokens { ID, PROC, IF, SWITCH, FOR, WHILE, VAR, DATUM, ATOM, OBJ, MOB, TURF, AREA, STATIC, GLOBAL, RETURN, SLASH, EQUALS, STAR, PLUS, MINUS, IN, SEMI, SQUOTE, DQUOTE, NULL, NUMBER, DOT, LPAREN, RPAREN, LCURL, RCURL, TRUE, FALSE, LBRACE, RBRACE, BSLASH, NOT, LTHAN, GTHAN, AND, OR, WS, LIST, COMMA, COLON, ESCAPED_DQUOTE, XOR, ELSE, SPAWN, STEP, TO, DQSTRING, SQSTRING, WORLD }

WS : [ \t\r\n]+ -> skip ;
DOT: '.';
ID : [a-zA-Z_][a-zA-Z0-9_\-]* ;             // match lower-case identifiers
NUMBER: [0-9]+;
TRUE: 'TRUE';
FALSE: 'FALSE';
DQUOTE: '"';
SQUOTE: '\'';
LBRACE: '[';
RBRACE: ']';
SLASH: '/';
BSLASH: '\\';
NOT: '!';
DATUM: 'datum';
ATOM: 'atom';
PROC: 'proc';
NULL: 'null';
RETURN: 'return';
STATIC: 'static';
GLOBAL: 'global';
OBJ: 'obj';
MOB: 'mob';
TURF: 'turf';
AREA: 'area';
IN: 'in';
LPAREN: '(';
RPAREN: ')';
MINUS: '-';
PLUS: '+';
STAR: '*';
EQUALS: '=';
TAB: '\t';
VAR: 'var';
SWITCH: 'switch';
IF: 'if';
FOR: 'for';
WHILE: 'while';
AND: '&';
OR: '|';
LTHAN: '<';
GTHAN: '>';
LCURL: '{';
RCURL: '}';
SEMI: ';';
LIST: 'list';
COMMA: ',';
COLON: ':';
XOR: '^';
ELSE: 'else';
SPAWN: 'spawn';
WORLD: 'world';
STEP: 'step';
TO: 'to';
DQSTRING : ~('\r' | '\n' | '"')+ ;
SQSTRING : ~('\r' | '\n' | '\'')+ ;

language : definition | definition language ;
definition : root_var_def | datum_def | proc_def;

optional_slash : SLASH | ;

string_text: BSLASH LBRACE string_text | embedded_expression string_text | BSLASH DQUOTE string_text | DQSTRING string_text | DQSTRING;

root_var_def: optional_slash var_def;
var_def : VAR id_typepath_decl | VAR optional_slash LBRACE id_typepath_decl_block RBRACE ;
id_typepath_decl_block : id_typepath_decl id_typepath_decl_block| id_typepath_decl;
id_typepath_decl : id_typepath | static_or_global SLASH id_typepath | static_or_global optional_slash LBRACE id_typepath_block RBRACE;
static_or_global : STATIC | GLOBAL;
id_typepath_block:  id_typepath id_typepath_block | id_typepath;
id_typepath: root_type SLASH custom_id_typepath | root_type optional_slash LBRACE custom_id_typepath_block RBRACE; 
custom_id_typepath_block: custom_id_typepath custom_id_typepath_block | custom_id_typepath;
custom_id_typepath: id_and_assignment SEMI | ID SLASH custom_id_typepath | ID optional_slash LBRACE custom_id_typepath_block RBRACE;
id_and_assignment: assignment | id_specifier;

full_typepath: SLASH typepath;
typepath: root_type SLASH id_typepath_oneline;
id_typepath_oneline: ID SLASH id_typepath_oneline | ID;

datum_def : optional_slash root_type datum_inner_def;
datum_inner_def: proc_def | SLASH ID datum_inner_def | optional_slash LBRACE datum_def_block RBRACE;
datum_def_block: datum_def_contents | datum_def_contents datum_def_block;
datum_def_contents: var_def | proc_def | custom_id_typepath_block;

proc_def: PROC SLASH proc_id_def | PROC optional_slash LBRACE proc_id_def_block RBRACE;
proc_id_def_block: proc_id_def proc_id_def_block | proc_id_def;
proc_id_def: ID LPAREN RPAREN block | ID LPAREN arguments_def RPAREN block;
arguments_def: argument_def COMMA arguments_def | argument_def;
argument_def: argument_decl EQUALS expression | argument_decl;
argument_decl: VAR full_typepath | typepath | ID;

block: LBRACE statements RBRACE | LBRACE RBRACE;
statements: statement statements | statement;
statement: control_flow | var_def | assignment_statement | proccall_statement;
proccall_statement: proccall SEMI;
assignment_statement: id_specifier assignment_op expression SEMI;

control_flow: if | switch | while | for | spawn;

spawn: spawn_invocation block;
spawn_invocation: SPAWN LPAREN RPAREN | SPAWN LPAREN expression RPAREN;

if: if_check root_if_continuation;
root_if_continuation: block if_continuation | block;
if_check: IF LPAREN expression RPAREN;
if_continuation: ELSE block | ELSE if_check block if_continuation | root_if_continuation;

switch: SWITCH LPAREN expression RPAREN root_switch_block;
const_if_check: IF LPAREN constexpr RPAREN;
root_switch_block: const_if_check block switch_block | const_if_check block;
switch_block: ELSE block | root_switch_block;

while: WHILE LPAREN expression RPAREN block;

for: FOR LPAREN for_expression RPAREN block;
for_expression: for_in | for_standard;
for_in: argument_def IN expression;
for_standard: for_optional_argument_def SEMI optional_expression SEMI optional_expression;
for_optional_argument_def: argument_def | ;
optional_expression: expression | ;

proccall: proc_invocation | id_specifier proccall | proccall;
proc_invocation: ID LPAREN arguments RPAREN | ID LPAREN RPAREN;
unquotable_associated_argument: ID EQUALS expression | expression;
arguments: unquotable_associated_argument | unquotable_associated_argument COMMA arguments;

associated_argument: string EQUALS expression | unquotable_associated_argument;
associated_arguments: associated_argument | associated_argument COMMA associated_arguments;
list_declaration : LIST LPAREN associated_arguments RPAREN;

id_specifier: proccall datum_access id_specifier | ID datum_access id_specifier | ID | WORLD | GLOBAL;
datum_access: DOT | COLON;

//TODO go over this
expression : wrapped_expression | NOT wrapped_expression;
wrapped_expression : inner_expression | LPAREN inner_expression RPAREN;
inner_expression: operation | expression | assignment | list_declaration | value_range | value;
operation: value lhrh_op expression | expression lhrh_op expression;

lhrh_op: equals | not_equals | and | or | AND | OR | XOR | STAR | PLUS | MINUS | SLASH;

value: constexpr | proccall;
constexpr: number | string;
value_range: expression TO expression STEP expression | expression TO expression;

assignment: id_specifier EQUALS expression;
assignment_op: or_equals | and_equals | xor_equals | mult_equals | minus_equals | plus_equals | slash_equals | EQUALS;

embedded_expression : LBRACE expression RBRACE;
inner_string: string_text | string_text embedded_expression inner_string;
string: DQUOTE inner_string DQUOTE | DQUOTE DQUOTE;

file_ref: SQUOTE SQSTRING SQUOTE;
number: NUMBER DOT NUMBER | NUMBER | TRUE | FALSE;

equals: EQUALS EQUALS;
not_equals: NOT EQUALS;
and: AND AND;
or: OR OR;

or_equals: OR EQUALS;
and_equals: AND EQUALS;
xor_equals: XOR EQUALS;
mult_equals: STAR EQUALS;
minus_equals: MINUS EQUALS;
plus_equals: PLUS EQUALS;
slash_equals: SLASH EQUALS;

root_type: DATUM | ATOM | OBJ | MOB | TURF | AREA | WORLD;