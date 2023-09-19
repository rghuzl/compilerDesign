%{
#include<stdio.h>
%}
%option noyywrap

%%
"//".* ;
. printf("%c",yytext[0]);
%%

int main(){
    FILE *inputFile = fopen("./Testcases/input.txt","r");
    if(!inputFile){
        printf("\nERROR! Failed To Open File \n");
        return 0;
    }

    // if file opened : read from it using yyin pointer
    yyin = inputFile;
    yylex();

    //fclose(inputFile);
}