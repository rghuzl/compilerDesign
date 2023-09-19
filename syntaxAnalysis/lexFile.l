%{
#include<stdio.h>
%}

DIGIT [0-9]

%%
{DIGIT}     {return atoi(yytext);};
%%

int main()
{
    FILE *inputFile = fopen("input.txt","r");
    if(!inputFile){
        printf("\nerror! while opening file\n");

    }

    yyin = inputFile;
    printf("\n  %d\n",yylex());
    fclose(inputFile);

}