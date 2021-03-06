%{
#include <stdio.h>
#include <ctype.h>
#include <math.h>
#include <string.h>
#include "common.h"

unsigned int it;
unsigned int prev_block[BLOCK_NEST_MAX];
int num_prev_block = 0;
unsigned int block;
BOOL var_arg;
unsigned int func_params;
unsigned int params;
extern int yyerror(char *msg);
extern int yylex();
sCompileInfo cinfo;
unsigned int elif_exps[ELIF_NEST_MAX][ELIF_NUM_MAX];
unsigned int elif_blocks[ELIF_NEST_MAX][ELIF_NUM_MAX];
int elif_num[ELIF_NEST_MAX];
unsigned int else_block[ELIF_NEST_MAX];
int elif_nest_num = 0;
unsigned int fields[128];
int num_fields = 0;
char variable_names[VAR_NAME_MAX][128];
int multiple_init_values[128];
int num_variable_names = 0;
int num_multiple_variable_names  =0;
char variable_name[VAR_NAME_MAX];
char type_params[VAR_NAME_MAX];
char typedef_type_params[VAR_NAME_MAX];
int num_struct_generics_types = 0;
char struct_generics_types[GENERICS_TYPES_MAX][VAR_NAME_MAX];
int num_function_generics_types = 0;
char function_generics_types[GENERICS_TYPES_MAX][VAR_NAME_MAX];
int num_method_generics_types = 0;
char method_generics_types[GENERICS_TYPES_MAX][VAR_NAME_MAX];
unsigned int object;
BOOL inline_ = FALSE;
BOOL static_ = FALSE;
BOOL inherit_ = FALSE;
int enum_number = 0;
int array_index_num_dimention[128];
unsigned int array_index_index_node[128][ARRAY_DIMENTION_MAX];
int array_index_num = 0;
int num_array_value;
unsigned int array_values[INIT_ARRAY_MAX];
unsigned int num_switch_expression;
unsigned int switch_expression[SWITCH_STASTMENT_NODE_MAX];
unsigned int fun_node;
sVarTable* gLVTable;
unsigned int multiple_nodes[128];
int num_multiple_node = 0;
char recent_type_name[VAR_NAME_MAX];
char struct_name_now[VAR_NAME_MAX];

%}

%union {
    long ival;
    char char_val;
    unsigned int node;
    char cval[128];
    char sval[512];
    int rval;
}

%token <ival> INTNUM 
%token <char_val> CHARNUM 
%token <cval> IDENTIFIER
%token <cval> TYPE_NAME
%token <cval> LONG
%token <cval> SHORT
%token <sval> CSTRING
%token <cval> VOID
%token <cval> IF
%token <cval> ELSE
%token <cval> EXTERN
%token <cval> RETURN
%token <cval> TYPEDEF
%token <cval> TOKEN_TRUE
%token <cval> TOKEN_FALSE
%token <cval> TOKEN_DELETE
%token <cval> TOKEN_MANAGED
%token <cval> TOKEN_BORROW
%token <cval> CONST
%token <cval> UNSIGNED
%token <cval> SIGNED
%token <cval> REGISTER
%token <cval> VOLATILE
%token <cval> STATIC
%token <cval> NEW
%token <cval> CLONE
%token <cval> INLINE
%token <cval> STRUCT
%token <cval> UNION
%token <cval> EQEQ
%token <cval> NOT_EQ
%token <cval> ANDAND
%token <cval> OROR
%token <cval> LAMBDA
%token <cval> TEMPLATE
%token <cval> ENUM
%token <cval> INHERIT
%token <cval> METHOD_MARK
%token <cval> PLUS_PLUS
%token <cval> PLUS_EQ
%token <cval> MINUS_MINUS
%token <cval> MINUS_EQ
%token <cval> MULT_EQ
%token <cval> DIV_EQ
%token <cval> MOD_EQ
%token <cval> AND_EQ
%token <cval> XOR_EQ
%token <cval> OR_EQ
%token <cval> LSHIFT_EQ
%token <cval> RSHIFT_EQ
%token <cval> FOR
%token <cval> WHILE
%token <cval> DO
%token <cval> SWITCH
%token <cval> CASE
%token <cval> BREAK
%token <cval> CONTINUE
%token <cval> DEFAULT
%token <cval> SIZEOF
%token <cval> ISHEAP
%token <cval> NULLPTR
%token <cval> __ALIGNOF__
%token <cval> ERROR
%token <cval> DEPRECATED
%token <cval> __WARN_UNUSED_RESULT__
%token <cval> __CONST__
%token <cval> __ALLOC_SIZE__
%token <cval> __MALLOC__
%token <cval> __ATTRIBUTE__
%token <cval> __LEAF__
%token <cval> __NOTHROW__
%token <cval> __FORMAT__
%token <cval> __PRINTF__
%token <cval> __SCANF__
%token <cval> __RESTRICT
%token <cval> STRFTIME
%token <cval> __ASM__
%token <cval> __NONNULL__
%token <cval> __PURE__
%token <cval> __MODE__
%token <cval> __QI__
%token <cval> __HI__
%token <cval> __SI__
%token <cval> __DI__
%token <cval> __WORD__
%token <cval> __ALIGNED__
%token <cval> __ALWAYS_INLINE__
%token <cval> __NORETURN__
%token <cval> __RETURNS_TWICE__
%token <cval> __SENTINEL__
%token <cval> ANNOTATE
%token <cval> OVERLOADABLE
%token <cval> ENABLE_IF
%token <cval> DUMMY_HEAP
%type <cval> type 
%type <cval> type_name
%type <cval> type_attribute
%type <cval> type_and_variable_name
%type <cval> fields_type_and_variable_names;
%type <cval> global_type_and_variable_names;
%type <cval> local_type_and_variable_names
%type <cval> type_params
%type <cval> function_pointer_type_params;
%type <cval> generics_types 
%type <cval> function_generics_types 
%type <cval> function_struct_type_name 
%type <cval> pointer
%type <cval> array_type
%type <cval> const_array_type
%type <cval> typedef_type_params_
%type <cval> name
%type <cval> struct_name
%type <cval> struct_name2
%type <node> program function block function_block block_end statment node assign_node function_params function_params2 function_params3 function_params_end exp comma_exp params elif_statment prepare_elif_statment end_elif_statment struct_ fields union_ method_generics_types global_variable enum_ enum_fields array_index array_value switch_block case_statment after_return_case_statment cstring_array_value2 sub_array sub_array_init typedef_ function_attribute pre_function_attribute function_attribute_core restrict typedef_attribute typedef_attribute_core conditional_exp type_attribute2 type_attribute2_core free_right_value_objects some_variable_names global_some_variable_names local_some_variable_names define_struct_before_fields none_elif_statment;

%left '[' ']' '='
%left '?' ':'
%left OROR
%left ANDAND
%left '|'
%left '^'
%left '&'
%left EQEQ NOT_EQ 
%left '<' '>' GTEQ LTEQ
%left LSHIFT RSHIFT
%left '+' '-'
%left '*' '/' '%'
%left '!' '~'

%start program

%%

program:
        | ERROR {
            fprintf(stderr, "%s\n", $1);
            exit(2);
        }
        | function {
            $$ = compile($1, &cinfo);
        }
        | pre_function_attribute function {
            $$ = compile($2, &cinfo);
        }
        | global_variable {
            $$ = compile($1, &cinfo);
        }
        | typedef_ {
            $$ = compile($1, &cinfo);
        }
        | struct_ {
            $$ = compile($1, &cinfo);
        }
        | union_ {
            $$ = compile($1, &cinfo);
        }
        | enum_ {
        }
        | program ERROR {
            fprintf(stderr, "%s\n", $2);
            exit(2);
        }
        | program function {
            $$ = compile($2, &cinfo);
        }
        | program pre_function_attribute function {
            $$ = compile($3, &cinfo);
        }
        | program global_variable {
            $$ = compile($2, &cinfo);
        }
        | program struct_ {
            $$ = compile($2, &cinfo);
        }
        | program union_ {
            $$ = compile($2, &cinfo);
        }
        | program enum_ {
        }
        | program typedef_ {
            $$ = compile($2, &cinfo);
        }
        ;

restrict: {
    }
    | __RESTRICT {
    }
    ;

enum_: ENUM '{' enum_fields '}' ';' {
    }
    | ENUM IDENTIFIER '{' enum_fields '}' ';' {
        char* name = $2;
        char* type_name = "int";
        unsigned int node = sNodeTree_create_typedef(name, type_name, gSName, yylineno);

        compile(node, &cinfo);
    }
    ;

enum_fields: {
        enum_number = 0;
    }
    | IDENTIFIER {
        enum_number = 0;

        BOOL alloc = TRUE;
        BOOL global = TRUE;
        char* var_name = $1;
        unsigned int exp = sNodeTree_create_int_value(enum_number, gSName, yylineno);

        char* type_name = "const int";

        unsigned int node = sNodeTree_create_store_variable(var_name, type_name, exp, alloc, global, gSName, yylineno); 

        compile(node, &cinfo);

        enum_number++;
    }
    | IDENTIFIER '=' INTNUM {
        enum_number = $3;

        BOOL alloc = TRUE;
        BOOL global = TRUE;
        char* var_name = $1;
        unsigned int exp = sNodeTree_create_int_value(enum_number, gSName, yylineno);

        char* type_name = "const int";

        unsigned int node = sNodeTree_create_store_variable(var_name, type_name, exp, alloc, global, gSName, yylineno); 

        compile(node, &cinfo);

        enum_number++;
    }
    | IDENTIFIER '=' exp {
        unsigned int exp = $3;

        char* var_name = $1;
        char* type_name = "const int";
        BOOL alloc = TRUE;
        BOOL global = TRUE;

        unsigned int node = sNodeTree_create_store_variable(var_name, type_name, exp, alloc, global, gSName, yylineno); 

        compile(node, &cinfo);

        enum_number++;
    }
    | enum_fields ',' IDENTIFIER {
        BOOL alloc = TRUE;
        BOOL global = TRUE;
        char* var_name = $3;
        unsigned int exp = sNodeTree_create_int_value(enum_number, gSName, yylineno);

        char* type_name = "const int";

        unsigned int node = sNodeTree_create_store_variable(var_name, type_name, exp, alloc, global, gSName, yylineno); 

        compile(node, &cinfo);

        enum_number++;
    }
    | enum_fields ',' IDENTIFIER '=' INTNUM {
        enum_number = $5;

        BOOL alloc = TRUE;
        BOOL global = TRUE;
        char* var_name = $3;
        unsigned int exp = sNodeTree_create_int_value(enum_number, gSName, yylineno);

        char* type_name = "const int";

        unsigned int node = sNodeTree_create_store_variable(var_name, type_name, exp, alloc, global, gSName, yylineno); 

        compile(node, &cinfo);

        enum_number++;
    }
    | enum_fields ',' IDENTIFIER '=' exp {
        BOOL alloc = TRUE;
        BOOL global = TRUE;
        char* var_name = $3;
        unsigned int exp = $5;

        char* type_name = "const int";

        unsigned int node = sNodeTree_create_store_variable(var_name, type_name, exp, alloc, global, gSName, yylineno); 

        compile(node, &cinfo);

        enum_number++;
    }
    ;

type:
    type_attribute restrict {
        if(strcmp($1, "long ") == 0) {
            xstrncpy($$, "long", VAR_NAME_MAX);
        }
        else if(strcmp($1, "unsigned long ") == 0) {
            xstrncpy($$, "unsigned long", VAR_NAME_MAX);
        }
        else if(strcmp($1, "const unsigned long ") == 0) {
            xstrncpy($$, "const unsigned long", VAR_NAME_MAX);
        }
        else if(strcmp($1, "signed long ") == 0) {
            xstrncpy($$, "signed long", VAR_NAME_MAX);
        }
        else if(strcmp($1, "const signed long ") == 0) {
            xstrncpy($$, "const signed long", VAR_NAME_MAX);
        }
        else if(strcmp($1, "long long ") == 0) {
            xstrncpy($$, "long", VAR_NAME_MAX);
        }
        else if(strcmp($1, "const long long ") == 0) {
            xstrncpy($$, "const long", VAR_NAME_MAX);
        }
        else if(strcmp($1, "static long ") == 0) {
            xstrncpy($$, "static long", VAR_NAME_MAX);
        }
        else if(strcmp($1, "static const long ") == 0) {
            xstrncpy($$, "static const long", VAR_NAME_MAX);
        }
        else if(strcmp($1, "signed long long ") == 0) {
            xstrncpy($$, "long", VAR_NAME_MAX);
        }
        else if(strcmp($1, "const signed long long ") == 0) {
            xstrncpy($$, "const long", VAR_NAME_MAX);
        }
        else if(strcmp($1, "unsigned long long ") == 0) {
            xstrncpy($$, "unsigned long", VAR_NAME_MAX);
        }
        else if(strcmp($1, "const unsigned long long ") == 0) {
            xstrncpy($$, "const unsigned long", VAR_NAME_MAX);
        }
        else if(strcmp($1, "short ") == 0) {
            xstrncpy($$, "short", VAR_NAME_MAX);
        }
        else if(strcmp($1, "const short ") == 0) {
            xstrncpy($$, "const short", VAR_NAME_MAX);
        }
        else if(strcmp($1, "unsigned short ") == 0) {
            xstrncpy($$, "unsigned short", VAR_NAME_MAX);
        }
        else if(strcmp($1, "const unsigned short ") == 0) {
            xstrncpy($$, "const unsigned short", VAR_NAME_MAX);
        }
        else if(strcmp($1, "const unsigned short ") == 0) {
            xstrncpy($$, "const unsigned short", VAR_NAME_MAX);
        }
        else if(strcmp($1, "signed short ") == 0) {
            xstrncpy($$, "signed short", VAR_NAME_MAX);
        }
        else if(strcmp($1, "const signed short ") == 0) {
            xstrncpy($$, "const signed short", VAR_NAME_MAX);
        }
        else if(strcmp($1, "unsigned ") == 0) {
            xstrncpy($$, "unsigned int", VAR_NAME_MAX);
        }
        else if(strcmp($1, "const unsigned ") == 0) {
            xstrncpy($$, "const unsigned int", VAR_NAME_MAX);
        }
        else if(strcmp($1, "singed ") == 0) {
            xstrncpy($$, "singed int", VAR_NAME_MAX);
        }
        else if(strcmp($1, "const singed ") == 0) {
            xstrncpy($$, "const singed int", VAR_NAME_MAX);
        }
        else {
            fprintf(stderr, "%s %d: invalid type name (%s)\n", gSName, yylineno, $1);
            exit(1);
        }

        xstrncpy(recent_type_name, $$, VAR_NAME_MAX);
    }
    | type_attribute restrict pointer restrict {
        if(strcmp($1, "long ") == 0) {
            xstrncpy($$, "long", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
        }
        else if(strcmp($1, "unsigned long ") == 0) {
            xstrncpy($$, "unsigned long", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
        }
        else if(strcmp($1, "const unsigned long ") == 0) {
            xstrncpy($$, "const unsigned long", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
        }
        else if(strcmp($1, "signed long ") == 0) {
            xstrncpy($$, "signed long", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
        }
        else if(strcmp($1, "const signed long ") == 0) {
            xstrncpy($$, "const signed long", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
        }
        else if(strcmp($1, "long long ") == 0) {
            xstrncpy($$, "long", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
        }
        else if(strcmp($1, "const long long ") == 0) {
            xstrncpy($$, "const long", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
        }
        else if(strcmp($1, "static long ") == 0) {
            xstrncpy($$, "static long", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
        }
        else if(strcmp($1, "static const long ") == 0) {
            xstrncpy($$, "static const long", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
        }
        else if(strcmp($1, "signed long long ") == 0) {
            xstrncpy($$, "long", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
        }
        else if(strcmp($1, "const signed long long ") == 0) {
            xstrncpy($$, "const long", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
        }
        else if(strcmp($1, "unsigned long long ") == 0) {
            xstrncpy($$, "unsigned long", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
        }
        else if(strcmp($1, "const unsigned long long ") == 0) {
            xstrncpy($$, "const unsigned long", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
        }
        else if(strcmp($1, "short ") == 0) {
            xstrncpy($$, "short", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
        }
        else if(strcmp($1, "const short ") == 0) {
            xstrncpy($$, "const short", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
        }
        else if(strcmp($1, "unsigned short ") == 0) {
            xstrncpy($$, "unsigned short", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
        }
        else if(strcmp($1, "const unsigned short ") == 0) {
            xstrncpy($$, "const unsigned short", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
        }
        else if(strcmp($1, "const unsigned short ") == 0) {
            xstrncpy($$, "const unsigned short", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
        }
        else if(strcmp($1, "signed short ") == 0) {
            xstrncpy($$, "signed short", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
        }
        else if(strcmp($1, "const signed short ") == 0) {
            xstrncpy($$, "const signed short", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
        }
        else if(strcmp($1, "unsigned ") == 0) {
            xstrncpy($$, "unsigned int", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
        }
        else if(strcmp($1, "const unsigned ") == 0) {
            xstrncpy($$, "const unsigned int", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
        }
        else if(strcmp($1, "singed ") == 0) {
            xstrncpy($$, "singed int", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
        }
        else if(strcmp($1, "const singed ") == 0) {
            xstrncpy($$, "const singed int", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
        }
        else {
            fprintf(stderr, "%s %d: invalid type name (%s)\n", gSName, yylineno, $1);
            exit(1);
        }

        xstrncpy(recent_type_name, $$, VAR_NAME_MAX);
    }
    | type_attribute restrict pointer restrict '%' {
        if(strcmp($1, "long ") == 0) {
            xstrncpy($$, "long", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
            xstrncat($$, "%", VAR_NAME_MAX);
        }
        else if(strcmp($1, "unsigned long ") == 0) {
            xstrncpy($$, "unsigned long", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
            xstrncat($$, "%", VAR_NAME_MAX);
        }
        else if(strcmp($1, "const unsigned long ") == 0) {
            xstrncpy($$, "const unsigned long", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
            xstrncat($$, "%", VAR_NAME_MAX);
        }
        else if(strcmp($1, "signed long ") == 0) {
            xstrncpy($$, "signed long", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
            xstrncat($$, "%", VAR_NAME_MAX);
        }
        else if(strcmp($1, "const signed long ") == 0) {
            xstrncpy($$, "const signed long", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
            xstrncat($$, "%", VAR_NAME_MAX);
        }
        else if(strcmp($1, "long long ") == 0) {
            xstrncpy($$, "long", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
            xstrncat($$, "%", VAR_NAME_MAX);
        }
        else if(strcmp($1, "const long long ") == 0) {
            xstrncpy($$, "const long", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
            xstrncat($$, "%", VAR_NAME_MAX);
        }
        else if(strcmp($1, "static long ") == 0) {
            xstrncpy($$, "static long", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
            xstrncat($$, "%", VAR_NAME_MAX);
        }
        else if(strcmp($1, "static const long ") == 0) {
            xstrncpy($$, "static const long", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
            xstrncat($$, "%", VAR_NAME_MAX);
        }
        else if(strcmp($1, "signed long long ") == 0) {
            xstrncpy($$, "long", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
            xstrncat($$, "%", VAR_NAME_MAX);
        }
        else if(strcmp($1, "const signed long long ") == 0) {
            xstrncpy($$, "const long", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
            xstrncat($$, "%", VAR_NAME_MAX);
        }
        else if(strcmp($1, "unsigned long long ") == 0) {
            xstrncpy($$, "unsigned long", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
            xstrncat($$, "%", VAR_NAME_MAX);
        }
        else if(strcmp($1, "const unsigned long long ") == 0) {
            xstrncpy($$, "const unsigned long", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
            xstrncat($$, "%", VAR_NAME_MAX);
        }
        else if(strcmp($1, "short ") == 0) {
            xstrncpy($$, "short", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
            xstrncat($$, "%", VAR_NAME_MAX);
        }
        else if(strcmp($1, "const short ") == 0) {
            xstrncpy($$, "const short", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
            xstrncat($$, "%", VAR_NAME_MAX);
        }
        else if(strcmp($1, "unsigned short ") == 0) {
            xstrncpy($$, "unsigned short", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
            xstrncat($$, "%", VAR_NAME_MAX);
        }
        else if(strcmp($1, "const unsigned short ") == 0) {
            xstrncpy($$, "const unsigned short", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
            xstrncat($$, "%", VAR_NAME_MAX);
        }
        else if(strcmp($1, "const unsigned short ") == 0) {
            xstrncpy($$, "const unsigned short", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
            xstrncat($$, "%", VAR_NAME_MAX);
        }
        else if(strcmp($1, "signed short ") == 0) {
            xstrncpy($$, "signed short", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
            xstrncat($$, "%", VAR_NAME_MAX);
        }
        else if(strcmp($1, "const signed short ") == 0) {
            xstrncpy($$, "const signed short", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
            xstrncat($$, "%", VAR_NAME_MAX);
        }
        else if(strcmp($1, "unsigned ") == 0) {
            xstrncpy($$, "unsigned int", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
            xstrncat($$, "%", VAR_NAME_MAX);
        }
        else if(strcmp($1, "const unsigned ") == 0) {
            xstrncpy($$, "const unsigned int", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
            xstrncat($$, "%", VAR_NAME_MAX);
        }
        else if(strcmp($1, "singed ") == 0) {
            xstrncpy($$, "singed int", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
            xstrncat($$, "%", VAR_NAME_MAX);
        }
        else if(strcmp($1, "const singed ") == 0) {
            xstrncpy($$, "const singed int", VAR_NAME_MAX);
            xstrncat($$, $3, VAR_NAME_MAX);
            xstrncat($$, "%", VAR_NAME_MAX);
        }
        else {
            fprintf(stderr, "%s %d: invalid type name (%s)\n", gSName, yylineno, $1);
            exit(1);
        }

        xstrncpy(recent_type_name, $$, VAR_NAME_MAX);
    }
    | type_attribute restrict type_name {
        xstrncpy($$, $1, VAR_NAME_MAX);
        xstrncat($$, $3, VAR_NAME_MAX);

        xstrncpy(recent_type_name, $$, VAR_NAME_MAX);
    }
    | type_attribute restrict type_name '&' {
        xstrncpy($$, $1, VAR_NAME_MAX);
        xstrncat($$, $3, VAR_NAME_MAX);
        xstrncat($$, "&", VAR_NAME_MAX);

        xstrncpy(recent_type_name, $$, VAR_NAME_MAX);
    }
    | type_attribute restrict type_name restrict pointer {
        xstrncpy($$, $1, VAR_NAME_MAX);
        xstrncat($$, $3, VAR_NAME_MAX);
        xstrncat($$, $5, VAR_NAME_MAX);

        xstrncpy(recent_type_name, $$, VAR_NAME_MAX);
    }
    | type_attribute restrict type_name restrict pointer restrict '%' {
        xstrncpy($$, $1, VAR_NAME_MAX);
        xstrncat($$, $3, VAR_NAME_MAX);
        xstrncat($$, $5, VAR_NAME_MAX);
        xstrncat($$, "%", VAR_NAME_MAX);

        xstrncpy(recent_type_name, $$, VAR_NAME_MAX);
    }
    | type_attribute restrict type_name restrict pointer restrict '&' {
        xstrncpy($$, $1, VAR_NAME_MAX);
        xstrncat($$, $3, VAR_NAME_MAX);
        xstrncat($$, $5, VAR_NAME_MAX);
        xstrncat($$, "&", VAR_NAME_MAX);

        xstrncpy(recent_type_name, $$, VAR_NAME_MAX);
    }
    | type_name restrict {
        xstrncpy($$, $1, VAR_NAME_MAX);

        xstrncpy(recent_type_name, $$, VAR_NAME_MAX);
    } 
    | type_name restrict '&' {
        xstrncpy($$, $1, VAR_NAME_MAX);
        xstrncat($$, "&", VAR_NAME_MAX);

        xstrncpy(recent_type_name, $$, VAR_NAME_MAX);
    } 
    | type_name restrict pointer restrict {
        xstrncpy($$, $1, VAR_NAME_MAX);
        xstrncat($$, $3, VAR_NAME_MAX);

        xstrncpy(recent_type_name, $$, VAR_NAME_MAX);
    }
    | type_name restrict pointer restrict '%' {
        xstrncpy($$, $1, VAR_NAME_MAX);
        xstrncat($$, $3, VAR_NAME_MAX);
        xstrncat($$, "%", VAR_NAME_MAX);

        xstrncpy(recent_type_name, $$, VAR_NAME_MAX);
    }
    | type_name restrict pointer restrict '&' {
        xstrncpy($$, $1, VAR_NAME_MAX);
        xstrncat($$, $3, VAR_NAME_MAX);
        xstrncat($$, "&", VAR_NAME_MAX);

        xstrncpy(recent_type_name, $$, VAR_NAME_MAX);
    }
    | STRUCT '{' fields '}' {
            static int anonyomous_struct_num = 0;
            char buf[VAR_NAME_MAX];
            snprintf(buf, VAR_NAME_MAX, "anonmous_struct%d", anonyomous_struct_num);
            anonyomous_struct_num++;
            char* struct_name = buf;
            unsigned int fields = $3;
            BOOL anonymous = TRUE;
            BOOL generics = FALSE;

            unsigned int node = sNodeTree_create_struct(struct_name, fields, generics, anonymous, gSName, yylineno);

            compile(node, &cinfo);

            xstrncpy($$, buf, VAR_NAME_MAX);

            xstrncpy(recent_type_name, $$, VAR_NAME_MAX);
    }
    | STRUCT IDENTIFIER pointer {
        char* struct_name = $2;
        unsigned int fields = 0;
        BOOL anonymous = FALSE;
        BOOL generics = FALSE;

        unsigned int node = sNodeTree_create_struct(struct_name, fields, generics, anonymous, gSName, yylineno);

        compile(node, &cinfo);

        xstrncpy($$, struct_name, VAR_NAME_MAX);
        xstrncat($$, $3, VAR_NAME_MAX);

        xstrncpy(recent_type_name, $$, VAR_NAME_MAX);
    }
    | UNION '{' fields '}' {
            static int anonyomous_union_num = 0;
            char buf[VAR_NAME_MAX];
           
            snprintf(buf, VAR_NAME_MAX, "anonmous_union%d", anonyomous_union_num);
            anonyomous_union_num++;
            char* union_name = buf;
            unsigned int fields = $3;
            BOOL anonymous = TRUE;

            unsigned int node = sNodeTree_create_union(union_name, fields, anonymous, gSName, yylineno);

            compile(node, &cinfo);

            xstrncpy($$, buf, VAR_NAME_MAX);

            xstrncpy(recent_type_name, $$, VAR_NAME_MAX);
    }

    | ENUM '{' enum_fields '}'  {
        xstrncpy($$, "int", VAR_NAME_MAX);

        xstrncpy(recent_type_name, $$, VAR_NAME_MAX);
    }
    ;

pointer: 
    '*' restrict {
        xstrncpy($$, "*", VAR_NAME_MAX);
    }
    | '*' restrict CONST{
        xstrncpy($$, "*", VAR_NAME_MAX);
    }
    | pointer restrict '*' restrict {
        xstrncpy($$, $1, VAR_NAME_MAX);
        xstrncat($$, "*", VAR_NAME_MAX);
    }
    | pointer restrict '*' restrict CONST {
        xstrncpy($$, $1, VAR_NAME_MAX);
        xstrncat($$, "*", VAR_NAME_MAX);
    }
    ;

type_attribute: 
    LONG {
        xstrncpy($$, "long ", VAR_NAME_MAX); 
        inline_ = FALSE;
        static_ = FALSE;
        inherit_ = FALSE;
    }
    | SHORT {
        xstrncpy($$, "short ", VAR_NAME_MAX); 
        inline_ = FALSE;
        static_ = FALSE;
        inherit_ = FALSE;
    }
    | CONST {
        xstrncpy($$, "const ", VAR_NAME_MAX); 
        inline_ = FALSE;
        static_ = FALSE;
        inherit_ = FALSE;
    }
    | VOLATILE {
/*
        xstrncpy($$, "volatile ", VAR_NAME_MAX); 
*/
        inline_ = FALSE;
        static_ = FALSE;
        inherit_ = FALSE;
    }
    | UNSIGNED {
        xstrncpy($$, "unsigned ", VAR_NAME_MAX); 
        inline_ = FALSE;
        static_ = FALSE;
        inherit_ = FALSE;
    }
    | SIGNED {
        xstrncpy($$, "signed ", VAR_NAME_MAX); 
        inline_ = FALSE;
        static_ = FALSE;
        inherit_ = FALSE;
    }
    | REGISTER {
        xstrncpy($$, "regisster ", VAR_NAME_MAX); 
        inline_ = FALSE;
        static_ = FALSE;
        inherit_ = FALSE;
    }
    | STATIC {
        xstrncpy($$, "static ", VAR_NAME_MAX); 
        static_ = TRUE;
        inline_ = FALSE;
        static_ = FALSE;
        inherit_ = FALSE;
    }
    | __ATTRIBUTE__ '(' '(' __ALWAYS_INLINE__ ')' ')' {
    }
    | INLINE {
        xstrncpy($$, "", VAR_NAME_MAX); 
        inline_ = TRUE;
        static_ = FALSE;
        inherit_ = FALSE;
    }
    | INHERIT {
        xstrncpy($$, "", VAR_NAME_MAX); 
        inherit_ = TRUE;
        inline_ = FALSE;
        static_ = FALSE;
    }
    | type_attribute LONG {
        xstrncpy($$, $1, VAR_NAME_MAX); 
        xstrncat($$, "long ", VAR_NAME_MAX); 
    }
    | type_attribute SHORT {
        xstrncpy($$, $1, VAR_NAME_MAX); 
        xstrncat($$, "short ", VAR_NAME_MAX); 
    }
    | type_attribute CONST {
        xstrncpy($$, $1, VAR_NAME_MAX); 
        xstrncat($$, "const ", VAR_NAME_MAX); 
    }
    | type_attribute UNSIGNED {
        xstrncpy($$, $1, VAR_NAME_MAX); 
        xstrncat($$, "unsigned ", VAR_NAME_MAX); 
    }
    | type_attribute SIGNED {
        xstrncpy($$, $1, VAR_NAME_MAX); 
        xstrncat($$, "signed ", VAR_NAME_MAX); 
    }
    | type_attribute REGISTER {
        xstrncpy($$, $1, VAR_NAME_MAX); 
        xstrncat($$, "regisster ", VAR_NAME_MAX); 
    }
    | type_attribute STATIC {
        xstrncpy($$, $1, VAR_NAME_MAX); 
        xstrncat($$, "static ", VAR_NAME_MAX); 
        static_ = TRUE;
    }
    | type_attribute VOLATILE {
/*
        xstrncpy($$, $1, VAR_NAME_MAX); 
        xstrncat($$, "static ", VAR_NAME_MAX); 
        static_ = TRUE;
*/
    }
    | type_attribute __ATTRIBUTE__ '(' '(' __ALWAYS_INLINE__ ')' ')' {
    }
    | type_attribute INLINE {
        xstrncpy($$, $1, VAR_NAME_MAX); 
        inline_ = TRUE;
    }
    | type_attribute INHERIT {
        xstrncpy($$, $1, VAR_NAME_MAX); 
        inherit_ = TRUE;
    }
    | type_attribute restrict {
        xstrncpy($$, $1, VAR_NAME_MAX); 
    }
    ;

type_name: 
    STRUCT TYPE_NAME {
        char type_name[VAR_NAME_MAX];
        get_typedef($2, type_name);

        int i;
        for(i=0; i<num_function_generics_types; i++) {
            if(strcmp(type_name, function_generics_types[i]) == 0) {
                char buf[VAR_NAME_MAX];
                snprintf(buf, VAR_NAME_MAX, "generics%d", i);
                xstrncpy(type_name, buf, VAR_NAME_MAX);
            }
        }
        for(i=0; i<num_struct_generics_types; i++) {
            if(strcmp(type_name, struct_generics_types[i]) == 0) {
                char buf[VAR_NAME_MAX];
                snprintf(buf, VAR_NAME_MAX, "generics%d", i);
                xstrncpy(type_name, buf, VAR_NAME_MAX);
            }
        }
        for(i=0; i<num_method_generics_types; i++) {
            if(strcmp(type_name, method_generics_types[i]) == 0) {
                char buf[VAR_NAME_MAX];
                snprintf(buf, VAR_NAME_MAX, "mgenerics%d", i);
                xstrncpy(type_name, buf, VAR_NAME_MAX);
            }
        }

        xstrncpy($$, type_name, VAR_NAME_MAX);
    }
    | UNION TYPE_NAME {
        char type_name[VAR_NAME_MAX];
        get_typedef($2, type_name);

        int i;
        for(i=0; i<num_function_generics_types; i++) {
            if(strcmp(type_name, function_generics_types[i]) == 0) {
                char buf[VAR_NAME_MAX];
                snprintf(buf, VAR_NAME_MAX, "generics%d", i);
                xstrncpy(type_name, buf, VAR_NAME_MAX);
            }
        }
        for(i=0; i<num_struct_generics_types; i++) {
            if(strcmp(type_name, struct_generics_types[i]) == 0) {
                char buf[VAR_NAME_MAX];
                snprintf(buf, VAR_NAME_MAX, "generics%d", i);
                xstrncpy(type_name, buf, VAR_NAME_MAX);
            }
        }
        for(i=0; i<num_method_generics_types; i++) {
            if(strcmp(type_name, method_generics_types[i]) == 0) {
                char buf[VAR_NAME_MAX];
                snprintf(buf, VAR_NAME_MAX, "mgenerics%d", i);
                xstrncpy(type_name, buf, VAR_NAME_MAX);
            }
        }

        xstrncpy($$, type_name, VAR_NAME_MAX);
    }
    | ENUM TYPE_NAME {
        char type_name[VAR_NAME_MAX];
        get_typedef($2, type_name);

        int i;
        for(i=0; i<num_function_generics_types; i++) {
            if(strcmp(type_name, function_generics_types[i]) == 0) {
                char buf[VAR_NAME_MAX];
                snprintf(buf, VAR_NAME_MAX, "generics%d", i);
                xstrncpy(type_name, buf, VAR_NAME_MAX);
            }
        }
        for(i=0; i<num_struct_generics_types; i++) {
            if(strcmp(type_name, struct_generics_types[i]) == 0) {
                char buf[VAR_NAME_MAX];
                snprintf(buf, VAR_NAME_MAX, "generics%d", i);
                xstrncpy(type_name, buf, VAR_NAME_MAX);
            }
        }
        for(i=0; i<num_method_generics_types; i++) {
            if(strcmp(type_name, method_generics_types[i]) == 0) {
                char buf[VAR_NAME_MAX];
                snprintf(buf, VAR_NAME_MAX, "mgenerics%d", i);
                xstrncpy(type_name, buf, VAR_NAME_MAX);
            }
        }

        xstrncpy($$, type_name, VAR_NAME_MAX);
    }
    | TYPE_NAME {
        char type_name[VAR_NAME_MAX];
        get_typedef($1, type_name);

        int i;
        for(i=0; i<num_function_generics_types; i++) {
            if(strcmp(type_name, function_generics_types[i]) == 0) {
                char buf[VAR_NAME_MAX];
                snprintf(buf, VAR_NAME_MAX, "generics%d", i);
                xstrncpy(type_name, buf, VAR_NAME_MAX);
            }
        }
        for(i=0; i<num_struct_generics_types; i++) {
            if(strcmp(type_name, struct_generics_types[i]) == 0) {
                char buf[VAR_NAME_MAX];
                snprintf(buf, VAR_NAME_MAX, "generics%d", i);
                xstrncpy(type_name, buf, VAR_NAME_MAX);
            }
        }
        for(i=0; i<num_method_generics_types; i++) {
            if(strcmp(type_name, method_generics_types[i]) == 0) {
                char buf[VAR_NAME_MAX];
                snprintf(buf, VAR_NAME_MAX, "mgenerics%d", i);
                xstrncpy(type_name, buf, VAR_NAME_MAX);
            }
        }

        xstrncpy($$, type_name, VAR_NAME_MAX);
    }
    | TYPE_NAME '!' '<' generics_types '>' {
        char type_name[VAR_NAME_MAX];
        get_typedef($1, type_name);

        int i;
        for(i=0; i<num_function_generics_types; i++) {
            if(strcmp(type_name, function_generics_types[i]) == 0) {
                char buf[VAR_NAME_MAX];
                snprintf(buf, VAR_NAME_MAX, "generics%d", i);
                xstrncpy(type_name, buf, VAR_NAME_MAX);
            }
        }
        for(i=0; i<num_struct_generics_types; i++) {
            if(strcmp(type_name, struct_generics_types[i]) == 0) {
                char buf[VAR_NAME_MAX];
                snprintf(buf, VAR_NAME_MAX, "generics%d", i);
                xstrncpy(type_name, buf, VAR_NAME_MAX);
            }
        }
        for(i=0; i<num_method_generics_types; i++) {
            if(strcmp(type_name, method_generics_types[i]) == 0) {
                char buf[VAR_NAME_MAX];
                snprintf(buf, VAR_NAME_MAX, "mgenerics%d", i);
                xstrncpy(type_name, buf, VAR_NAME_MAX);
            }
        }

        xstrncat(type_name, "<", VAR_NAME_MAX);
        xstrncat(type_name, $4, VAR_NAME_MAX);
        xstrncat(type_name, ">", VAR_NAME_MAX);

        xstrncpy($$, type_name, VAR_NAME_MAX);
    }
/*
    | LONG {
        xstrncpy($$, "long",  VAR_NAME_MAX);
    }
    | SHORT {
        xstrncpy($$, "short",  VAR_NAME_MAX);
    }
*/
    | VOID {
        xstrncpy($$, "void",  VAR_NAME_MAX);
    }
    ;

typedef_attribute_core:
    __MODE__ '(' __QI__ ')' { } 
    | __MODE__ '(' __HI__ ')' { } 
    | __MODE__ '(' __SI__ ')' { } 
    | __MODE__ '(' __DI__ ')' { } 
    | __MODE__ '(' __WORD__ ')' { } 
    | typedef_attribute_core __MODE__ '(' __QI__ ')' { } 
    | typedef_attribute_core __MODE__ '(' __HI__ ')' { } 
    | typedef_attribute_core __MODE__ '(' __SI__ ')' { } 
    | typedef_attribute_core __MODE__ '(' __DI__ ')' { } 
    | typedef_attribute_core __MODE__ '(' __WORD__ ')' { } 
    ;

typedef_attribute: {
    }
    | __ATTRIBUTE__ '(' '(' typedef_attribute_core ')' ')' { }

    | typedef_attribute __ATTRIBUTE__ '(' '(' typedef_attribute_core ')' ')' { }
    ;

type_attribute2_core: 
    __ALIGNED__ '(' __ALIGNOF__ '(' type ')' ')' { } 
    | __ALIGNED__ '(' INTNUM ')'
    | ANNOTATE '(' CSTRING CSTRING ')' { }
    ;

type_attribute2: {
    }
    | __ATTRIBUTE__ '(' '(' type_attribute2_core ')' ')' { }

    | type_attribute2 __ATTRIBUTE__ '(' '(' type_attribute2_core ')' ')' { }
    ;
    
typedef_type_params_: {
        xstrncpy(typedef_type_params, "", VAR_NAME_MAX);
        xstrncpy($$, typedef_type_params, VAR_NAME_MAX);
    }
    | type IDENTIFIER {
        xstrncpy(typedef_type_params, $1, VAR_NAME_MAX);
        xstrncpy($$, typedef_type_params, VAR_NAME_MAX);
    }
    | typedef_type_params_ ',' type IDENTIFIER {
        xstrncat(typedef_type_params, ",", VAR_NAME_MAX);
        xstrncat(typedef_type_params, $3, VAR_NAME_MAX);
        xstrncpy($$, typedef_type_params, VAR_NAME_MAX);
    };

typedef_: 
    | TYPEDEF type IDENTIFIER  typedef_attribute ';' {
        char* name = $3;
        char* type_name = $2;
        $$ = sNodeTree_create_typedef(name, type_name, gSName, yylineno);
    }
    | TYPEDEF type '(' '*' IDENTIFIER ')' '(' typedef_type_params_ ')' ';' {
        char* name = $5;
        char type_name[VAR_NAME_MAX];

        xstrncpy(type_name, $2, VAR_NAME_MAX);
        xstrncat(type_name, " lambda(", VAR_NAME_MAX);
        xstrncat(type_name, $8, VAR_NAME_MAX);
        xstrncat(type_name, ")", VAR_NAME_MAX);

        $$ = sNodeTree_create_typedef(name, type_name, gSName, yylineno);
    }
    | TYPEDEF type '(' '*' IDENTIFIER ')' '(' type_params ')' ';' {
        char* name = $5;
        char type_name[VAR_NAME_MAX];

        xstrncpy(type_name, $2, VAR_NAME_MAX);
        xstrncat(type_name, " lambda(", VAR_NAME_MAX);
        xstrncat(type_name, $8, VAR_NAME_MAX);
        xstrncat(type_name, ")", VAR_NAME_MAX);

        $$ = sNodeTree_create_typedef(name, type_name, gSName, yylineno);
    }
    | TYPEDEF type IDENTIFIER '(' typedef_type_params_ ')' ';' {
        char* name = $3;
        char type_name[VAR_NAME_MAX];

        xstrncpy(type_name, $2, VAR_NAME_MAX);
        xstrncat(type_name, " lambda(", VAR_NAME_MAX);
        xstrncat(type_name, $5, VAR_NAME_MAX);
        xstrncat(type_name, ")", VAR_NAME_MAX);

        $$ = sNodeTree_create_typedef(name, type_name, gSName, yylineno);
    }
    | TYPEDEF type IDENTIFIER '(' type_params ')' ';' {
        char* name = $3;
        char type_name[VAR_NAME_MAX];

        xstrncpy(type_name, $2, VAR_NAME_MAX);
        xstrncat(type_name, " lambda(", VAR_NAME_MAX);
        xstrncat(type_name, $5, VAR_NAME_MAX);
        xstrncat(type_name, ")", VAR_NAME_MAX);

        $$ = sNodeTree_create_typedef(name, type_name, gSName, yylineno);
    }
    | TYPEDEF type TYPE_NAME  typedef_attribute ';' {
        char* name = $3;
        char* type_name = $2;
        $$ = sNodeTree_create_typedef(name, type_name, gSName, yylineno);
    }
    | TYPEDEF STRUCT IDENTIFIER '{' fields '}' IDENTIFIER  typedef_attribute ';' {
            char buf[VAR_NAME_MAX];
            xstrncpy(buf, $3, VAR_NAME_MAX);

            char* struct_name = buf;
            unsigned int fields = $5;
            BOOL anonymous = FALSE;
            BOOL generics = FALSE;

            unsigned int node = sNodeTree_create_struct(struct_name, fields, generics, anonymous, gSName, yylineno);

            compile(node, &cinfo);

            char* name = $7;
            char* type_name = buf;

            $$ = sNodeTree_create_typedef(name, type_name, gSName, yylineno);
    }
    | TYPEDEF STRUCT IDENTIFIER '{' fields '}' TYPE_NAME  typedef_attribute ';' {
            char buf[VAR_NAME_MAX];
            xstrncpy(buf, $3, VAR_NAME_MAX);

            char* struct_name = buf;
            unsigned int fields = $5;
            BOOL anonymous = FALSE;
            BOOL generics = FALSE;

            unsigned int node = sNodeTree_create_struct(struct_name, fields, generics, anonymous, gSName, yylineno);

            compile(node, &cinfo);

            char* name = $7;
            char* type_name = buf;

            $$ = sNodeTree_create_typedef(name, type_name, gSName, yylineno);
    }
    | TYPEDEF STRUCT TYPE_NAME IDENTIFIER  typedef_attribute ';' {
            char buf[VAR_NAME_MAX];
            xstrncpy(buf, $4, VAR_NAME_MAX);

            char* name = buf;
            char* type_name = $3;

            $$ = sNodeTree_create_typedef(name, type_name, gSName, yylineno);
    }
    | TYPEDEF STRUCT TYPE_NAME TYPE_NAME  typedef_attribute ';' {
            char buf[VAR_NAME_MAX];
            xstrncpy(buf, $4, VAR_NAME_MAX);

            char* name = buf;
            char* type_name = $3;

            $$ = sNodeTree_create_typedef(name, type_name, gSName, yylineno);
    }
    | TYPEDEF STRUCT IDENTIFIER IDENTIFIER  typedef_attribute ';' {
            char buf[VAR_NAME_MAX];
            xstrncpy(buf, $3, VAR_NAME_MAX);

            char* struct_name = buf;
            unsigned int fields = 0;
            BOOL anonymous = FALSE;
            BOOL generics = FALSE;

            unsigned int node = sNodeTree_create_struct(struct_name, fields, generics, anonymous, gSName, yylineno);

            compile(node, &cinfo);

            char* name = $4;
            char* type_name = buf;

            $$ = sNodeTree_create_typedef(name, type_name, gSName, yylineno);
    }
    | TYPEDEF UNION IDENTIFIER '{' fields '}' IDENTIFIER  typedef_attribute ';' {
            char buf[VAR_NAME_MAX];
            xstrncpy(buf, $3, VAR_NAME_MAX);

            char* struct_name = buf;
            unsigned int fields = $5;
            BOOL anonymous = FALSE;

            unsigned int node = sNodeTree_create_union(struct_name, fields, anonymous, gSName, yylineno);

            compile(node, &cinfo);

            char* name = $7;
            char* type_name = buf;

            $$ = sNodeTree_create_typedef(name, type_name, gSName, yylineno);
    }
    | TYPEDEF UNION IDENTIFIER '{' fields '}' TYPE_NAME  typedef_attribute ';' {
            char buf[VAR_NAME_MAX];
            xstrncpy(buf, $3, VAR_NAME_MAX);

            char* struct_name = buf;
            unsigned int fields = $5;
            BOOL anonymous = FALSE;

            unsigned int node = sNodeTree_create_union(struct_name, fields, anonymous, gSName, yylineno);

            compile(node, &cinfo);

            char* name = $7;
            char* type_name = buf;

            $$ = sNodeTree_create_typedef(name, type_name, gSName, yylineno);
    }
    | TYPEDEF UNION TYPE_NAME IDENTIFIER  typedef_attribute ';' {
            char buf[VAR_NAME_MAX];
            xstrncpy(buf, $4, VAR_NAME_MAX);

            char* name = buf;
            char* type_name = $3;

            $$ = sNodeTree_create_typedef(name, type_name, gSName, yylineno);
    }
    | TYPEDEF UNION TYPE_NAME TYPE_NAME  typedef_attribute ';' {
            char buf[VAR_NAME_MAX];
            xstrncpy(buf, $4, VAR_NAME_MAX);

            char* name = buf;
            char* type_name = $3;

            $$ = sNodeTree_create_typedef(name, type_name, gSName, yylineno);
    }
    | TYPEDEF type IDENTIFIER const_array_type typedef_attribute ';' {
        char type_name[VAR_NAME_MAX];

        xstrncpy(type_name, $2, VAR_NAME_MAX);
        xstrncat(type_name, $4, VAR_NAME_MAX);

        char* name = $3;

        $$ = sNodeTree_create_typedef(name, type_name, gSName, yylineno);
    }
    | TYPEDEF type TYPE_NAME const_array_type typedef_attribute ';' {
        char type_name[VAR_NAME_MAX];

        xstrncpy(type_name, $2, VAR_NAME_MAX);
        xstrncat(type_name, $4, VAR_NAME_MAX);

        char* name = $3;

        $$ = sNodeTree_create_typedef(name, type_name, gSName, yylineno);
    }
    ;

generics_types: type {
        char type_name[VAR_NAME_MAX];
        get_typedef($1, type_name);

        xstrncpy($$, type_name, VAR_NAME_MAX);
    }
    | generics_types type {
        char type_name[VAR_NAME_MAX];
        get_typedef($2, type_name);

        xstrncat($$, ",", VAR_NAME_MAX);
        xstrncat($$, type_name, VAR_NAME_MAX);
    }
    | generics_types ',' type {
        char type_name[VAR_NAME_MAX];
        get_typedef($3, type_name);

        xstrncat($$, ",", VAR_NAME_MAX);
        xstrncat($$, type_name, VAR_NAME_MAX);
    }
    ;

function_pointer_type_params: {
        xstrncpy(type_params, "", VAR_NAME_MAX);
        xstrncpy($$, type_params, VAR_NAME_MAX);
    }
    | type_and_variable_name {
        if(strcmp($1, "void") == 0) {
            xstrncpy($$, "", VAR_NAME_MAX);
        }
        else {
            xstrncpy(type_params, $1, VAR_NAME_MAX);
            xstrncpy($$, type_params, VAR_NAME_MAX);
        }
    }
    | function_pointer_type_params ',' type_and_variable_name {
        xstrncat(type_params, ",", VAR_NAME_MAX);
        xstrncat(type_params, $3, VAR_NAME_MAX);
        xstrncpy($$, type_params, VAR_NAME_MAX);
    }
    | function_pointer_type_params ',' type {
        xstrncat(type_params, ",", VAR_NAME_MAX);
        xstrncat(type_params, $3, VAR_NAME_MAX);
        xstrncpy($$, type_params, VAR_NAME_MAX);
    }
    ;

type_and_variable_name: 
    type IDENTIFIER type_attribute2 {
        char type_name[VAR_NAME_MAX];

        xstrncpy(type_name, $1, VAR_NAME_MAX);
    
        xstrncpy($$, type_name, VAR_NAME_MAX);
        xstrncpy(variable_names[num_variable_names++], $2, VAR_NAME_MAX);

        num_multiple_variable_names = 1;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    | type IDENTIFIER '[' ']' type_attribute2 {
        char type_name[VAR_NAME_MAX];

        xstrncpy(type_name, $1, VAR_NAME_MAX);
        xstrncat(type_name, "*", VAR_NAME_MAX);
    
        xstrncpy($$, type_name, VAR_NAME_MAX);
        xstrncpy(variable_names[num_variable_names++], $2, VAR_NAME_MAX);

        num_multiple_variable_names  = 1;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    | type IDENTIFIER array_type type_attribute2 {
        char type_name[VAR_NAME_MAX];

        xstrncpy(type_name, $1, VAR_NAME_MAX);
        xstrncat(type_name, $3, VAR_NAME_MAX);
    
        xstrncpy($$, type_name, VAR_NAME_MAX);
        xstrncpy(variable_names[num_variable_names++], $2, VAR_NAME_MAX);

        num_multiple_variable_names  = 1;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    | type IDENTIFIER const_array_type type_attribute2 {
        char type_name[VAR_NAME_MAX];

        xstrncpy(type_name, $1, VAR_NAME_MAX);
        xstrncat(type_name, $3, VAR_NAME_MAX);

        xstrncpy($$, type_name, VAR_NAME_MAX);
        xstrncpy(variable_names[num_variable_names++], $2, VAR_NAME_MAX);

        num_multiple_variable_names  = 1;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    | type IDENTIFIER ':' INTNUM type_attribute2 {
        char type_name[VAR_NAME_MAX];

        xstrncpy(type_name, $1, VAR_NAME_MAX);
        xstrncat(type_name, ":", VAR_NAME_MAX);

        char buf[128];
        snprintf(buf, 128, "%d", $4);

        xstrncat(type_name, buf, VAR_NAME_MAX);
    
        xstrncpy($$, type_name, VAR_NAME_MAX);
        xstrncpy(variable_names[num_variable_names++], $2, VAR_NAME_MAX);

        num_multiple_variable_names  = 1;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    | type ':' INTNUM type_attribute2 {
        char type_name[VAR_NAME_MAX];

        xstrncpy(type_name, $1, VAR_NAME_MAX);
        xstrncat(type_name, ":", VAR_NAME_MAX);

        char buf[128];
        snprintf(buf, 128, "%d", $3);

        xstrncat(type_name, buf, VAR_NAME_MAX);

        static int n = 0;
        n++;

        char variable_name[VAR_NAME_MAX];
        snprintf(variable_names, VAR_NAME_MAX, "anonymous%d\n", n);
    
        xstrncpy($$, type_name, VAR_NAME_MAX);
        xstrncpy(variable_names[num_variable_names++], variable_name, VAR_NAME_MAX);

        num_multiple_variable_names  = 1;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    | type '(' '*' IDENTIFIER ')' '(' type_params ')' type_attribute2 {
        xstrncpy($$, $1, VAR_NAME_MAX);
        xstrncat($$, " lambda(", VAR_NAME_MAX);
        xstrncat($$, $7, VAR_NAME_MAX);
        xstrncat($$, ")", VAR_NAME_MAX);

        xstrncpy(variable_names[num_variable_names++], $4, VAR_NAME_MAX);

        xstrncpy(type_params, "", VAR_NAME_MAX);

        num_multiple_variable_names  = 1;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    | type '(' '*' IDENTIFIER ')' '(' function_pointer_type_params ')' type_attribute2 {
        xstrncpy($$, $1, VAR_NAME_MAX);
        xstrncat($$, " lambda(", VAR_NAME_MAX);
        xstrncat($$, $7, VAR_NAME_MAX);
        xstrncat($$, ")", VAR_NAME_MAX);

        xstrncpy(variable_names[num_variable_names++], $4, VAR_NAME_MAX);

        xstrncpy(type_params, "", VAR_NAME_MAX);

        num_multiple_variable_names  = 1;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    | type '(' '*' VOLATILE IDENTIFIER ')' '(' type_params ')' type_attribute2 {
        xstrncpy($$, $1, VAR_NAME_MAX);
        xstrncat($$, " lambda(", VAR_NAME_MAX);
        xstrncat($$, $8, VAR_NAME_MAX);
        xstrncat($$, ")", VAR_NAME_MAX);

        xstrncpy(variable_names[num_variable_names++], $5, VAR_NAME_MAX);

        xstrncpy(type_params, "", VAR_NAME_MAX);

        num_multiple_variable_names  = 1;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    | type '(' '*' VOLATILE IDENTIFIER ')' '(' function_pointer_type_params ')' type_attribute2 {
        xstrncpy($$, $1, VAR_NAME_MAX);
        xstrncat($$, " lambda(", VAR_NAME_MAX);
        xstrncat($$, $8, VAR_NAME_MAX);
        xstrncat($$, ")", VAR_NAME_MAX);

        xstrncpy(variable_names[num_variable_names++], $5, VAR_NAME_MAX);

        xstrncpy(type_params, "", VAR_NAME_MAX);

        num_multiple_variable_names  = 1;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    | type TYPE_NAME type_attribute2 {
        char type_name[VAR_NAME_MAX];

        xstrncpy(type_name, $1, VAR_NAME_MAX);
    
        xstrncpy($$, type_name, VAR_NAME_MAX);
        xstrncpy(variable_names[num_variable_names++], $2, VAR_NAME_MAX);

        num_multiple_variable_names = 1;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    | type TYPE_NAME '[' ']' type_attribute2 {
        char type_name[VAR_NAME_MAX];

        xstrncpy(type_name, $1, VAR_NAME_MAX);
        xstrncat(type_name, "*", VAR_NAME_MAX);
    
        xstrncpy($$, type_name, VAR_NAME_MAX);
        xstrncpy(variable_names[num_variable_names++], $2, VAR_NAME_MAX);

        num_multiple_variable_names  = 1;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    | type TYPE_NAME array_type type_attribute2 {
        char type_name[VAR_NAME_MAX];

        xstrncpy(type_name, $1, VAR_NAME_MAX);
        xstrncat(type_name, $3, VAR_NAME_MAX);
    
        xstrncpy($$, type_name, VAR_NAME_MAX);
        xstrncpy(variable_names[num_variable_names++], $2, VAR_NAME_MAX);

        num_multiple_variable_names  = 1;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    | type TYPE_NAME const_array_type type_attribute2 {
        char type_name[VAR_NAME_MAX];

        xstrncpy(type_name, $1, VAR_NAME_MAX);
        xstrncat(type_name, $3, VAR_NAME_MAX);

        xstrncpy($$, type_name, VAR_NAME_MAX);
        xstrncpy(variable_names[num_variable_names++], $2, VAR_NAME_MAX);

        num_multiple_variable_names  = 1;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    | type TYPE_NAME ':' INTNUM type_attribute2 {
        char type_name[VAR_NAME_MAX];

        xstrncpy(type_name, $1, VAR_NAME_MAX);
        xstrncat(type_name, ":", VAR_NAME_MAX);

        char buf[128];
        snprintf(buf, 128, "%d", $4);

        xstrncat(type_name, buf, VAR_NAME_MAX);
    
        xstrncpy($$, type_name, VAR_NAME_MAX);
        xstrncpy(variable_names[num_variable_names++], $2, VAR_NAME_MAX);

        num_multiple_variable_names  = 1;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    | type '(' '*' TYPE_NAME ')' '(' type_params ')' type_attribute2 {
        xstrncpy($$, $1, VAR_NAME_MAX);
        xstrncat($$, " lambda(", VAR_NAME_MAX);
        xstrncat($$, $7, VAR_NAME_MAX);
        xstrncat($$, ")", VAR_NAME_MAX);

        xstrncpy(variable_names[num_variable_names++], $4, VAR_NAME_MAX);

        xstrncpy(type_params, "", VAR_NAME_MAX);

        num_multiple_variable_names  = 1;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    | type '(' '*' TYPE_NAME ')' '(' function_pointer_type_params ')' type_attribute2 {
        xstrncpy($$, $1, VAR_NAME_MAX);
        xstrncat($$, " lambda(", VAR_NAME_MAX);
        xstrncat($$, $7, VAR_NAME_MAX);
        xstrncat($$, ")", VAR_NAME_MAX);

        xstrncpy(variable_names[num_variable_names++], $4, VAR_NAME_MAX);

        xstrncpy(type_params, "", VAR_NAME_MAX);

        num_multiple_variable_names  = 1;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    | type '(' '*' VOLATILE TYPE_NAME ')' '(' type_params ')' type_attribute2 {
        xstrncpy($$, $1, VAR_NAME_MAX);
        xstrncat($$, " lambda(", VAR_NAME_MAX);
        xstrncat($$, $8, VAR_NAME_MAX);
        xstrncat($$, ")", VAR_NAME_MAX);

        xstrncpy(variable_names[num_variable_names++], $5, VAR_NAME_MAX);

        xstrncpy(type_params, "", VAR_NAME_MAX);

        num_multiple_variable_names  = 1;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    | type '(' '*' VOLATILE TYPE_NAME ')' '(' function_pointer_type_params ')' type_attribute2 {
        xstrncpy($$, $1, VAR_NAME_MAX);
        xstrncat($$, " lambda(", VAR_NAME_MAX);
        xstrncat($$, $8, VAR_NAME_MAX);
        xstrncat($$, ")", VAR_NAME_MAX);

        xstrncpy(variable_names[num_variable_names++], $5, VAR_NAME_MAX);

        xstrncpy(type_params, "", VAR_NAME_MAX);

        num_multiple_variable_names  = 1;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    ;

some_variable_names: 
    IDENTIFIER {
        num_multiple_variable_names  = 0;

        xstrncpy(variable_names[num_variable_names++], $1, VAR_NAME_MAX);
        num_multiple_variable_names ++;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    | some_variable_names ',' IDENTIFIER {
        xstrncpy(variable_names[num_variable_names++], $3, VAR_NAME_MAX);
        num_multiple_variable_names ++;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    | TYPE_NAME {
        num_multiple_variable_names  = 0;

        xstrncpy(variable_names[num_variable_names++], $1, VAR_NAME_MAX);
        num_multiple_variable_names ++;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    | some_variable_names ',' TYPE_NAME {
        xstrncpy(variable_names[num_variable_names++], $3, VAR_NAME_MAX);
        num_multiple_variable_names ++;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    ;

fields_type_and_variable_names: 
    type_and_variable_name {
        xstrncpy($$, $1, VAR_NAME_MAX);
    }
    | type some_variable_names {
        char type_name[VAR_NAME_MAX];

        xstrncpy(type_name, $1, VAR_NAME_MAX);
    
        xstrncpy($$, type_name, VAR_NAME_MAX);
    }
    ;

global_some_variable_names: 
    IDENTIFIER {
        num_multiple_variable_names  = 0;

        xstrncpy(variable_names[num_variable_names++], $1, VAR_NAME_MAX);
        num_multiple_variable_names ++;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    | IDENTIFIER '=' exp {
        num_multiple_variable_names  = 0;

        xstrncpy(variable_names[num_variable_names++], $1, VAR_NAME_MAX);
        num_multiple_variable_names ++;

        multiple_init_values[num_multiple_variable_names-1] = $3;
    }
    | IDENTIFIER const_array_type '=' '{' array_value '}' { 
        num_multiple_variable_names  = 0;

        char type_name[VAR_NAME_MAX];
        xstrncpy(type_name, recent_type_name, VAR_NAME_MAX);
        xstrncat(type_name, $2, VAR_NAME_MAX);

        char* var_name = $1;

        BOOL global = TRUE;
        BOOL extern_ = FALSE;

        $$ = sNodeTree_create_define_variable(type_name, var_name, global, extern_, 0, gSName, yylineno);

        $$ = sNodeTree_create_array_initializer($$, var_name, num_array_value, array_values, global, gSName, yylineno);

        compile($$, &cinfo);
    }
    | IDENTIFIER '[' ']' '=' '{' array_value '}' { 
        num_multiple_variable_names  = 0;

        char type_name[VAR_NAME_MAX];
        xstrncpy(type_name, recent_type_name, VAR_NAME_MAX);

        char buf[128];
        snprintf(buf, 128, "[%d]", num_array_value);
        xstrncat(type_name, buf, VAR_NAME_MAX);

        char* var_name = $1;

        BOOL global = TRUE;
        BOOL extern_ = FALSE;

        $$ = sNodeTree_create_define_variable(type_name, var_name, global, extern_, 0, gSName, yylineno);

        $$ = sNodeTree_create_array_initializer($$, var_name, num_array_value, array_values, global, gSName, yylineno);

        compile($$, &cinfo);
    }
    | IDENTIFIER const_array_type '=' CSTRING  { 
        num_multiple_variable_names  = 0;

        char type_name[VAR_NAME_MAX];
        xstrncpy(type_name, recent_type_name, VAR_NAME_MAX);
        xstrncat(type_name, $2, VAR_NAME_MAX);

        char* var_name = $1;

        BOOL global = TRUE;
        BOOL extern_ = FALSE;

        $$ = sNodeTree_create_define_variable(type_name, var_name, global, extern_, 0, gSName, yylineno);

        unsigned int array_values[512];

        char* str = $4;

        if(strlen(str) >= 512) {
            fprintf(stderr, "overflow c string length\n");
            exit(2);
        }

        int i;
        for(i=0; i<strlen(str); i++) {
            array_values[i] = sNodeTree_create_char_value(str[i], gSName, yylineno);
        }
        array_values[i] = sNodeTree_create_char_value('\0', gSName, yylineno);

        int num_array_value = strlen(str) + 1;

        $$ = sNodeTree_create_array_initializer($$, var_name, num_array_value, array_values, global, gSName, yylineno);

        compile($$, &cinfo);
    }
    | global_some_variable_names ',' IDENTIFIER {
        xstrncpy(variable_names[num_variable_names++], $3, VAR_NAME_MAX);
        num_multiple_variable_names ++;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    | global_some_variable_names ',' IDENTIFIER '=' exp {
        xstrncpy(variable_names[num_variable_names++], $3, VAR_NAME_MAX);
        num_multiple_variable_names ++;

        multiple_init_values[num_multiple_variable_names-1] = $5;
    }
    ;

global_type_and_variable_names: 
    type_and_variable_name {
        xstrncpy($$, $1, VAR_NAME_MAX);
    }
    | type global_some_variable_names {
        char type_name[VAR_NAME_MAX];

        xstrncpy(type_name, $1, VAR_NAME_MAX);
    
        xstrncpy($$, type_name, VAR_NAME_MAX);
    }
    ;

local_some_variable_names: 
    IDENTIFIER {
        num_multiple_variable_names  = 0;

        xstrncpy(variable_names[num_variable_names++], $1, VAR_NAME_MAX);
        num_multiple_variable_names ++;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    | IDENTIFIER '=' exp {
        num_multiple_variable_names  = 0;

        xstrncpy(variable_names[num_variable_names++], $1, VAR_NAME_MAX);
        num_multiple_variable_names ++;

        multiple_init_values[num_multiple_variable_names-1] = $3;
    }

    | IDENTIFIER const_array_type '=' '{' cstring_array_value2 '}' { 
        num_multiple_variable_names  = 0;

        char type_name[VAR_NAME_MAX];
        xstrncpy(type_name, recent_type_name, VAR_NAME_MAX);
        xstrncat(type_name, $2, VAR_NAME_MAX);

        char* var_name = $1;

        BOOL global = FALSE;
        BOOL extern_ = FALSE;

        $$ = sNodeTree_create_define_variable(type_name, var_name, global, extern_, 0, gSName, yylineno);

        multiple_nodes[num_multiple_node++] = sNodeTree_create_array_initializer($$, var_name, num_array_value, array_values, global, gSName, yylineno);
    }
    | IDENTIFIER const_array_type '=' '{' array_value '}' { 
        num_multiple_variable_names  = 0;

        char type_name[VAR_NAME_MAX];
        xstrncpy(type_name, recent_type_name, VAR_NAME_MAX);
        xstrncat(type_name, $2, VAR_NAME_MAX);

        char* var_name = $1;

        BOOL global = FALSE;
        BOOL extern_ = FALSE;

        $$ = sNodeTree_create_define_variable(type_name, var_name, global, extern_, 0, gSName, yylineno);

        multiple_nodes[num_multiple_node++] = sNodeTree_create_array_initializer($$, var_name, num_array_value, array_values, global, gSName, yylineno);
    }
    | IDENTIFIER '[' ']' '=' '{' array_value '}' { 
        num_multiple_variable_names  = 0;

        char type_name[VAR_NAME_MAX];
        xstrncpy(type_name, recent_type_name, VAR_NAME_MAX);

        char buf[128];
        snprintf(buf, 128, "[%d]", num_array_value);

        xstrncat(type_name, buf, VAR_NAME_MAX);

        char* var_name = $1;

        BOOL global = FALSE;
        BOOL extern_ = FALSE;

        $$ = sNodeTree_create_define_variable(type_name, var_name, global, extern_, 0, gSName, yylineno);

        multiple_nodes[num_multiple_node++] = sNodeTree_create_array_initializer($$, var_name, num_array_value, array_values, global, gSName, yylineno);
    }
    | IDENTIFIER const_array_type '=' CSTRING { 
        num_multiple_variable_names  = 0;

        char type_name[VAR_NAME_MAX];
        xstrncpy(type_name, recent_type_name, VAR_NAME_MAX);
        xstrncat(type_name, $2, VAR_NAME_MAX);

        char* var_name = $1;

        BOOL global = FALSE;
        BOOL extern_ = FALSE;

        $$ = sNodeTree_create_define_variable(type_name, var_name, global, extern_, 0, gSName, yylineno);

        unsigned int array_values[512];

        char* str = $4;

        if(strlen(str) >= 512) {
            fprintf(stderr, "overflow c string length\n");
            exit(2);
        }

        int i;
        for(i=0; i<strlen(str); i++) {
            array_values[i] = sNodeTree_create_char_value(str[i], gSName, yylineno);
        }
        array_values[i] = sNodeTree_create_char_value('\0', gSName, yylineno);

        int num_array_value = strlen(str) + 1;

        multiple_nodes[num_multiple_node++] = sNodeTree_create_array_initializer($$, var_name, num_array_value, array_values, global, gSName, yylineno);
    }
    | local_some_variable_names ',' IDENTIFIER {
        xstrncpy(variable_names[num_variable_names++], $3, VAR_NAME_MAX);
        num_multiple_variable_names ++;

        multiple_init_values[num_multiple_variable_names-1] = 0;
    }
    | local_some_variable_names ',' IDENTIFIER '=' exp {
        xstrncpy(variable_names[num_variable_names++], $3, VAR_NAME_MAX);
        num_multiple_variable_names ++;

        multiple_init_values[num_multiple_variable_names-1] = $5;
    }
    ;

local_type_and_variable_names: 
    type_and_variable_name {
        xstrncpy($$, $1, VAR_NAME_MAX);
    }
    | type local_some_variable_names {
        char type_name[VAR_NAME_MAX];

        xstrncpy(type_name, $1, VAR_NAME_MAX);
    
        xstrncpy($$, type_name, VAR_NAME_MAX);
    }
    ;

array_type: '[' exp ']' {
        snprintf($$, VAR_NAME_MAX, "[!%d]", $2);
    }
    | array_type '[' exp ']' {
        char buf[VAR_NAME_MAX];
        snprintf(buf, VAR_NAME_MAX, "[!%d]", $3);

        xstrncat($$, buf, VAR_NAME_MAX);
    }
    ;

const_array_type: '[' INTNUM ']' {
        snprintf($$, VAR_NAME_MAX, "[%d]", $2);
    }
    | const_array_type '[' INTNUM ']' {
        char buf[VAR_NAME_MAX];
        snprintf(buf, VAR_NAME_MAX, "[%d]", $3);

        xstrncat($$, buf, VAR_NAME_MAX);
    }
    ;

type_params: {
        xstrncpy(type_params, "", VAR_NAME_MAX);
        xstrncpy($$, type_params, VAR_NAME_MAX);
    }
    | type {
        if(strcmp($1, "void") == 0) {
            xstrncpy($$, "", VAR_NAME_MAX);
        }
        else {
            xstrncpy(type_params, $1, VAR_NAME_MAX);
            xstrncpy($$, type_params, VAR_NAME_MAX);
        }
    }
    | type_params ',' type {
        xstrncat(type_params, ",", VAR_NAME_MAX);
        xstrncat(type_params, $3, VAR_NAME_MAX);
        xstrncpy($$, type_params, VAR_NAME_MAX);
    }
    ;


union_: UNION IDENTIFIER '{' fields '}' ';' { 
            char* union_name = $2;
            unsigned int fields = $4;
            BOOL anonymous = FALSE;

            $$ = sNodeTree_create_union(union_name, fields, anonymous, gSName, yylineno);
        }
        ;

struct_name:
    IDENTIFIER {
        char* struct_name = $1;
        unsigned int fields = 0;
        BOOL anonymous = FALSE;
        BOOL generics = FALSE;

        unsigned int node = sNodeTree_create_struct(struct_name, fields, generics, anonymous, gSName, yylineno);

        compile(node, &cinfo);

        xstrncpy($$, struct_name, VAR_NAME_MAX);
    }
    | TYPE_NAME {
        char* struct_name = $1;
        unsigned int fields = 0;
        BOOL anonymous = FALSE;
        BOOL generics = FALSE;

        unsigned int node = sNodeTree_create_struct(struct_name, fields, generics, anonymous, gSName, yylineno);

        compile(node, &cinfo);

        xstrncpy($$, struct_name, VAR_NAME_MAX);
    }
    ;

struct_: 
        STRUCT IDENTIFIER '!' '<' struct_generics_types '>' '{' fields '}' ';' {
            char* struct_name = $2;
            unsigned int fields = $8;
            BOOL anonymous = FALSE;
            BOOL generics = num_struct_generics_types > 0;

            $$ = sNodeTree_create_struct(struct_name, fields, generics, anonymous, gSName, yylineno);
        }
        | STRUCT IDENTIFIER '{' fields '}' ';' {
            char* struct_name = $2;
            unsigned int fields = $4;
            BOOL anonymous = FALSE;
            BOOL generics = FALSE;

            $$ = sNodeTree_create_struct(struct_name, fields, generics, anonymous, gSName, yylineno);
        }
        | STRUCT TYPE_NAME '{' fields '}' ';' {
            char* struct_name = $2;
            unsigned int fields = $4;
            BOOL anonymous = FALSE;
            BOOL generics = FALSE;

            $$ = sNodeTree_create_struct(struct_name, fields, generics, anonymous, gSName, yylineno);
        }
        | STRUCT IDENTIFIER ';' {
            char* struct_name = $2;
            unsigned int fields = 0;
            BOOL anonymous = FALSE;
            BOOL generics = FALSE;

            $$ = sNodeTree_create_struct(struct_name, fields, generics, anonymous, gSName, yylineno);
        }
        | STRUCT TYPE_NAME ';' {
            char* struct_name = $2;
            unsigned int fields = 0;
            BOOL anonymous = FALSE;
            BOOL generics = FALSE;

            $$ = sNodeTree_create_struct(struct_name, fields, generics, anonymous, gSName, yylineno);
        }
        ;

struct_generics_types: {
        num_struct_generics_types = 0;
    }
    | struct_generics_types IDENTIFIER {
        xstrncpy(struct_generics_types[num_struct_generics_types], $2, VAR_NAME_MAX);

        num_struct_generics_types++;

        if(num_struct_generics_types >= GENERICS_TYPES_MAX) {
            fprintf(stderr, "overflow method generics types number\n");
            exit(2);
        }
    }
    | struct_generics_types ',' IDENTIFIER {
        xstrncpy(struct_generics_types[num_struct_generics_types], $3, VAR_NAME_MAX);

        num_struct_generics_types++;

        if(num_struct_generics_types >= GENERICS_TYPES_MAX) {
            fprintf(stderr, "overflow method generics types number\n");
            exit(2);
        }
    }
    ;

fields:  { 
            fields[num_fields++] = sNodeTree_create_struct_fields(gSName, yylineno); $$ = fields[num_fields-1]; 
        }
        | fields fields_type_and_variable_names ';' { 
            $$ = fields[num_fields-1]; 
            int i;
            for(i=0; i<num_multiple_variable_names ; i++) {
                append_field_to_fields(fields[num_fields-1], variable_names[--num_variable_names], $2); 
            }
        }
        | STRUCT TYPE_NAME IDENTIFIER ';' {
            char* var_name = $3;
            char* type_name = $2;

            $$ = fields[num_fields-1]; 
            append_field_to_fields(fields[num_fields-1], var_name, type_name); 
        }
        | fields STRUCT TYPE_NAME IDENTIFIER ';' {
            char* var_name = $4;
            char* type_name = $3;

            $$ = fields[num_fields-1]; 
            append_field_to_fields(fields[num_fields-1], var_name, type_name); 
        }

        | STRUCT TYPE_NAME IDENTIFIER const_array_type ';' {
            char* var_name = $3;
            char type_name[VAR_NAME_MAX];

            xstrncpy(type_name, $2, VAR_NAME_MAX);
            xstrncat(type_name, $4, VAR_NAME_MAX);

            $$ = fields[num_fields-1]; 
            append_field_to_fields(fields[num_fields-1], var_name, type_name); 
        }
        | fields STRUCT TYPE_NAME IDENTIFIER const_array_type ';' {
            char* var_name = $4;
            char type_name[VAR_NAME_MAX];

            xstrncpy(type_name, $3, VAR_NAME_MAX);
            xstrncat(type_name, $5, VAR_NAME_MAX);

            $$ = fields[num_fields-1]; 
            append_field_to_fields(fields[num_fields-1], var_name, type_name); 
        }
        | STRUCT TYPE_NAME pointer IDENTIFIER ';' {
            char* var_name = $3;
            char type_name[VAR_NAME_MAX];

            xstrncpy(type_name, $2, VAR_NAME_MAX);
            xstrncat(type_name, $3, VAR_NAME_MAX);

            $$ = fields[num_fields-1]; 
            append_field_to_fields(fields[num_fields-1], var_name, type_name); 
        }
        | fields STRUCT TYPE_NAME pointer IDENTIFIER';' {
            char* var_name = $4;
            char type_name[VAR_NAME_MAX];

            xstrncpy(type_name, $3, VAR_NAME_MAX);
            xstrncat(type_name, $4, VAR_NAME_MAX);

            $$ = fields[num_fields-1]; 
            append_field_to_fields(fields[num_fields-1], var_name, type_name); 
        }
        | STRUCT '{' fields '}' IDENTIFIER ';' {
            static int anonyomous_struct_num = 0;
            char buf[VAR_NAME_MAX];
            snprintf(buf, VAR_NAME_MAX, "anonmous_struct%d", anonyomous_struct_num);
            anonyomous_struct_num++;
            char* struct_name = buf;
            unsigned int fields2 = $3;
            BOOL anonymous = TRUE;
            BOOL generics = FALSE;

            unsigned int node = sNodeTree_create_struct(struct_name, fields2, generics, anonymous, gSName, yylineno);

            num_fields--;

            compile(node, &cinfo);

            char* var_name = $5;
            char* type_name = buf;

            $$ = fields[num_fields-1]; 
            append_field_to_fields(fields[num_fields-1], var_name, type_name); 
        }
        | fields STRUCT '{' fields '}' IDENTIFIER ';' {
            static int anonyomous_struct_num = 0;
            char buf[VAR_NAME_MAX];
            snprintf(buf, VAR_NAME_MAX, "anonmous_struct%d", anonyomous_struct_num);
            anonyomous_struct_num++;
            char* struct_name = buf;
            unsigned int fields2 = $4;
            BOOL anonymous = TRUE;
            BOOL generics = FALSE;

            unsigned int node = sNodeTree_create_struct(struct_name, fields2, generics, anonymous, gSName, yylineno);

            num_fields--;

            compile(node, &cinfo);

            char* var_name = $6;
            char* type_name = buf;

            $$ = fields[num_fields-1]; 
            append_field_to_fields(fields[num_fields-1], var_name, type_name); 
        }
        | UNION '{' fields '}' IDENTIFIER ';' {
            static int anonyomous_union_num = 0;
            char buf[VAR_NAME_MAX];
           
            snprintf(buf, VAR_NAME_MAX, "anonmous_union%d", anonyomous_union_num);
            anonyomous_union_num++;
            char* union_name = buf;
            unsigned int fields2 = $3;
            BOOL anonymous = TRUE;

            unsigned int node = sNodeTree_create_union(union_name, fields2, anonymous, gSName, yylineno);

            num_fields--;

            compile(node, &cinfo);

            char* var_name = $5;
            char* type_name[VAR_NAME_MAX];

            xstrncpy(type_name, buf, VAR_NAME_MAX);

            $$ = fields[num_fields-1]; 
            append_field_to_fields(fields[num_fields-1], var_name, type_name); 
        }
        | fields UNION '{' fields '}' IDENTIFIER ';' {
            static int anonyomous_union_num = 0;
            char buf[VAR_NAME_MAX];
           
            snprintf(buf, VAR_NAME_MAX, "anonmous_union%d", anonyomous_union_num);
            anonyomous_union_num++;
            char* union_name = buf;
            unsigned int fields2 = $4;
            BOOL anonymous = TRUE;

            unsigned int node = sNodeTree_create_union(union_name, fields2, anonymous, gSName, yylineno);

            num_fields--;

            compile(node, &cinfo);

            char* var_name = $6;
            char* type_name[VAR_NAME_MAX];

            xstrncpy(type_name, buf, VAR_NAME_MAX);

            $$ = fields[num_fields-1]; 
            append_field_to_fields(fields[num_fields-1], var_name, type_name); 
        }


        | STRUCT IDENTIFIER pointer IDENTIFIER ';' {
            char* struct_name = $2;
            unsigned int fields2 = 0;
            BOOL anonymous = FALSE;
            BOOL generics = FALSE;

            unsigned int node = sNodeTree_create_struct(struct_name, fields2, generics, anonymous, gSName, yylineno);

            compile(node, &cinfo);

            char* var_name = $4;
            char type_name[VAR_NAME_MAX];

            xstrncpy(type_name,  struct_name, VAR_NAME_MAX);
            xstrncat(type_name, $3, VAR_NAME_MAX);

            $$ = fields[num_fields-1]; 
            append_field_to_fields(fields[num_fields-1], var_name, type_name); 
        }
        | STRUCT IDENTIFIER pointer IDENTIFIER const_array_type ';' {
            char struct_name[VAR_NAME_MAX];
            xstrncpy(struct_name, $2, VAR_NAME_MAX);
            unsigned int fields2 = 0;
            BOOL anonymous = FALSE;
            BOOL generics = FALSE;

            unsigned int node = sNodeTree_create_struct(struct_name, fields2, generics, anonymous, gSName, yylineno);

            compile(node, &cinfo);

            char* var_name = $4;
            char* type_name[VAR_NAME_MAX];

            xstrncpy(type_name,  struct_name, VAR_NAME_MAX);
            xstrncat(type_name, $3, VAR_NAME_MAX);
            xstrncat(type_name, $5, VAR_NAME_MAX);

            $$ = fields[num_fields-1]; 
            append_field_to_fields(fields[num_fields-1], var_name, type_name); 
        }
        | fields STRUCT IDENTIFIER pointer IDENTIFIER ';' {
            char* struct_name = $3;
            unsigned int fields2 = 0;
            BOOL anonymous = FALSE;
            BOOL generics = FALSE;

            unsigned int node = sNodeTree_create_struct(struct_name, fields2, generics, anonymous, gSName, yylineno);

            compile(node, &cinfo);

            char* var_name = $5;
            char* type_name[VAR_NAME_MAX];

            xstrncpy(type_name,  struct_name, VAR_NAME_MAX);
            xstrncat(type_name, $4, VAR_NAME_MAX);

            $$ = fields[num_fields-1]; 
            append_field_to_fields(fields[num_fields-1], var_name, type_name); 
        }
        | fields STRUCT IDENTIFIER pointer IDENTIFIER const_array_type ';' {
            char struct_name[VAR_NAME_MAX];
            xstrncpy(struct_name, $3, VAR_NAME_MAX);
            unsigned int fields2 = 0;
            BOOL anonymous = FALSE;
            BOOL generics = FALSE;

            unsigned int node = sNodeTree_create_struct(struct_name, fields2, generics, anonymous, gSName, yylineno);

            compile(node, &cinfo);

            char* var_name = $5;
            char* type_name[VAR_NAME_MAX];

            xstrncpy(type_name,  struct_name, VAR_NAME_MAX);
            xstrncat(type_name, $4, VAR_NAME_MAX);
            xstrncat(type_name, $6, VAR_NAME_MAX);

            $$ = fields[num_fields-1]; 
            append_field_to_fields(fields[num_fields-1], var_name, type_name); 
        }
        | UNION '{' fields '}' ';' {
                static int anonyomous_union_num = 0;
                char buf[VAR_NAME_MAX];
               
                snprintf(buf, VAR_NAME_MAX, "anonmous_union_a%d", anonyomous_union_num);
                anonyomous_union_num++;
                char* union_name = buf;
                unsigned int fields2 = $3;
                BOOL anonymous = TRUE;

                unsigned int node = sNodeTree_create_union(union_name, fields2, anonymous, gSName, yylineno);

                compile(node, &cinfo);

                num_fields--;

                static int anonyomous_union_name_num = 0;
                char var_name[VAR_NAME_MAX];
               
                snprintf(var_name, VAR_NAME_MAX, "anonmous_union_name%d", anonyomous_union_name_num);
                anonyomous_union_name_num++;

                $$ = fields[num_fields-1]; 
                append_field_to_fields(fields[num_fields-1], var_name, union_name); 
        }
        | fields UNION '{' fields '}' ';' {
                static int anonyomous_union_num = 0;
                char buf[VAR_NAME_MAX];
               
                snprintf(buf, VAR_NAME_MAX, "anonmous_union_a%d", anonyomous_union_num);
                anonyomous_union_num++;
                char* union_name = buf;
                unsigned int fields2 = $4;
                BOOL anonymous = TRUE;

                unsigned int node = sNodeTree_create_union(union_name, fields2, anonymous, gSName, yylineno);

                compile(node, &cinfo);

                num_fields--;

                static int anonyomous_union_name_num = 0;
                char var_name[VAR_NAME_MAX];
               
                snprintf(var_name, VAR_NAME_MAX, "anonmous_union_name%d", anonyomous_union_name_num);
                anonyomous_union_name_num++;

                $$ = fields[num_fields-1]; 
                append_field_to_fields(fields[num_fields-1], var_name, union_name); 
        }
        | STRUCT '{' fields '}' ';' {
                static int anonyomous_struct_num = 0;
                char buf[VAR_NAME_MAX];
               
                snprintf(buf, VAR_NAME_MAX, "anonmous_struct_a%d", anonyomous_struct_num);
                anonyomous_struct_num++;
                char* struct_name = buf;
                unsigned int fields2 = $3;
                BOOL anonymous = TRUE;
                BOOL generics = FALSE;

                unsigned int node = sNodeTree_create_struct(struct_name, fields2, generics, anonymous, gSName, yylineno);

                compile(node, &cinfo);

                num_fields--;

                static int anonyomous_struct_name_num = 0;
                char var_name[VAR_NAME_MAX];
               
                snprintf(var_name, VAR_NAME_MAX, "anonmous_struct_name%d", anonyomous_struct_name_num);
                anonyomous_struct_name_num++;

                $$ = fields[num_fields-1]; 
                append_field_to_fields(fields[num_fields-1], var_name, struct_name); 
        }
        | fields STRUCT '{' fields '}' ';' {
                static int anonyomous_struct_num = 0;
                char buf[VAR_NAME_MAX];
               
                snprintf(buf, VAR_NAME_MAX, "anonmous_struct_a%d", anonyomous_struct_num);
                anonyomous_struct_num++;
                char* struct_name = buf;
                unsigned int fields2 = $4;
                BOOL anonymous = TRUE;
                BOOL generics = FALSE;

                unsigned int node = sNodeTree_create_struct(struct_name, fields2, generics, anonymous, gSName, yylineno);

                compile(node, &cinfo);

                num_fields--;

                static int anonyomous_struct_name_num = 0;
                char var_name[VAR_NAME_MAX];
               
                snprintf(var_name, VAR_NAME_MAX, "anonmous_struct_name%d", anonyomous_struct_name_num);
                anonyomous_struct_name_num++;

                $$ = fields[num_fields-1]; 
                append_field_to_fields(fields[num_fields-1], var_name, struct_name); 
        }







        | STRUCT IDENTIFIER '!' '<' struct_generics_types '>' pointer IDENTIFIER ';' {
            char* struct_name = $2;
            unsigned int fields2 = 0;
            BOOL anonymous = FALSE;
            BOOL generics = num_struct_generics_types > 0;

            unsigned int node = sNodeTree_create_struct(struct_name, fields2, generics, anonymous, gSName, yylineno);

            compile(node, &cinfo);

            char* var_name = $8;

            char* type_name[VAR_NAME_MAX];

            xstrncpy(type_name, struct_name, VAR_NAME_MAX);
            xstrncat(type_name, "<", VAR_NAME_MAX);

            int i;
            for(i=0; i<num_struct_generics_types; i++) {
                char buf[VAR_NAME_MAX];
                snprintf(buf, VAR_NAME_MAX, "generics%d", i);

                xstrncat(type_name, buf, VAR_NAME_MAX);

                if(i != num_struct_generics_types-1) {
                    xstrncat(type_name, ",", VAR_NAME_MAX);
                }
            }

            xstrncat(type_name, ">", VAR_NAME_MAX);
            xstrncat(type_name, $7, VAR_NAME_MAX);

            $$ = fields[num_fields-1]; 
            append_field_to_fields(fields[num_fields-1], var_name, type_name); 
        }
        | fields STRUCT IDENTIFIER '!' '<' struct_generics_types '>' pointer IDENTIFIER ';' {
            char* struct_name = $3;
            unsigned int fields2 = 0;
            BOOL anonymous = FALSE;
            BOOL generics = num_struct_generics_types > 0;

            unsigned int node = sNodeTree_create_struct(struct_name, fields2, generics, anonymous, gSName, yylineno);

            compile(node, &cinfo);

            char* var_name = $9;

            char* type_name[VAR_NAME_MAX];

            xstrncpy(type_name, struct_name, VAR_NAME_MAX);
            xstrncat(type_name, "<", VAR_NAME_MAX);

            int i;
            for(i=0; i<num_struct_generics_types; i++) {
                char buf[VAR_NAME_MAX];
                snprintf(buf, VAR_NAME_MAX, "generics%d", i);

                xstrncat(type_name, buf, VAR_NAME_MAX);

                if(i != num_struct_generics_types-1) {
                    xstrncat(type_name, ",", VAR_NAME_MAX);
                }
            }

            xstrncat(type_name, ">", VAR_NAME_MAX);
            xstrncat(type_name, $8, VAR_NAME_MAX);

            $$ = fields[num_fields-1]; 
            append_field_to_fields(fields[num_fields-1], var_name, type_name); 
        }
        | STRUCT TYPE_NAME '!' '<' struct_generics_types '>' pointer IDENTIFIER ';' {
            char* struct_name = $2;
            unsigned int fields2 = 0;
            BOOL anonymous = FALSE;
            BOOL generics = num_struct_generics_types > 0;

            unsigned int node = sNodeTree_create_struct(struct_name, fields2, generics, anonymous, gSName, yylineno);

            compile(node, &cinfo);

            char* var_name = $8;

            char* type_name[VAR_NAME_MAX];

            xstrncpy(type_name, struct_name, VAR_NAME_MAX);
            xstrncat(type_name, "<", VAR_NAME_MAX);

            int i;
            for(i=0; i<num_struct_generics_types; i++) {
                char buf[VAR_NAME_MAX];
                snprintf(buf, VAR_NAME_MAX, "generics%d", i);

                xstrncat(type_name, buf, VAR_NAME_MAX);

                if(i != num_struct_generics_types-1) {
                    xstrncat(type_name, ",", VAR_NAME_MAX);
                }
            }

            xstrncat(type_name, ">", VAR_NAME_MAX);
            xstrncat(type_name, $7, VAR_NAME_MAX);

            $$ = fields[num_fields-1]; 
            append_field_to_fields(fields[num_fields-1], var_name, type_name); 
        }
        | fields STRUCT TYPE_NAME '!' '<' struct_generics_types '>' pointer IDENTIFIER ';' {
            char* struct_name = $3;
            unsigned int fields2 = 0;
            BOOL anonymous = FALSE;
            BOOL generics = num_struct_generics_types > 0;

            unsigned int node = sNodeTree_create_struct(struct_name, fields2, generics, anonymous, gSName, yylineno);

            compile(node, &cinfo);

            char* var_name = $9;

            char* type_name[VAR_NAME_MAX];

            xstrncpy(type_name, struct_name, VAR_NAME_MAX);
            xstrncat(type_name, "<", VAR_NAME_MAX);

            int i;
            for(i=0; i<num_struct_generics_types; i++) {
                char buf[VAR_NAME_MAX];
                snprintf(buf, VAR_NAME_MAX, "generics%d", i);

                xstrncat(type_name, buf, VAR_NAME_MAX);

                if(i != num_struct_generics_types-1) {
                    xstrncat(type_name, ",", VAR_NAME_MAX);
                }
            }

            xstrncat(type_name, ">", VAR_NAME_MAX);
            xstrncat(type_name, $8, VAR_NAME_MAX);

            $$ = fields[num_fields-1]; 
            append_field_to_fields(fields[num_fields-1], var_name, type_name); 
        }
        ;

global_variable:
        global_type_and_variable_names ';' {
            char* type_name = $1;
            BOOL global = TRUE;
            BOOL extern_ = FALSE;

            int i;
            for(i=0; i<num_multiple_variable_names ; i++) {
                char* var_name = variable_names[--num_variable_names];
                unsigned int init_value = multiple_init_values[num_multiple_variable_names-i-1];

                if(init_value) {
                    BOOL alloc = TRUE;
                    unsigned int node = sNodeTree_create_store_variable(var_name, type_name, init_value, alloc, global, gSName, yylineno);

                    compile(node, &cinfo);
                }
                else {
                    unsigned int node = sNodeTree_create_define_variable(type_name, var_name, global, extern_, init_value, gSName, yylineno);

                    compile(node, &cinfo);
                }
            }

            $$ = 0;
        }
        | EXTERN global_type_and_variable_names ';' {
            char* type_name = $2;
            BOOL global = TRUE;
            BOOL extern_ = TRUE;


            int i;
            for(i=0; i<num_multiple_variable_names ; i++) {
                char* var_name = variable_names[--num_variable_names];
                unsigned int init_value = multiple_init_values[num_multiple_variable_names-i-1];
                if(init_value) {
                    BOOL alloc = TRUE;
                    unsigned int node = sNodeTree_create_store_variable(var_name, type_name, init_value, alloc, global, gSName, yylineno);

                    compile(node, &cinfo);
                }
                else {
                    unsigned int node = sNodeTree_create_define_variable(type_name, var_name, global, extern_, init_value, gSName, yylineno);

                    compile(node, &cinfo);
                }
            }

            $$ = 0;
        }
        | EXTERN type IDENTIFIER '[' ']' ';' { 
            char* type_name[VAR_NAME_MAX];
            xstrncpy(type_name, $2, VAR_NAME_MAX);
            xstrncat(type_name, "*", VAR_NAME_MAX);
            char* var_name = $3;
            BOOL global = TRUE;
            BOOL extern_ = TRUE;

            $$ = sNodeTree_create_define_variable(type_name, var_name, global, extern_, 0, gSName, yylineno);
        }
        ;

sub_array: 
    exp {
        array_values[num_array_value++] = $1;

        if(num_array_value >= INIT_ARRAY_MAX) {
            fprintf(stderr, "overflow array element numver\n");
            exit(1);
        }

        $$ = $1;
    }
    | sub_array ',' exp {
        array_values[num_array_value++] = $3;

        if(num_array_value >= INIT_ARRAY_MAX) {
            fprintf(stderr, "overflow array element numver\n");
            exit(1);
        }

        $$ = $3;
    }
    ;

sub_array_init: {
    num_array_value = 0;
    }
    ;

array_value: 
    exp {
        num_array_value = 0;
        array_values[num_array_value++] = $1;

        if(num_array_value >= INIT_ARRAY_MAX) {
            fprintf(stderr, "overflow array element numver\n");
            exit(1);
        }

        $$ = $1;
    }
    | '{' sub_array_init sub_array '}' {
        $$ = $2;
    }
    | array_value ',' exp {
        array_values[num_array_value++] = $3;

        if(num_array_value >= INIT_ARRAY_MAX) {
            fprintf(stderr, "overflow array element numver\n");
            exit(1);
        }

        $$ = $3;
    }
    | array_value ',' '{' sub_array '}' {
        $$ = $4;
    }
    ;

name:
    IDENTIFIER {
        xstrncpy($$, $1, VAR_NAME_MAX);
    }
    | TYPE_NAME {
        xstrncpy($$, $1, VAR_NAME_MAX);
    }
    | __PRINTF__ {
        xstrncpy($$, "printf", VAR_NAME_MAX);
    }
    | STRFTIME {
        xstrncpy($$, "strftime", VAR_NAME_MAX);
    }
    | __SCANF__ {
        xstrncpy($$, "scanf", VAR_NAME_MAX);
    }
    | CLONE {
        xstrncpy($$, "clone", VAR_NAME_MAX);
    }
    | TOKEN_DELETE {
        xstrncpy($$, "delete", VAR_NAME_MAX);
    }
    ;

function: 
        type name '(' function_params ')' function_attribute ';' {
            char* result_type = $1;
            char* fun_name = $2;
            unsigned int function_params = $4;
            $$ = it = sNodeTree_create_external_function(fun_name, function_params, result_type, var_arg, inherit_, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        | type function_struct_type_name METHOD_MARK name '(' function_params ')' function_attribute ';'
        {
            char* result_type = $1;

            char fun_name[VAR_NAME_MAX];

            char* struct_name = $2;

            char struct_name2[VAR_NAME_MAX];

            char* p = strstr(struct_name, "<");

            if(p) {
                memcpy(struct_name2, struct_name, p - struct_name);
                struct_name2[p-struct_name] = '\0';
            }
            else {
                xstrncpy(struct_name2, struct_name, VAR_NAME_MAX);
            }

            xstrncpy(fun_name, struct_name2, VAR_NAME_MAX);
            xstrncat(fun_name, "_", VAR_NAME_MAX);
            xstrncat(fun_name, $4, VAR_NAME_MAX);

            char fun_base_name[VAR_NAME_MAX];

            xstrncpy(fun_base_name, $4, VAR_NAME_MAX);

            unsigned int function_params = $6;
            BOOL generics = num_function_generics_types > 0;
            BOOL method_generics = num_method_generics_types > 0;

            $$ = it = sNodeTree_create_external_function(fun_name, function_params, result_type, var_arg, inherit_, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        | EXTERN type function_struct_type_name METHOD_MARK name '(' function_params ')' function_attribute ';'
        {
            char* result_type = $2;

            char fun_name[VAR_NAME_MAX];

            char* struct_name = $3;

            char struct_name2[VAR_NAME_MAX];

            char* p = strstr(struct_name, "<");

            if(p) {
                memcpy(struct_name2, struct_name, p - struct_name);
                struct_name2[p-struct_name] = '\0';
            }
            else {
                xstrncpy(struct_name2, struct_name, VAR_NAME_MAX);
            }

            xstrncpy(fun_name, struct_name2, VAR_NAME_MAX);
            xstrncat(fun_name, "_", VAR_NAME_MAX);
            xstrncat(fun_name, $5, VAR_NAME_MAX);

            char fun_base_name[VAR_NAME_MAX];

            xstrncpy(fun_base_name, $5, VAR_NAME_MAX);

            unsigned int function_params = $7;
            BOOL generics = num_function_generics_types > 0;
            BOOL method_generics = num_method_generics_types > 0;

            $$ = it = sNodeTree_create_external_function(fun_name, function_params, result_type, var_arg, inherit_, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        | EXTERN type name '(' function_params ')' function_attribute ';' {
            char* result_type = $2;
            char* fun_name = $3;
            unsigned int function_params = $5;
            $$ = it = sNodeTree_create_external_function(fun_name, function_params, result_type, var_arg, inherit_, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }

        | type name '(' function_params ')' __ASM__ '(' CSTRING CSTRING ')' function_attribute ';' {
            char* result_type = $1;
            char* fun_name = $9;
            unsigned int function_params = $4;
            $$ = it = sNodeTree_create_external_function(fun_name, function_params, result_type, var_arg, inherit_, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        | EXTERN type name '(' function_params ')' __ASM__ '(' CSTRING CSTRING ')'  function_attribute ';' {
            char* result_type = $2;
            char* fun_name = $10;
            unsigned int function_params = $5;
            $$ = it = sNodeTree_create_external_function(fun_name, function_params, result_type, var_arg, inherit_, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        | type name '(' function_params ')' __ASM__ '(' CSTRING ')' function_attribute ';' {
            char* result_type = $1;
            char* fun_name = $8;
            unsigned int function_params = $4;
            $$ = it = sNodeTree_create_external_function(fun_name, function_params, result_type, var_arg, inherit_, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        | EXTERN type name '(' function_params ')' __ASM__ '(' CSTRING ')'  function_attribute ';' {
            char* result_type = $2;
            char* fun_name = $9;
            unsigned int function_params = $5;
            $$ = it = sNodeTree_create_external_function(fun_name, function_params, result_type, var_arg, inherit_, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }

        | type name '(' function_params ')' function_attribute __ASM__ '(' CSTRING ')' ';' {
            char* result_type = $1;
            char* fun_name = $9;
            unsigned int function_params = $4;
            $$ = it = sNodeTree_create_external_function(fun_name, function_params, result_type, var_arg, inherit_, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        | EXTERN type name '(' function_params ')'  function_attribute  __ASM__ '(' CSTRING ')'';' {
            char* result_type = $2;
            char* fun_name = $10;
            unsigned int function_params = $5;
            $$ = it = sNodeTree_create_external_function(fun_name, function_params, result_type, var_arg, inherit_, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }

        | type name '(' function_params2 ')' function_attribute ';' {
            char* result_type = $1;
            char* fun_name = $2;
            unsigned int function_params = $4;
            $$ = it = sNodeTree_create_external_function(fun_name, function_params, result_type, var_arg, inherit_, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        | EXTERN type name '(' function_params2 ')' function_attribute ';' {
            char* result_type = $2;
            char* fun_name = $3;
            unsigned int function_params = $5;
            $$ = it = sNodeTree_create_external_function(fun_name, function_params, result_type, var_arg, inherit_, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        | type TYPE_NAME '(' function_params2 ')' function_attribute ';' {
            char* result_type = $1;
            char* fun_name = $2;
            unsigned int function_params = $4;
            $$ = it = sNodeTree_create_external_function(fun_name, function_params, result_type, var_arg, inherit_, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        | EXTERN type TYPE_NAME '(' function_params2 ')' function_attribute ';' {
            char* result_type = $2;
            char* fun_name = $3;
            unsigned int function_params = $5;
            $$ = it = sNodeTree_create_external_function(fun_name, function_params, result_type, var_arg, inherit_, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        | type TYPE_NAME '(' function_params2 ')' __ASM__ '(' CSTRING CSTRING ')' function_attribute ';' {
            char* result_type = $1;
            char* fun_name = $9;
            unsigned int function_params = $4;
            $$ = it = sNodeTree_create_external_function(fun_name, function_params, result_type, var_arg, inherit_, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        | EXTERN type TYPE_NAME '(' function_params2 ')' __ASM__ '(' CSTRING CSTRING ')'  function_attribute ';' {
            char* result_type = $2;
            char* fun_name = $10;
            unsigned int function_params = $5;
            $$ = it = sNodeTree_create_external_function(fun_name, function_params, result_type, var_arg, inherit_, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }




        | type name '(' function_params ')' function_params_end '{' function_block '}' block_end {
            char* result_type = $1;
            char* fun_name = $2;
            unsigned int function_params = $4;
            unsigned int node_block = $8;
            BOOL generics = FALSE;
            BOOL method_generics = FALSE;

            $$ = it = sNodeTree_create_function(fun_node, fun_name, fun_name, function_params, result_type, node_block, var_arg, inline_, static_, inherit_, generics, num_method_generics_types, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        | type name '(' function_params2 ')' __ASM__ '(' CSTRING CSTRING ')' function_attribute ';' {
            char* result_type = $1;
            char* fun_name = $9;
            unsigned int function_params = $4;
            $$ = it = sNodeTree_create_external_function(fun_name, function_params, result_type, var_arg, inherit_, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        | EXTERN type name '(' function_params2 ')' __ASM__ '(' CSTRING CSTRING ')'  function_attribute ';' {
            char* result_type = $2;
            char* fun_name = $10;
            unsigned int function_params = $5;
            $$ = it = sNodeTree_create_external_function(fun_name, function_params, result_type, var_arg, inherit_, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        | type TYPE_NAME '(' function_params ')' function_attribute ';' {
            char* result_type = $1;
            char* fun_name = $2;
            unsigned int function_params = $4;
            $$ = it = sNodeTree_create_external_function(fun_name, function_params, result_type, var_arg, inherit_, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        | EXTERN type TYPE_NAME '(' function_params ')' function_attribute ';' {
            char* result_type = $2;
            char* fun_name = $3;
            unsigned int function_params = $5;
            $$ = it = sNodeTree_create_external_function(fun_name, function_params, result_type, var_arg, inherit_, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        | type TYPE_NAME '(' function_params ')' __ASM__ '(' CSTRING CSTRING ')' function_attribute ';' {
            char* result_type = $1;
            char* fun_name = $9;
            unsigned int function_params = $4;
            $$ = it = sNodeTree_create_external_function(fun_name, function_params, result_type, var_arg, inherit_, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        | EXTERN type TYPE_NAME '(' function_params ')' __ASM__ '(' CSTRING CSTRING ')'  function_attribute ';' {
            char* result_type = $2;
            char* fun_name = $10;
            unsigned int function_params = $5;
            $$ = it = sNodeTree_create_external_function(fun_name, function_params, result_type, var_arg, inherit_, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        | type TYPE_NAME '(' function_params ')' __ASM__ '(' CSTRING ')' function_attribute ';' {
            char* result_type = $1;
            char* fun_name = $8;
            unsigned int function_params = $4;
            $$ = it = sNodeTree_create_external_function(fun_name, function_params, result_type, var_arg, inherit_, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        | EXTERN type TYPE_NAME '(' function_params ')' __ASM__ '(' CSTRING ')'  function_attribute ';' {
            char* result_type = $2;
            char* fun_name = $9;
            unsigned int function_params = $5;
            $$ = it = sNodeTree_create_external_function(fun_name, function_params, result_type, var_arg, inherit_, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }








        | type function_struct_type_name METHOD_MARK name '(' function_params ')' function_params_end '{' function_block '}' block_end 
        {
            char* result_type = $1;

            char fun_name[VAR_NAME_MAX];

            char* struct_name = $2;

            char struct_name2[VAR_NAME_MAX];

            char* p = strstr(struct_name, "<");

            if(p) {
                memcpy(struct_name2, struct_name, p - struct_name);
                struct_name2[p-struct_name] = '\0';
            }
            else {
                xstrncpy(struct_name2, struct_name, VAR_NAME_MAX);
            }

            xstrncpy(fun_name, struct_name2, VAR_NAME_MAX);
            xstrncat(fun_name, "_", VAR_NAME_MAX);
            xstrncat(fun_name, $4, VAR_NAME_MAX);

            char fun_base_name[VAR_NAME_MAX];

            xstrncpy(fun_base_name, $4, VAR_NAME_MAX);

            unsigned int function_params = $6;
            unsigned int node_block = $10;
            BOOL generics = num_function_generics_types > 0;
            BOOL method_generics = num_method_generics_types > 0;

            $$ = it = sNodeTree_create_function(fun_node, fun_name, fun_base_name, function_params, result_type, node_block, var_arg, inline_, static_, inherit_, generics, method_generics, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        | TEMPLATE '!' '<' method_generics_types '>' type name '(' function_params ')' function_params_end '{' function_block '}' block_end {
            char* result_type = $6;
            char* fun_name = $7;
            unsigned int function_params = $9;
            unsigned int node_block = $13;
            BOOL generics = FALSE;
            BOOL method_generics = num_method_generics_types > 0;

            $$ = it = sNodeTree_create_function(fun_node, fun_name, fun_name, function_params, result_type, node_block, var_arg, inline_, static_, inherit_, generics, num_method_generics_types, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        | TEMPLATE '!' '<' method_generics_types '>' type function_struct_type_name METHOD_MARK name '(' function_params ')' function_params_end '{' function_block '}' block_end 
        {
            char* result_type = $6;

            char fun_name[VAR_NAME_MAX];

            char* struct_name = $7;

            char* p = strstr(struct_name, "<");

            char struct_name2[VAR_NAME_MAX];

            if(p) {
                memcpy(struct_name2, struct_name, p - struct_name);
                struct_name2[p-struct_name] = '\0';
            }
            else {
                xstrncpy(struct_name2, struct_name, VAR_NAME_MAX);
            }

            xstrncpy(fun_name, struct_name2, VAR_NAME_MAX);
            xstrncat(fun_name, "_", VAR_NAME_MAX);
            xstrncat(fun_name, $9, VAR_NAME_MAX);

            char fun_base_name[VAR_NAME_MAX];

            xstrncpy(fun_base_name, $8, VAR_NAME_MAX);

            unsigned int function_params = $11;
            unsigned int node_block = $15;
            BOOL generics = num_function_generics_types > 0;
            BOOL method_generics = num_method_generics_types > 0;

            $$ = it = sNodeTree_create_function(fun_node, fun_name, fun_base_name, function_params, result_type, node_block, var_arg, inline_, static_, inherit_, generics, method_generics, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        | type TYPE_NAME '(' function_params ')' function_params_end '{' function_block '}' block_end {
            char* result_type = $1;
            char* fun_name = $2;
            unsigned int function_params = $4;
            unsigned int node_block = $8;
            BOOL generics = FALSE;
            BOOL method_generics = FALSE;

            $$ = it = sNodeTree_create_function(fun_node, fun_name, fun_name, function_params, result_type, node_block, var_arg, inline_, static_, inherit_, generics, num_method_generics_types, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        | type function_struct_type_name METHOD_MARK TYPE_NAME '(' function_params ')' function_params_end '{' function_block '}' block_end 
        {
            char* result_type = $1;

            char fun_name[VAR_NAME_MAX];

            char* struct_name = $2;

            char* p = strstr(struct_name, "<");

            char struct_name2[VAR_NAME_MAX];

            if(p) {
                memcpy(struct_name2, struct_name, p - struct_name);
                struct_name2[p-struct_name] = '\0';
            }
            else {
                xstrncpy(struct_name2, struct_name, VAR_NAME_MAX);
            }

            xstrncpy(fun_name, struct_name2, VAR_NAME_MAX);
            xstrncat(fun_name, "_", VAR_NAME_MAX);
            xstrncat(fun_name, $4, VAR_NAME_MAX);

            char fun_base_name[VAR_NAME_MAX];

            xstrncpy(fun_base_name, $4, VAR_NAME_MAX);

            unsigned int function_params = $6;
            unsigned int node_block = $10;
            BOOL generics = num_function_generics_types > 0;
            BOOL method_generics = num_method_generics_types > 0;

            $$ = it = sNodeTree_create_function(fun_node, fun_name, fun_base_name, function_params, result_type, node_block, var_arg, inline_, static_, inherit_, generics, method_generics, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        | TEMPLATE '!' '<' method_generics_types '>' type TYPE_NAME '(' function_params ')' function_params_end '{' function_block '}' block_end {
            char* result_type = $6;
            char* fun_name = $7;
            unsigned int function_params = $9;
            unsigned int node_block = $13;
            BOOL generics = FALSE;
            BOOL method_generics = num_method_generics_types > 0;

            $$ = it = sNodeTree_create_function(fun_node, fun_name, fun_name, function_params, result_type, node_block, var_arg, inline_, static_, inherit_, generics, num_method_generics_types, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        | TEMPLATE '!' '<' method_generics_types '>' type function_struct_type_name METHOD_MARK TYPE_NAME '(' function_params ')' function_params_end '{' function_block '}' block_end 
        {
            char* result_type = $6;

            char fun_name[VAR_NAME_MAX];

            char* struct_name = $7;

            char* p = strstr(struct_name, "<");

            char struct_name2[VAR_NAME_MAX];

            if(p) {
                memcpy(struct_name2, struct_name, p - struct_name);
                struct_name2[p-struct_name] = '\0';
            }
            else {
                xstrncpy(struct_name2, struct_name, VAR_NAME_MAX);
            }

            xstrncpy(fun_name, struct_name2, VAR_NAME_MAX);
            xstrncat(fun_name, "_", VAR_NAME_MAX);
            xstrncat(fun_name, $9, VAR_NAME_MAX);

            char fun_base_name[VAR_NAME_MAX];

            xstrncpy(fun_base_name, $8, VAR_NAME_MAX);

            unsigned int function_params = $11;
            unsigned int node_block = $15;
            BOOL generics = num_function_generics_types > 0;
            BOOL method_generics = num_method_generics_types > 0;

            $$ = it = sNodeTree_create_function(fun_node, fun_name, fun_base_name, function_params, result_type, node_block, var_arg, inline_, static_, inherit_, generics, method_generics, gSName, yylineno);

            num_function_generics_types = 0;
            num_method_generics_types = 0;
            inline_ = FALSE;
            static_ = FALSE;
            inherit_ = FALSE;
        }
        ;

function_attribute_core:
    __NOTHROW__ { } 
    | __LEAF__ { }
    | __MALLOC__ { }
    | __FORMAT__ '(' __PRINTF__ ',' INTNUM ',' INTNUM ')'
    | __FORMAT__ '(' __SCANF__ ',' INTNUM ',' INTNUM ')'
    | __FORMAT__ '(' STRFTIME ',' INTNUM ',' INTNUM ')'
    | __PURE__ { }
    | __NONNULL__ '(' INTNUM ')' { }
    | __NONNULL__ '(' INTNUM ',' INTNUM ')' { }
    | ANNOTATE '(' CSTRING CSTRING')' { }
    | ANNOTATE '(' CSTRING ')' { }
    | DEPRECATED '(' CSTRING ')'
    | __WARN_UNUSED_RESULT__ {}
    | __ALLOC_SIZE__ '(' INTNUM ')'
    | __ALLOC_SIZE__ '(' INTNUM ',' INTNUM ')'
    | __MALLOC__
    | __NORETURN__
    | __CONST__
    | OVERLOADABLE
    | __RETURNS_TWICE__
    | __SENTINEL__
    | __SENTINEL__ '(' INTNUM ')'
    | ENABLE_IF '(' INTNUM ',' CSTRING ')'
    | function_attribute_core ',' __NOTHROW__ { }
    | function_attribute_core ',' __LEAF__ { }
    | function_attribute_core ',' __MALLOC__ { }
    | function_attribute_core ',' __FORMAT__ '(' __PRINTF__ ',' INTNUM ',' INTNUM ')'
    | function_attribute_core ',' __FORMAT__ '(' __SCANF__ ',' INTNUM ',' INTNUM ')'
    | function_attribute_core ',' __FORMAT__ '(' STRFTIME ',' INTNUM ',' INTNUM ')'
    | function_attribute_core ',' __PURE__ { }
    | function_attribute_core __NONNULL__ '(' INTNUM ')' { }
    | function_attribute_core __NONNULL__ '(' INTNUM ',' INTNUM ')' { }
    | function_attribute_core ANNOTATE '(' CSTRING CSTRING')' { }
    | function_attribute_core ANNOTATE '(' CSTRING ')' { }
    | function_attribute_core DEPRECATED '(' CSTRING ')'
    | function_attribute_core __WARN_UNUSED_RESULT__
    | function_attribute_core __ALLOC_SIZE__ '(' INTNUM ')'
    | function_attribute_core __ALLOC_SIZE__ '(' INTNUM ',' INTNUM ')'
    | function_attribute_core __MALLOC__
    | function_attribute_core __NORETURN__
    | function_attribute_core __CONST__
    | function_attribute_core OVERLOADABLE
    | function_attribute_core __RETURNS_TWICE__
    | function_attribute_core __SENTINEL__
    | function_attribute_core __SENTINEL__ '(' INTNUM ')'
    | function_attribute_core ENABLE_IF '(' INTNUM ',' CSTRING ')'
    ;

function_attribute: {
    }
    | __ATTRIBUTE__ '(' '(' function_attribute_core ')' ')' { }

    | function_attribute __ATTRIBUTE__ '(' '(' function_attribute_core ')' ')' { }
    ;

pre_function_attribute: {
    }
    | __ATTRIBUTE__ '(' '(' __NORETURN__ ')' ')' { }
    | __ATTRIBUTE__ '(' '(' __WARN_UNUSED_RESULT__ ')' ')' { }

    | function_attribute __ATTRIBUTE__ '(' '(' __NORETURN__ ')' ')' { }
    | function_attribute __ATTRIBUTE__ '(' '(' __WARN_UNUSED_RESULT__ ')' ')' { }
    ;
    

function_params: { 
            func_params = sNodeTree_create_function_params(gSName, yylineno); $$ = func_params; var_arg = FALSE; 
        }
        | VOID { 
            func_params = sNodeTree_create_function_params(gSName, yylineno); $$ = func_params; 
        }
        | type_and_variable_name {
            func_params = sNodeTree_create_function_params(gSName, yylineno);
            $$ = func_params; 
            var_arg = FALSE; 

            if(num_multiple_variable_names  != 1) {
                fprintf("%s %d: syntax error\n", gSName, yylineno);
                exit(2);
            }

            append_param_to_function_params(func_params, $1, variable_names[--num_variable_names]);
        }
        | function_params ',' type_and_variable_name { 
            $$ = func_params; 

            if(num_multiple_variable_names  != 1) {
                fprintf("%s %d: syntax error\n", gSName, yylineno);
                exit(2);
            }

            append_param_to_function_params(func_params, $3, variable_names[--num_variable_names]); 
        }
        | function_params ',' '.' '.' '.' {
            var_arg = TRUE;
        }
        ;

function_params2: { 
            func_params = sNodeTree_create_function_params(gSName, yylineno); $$ = func_params; var_arg = FALSE; 
        }
        | VOID { 
            func_params = sNodeTree_create_function_params(gSName, yylineno); $$ = func_params; 
        }
        | type {
            func_params = sNodeTree_create_function_params(gSName, yylineno);

            $$ = func_params; 
            if(strcmp($1, "void") != 0) {
                var_arg = FALSE; 
                append_param_to_function_params(func_params, $1,  "");
            }
        }
        | function_params2 ',' type { 
            $$ = func_params; 
            append_param_to_function_params(func_params, $3, ""); 
        }
        | function_params2 ',' '.' '.' '.' {
            var_arg = TRUE;
        }
        ;

function_params3: { 
            func_params = sNodeTree_create_function_params(gSName, yylineno); $$ = func_params; var_arg = FALSE; 
        }
        | VOID { 
            func_params = sNodeTree_create_function_params(gSName, yylineno); $$ = func_params; 
        }
        | type IDENTIFIER {
            func_params = sNodeTree_create_function_params(gSName, yylineno);

            $$ = func_params; 
            if(strcmp($1, "void") != 0) {
                var_arg = FALSE; 
                append_param_to_function_params(func_params, $1,  "");
            }
        }
        | function_params3 ',' type IDENTIFIER { 
            $$ = func_params; 
            append_param_to_function_params(func_params, $3, ""); 
        }
        | function_params3 ',' '.' '.' '.' {
            var_arg = TRUE;
        }
        ;

function_params_end: {
        $$ = fun_node = sNodeTree_pre_create_function(func_params, gSName, yylineno);
        }
        ;


method_generics_types: {
        num_method_generics_types = 0;
    }
    | method_generics_types IDENTIFIER {
        xstrncpy(method_generics_types[num_method_generics_types], $2, VAR_NAME_MAX);

        num_method_generics_types++;

        if(num_method_generics_types >= GENERICS_TYPES_MAX) {
            fprintf(stderr, "overflow method generics types number\n");
            exit(2);
        }
    }
    ;

function_struct_type_name: 
    TYPE_NAME {
        char type_name[VAR_NAME_MAX];

        if(strcmp($1, "string") == 0) {
            xstrncpy(type_name, "string", VAR_NAME_MAX);
        }
        else if(strcmp($1, "wstring") == 0) {
            xstrncpy(type_name, "wstring", VAR_NAME_MAX);
        }
        else {
            get_typedef($1, type_name);
        }

        xstrncpy($$, type_name, VAR_NAME_MAX);
        num_function_generics_types = 0;
    }
    | LONG {
        char type_name[VAR_NAME_MAX];

        get_typedef($1, type_name);

        xstrncpy($$, type_name, VAR_NAME_MAX);
        num_function_generics_types = 0;
    }
    | SHORT {
        char type_name[VAR_NAME_MAX];

        get_typedef($1, type_name);

        xstrncpy($$, type_name, VAR_NAME_MAX);
        num_function_generics_types = 0;
    }
    | TYPE_NAME pointer {
        char type_name[VAR_NAME_MAX];

        if(strcmp($1, "string") == 0) {
            xstrncpy(type_name, "string", VAR_NAME_MAX);
        }
        else if(strcmp($1, "wstring") == 0) {
            xstrncpy(type_name, "wstring", VAR_NAME_MAX);
        }
        else {
            get_typedef($1, type_name);
        }

        char* pointer = $2;

        int i;
        for(i=0; i<strlen(pointer); i++) {
            xstrncat(type_name, "p", VAR_NAME_MAX);
        }

        xstrncpy($$, type_name, VAR_NAME_MAX);
        num_function_generics_types = 0;
    }
    | LONG pointer {
        char type_name[VAR_NAME_MAX];

        get_typedef($1, type_name);

        char* pointer = $2;

        int i;
        for(i=0; i<strlen(pointer); i++) {
            xstrncat(type_name, "p", VAR_NAME_MAX);
        }

        xstrncpy($$, type_name, VAR_NAME_MAX);
        num_function_generics_types = 0;
    }
    | SHORT pointer {
        char type_name[VAR_NAME_MAX];

        get_typedef($1, type_name);

        char* pointer = $2;

        int i;
        for(i=0; i<strlen(pointer); i++) {
            xstrncat(type_name, "p", VAR_NAME_MAX);
        }

        xstrncpy($$, type_name, VAR_NAME_MAX);
        num_function_generics_types = 0;
    }
    | TYPE_NAME '!' '<' function_generics_types '>' {
        char type_name[VAR_NAME_MAX];
        get_typedef($1, type_name);

        xstrncat(type_name, "<", VAR_NAME_MAX);
        xstrncat(type_name, $4, VAR_NAME_MAX);
        xstrncat(type_name, ">", VAR_NAME_MAX);

        xstrncpy($$, type_name, VAR_NAME_MAX);
    }
    ;


function_generics_types: {
        num_function_generics_types = 0;
    }
    | function_generics_types type {
        char type_name[VAR_NAME_MAX];
        get_typedef($2, type_name);

        xstrncpy($$, ",", VAR_NAME_MAX);
        xstrncpy($$, type_name, VAR_NAME_MAX);

        xstrncpy(function_generics_types[num_function_generics_types], type_name, VAR_NAME_MAX);
        num_function_generics_types++;

        if(num_function_generics_types >= GENERICS_TYPES_MAX) {
            fprintf(stderr, "overflow generics type number\n");
            exit(2);
        }
    }
    | function_generics_types ',' type {
        char type_name[VAR_NAME_MAX];
        get_typedef($3, type_name);

        xstrncpy($$, ",", VAR_NAME_MAX);
        xstrncpy($$, type_name, VAR_NAME_MAX);

        xstrncpy(function_generics_types[num_function_generics_types], type_name, VAR_NAME_MAX);
        num_function_generics_types++;

        if(num_function_generics_types >= GENERICS_TYPES_MAX) {
            fprintf(stderr, "overflow generics type number\n");
            exit(2);
        }
    }
    ;


block:  
        | statment                  { 
            prev_block[num_prev_block] = block;
            num_prev_block++;

            if(num_prev_block >= BLOCK_NEST_MAX) {
                fprintf(stderr, "overflow nest block\n");
                exit(2);
            }

            BOOL create_lv_table = TRUE;

            block = sNodeTree_create_block(create_lv_table, gSName, yylineno); 
            append_node_to_node_block(block, $1); 

            $$ = block; 

            int i=0;
            for(i=0; i< num_multiple_node; i++) {
                append_node_to_node_block(block, multiple_nodes[i]); 
            }
            num_multiple_node = 0;
        } 
        | block statment          { 
            $$ = block; 

            append_node_to_node_block(block, $2); 

            int i=0;
            for(i=0; i< num_multiple_node; i++) {
                append_node_to_node_block(block, multiple_nodes[i]); 
            }
            num_multiple_node = 0;
        }
        ;

function_block:  
        | statment                  { 
            prev_block[num_prev_block] = block;
            num_prev_block++;

            if(num_prev_block >= BLOCK_NEST_MAX) {
                fprintf(stderr, "overflow nest block\n");
                exit(2);
            }

            BOOL create_lv_table = FALSE;

            block = sNodeTree_create_block(create_lv_table, gSName, yylineno); 
            append_node_to_node_block(block, $1); $$ = block; 

            int i=0;
            for(i=0; i< num_multiple_node; i++) {
                append_node_to_node_block(block, multiple_nodes[i]); 
            }
            num_multiple_node = 0;
        } 
        | function_block statment          { 
            $$ = block; 

            append_node_to_node_block(block, $2); 

            int i=0;
            for(i=0; i< num_multiple_node; i++) {
                append_node_to_node_block(block, multiple_nodes[i]); 
            }
            num_multiple_node = 0;
        }
        ;

block_end: {
        block = prev_block[num_prev_block-1];

        num_prev_block--;
        if(num_prev_block < 0) {
            fprintf(stderr, "overflow nest block\n");
            exit(2);
        }
        $$ = block;
        };

free_right_value_objects: {
    free_right_value_objects(&cinfo);
    }
    ;

statment: comma_exp free_right_value_objects ';'              { 
        $$ = $1; 
    }
    | struct_  {
        compile($1, &cinfo);
        $$ = 0;
    }
    | RETURN ';'               { $$ = sNodeTree_create_return(0, 0, gSName, yylineno); }
    | RETURN '(' comma_exp ')' ';'   { $$ = sNodeTree_create_return($3, 0, gSName, yylineno); }
    | RETURN comma_exp ';'  { $$ = sNodeTree_create_return($2, 0, gSName, yylineno); }
    | RETURN ';' after_return_case_statment { $$ = sNodeTree_create_return(0, $3, gSName, yylineno); }
    | RETURN '(' comma_exp ')' ';' after_return_case_statment   { $$ = sNodeTree_create_return($3, $6, gSName, yylineno); }
    | RETURN comma_exp ';' after_return_case_statment  { $$ = sNodeTree_create_return($2, $4, gSName, yylineno); }
    | IF '(' comma_exp free_right_value_objects ')' '{' block '}' block_end {
        unsigned int if_exp = $3;
        unsigned int if_block = $7;
        int elif_num = 0;
        unsigned int elif_exps[ELIF_NUM_MAX];
        unsigned int elif_blocks[ELIF_NUM_MAX];
        unsigned else_block = 0;
        
        $$ = sNodeTree_create_if(if_exp, if_block, elif_num, elif_exps, elif_blocks, else_block, gSName, yylineno);
    }
    | IF '(' comma_exp free_right_value_objects ')' statment {
        BOOL create_lv_table = FALSE;

        unsigned int block = sNodeTree_create_block(create_lv_table, gSName, yylineno); 
        append_node_to_node_block(block, $6);

        unsigned int if_exp = $3;
        unsigned int if_block = block;
        int elif_num = 0;
        unsigned int elif_exps[ELIF_NUM_MAX];
        unsigned int elif_blocks[ELIF_NUM_MAX];
        unsigned else_block = 0;
        
        $$ = sNodeTree_create_if(if_exp, if_block, elif_num, elif_exps, elif_blocks, else_block, gSName, yylineno);
    }
    | IF '(' comma_exp free_right_value_objects ')' '{' block '}' block_end ELSE '{' block '}' block_end 
    {
        unsigned int if_exp = $3;
        unsigned int if_block = $7;
        int elif_num = 0;
        unsigned int elif_exps[ELIF_NUM_MAX];
        unsigned int elif_blocks[ELIF_NUM_MAX];
        unsigned int else_block = $12;
        
        $$ = sNodeTree_create_if(if_exp, if_block, elif_num, elif_exps, elif_blocks, else_block, gSName, yylineno);
    }
    | IF '(' comma_exp free_right_value_objects ')' statment  ELSE '{' block '}' block_end 
    {
        BOOL create_lv_table = FALSE;

        unsigned int block = sNodeTree_create_block(create_lv_table, gSName, yylineno); 
        append_node_to_node_block(block, $6);

        unsigned int if_exp = $3;
        unsigned int if_block = block;
        int elif_num = 0;
        unsigned int elif_exps[ELIF_NUM_MAX];
        unsigned int elif_blocks[ELIF_NUM_MAX];
        unsigned int else_block = $9;
        
        $$ = sNodeTree_create_if(if_exp, if_block, elif_num, elif_exps, elif_blocks, else_block, gSName, yylineno);
    }
    | IF '(' comma_exp free_right_value_objects ')' '{' block '}' block_end ELSE statment 
    {
        BOOL create_lv_table = FALSE;

        unsigned int block = sNodeTree_create_block(create_lv_table, gSName, yylineno); 
        append_node_to_node_block(block, $11);

        unsigned int if_exp = $3;
        unsigned int if_block = $7;
        int elif_num = 0;
        unsigned int elif_exps[ELIF_NUM_MAX];
        unsigned int elif_blocks[ELIF_NUM_MAX];
        unsigned int else_block = block;
        
        $$ = sNodeTree_create_if(if_exp, if_block, elif_num, elif_exps, elif_blocks, else_block, gSName, yylineno);
    }
    | IF '(' comma_exp free_right_value_objects ')' '{' block '}' block_end ELSE IF prepare_elif_statment elif_statment end_elif_statment
    {
        unsigned int if_exp = $3;
        unsigned int if_block = $7;
        
        $$ = sNodeTree_create_if(if_exp, if_block, elif_num[elif_nest_num], elif_exps[elif_nest_num], elif_blocks[elif_nest_num], else_block[elif_nest_num], gSName, yylineno);
    }
    | IF '(' comma_exp free_right_value_objects ')' statment ELSE IF prepare_elif_statment elif_statment end_elif_statment {
        BOOL create_lv_table = FALSE;

        unsigned int block = sNodeTree_create_block(create_lv_table, gSName, yylineno); 
        append_node_to_node_block(block, $6);

        unsigned int if_exp = $3;
        unsigned int if_block = block;
        unsigned else_block = 0;
        
        $$ = sNodeTree_create_if(if_exp, if_block, elif_num[elif_nest_num], elif_exps[elif_nest_num], elif_blocks[elif_nest_num], else_block, gSName, yylineno);
    }
    | FOR '(' comma_exp free_right_value_objects ';' comma_exp free_right_value_objects ';' comma_exp free_right_value_objects ')' '{' block '}' block_end {
        unsigned int expression_node1 = $3;
        unsigned int expression_node2 = $6;
        unsigned int expression_node3 = $9;

        unsigned int for_node_block = $13;

        $$ = sNodeTree_for_statment(expression_node1, expression_node2, expression_node3, for_node_block, gSName, yylineno);
    }
    | WHILE '(' comma_exp free_right_value_objects ')' '{' block '}' block_end {
        unsigned int expression_node1 = $3;

        unsigned int while_node_block = $7;

        $$ = sNodeTree_while_statment(expression_node1, while_node_block, gSName, yylineno);
    }
    | SWITCH '(' comma_exp free_right_value_objects ')' '{' switch_block '}' {
        unsigned int expression_node = $3;

        $$ = sNodeTree_switch_statment(expression_node, num_switch_expression, switch_expression, gSName, yylineno);
    }
    | case_statment  {
        $$ = $1;
    }
    | DEFAULT ':' {
        BOOL first_case = TRUE;
        BOOL last_case = TRUE;
        BOOL case_after_return = FALSE;
        unsigned int first_statment = 0;
        unsigned int last_statment = 0;

        $$ = sNodeTree_case_expression(0, first_case, last_case, case_after_return, first_statment, last_statment, gSName, yylineno);
    }
    | BREAK ';' {
        $$ = sNodeTree_create_break_expression(gSName, yylineno);
    }
    | CONTINUE ';' {
        $$ = sNodeTree_create_continue_expression(gSName, yylineno);
    }
    | DO '{' block '}' block_end WHILE '(' comma_exp free_right_value_objects ')' ';' {
        unsigned int expression_node1 = $8;

        unsigned int while_node_block = $3;

        $$ = sNodeTree_do_while_expression(expression_node1, while_node_block, gSName, yylineno);
    }
    | local_type_and_variable_names ';' {
        char* type_name = $1;
        BOOL global = FALSE;
        BOOL extern_ = FALSE;

        int i;
        for(i=0; i<num_multiple_variable_names; i++) {
            char* var_name = variable_names[--num_variable_names];
            unsigned int init_value = multiple_init_values[num_multiple_variable_names-i-1];

            if(init_value) {
                BOOL alloc = TRUE;
                multiple_nodes[num_multiple_node++]  = sNodeTree_create_store_variable(var_name, type_name, init_value, alloc, global, gSName, yylineno);
            }
            else {
                multiple_nodes[num_multiple_node++] = sNodeTree_create_define_variable(type_name, var_name, global, extern_, init_value, gSName, yylineno);
            }
        }

        $$ = 0;
    }
    ;

case_statment: CASE exp ':' {
        BOOL first_case = TRUE;
        BOOL last_case = TRUE;
        BOOL case_after_return = FALSE;

        unsigned int expression_node = $2;

        unsigned int first_statment = 0;
        unsigned int last_statment = 0;

        $$ = sNodeTree_case_expression(expression_node, first_case, last_case, case_after_return, first_statment, last_statment, gSName, yylineno);
    }
    | case_statment CASE exp ':' {
        BOOL first_case = FALSE;
        BOOL last_case = TRUE;
        BOOL case_after_return = FALSE;

        unsigned int first_statment = 0;
        unsigned int last_statment = $1;
        unsigned int expression_node = $3;

        gNodes[last_statment].uValue.sCase.mLastCase = FALSE;

        $$ = sNodeTree_case_expression(expression_node, first_case, last_case, case_after_return, first_statment, last_statment, gSName, yylineno);
    }
    ;

after_return_case_statment: CASE exp ':' {
        BOOL first_case = TRUE;
        BOOL last_case = TRUE;
        BOOL case_after_return = TRUE;

        unsigned int expression_node = $2;

        unsigned int first_statment = 0;
        unsigned int last_statment = 0;

        $$ = sNodeTree_case_expression(expression_node, first_case, last_case, case_after_return, first_statment, last_statment, gSName, yylineno);
    }
    | after_return_case_statment CASE exp ':' {
        BOOL first_case = FALSE;
        BOOL last_case = TRUE;
        BOOL case_after_return = FALSE;

        unsigned int first_statment = 0;
        unsigned int last_statment = $1;
        unsigned int expression_node = $3;

        gNodes[last_statment].uValue.sCase.mLastCase = FALSE;

        $$ = sNodeTree_case_expression(expression_node, first_case, last_case, case_after_return, first_statment, last_statment, gSName, yylineno);
    }
    ;

switch_block: statment {
        num_switch_expression = 0;

        switch_expression[num_switch_expression] = $1;

        num_switch_expression++;

        if(num_switch_expression >= SWITCH_STASTMENT_NODE_MAX) {
            fprintf(stderr, "overflow switch expression\n");
            exit(2);
        }
    }
    | switch_block statment {
        switch_expression[num_switch_expression] = $2;

        num_switch_expression++;

        if(num_switch_expression >= SWITCH_STASTMENT_NODE_MAX) {
            fprintf(stderr, "overflow switch expression\n");
            exit(2);
        }
    }
    ;


prepare_elif_statment: '(' comma_exp ')' '{' block '}' block_end {
    elif_num[elif_nest_num] = 0;
    elif_exps[elif_nest_num][elif_num[elif_nest_num]] = $2;
    elif_blocks[elif_nest_num][elif_num[elif_nest_num]] = $5;
    elif_num[elif_nest_num]++;
    else_block[elif_nest_num] = 0;
    elif_nest_num++;

    if(elif_num[elif_nest_num-1] >= ELIF_NUM_MAX) {
        fprintf(stderr, "overflow else if number\n");
        exit(2);
    }

    if(elif_nest_num >= ELIF_NEST_MAX) {
        fprintf(stderr, "overflow else if nest number\n");
        exit(2);
    }

    $$ = 0;
    }
    ;

end_elif_statment: {
    elif_nest_num--;
    }
    ;

none_elif_statment:
    ;

elif_statment:
    ELSE IF '(' comma_exp ')' '{' block '}' block_end {
        elif_exps[elif_nest_num-1][elif_num[elif_nest_num-1]] = $4;
        elif_blocks[elif_nest_num-1][elif_num[elif_nest_num-1]] = $7;
        elif_num[elif_nest_num-1]++;

        if(elif_num[elif_nest_num-1] >= ELIF_NUM_MAX) {
            fprintf(stderr, "overflow else if number\n");
            exit(2);
        }
    }
    | ELSE IF '(' comma_exp ')' statment {
        BOOL create_lv_table = FALSE;

        unsigned int block = sNodeTree_create_block(create_lv_table, gSName, yylineno); 
        append_node_to_node_block(block, $6);

        elif_exps[elif_nest_num-1][elif_num[elif_nest_num-1]] = $4;
        elif_blocks[elif_nest_num-1][elif_num[elif_nest_num-1]] = block;
        elif_num[elif_nest_num-1]++;

        if(elif_num[elif_nest_num-1] >= ELIF_NUM_MAX) {
            fprintf(stderr, "overflow else if number\n");
            exit(2);
        }
    }
    | ELSE '{' block '}' block_end {
        else_block[elif_nest_num-1] = $3;
    }
    | ELSE statment {
        BOOL create_lv_table = FALSE;
        unsigned int block = sNodeTree_create_block(create_lv_table, gSName, yylineno); 
        append_node_to_node_block(block, $2);

        else_block[elif_nest_num-1] = block;
    }
    | none_elif_statment {
    }
    | elif_statment ELSE IF '(' comma_exp ')' '{' block '}' block_end {
        elif_exps[elif_nest_num-1][elif_num[elif_nest_num-1]] = $5;
        elif_blocks[elif_nest_num-1][elif_num[elif_nest_num-1]] = $8;
        elif_num[elif_nest_num-1]++;

        if(elif_num[elif_nest_num-1] >= ELIF_NUM_MAX) {
            fprintf(stderr, "overflow else if number\n");
            exit(2);
        }
    }
    | elif_statment ELSE IF '(' comma_exp ')' statment {
        BOOL create_lv_table = FALSE;

        unsigned int block = sNodeTree_create_block(create_lv_table, gSName, yylineno); 
        append_node_to_node_block(block, $7);

        elif_exps[elif_nest_num-1][elif_num[elif_nest_num-1]] = $5;
        elif_blocks[elif_nest_num-1][elif_num[elif_nest_num-1]] = block;
        elif_num[elif_nest_num-1]++;

        if(elif_num[elif_nest_num-1] >= ELIF_NUM_MAX) {
            fprintf(stderr, "overflow else if number\n");
            exit(2);
        }
    }
    | elif_statment ELSE '{' block '}' block_end {
        else_block[elif_nest_num-1] = $4;
    }
    | elif_statment ELSE statment {
        BOOL create_lv_table = FALSE;
        unsigned int block = sNodeTree_create_block(create_lv_table, gSName, yylineno); 
        append_node_to_node_block(block, $3);

        else_block[elif_nest_num-1] = block;
    }
    | elif_statment none_elif_statment {
    }
    ;

exp: 
    | assign_node {
        $$ = $1;
    }
    | node {
        $$ = $1;
    }
    | exp '+' exp    { $$ = sNodeTree_create_add($1, $3, gSName, yylineno); }
    | exp '-' exp    { $$ = sNodeTree_create_sub($1, $3, gSName, yylineno); }
    | exp '/' exp    { $$ = sNodeTree_create_div($1, $3, gSName, yylineno); }
    | exp '*' exp   { $$ = sNodeTree_create_mult($1, $3,  gSName, yylineno); }
    | exp '%' exp    { $$ = sNodeTree_create_mod($1, $3, gSName, yylineno); }
    | exp EQEQ exp   { $$ = sNodeTree_create_equals($1, $3, gSName, yylineno); }
    | exp NOT_EQ exp   { $$ = sNodeTree_create_not_equals($1, $3, gSName, yylineno); }
    | exp '>' exp    { $$ = sNodeTree_create_gt($1, $3, gSName, yylineno); }
    | exp '<' exp    { $$ = sNodeTree_create_lt($1, $3, gSName, yylineno); }
    | exp GTEQ exp   { $$ = sNodeTree_create_ge($1, $3, gSName, yylineno); }
    | exp LTEQ exp   { $$ = sNodeTree_create_le($1, $3, gSName, yylineno); }
    | exp ANDAND exp { $$ = sNodeTree_create_and_and($1, $3, gSName, yylineno); }
    | exp OROR exp   { $$ = sNodeTree_create_or_or($1, $3, gSName, yylineno); }
    | exp LSHIFT exp { $$ = sNodeTree_create_lshift($1, $3, gSName, yylineno); }
    | exp RSHIFT exp { $$ = sNodeTree_create_rshift($1, $3, gSName, yylineno); }
    | exp '|' exp    { $$ = sNodeTree_create_or($1, $3, gSName, yylineno); }
    | exp '^' exp    { $$ = sNodeTree_create_xor($1, $3, gSName, yylineno); }
    | exp '&' exp    { $$ = sNodeTree_create_and($1, $3, gSName, yylineno); }
    | '!' exp        { $$ = sNodeTree_create_logical_denial($2, gSName, yylineno); }
    | '~' exp        { $$ = sNodeTree_create_complement($2, gSName, yylineno); }
    | '&' node       { $$ = sNodeTree_create_refference($2, gSName, yylineno); }
    | exp '?' exp ':' exp {
        unsigned int conditional = $1;
        unsigned int value1 = $3;
        unsigned int value2 = $5;
        
        $$ = sNodeTree_create_conditional(conditional, value1, value2, gSName, yylineno);
    }
    | pointer IDENTIFIER '=' pointer node {
        unsigned int right_node = $5;

        int i;
        for(i=0; i<strlen($4); i++) {
            right_node = sNodeTree_create_derefference(right_node, gSName, yylineno); 
        }

        $$ = sNodeTree_create_load_variable($2, gSName, yylineno);

        for(i=0; i<strlen($1)-1; i++) {
            $$ = sNodeTree_create_derefference($$, gSName, yylineno); 
        }

        $$ = sNodeTree_create_store_value_to_address($$, right_node, gSName, yylineno);
    }
    | pointer IDENTIFIER {
        $$ = sNodeTree_create_load_variable($2, gSName, yylineno);

        int i;
        for(i=0; i<strlen($1); i++) {
            $$ = sNodeTree_create_derefference($$, gSName, yylineno); 
        }
    }
    | pointer '(' exp ')' { 
        $$ = $3;

        int i;
        for(i=0; i<strlen($1); i++) {
            $$ = sNodeTree_create_derefference($$, gSName, yylineno); 
        }
    }
    | pointer IDENTIFIER '(' ')' {
        BOOL existance = function_existance($2);

        if(existance) {
            $$ = sNodeTree_create_function_call($2, 0, FALSE, FALSE, gSName, yylineno);
        }
        else {
            unsigned int node = sNodeTree_create_load_variable($2, gSName, yylineno);
            $$ = sNodeTree_create_lambda_call(node, 0, gSName, yylineno);
        }
        int i;
        for(i=0; i<strlen($1); i++) {
            $$ = sNodeTree_create_derefference($$, gSName, yylineno); 
        }
    }
    | pointer IDENTIFIER '(' params ')' {
        BOOL existance = function_existance($2);

        if(existance) {
            $$ = sNodeTree_create_function_call($2, $4, FALSE, FALSE, gSName, yylineno);
        }
        else {
            unsigned int node = sNodeTree_create_load_variable($2, gSName, yylineno);
            $$ = sNodeTree_create_lambda_call(node, $4, gSName, yylineno);
        }
        int i;
        for(i=0; i<strlen($1); i++) {
            $$ = sNodeTree_create_derefference($$, gSName, yylineno); 
        }
    }

    | pointer TYPE_NAME '(' ')' {
        BOOL existance = function_existance($2);

        if(existance) {
            $$ = sNodeTree_create_function_call($2, 0, FALSE, FALSE, gSName, yylineno);
        }
        else {
            unsigned int node = sNodeTree_create_load_variable($2, gSName, yylineno);
            $$ = sNodeTree_create_lambda_call(node, 0, gSName, yylineno);
        }
        int i;
        for(i=0; i<strlen($1); i++) {
            $$ = sNodeTree_create_derefference($$, gSName, yylineno); 
        }
    }
    | pointer TYPE_NAME '(' params ')' {
        BOOL existance = function_existance($2);

        if(existance) {
            $$ = sNodeTree_create_function_call($2, $4, FALSE, FALSE, gSName, yylineno);
        }
        else {
            unsigned int node = sNodeTree_create_load_variable($2, gSName, yylineno);
            $$ = sNodeTree_create_lambda_call(node, $4, gSName, yylineno);
        }
        int i;
        for(i=0; i<strlen($1); i++) {
            $$ = sNodeTree_create_derefference($$, gSName, yylineno); 
        }
    }
    ;

comma_exp: exp {
         $$ = $1;
         }
         | comma_exp ',' comma_exp {
            compile($1, &cinfo); $$ = $3;
         }
         ;


cstring_array_value2: CSTRING {
        $$ = sNodeTree_create_c_string($1, gSName, yylineno);

        num_array_value = 0;
        array_values[num_array_value++] = $$;
    }
    | cstring_array_value2 ',' CSTRING {
        $$ = sNodeTree_create_c_string($3, gSName, yylineno);

        array_values[num_array_value++] = $$;
    };

assign_node:
    | IDENTIFIER '=' comma_exp { 
        BOOL alloc = FALSE;
        BOOL global = FALSE;

        $$ = sNodeTree_create_store_variable($1, "", $3, alloc, global, gSName, yylineno); 
    }
    | type_and_variable_name '=' comma_exp  { 
        BOOL alloc = TRUE;
        BOOL global = FALSE;

        if(num_multiple_variable_names  != 1) {
            fprintf("%s %d: syntax error\n", gSName, yylineno);
            exit(2);
        }

        $$ = sNodeTree_create_store_variable(variable_names[--num_variable_names], $1, $3, alloc, global, gSName, yylineno); 
    }
    | exp '.' name '=' comma_exp  { 
        $$ = sNodeTree_create_store_field($3, $1, $5, gSName, yylineno); 
    }
    | exp '-' '>' name '=' comma_exp  { 
        $$ = sNodeTree_create_store_field($4, $1, $6, gSName, yylineno); 
    }
    | pointer IDENTIFIER '=' comma_exp { 
        $$ = sNodeTree_create_load_variable($2, gSName, yylineno);

        int i;
        for(i=0; i<strlen($1)-1; i++) {
            $$ = sNodeTree_create_derefference($$, gSName, yylineno); 
        }

        unsigned int right_node = $4;

        $$ = sNodeTree_create_store_value_to_address($$, right_node, gSName, yylineno);
    }
    | pointer '(' exp ')' '=' comma_exp  { 
        $$ = $3;

        int i;
        for(i=0; i<strlen($1)-1; i++) {
            $$ = sNodeTree_create_derefference($$, gSName, yylineno); 
        }

        unsigned int right_node = $6;

        $$ = sNodeTree_create_store_value_to_address($$, right_node, gSName, yylineno);
    }
    ;

node: 
        | '(' comma_exp ')'    { $$ = $2; }
        | DUMMY_HEAP exp {
            unsigned int object_node = $2;
            $$ = sNodeTree_create_dummy_heap(object_node, gSName, yylineno);
        }
        | TOKEN_MANAGED IDENTIFIER {
            char* var_name = $2;
            $$ = sNodeTree_create_managed(var_name, gSName, yylineno);
        }
        | INTNUM                { $$ = it = sNodeTree_create_int_value($1, gSName, yylineno); }
        | '-' INTNUM                { $$ = it = sNodeTree_create_int_value(-$2, gSName, yylineno); }
        | CHARNUM                { $$ = it = sNodeTree_create_char_value($1, gSName, yylineno); }
        | CSTRING {
            $$ = it = sNodeTree_create_c_string($1, gSName, yylineno);
        }
        | TOKEN_TRUE {
            $$ = sNodeTree_create_true(gSName, yylineno);
        }
        | TOKEN_FALSE {
            $$ = sNodeTree_create_false(gSName, yylineno);
        }
        | NULLPTR {
            $$ = sNodeTree_create_null(gSName, yylineno);
        }
        | IDENTIFIER {
            $$ = sNodeTree_create_load_variable($1, gSName, yylineno);
        }
        | IDENTIFIER array_index '=' comma_exp {
            unsigned int array = sNodeTree_create_load_variable($1, gSName, yylineno);

            unsigned int* index_node = array_index_index_node[array_index_num];
            int num_dimention = array_index_num_dimention[array_index_num];

            array_index_num--;

            unsigned int right_node = $4;

            $$ = sNodeTree_create_store_element(array, index_node, num_dimention, right_node, gSName, yylineno);
        }
        | exp array_index '=' comma_exp {
            unsigned int array = $1;

            unsigned int* index_node = array_index_index_node[array_index_num];
            int num_dimention = array_index_num_dimention[array_index_num];

            array_index_num--;

            unsigned int right_node = $4;

            $$ = sNodeTree_create_store_element(array, index_node, num_dimention, right_node, gSName, yylineno);
        }
        | exp '.' name array_index '=' comma_exp {
            unsigned int array = sNodeTree_create_load_field($3, $1, gSName, yylineno);

            unsigned int* index_node = array_index_index_node[array_index_num];
            int num_dimention = array_index_num_dimention[array_index_num];

            array_index_num--;

            unsigned int right_node = $6;

            $$ = sNodeTree_create_store_element(array, index_node, num_dimention, right_node, gSName, yylineno);
        }
        | IDENTIFIER array_index {
            unsigned int array = sNodeTree_create_load_variable($1, gSName, yylineno);

            unsigned int* index_node = array_index_index_node[array_index_num];
            int num_dimention = array_index_num_dimention[array_index_num];

            array_index_num--;

            $$ = sNodeTree_create_load_array_element(array, index_node, num_dimention, gSName, yylineno);
        }
        | exp array_index {
            unsigned int array = $1;

            unsigned int* index_node = array_index_index_node[array_index_num];
            int num_dimention = array_index_num_dimention[array_index_num];

            array_index_num--;

            $$ = sNodeTree_create_load_array_element(array, index_node, num_dimention, gSName, yylineno);
        }
        | IDENTIFIER '(' ')' {
            BOOL existance = function_existance($1);

            if(existance) {
                $$ = sNodeTree_create_function_call($1, 0, FALSE, FALSE, gSName, yylineno);
            }
            else {
                unsigned int node = sNodeTree_create_load_variable($1, gSName, yylineno);
                $$ = sNodeTree_create_lambda_call(node, 0, gSName, yylineno);
            }
        }
        | IDENTIFIER '(' params ')' {
            BOOL existance = function_existance($1);

            if(existance) {
                $$ = sNodeTree_create_function_call($1, $3, FALSE, FALSE, gSName, yylineno);
            }
            else {
                unsigned int node = sNodeTree_create_load_variable($1, gSName, yylineno);
                $$ = sNodeTree_create_lambda_call(node, $3, gSName, yylineno);
            }
        }
        | __PRINTF__ '(' params ')' {
            BOOL existance = function_existance("printf");

            if(existance) {
                $$ = sNodeTree_create_function_call("printf", $3, FALSE, FALSE, gSName, yylineno);
            }
            else {
                unsigned int node = sNodeTree_create_load_variable("printf", gSName, yylineno);
                $$ = sNodeTree_create_lambda_call(node, $3, gSName, yylineno);
            }
        }
        | __SCANF__ '(' params ')' {
            BOOL existance = function_existance("scanf");

            if(existance) {
                $$ = sNodeTree_create_function_call("scanf", $3, FALSE, FALSE, gSName, yylineno);
            }
            else {
                unsigned int node = sNodeTree_create_load_variable("scanf", gSName, yylineno);
                $$ = sNodeTree_create_lambda_call(node, $3, gSName, yylineno);
            }
        }

        | TYPE_NAME '(' ')' {
            BOOL existance = function_existance($1);

            if(existance) {
                $$ = sNodeTree_create_function_call($1, 0, FALSE, FALSE, gSName, yylineno);
            }
            else {
                unsigned int node = sNodeTree_create_load_variable($1, gSName, yylineno);
                $$ = sNodeTree_create_lambda_call(node, 0, gSName, yylineno);
            }
        }
        | TYPE_NAME '(' params ')' {
            BOOL existance = function_existance($1);

            if(existance) {
                $$ = sNodeTree_create_function_call($1, $3, FALSE, FALSE, gSName, yylineno);
            }
            else {
                unsigned int node = sNodeTree_create_load_variable($1, gSName, yylineno);
                $$ = sNodeTree_create_lambda_call(node, $3, gSName, yylineno);
            }
        }
        | exp '.' name '(' ')' {
            params = sNodeTree_create_params(gSName, yylineno); 
            append_param_to_params(params, $1);

            $$ = sNodeTree_create_function_call($3, params, TRUE, FALSE, gSName, yylineno);
        }
        | exp '.' name '(' params ')' {
            append_param_to_params($5, $1);
            $$ = sNodeTree_create_function_call($3, $5, TRUE, FALSE, gSName, yylineno);
        }
        | INHERIT '(' ')' {
            $$ = sNodeTree_create_function_call("inherit", 0, FALSE, TRUE, gSName, yylineno);
        }
        | INHERIT '(' params ')' {
            $$ = sNodeTree_create_function_call("inherit", $3, FALSE, TRUE, gSName, yylineno);
        }
        | exp '.' INHERIT '(' ')' {
            params = sNodeTree_create_params(gSName, yylineno); 
            append_param_to_params(params, $1);

            $$ = sNodeTree_create_function_call("inherit", params, TRUE, TRUE, gSName, yylineno);
        }
        | exp '.' INHERIT '(' params ')' {
            append_param_to_params($5, $1);
            $$ = sNodeTree_create_function_call("inherit", $5, TRUE, TRUE, gSName, yylineno);
        }
        | exp '.' name {
            $$ = sNodeTree_create_load_field($3, $1, gSName, yylineno);
        }
        | exp '-' '>' name {
            $$ = sNodeTree_create_load_field($4, $1, gSName, yylineno);
        }
        | exp '.' name array_index {
            unsigned int array = sNodeTree_create_load_field($3, $1, gSName, yylineno);

            unsigned int* index_node = array_index_index_node[array_index_num];
            int num_dimention = array_index_num_dimention[array_index_num];

            array_index_num--;

            $$ = sNodeTree_create_load_array_element(array, index_node, num_dimention, gSName, yylineno);
        }



        | NEW type {
            char* type_name = $2;
            unsigned int object_num = 0;

            $$ = sNodeTree_create_object(type_name, object_num, gSName, yylineno);
        }
        | NEW type '[' comma_exp ']'  {
            char* type_name = $2;
            unsigned int object_num = $4;

            $$ = sNodeTree_create_object(type_name, object_num, gSName, yylineno);
        }
        | CLONE exp {
            unsigned int exp = $2;

            $$ = sNodeTree_create_clone(exp, gSName, yylineno);
        }
        | TOKEN_DELETE exp {
            unsigned int exp = $2;

            $$ = sNodeTree_create_delete(exp, gSName, yylineno);
        }
        | TOKEN_BORROW exp {
            unsigned int exp = $2;

            $$ = sNodeTree_create_borrow(exp, gSName, yylineno);
        }
        | type LAMBDA '(' function_params ')' '{' function_block '}' block_end 
        {
            char* result_type_name = $1;
            unsigned int function_params = $4;
            unsigned int node_block = $7;

            $$ = sNodeTree_create_coroutine(function_params, result_type_name, node_block, var_arg, gSName, yylineno);
        }
        | exp '(' params ')' {
            $$ = sNodeTree_create_lambda_call($1, $3, gSName, yylineno);
        }
        | pointer '(' exp ')'     { 
            $$ = sNodeTree_create_derefference($3, gSName, yylineno); 

            int i;
            for(i=0; i<strlen($1)-1; i++) {
                $$ = sNodeTree_create_derefference($$, gSName, yylineno); 
            }
        }

        | IDENTIFIER PLUS_PLUS { 
            $$ = sNodeTree_create_load_variable($1, gSName, yylineno);

            unsigned int int_value = sNodeTree_create_int_value(1, gSName, yylineno);

            $$ = sNodeTree_create_add($$, int_value, gSName, yylineno);

            BOOL alloc = FALSE;
            BOOL global = FALSE;

            $$ = sNodeTree_create_store_variable($1, "", $$, alloc, global, gSName, yylineno); 

            $$ = sNodeTree_create_sub($$, int_value, gSName, yylineno);
        }
        | exp '.' name PLUS_PLUS {
            char* var_name = $3;
            unsigned int obj = $1;

            $$ = sNodeTree_create_load_field(var_name, obj, gSName, yylineno);

            unsigned int int_value = sNodeTree_create_int_value(1, gSName, yylineno);

            $$ = sNodeTree_create_add($$, int_value, gSName, yylineno);

            unsigned int exp = $$;
            $$ = sNodeTree_create_store_field(var_name, obj, exp, gSName, yylineno); 
        }
        | exp '-' '>' name PLUS_PLUS {
            char* var_name = $4;
            unsigned int obj = $1;

            $$ = sNodeTree_create_load_field(var_name, obj, gSName, yylineno);

            unsigned int int_value = sNodeTree_create_int_value(1, gSName, yylineno);

            $$ = sNodeTree_create_add($$, int_value, gSName, yylineno);

            unsigned int exp = $$;
            $$ = sNodeTree_create_store_field(var_name, obj, exp, gSName, yylineno); 
        }
        | '(' comma_exp ')' PLUS_PLUS { 
            unsigned int left = $2;
            unsigned int right = sNodeTree_create_int_value(1, gSName, yylineno);

            $$ = sNodeTree_create_plus_eq(left, right, gSName, yylineno);
        }
        | PLUS_PLUS IDENTIFIER { 
            $$ = sNodeTree_create_load_variable($2, gSName, yylineno);

            unsigned int int_value = sNodeTree_create_int_value(1, gSName, yylineno);

            $$ = sNodeTree_create_add($$, int_value, gSName, yylineno);

            BOOL alloc = FALSE;
            BOOL global = FALSE;

            $$ = sNodeTree_create_store_variable($2, "", $$, alloc, global, gSName, yylineno); 
        }
        | IDENTIFIER MINUS_MINUS { 
            $$ = sNodeTree_create_load_variable($1, gSName, yylineno);

            unsigned int int_value = sNodeTree_create_int_value(1, gSName, yylineno); 

            $$ = sNodeTree_create_sub($$, int_value, gSName, yylineno);

            BOOL alloc = FALSE;
            BOOL global = FALSE;

            $$ = sNodeTree_create_store_variable($1, "", $$, alloc, global, gSName, yylineno); 

            $$ = sNodeTree_create_add($$, int_value, gSName, yylineno);
        }
        | MINUS_MINUS IDENTIFIER { 
            $$ = sNodeTree_create_load_variable($2, gSName, yylineno);

            unsigned int int_value = sNodeTree_create_int_value(1, gSName, yylineno); 

            $$ = sNodeTree_create_sub($$, int_value, gSName, yylineno);

            BOOL alloc = FALSE;
            BOOL global = FALSE;

            $$ = sNodeTree_create_store_variable($2, "", $$, alloc, global, gSName, yylineno); 
        }
        | '(' comma_exp ')' MINUS_MINUS { 
            unsigned int left = $2;
            unsigned int right = sNodeTree_create_int_value(1, gSName, yylineno);

            $$ = sNodeTree_create_minus_eq(left, right, gSName, yylineno);
        }
        | exp '.' name MINUS_MINUS {
            char* var_name = $3;
            unsigned int obj = $1;

            $$ = sNodeTree_create_load_field(var_name, obj, gSName, yylineno);

            unsigned int int_value = sNodeTree_create_int_value(1, gSName, yylineno); 

            $$ = sNodeTree_create_sub($$, int_value, gSName, yylineno);

            unsigned int exp = $$;
            $$ = sNodeTree_create_store_field(var_name, obj, exp, gSName, yylineno); 
        }
        | exp '-' '>' name MINUS_MINUS {
            char* var_name = $4;
            unsigned int obj = $1;

            $$ = sNodeTree_create_load_field(var_name, obj, gSName, yylineno);

            unsigned int int_value = sNodeTree_create_int_value(1, gSName, yylineno); 

            $$ = sNodeTree_create_sub($$, int_value, gSName, yylineno);

            unsigned int exp = $$;
            $$ = sNodeTree_create_store_field(var_name, obj, exp, gSName, yylineno); 
        }
        | IDENTIFIER PLUS_EQ comma_exp { 
            $$ = sNodeTree_create_load_variable($1, gSName, yylineno);

            unsigned int int_value = $3;

            $$ = sNodeTree_create_add($$, int_value, gSName, yylineno);

            BOOL alloc = FALSE;
            BOOL global = FALSE;

            $$ = sNodeTree_create_store_variable($1, "", $$, alloc, global, gSName, yylineno); 

            $$ = sNodeTree_create_sub($$, int_value, gSName, yylineno);
        }
        | exp '.' name PLUS_EQ comma_exp {
            char* var_name = $3;
            unsigned int obj = $1;

            $$ = sNodeTree_create_load_field(var_name, obj, gSName, yylineno);

            unsigned int int_value = $5;

            $$ = sNodeTree_create_add($$, int_value, gSName, yylineno);

            unsigned int exp = $$;
            $$ = sNodeTree_create_store_field(var_name, obj, exp, gSName, yylineno); 
        }
        | exp '-' '>' name PLUS_EQ comma_exp {
            char* var_name = $4;
            unsigned int obj = $1;

            $$ = sNodeTree_create_load_field(var_name, obj, gSName, yylineno);

            unsigned int int_value = $6;

            $$ = sNodeTree_create_add($$, int_value, gSName, yylineno);

            unsigned int exp = $$;
            $$ = sNodeTree_create_store_field(var_name, obj, exp, gSName, yylineno); 
        }
        | exp '.' name PLUS_EQ comma_exp {
            char* var_name = $3;
            unsigned int obj = $1;

            $$ = sNodeTree_create_load_field(var_name, obj, gSName, yylineno);

            unsigned int int_value = $5;

            $$ = sNodeTree_create_add($$, int_value, gSName, yylineno);

            unsigned int exp = $$;
            $$ = sNodeTree_create_store_field(var_name, obj, exp, gSName, yylineno); 
        }
        | '(' comma_exp ')' PLUS_EQ comma_exp { 
            unsigned int left = $2;
            unsigned int right = $5;

            $$ = sNodeTree_create_plus_eq(left, right, gSName, yylineno);
        }
        | IDENTIFIER MINUS_EQ comma_exp { 
            $$ = sNodeTree_create_load_variable($1, gSName, yylineno);

            unsigned int int_value = $3;

            $$ = sNodeTree_create_sub($$, int_value, gSName, yylineno);

            BOOL alloc = FALSE;
            BOOL global = FALSE;

            $$ = sNodeTree_create_store_variable($1, "", $$, alloc, global, gSName, yylineno); 

            $$ = sNodeTree_create_add($$, int_value, gSName, yylineno);
        }
        | exp '.' name MINUS_EQ comma_exp {
            char* var_name = $3;
            unsigned int obj = $1;

            $$ = sNodeTree_create_load_field(var_name, obj, gSName, yylineno);

            unsigned int int_value = $5;

            $$ = sNodeTree_create_sub($$, int_value, gSName, yylineno);

            unsigned int exp = $$;
            $$ = sNodeTree_create_store_field(var_name, obj, exp, gSName, yylineno); 
        }
        | exp '-' '>' name MINUS_EQ comma_exp {
            char* var_name = $4;
            unsigned int obj = $1;

            $$ = sNodeTree_create_load_field(var_name, obj, gSName, yylineno);

            unsigned int int_value = $6;

            $$ = sNodeTree_create_sub($$, int_value, gSName, yylineno);

            unsigned int exp = $$;
            $$ = sNodeTree_create_store_field(var_name, obj, exp, gSName, yylineno); 
        }
        | '(' comma_exp ')' MINUS_EQ exp { 
            unsigned int left = $2;
            unsigned int right = $5;

            $$ = sNodeTree_create_minus_eq(left, right, gSName, yylineno);
        }
        | IDENTIFIER MULT_EQ comma_exp { 
            $$ = sNodeTree_create_load_variable($1, gSName, yylineno);

            unsigned int int_value = $3;

            $$ = sNodeTree_create_mult($$, int_value, gSName, yylineno);

            BOOL alloc = FALSE;
            BOOL global = FALSE;

            $$ = sNodeTree_create_store_variable($1, "", $$, alloc, global, gSName, yylineno); 
        }
        | exp '.' name MULT_EQ comma_exp {
            char* var_name = $3;
            unsigned int obj = $1;

            $$ = sNodeTree_create_load_field(var_name, obj, gSName, yylineno);

            unsigned int int_value = $5;

            $$ = sNodeTree_create_mult($$, int_value, gSName, yylineno);

            unsigned int exp = $$;
            $$ = sNodeTree_create_store_field(var_name, obj, exp, gSName, yylineno); 
        }
        | exp '-' '>' name MULT_EQ comma_exp {
            char* var_name = $4;
            unsigned int obj = $1;

            $$ = sNodeTree_create_load_field(var_name, obj, gSName, yylineno);

            unsigned int int_value = $6;

            $$ = sNodeTree_create_mult($$, int_value, gSName, yylineno);

            unsigned int exp = $$;
            $$ = sNodeTree_create_store_field(var_name, obj, exp, gSName, yylineno); 
        }
        | '(' comma_exp ')' MULT_EQ exp { 
            unsigned int left = $2;
            unsigned int right = $5;

            $$ = sNodeTree_create_mult_eq(left, right, gSName, yylineno);
        }
        | IDENTIFIER DIV_EQ comma_exp {
            $$ = sNodeTree_create_load_variable($1, gSName, yylineno);

            unsigned int int_value = $3;

            $$ = sNodeTree_create_div($$, int_value, gSName, yylineno);

            BOOL alloc = FALSE;
            BOOL global = FALSE;

            $$ = sNodeTree_create_store_variable($1, "", $$, alloc, global, gSName, yylineno); 
        }
        | exp '.' name DIV_EQ comma_exp {
            char* var_name = $3;
            unsigned int obj = $1;

            $$ = sNodeTree_create_load_field(var_name, obj, gSName, yylineno);

            unsigned int int_value = $5;

            $$ = sNodeTree_create_div($$, int_value, gSName, yylineno);

            unsigned int exp = $$;
            $$ = sNodeTree_create_store_field(var_name, obj, exp, gSName, yylineno); 
        }
        | exp '-' '>' name DIV_EQ comma_exp {
            char* var_name = $4;
            unsigned int obj = $1;

            $$ = sNodeTree_create_load_field(var_name, obj, gSName, yylineno);

            unsigned int int_value = $6;

            $$ = sNodeTree_create_div($$, int_value, gSName, yylineno);

            unsigned int exp = $$;
            $$ = sNodeTree_create_store_field(var_name, obj, exp, gSName, yylineno); 
        }
        | '(' comma_exp ')' DIV_EQ exp { 
            unsigned int left = $2;
            unsigned int right = $5;

            $$ = sNodeTree_create_div_eq(left, right, gSName, yylineno);
        }
        | IDENTIFIER MOD_EQ comma_exp {
            $$ = sNodeTree_create_load_variable($1, gSName, yylineno);

            unsigned int int_value = $3;

            $$ = sNodeTree_create_mod($$, int_value, gSName, yylineno);

            BOOL alloc = FALSE;
            BOOL global = FALSE;

            $$ = sNodeTree_create_store_variable($1, "", $$, alloc, global, gSName, yylineno); 
        }
        | exp '.' name MOD_EQ comma_exp {
            char* var_name = $3;
            unsigned int obj = $1;

            $$ = sNodeTree_create_load_field(var_name, obj, gSName, yylineno);

            unsigned int int_value = $5;

            $$ = sNodeTree_create_mod($$, int_value, gSName, yylineno);

            unsigned int exp = $$;
            $$ = sNodeTree_create_store_field(var_name, obj, exp, gSName, yylineno); 
        }
        | exp '-' '>' name MOD_EQ comma_exp {
            char* var_name = $4;
            unsigned int obj = $1;

            $$ = sNodeTree_create_load_field(var_name, obj, gSName, yylineno);

            unsigned int int_value = $6;

            $$ = sNodeTree_create_mod($$, int_value, gSName, yylineno);

            unsigned int exp = $$;
            $$ = sNodeTree_create_store_field(var_name, obj, exp, gSName, yylineno); 
        }
        | '(' comma_exp ')' MOD_EQ exp { 
            unsigned int left = $2;
            unsigned int right = $5;

            $$ = sNodeTree_create_mod_eq(left, right, gSName, yylineno);
        }
        | IDENTIFIER AND_EQ comma_exp {
            $$ = sNodeTree_create_load_variable($1, gSName, yylineno);

            unsigned int int_value = $3;

            $$ = sNodeTree_create_and($$, int_value, gSName, yylineno);

            BOOL alloc = FALSE;
            BOOL global = FALSE;

            $$ = sNodeTree_create_store_variable($1, "", $$, alloc, global, gSName, yylineno); 
        }
        | exp '.' name AND_EQ comma_exp {
            char* var_name = $3;
            unsigned int obj = $1;

            $$ = sNodeTree_create_load_field(var_name, obj, gSName, yylineno);

            unsigned int int_value = $5;

            $$ = sNodeTree_create_and($$, int_value, gSName, yylineno);

            unsigned int exp = $$;
            $$ = sNodeTree_create_store_field(var_name, obj, exp, gSName, yylineno); 
        }
        | exp '-' '>' name AND_EQ comma_exp {
            char* var_name = $4;
            unsigned int obj = $1;

            $$ = sNodeTree_create_load_field(var_name, obj, gSName, yylineno);

            unsigned int int_value = $6;

            $$ = sNodeTree_create_and($$, int_value, gSName, yylineno);

            unsigned int exp = $$;
            $$ = sNodeTree_create_store_field(var_name, obj, exp, gSName, yylineno); 
        }
        | '(' comma_exp ')' AND_EQ exp { 
            unsigned int left = $2;
            unsigned int right = $5;

            $$ = sNodeTree_create_and_eq(left, right, gSName, yylineno);
        }
        | IDENTIFIER XOR_EQ comma_exp {
            $$ = sNodeTree_create_load_variable($1, gSName, yylineno);

            unsigned int int_value = $3;

            $$ = sNodeTree_create_xor($$, int_value, gSName, yylineno);

            BOOL alloc = FALSE;
            BOOL global = FALSE;

            $$ = sNodeTree_create_store_variable($1, "", $$, alloc, global, gSName, yylineno); 
        }
        | exp '.' name XOR_EQ comma_exp {
            char* var_name = $3;
            unsigned int obj = $1;

            $$ = sNodeTree_create_load_field(var_name, obj, gSName, yylineno);

            unsigned int int_value = $5;

            $$ = sNodeTree_create_xor($$, int_value, gSName, yylineno);

            unsigned int exp = $$;
            $$ = sNodeTree_create_store_field(var_name, obj, exp, gSName, yylineno); 
        }
        | exp '-' '>' name XOR_EQ comma_exp {
            char* var_name = $4;
            unsigned int obj = $1;

            $$ = sNodeTree_create_load_field(var_name, obj, gSName, yylineno);

            unsigned int int_value = $6;

            $$ = sNodeTree_create_xor($$, int_value, gSName, yylineno);

            unsigned int exp = $$;
            $$ = sNodeTree_create_store_field(var_name, obj, exp, gSName, yylineno); 
        }
        | '(' comma_exp ')' XOR_EQ exp { 
            unsigned int left = $2;
            unsigned int right = $5;

            $$ = sNodeTree_create_xor_eq(left, right, gSName, yylineno);
        }
        | IDENTIFIER OR_EQ comma_exp {
            $$ = sNodeTree_create_load_variable($1, gSName, yylineno);

            unsigned int int_value = $3;

            $$ = sNodeTree_create_or($$, int_value, gSName, yylineno);

            BOOL alloc = FALSE;
            BOOL global = FALSE;

            $$ = sNodeTree_create_store_variable($1, "", $$, alloc, global, gSName, yylineno); 
        }
        | exp '.' name OR_EQ comma_exp {
            char* var_name = $3;
            unsigned int obj = $1;

            $$ = sNodeTree_create_load_field(var_name, obj, gSName, yylineno);

            unsigned int int_value = $5;

            $$ = sNodeTree_create_or($$, int_value, gSName, yylineno);

            unsigned int exp = $$;
            $$ = sNodeTree_create_store_field(var_name, obj, exp, gSName, yylineno); 
        }
        | exp '-' '>' name OR_EQ comma_exp {
            char* var_name = $4;
            unsigned int obj = $1;

            $$ = sNodeTree_create_load_field(var_name, obj, gSName, yylineno);

            unsigned int int_value = $6;

            $$ = sNodeTree_create_or($$, int_value, gSName, yylineno);

            unsigned int exp = $$;
            $$ = sNodeTree_create_store_field(var_name, obj, exp, gSName, yylineno); 
        }
        | '(' comma_exp ')' OR_EQ exp { 
            unsigned int left = $2;
            unsigned int right = $5;

            $$ = sNodeTree_create_or_eq(left, right, gSName, yylineno);
        }
        | IDENTIFIER LSHIFT_EQ comma_exp {
            $$ = sNodeTree_create_load_variable($1, gSName, yylineno);

            unsigned int int_value = $3;

            $$ = sNodeTree_create_lshift($$, int_value, gSName, yylineno);

            BOOL alloc = FALSE;
            BOOL global = FALSE;

            $$ = sNodeTree_create_store_variable($1, "", $$, alloc, global, gSName, yylineno); 
        }
        | exp '.' name LSHIFT_EQ comma_exp {
            char* var_name = $3;
            unsigned int obj = $1;

            $$ = sNodeTree_create_load_field(var_name, obj, gSName, yylineno);

            unsigned int int_value = $5;

            $$ = sNodeTree_create_lshift($$, int_value, gSName, yylineno);

            unsigned int exp = $$;
            $$ = sNodeTree_create_store_field(var_name, obj, exp, gSName, yylineno); 
        }
        | exp '-' '>' name LSHIFT_EQ comma_exp {
            char* var_name = $4;
            unsigned int obj = $1;

            $$ = sNodeTree_create_load_field(var_name, obj, gSName, yylineno);

            unsigned int int_value = $6;

            $$ = sNodeTree_create_lshift($$, int_value, gSName, yylineno);

            unsigned int exp = $$;
            $$ = sNodeTree_create_store_field(var_name, obj, exp, gSName, yylineno); 
        }
        | '(' comma_exp ')' LSHIFT_EQ exp { 
            unsigned int left = $2;
            unsigned int right = $5;

            $$ = sNodeTree_create_lshift_eq(left, right, gSName, yylineno);
        }

        | IDENTIFIER RSHIFT_EQ comma_exp {
            $$ = sNodeTree_create_load_variable($1, gSName, yylineno);

            unsigned int int_value = $3;

            $$ = sNodeTree_create_rshift($$, int_value, gSName, yylineno);

            BOOL alloc = FALSE;
            BOOL global = FALSE;

            $$ = sNodeTree_create_store_variable($1, "", $$, alloc, global, gSName, yylineno); 
        }
        | exp '.' name RSHIFT_EQ comma_exp {
            char* var_name = $3;
            unsigned int obj = $1;

            $$ = sNodeTree_create_load_field(var_name, obj, gSName, yylineno);

            unsigned int int_value = $5;

            $$ = sNodeTree_create_rshift($$, int_value, gSName, yylineno);

            unsigned int exp = $$;
            $$ = sNodeTree_create_store_field(var_name, obj, exp, gSName, yylineno); 
        }
        | exp '-' '>' name RSHIFT_EQ comma_exp {
            char* var_name = $4;
            unsigned int obj = $1;

            $$ = sNodeTree_create_load_field(var_name, obj, gSName, yylineno);

            unsigned int int_value = $6;

            $$ = sNodeTree_create_rshift($$, int_value, gSName, yylineno);

            unsigned int exp = $$;
            $$ = sNodeTree_create_store_field(var_name, obj, exp, gSName, yylineno); 
        }
        | '(' comma_exp ')' RSHIFT_EQ exp { 
            unsigned int left = $2;
            unsigned int right = $5;

            $$ = sNodeTree_create_rshift_eq(left, right, gSName, yylineno);
        }
        | '(' type ')' exp {
            char type_name[VAR_NAME_MAX];

            xstrncpy(type_name, $2, VAR_NAME_MAX);

            unsigned int lnode = $4;

            $$ = sNodeTree_create_cast(type_name, lnode, gSName, yylineno);
        }
        | SIZEOF '(' IDENTIFIER ')' {
            char* var_name = $3;

            $$ = sNodeTree_create_sizeof2(var_name, gSName, yylineno);
        }
        | SIZEOF '(' type ')' {
            char* type_name = $3;

            $$ = sNodeTree_create_sizeof1(type_name, gSName, yylineno);
        }
        | ISHEAP '(' type ')' {
            char* type_name = $3;

            $$ = sNodeTree_create_isheap(type_name, gSName, yylineno);
        }
        | __ALIGNOF__ '(' IDENTIFIER ')' {
            char* var_name = $3;

            $$ = sNodeTree_create_alignof2(var_name, gSName, yylineno);
        }
        | __ALIGNOF__ '(' type ')' {
            char* type_name = $3;

            $$ = sNodeTree_create_alignof1(type_name, gSName, yylineno);
        }
        ;

array_index: '[' exp ']' {
        array_index_num++;
        array_index_num_dimention[array_index_num] = 0;
        array_index_index_node[array_index_num][array_index_num_dimention[array_index_num]] = $2;
        array_index_num_dimention[array_index_num]++;

        if(array_index_num_dimention[array_index_num] >= ARRAY_DIMENTION_MAX) {
            fprintf(stderr, "overflow array dimention number\n");
            exit(2);
        }
    }
    | array_index '[' exp ']' {
        array_index_index_node[array_index_num][array_index_num_dimention[array_index_num]] = $3;
        array_index_num_dimention[array_index_num]++;

        if(array_index_num_dimention[array_index_num] >= ARRAY_DIMENTION_MAX) {
            fprintf(stderr, "overflow array dimention number\n");
            exit(2);
        }
    }
    ;

params: { 
        params = sNodeTree_create_params(gSName, yylineno); 
        $$ = params; 
    }
    | exp { 
        params = sNodeTree_create_params(gSName, yylineno); 
        append_param_to_params(params, $1); 
        $$ = params; 
    }
    | exp ',' params { 
        append_param_to_params(params, $1); 
        $$ = params; 
    }
    ;

%%
int yyerror(char *msg)
{
    fprintf(stderr, "%s %d: %s\n", gSName, yylineno, msg);
    return 0;
}
