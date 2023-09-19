%{
#include<stdio.h>
int yylex();
void yyerror();
%}

%token DIGIT

%%
S:DIGIT {
        printf("\n%d",$1);
};
%%


int main()
{
    yyparse();
}

int yylex(){

    //how to read ?

    if(DIGIT)
            return yylval;
    else{
        return 1;
    }
}

void yyerror(char * s){
    fprintf(stderr,"%s\nh",s);
}

