%{
#include<stdio.h>
#include<ctype.h>
int yylex();
void yyerror(char const *);
%}

%token  DIGIT

%%
S:DIGIT {
           printf("\n%d",$1);
};
%%

void yyerror(char const* s){
    fprintf(stderr,"%s\nh",s);
}

int main()
{
    yyparse();
}

int yylex(){
    
    int ch = getchar();
    if(isdigit(ch)){
        yylval = ch-'0';
        return yylval;
    }
    return ch;
}




