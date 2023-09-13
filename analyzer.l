%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "./resource/symbolTable.txt"
void validateChar(char[] ,int,int);
void validateString(char[] ,int,int);
void validateIdentifier(char[],int,int);
void lookInSymbolTable(int,tokenNode  *[],char[],char[],int,int);
void validateMultilineComment(char[],int);
void printTable(tokenNode *[]);
int countSpace = 0;

tokenNode *hashTable[14];



%}

/* Rule's for Token's */
PREPROCESSOR_DIRECTIVE "#"[ ]*"include"[ ]*"<".*">"
COMPARISON_OPERATOR "=="|"<="|">="|">"|"<"
SHIFT_OPERATOR ">>"|"<<"
LOGICAL_OPERATOR "&&"|"||"|"!"
ARITHMETIC_OPERATOR "+"|"-"|"*"|"/"|"%"
BITWISE_OPERATOR "&"|"^"|"|"|"~"
ASSIGNMENT_OPERATOR "="|"+="|"-="|"%="|"*="|"/="|"&="|"^="|"|="|"~="|">>="|"<<="
DELIMITER [,;]
SPECIAL_CHAR "@"|"#"|"`"|"$"|"{"|"}"|"["|"]"|"."|"("|")"
KEYWORD "auto"|"double"|"int"|"struct"|"break"|"else"|"long"|"switch"|"case"|"enum"|"register"|"typedef"|"char"|"extern"|"return"|"union"|"const"|"float"|"short"|"unsigned"|"continue"|"for"|"signed"|"void"|"default"|"goto"|"sizeof"|"volatile"|"do"|"if"|"static"|"while"
INTEGER [+-]?[0-9]+ 
FLOAT [-+]?[0-9]+"."[0-9]+[f]?|[-+]?[0-9]+"."|[-+]?"."[0-9]+[f]?|[-+]?[0-9]+[e,E]"-"[0-9]+
IDENTIFIER [a-zA-Z_][a-zA-Z0-9]* 
/* char */
CHAR "'"."'"|"'".
/* string <mistake1:included new line in between string but fixed> */
STRING "\"".*"\""|"\"".*
SINGEL_LINE_COMMENT "//".*
MULTILINE_COMMENT "/*"(.|\n)*"*/"|"/*"(.|\n)*

/* line no */
NEW_LINE \n

/* nested comment: not able to implement*/
NESTED_COMMENT "/*"(.|\n)*"/*"(.|\n)*"*/"(.|\n)*"*/"
/* {NESTED_COMMENT}            printf("\n< %s : NESTED COMMENT >\n",yytext); */


%%      
[ ]                         countSpace++;
{PREPROCESSOR_DIRECTIVE}    printf("\n< %s : PREPROCESSOR DIRECTIVE >\n",yytext);
{NEW_LINE}                  yylineno++;
{KEYWORD}                   lookInSymbolTable(0,hashTable,yytext,"Keyword",yyleng,yylineno);
{IDENTIFIER}                lookInSymbolTable(1,hashTable,yytext,"Identifier",yyleng,yylineno);
{FLOAT}                     lookInSymbolTable(2,hashTable,yytext,"Float Constant",yyleng,yylineno);
{INTEGER}                   lookInSymbolTable(3,hashTable,yytext,"Integer Constant",yyleng,yylineno);
{CHAR}                      lookInSymbolTable(4,hashTable,yytext,"Char Literal",yyleng,yylineno);
{STRING}                    lookInSymbolTable(5,hashTable,yytext,"String Literal",yyleng,yylineno);
{SPECIAL_CHAR}              lookInSymbolTable(6,hashTable,yytext,"Special Character",yyleng,yylineno);
{DELIMITER}                 lookInSymbolTable(7,hashTable,yytext,"Seperator",yyleng,yylineno);
{SINGEL_LINE_COMMENT}       printf("\n< %s : SINGEL_LINE_COMMENT >\n",yytext);
{MULTILINE_COMMENT}         validateMultilineComment(yytext,yyleng);
{ARITHMETIC_OPERATOR}       lookInSymbolTable(8,hashTable,yytext,"Arithmetic Operator",yyleng,yylineno);
{LOGICAL_OPERATOR}          lookInSymbolTable(9,hashTable,yytext,"Logical Operator",yyleng,yylineno);
{ASSIGNMENT_OPERATOR}       lookInSymbolTable(10,hashTable,yytext,"Assignment Operator",yyleng,yylineno);
{COMPARISON_OPERATOR}       lookInSymbolTable(11,hashTable,yytext,"Comparison Operator",yyleng,yylineno);
{BITWISE_OPERATOR}          lookInSymbolTable(12,hashTable,yytext,"Bitwise Operator",yyleng,yylineno);
{SHIFT_OPERATOR}            lookInSymbolTable(13,hashTable,yytext,"Shift Operator",yyleng,yylineno);
.;
%%

int main(){

    FILE *inputFile = fopen("./testInput/input.txt","r");
    if(!inputFile){
        printf("\nERROR! unablE tO opeN filE\n");
        return 0;
    }

    //file opened successfully
    //read input from given input file "input.txt"
    yyin = inputFile;

    // hash table
    for(int i = 0;i<14;i++)
    {
        tokenNode *new = (tokenNode*)malloc(sizeof(tokenNode));
        new->next = NULL;
        hashTable[i] = new;
    }

   
    yylex();

    // printf("total space:%d\n",countSpace);
    
    //print symbol table
    printf("\n\x1B[35m::::::::::::::::::::::::::::::Symbol Table::::::::::::::::::::::::::::::\x1B[0m\n");
    printf("\x1B[36m\tTokenName\tlength\tScope\tLineOfRef\tTokenType\x1B[0m\n");
    printTable(hashTable);

    fclose(inputFile);
    return 0;
}

int yywrap(){
    return 1;
}

//symbol table operation:insertion , update , search
void lookInSymbolTable(int index,tokenNode *hashTable[],char yytext[],char type[],int yyleng,int yylineno){
    if(!strcmp(type,"Char Literal")){
        if(yyleng == 2)
            printf("\n\x1B[31merror! expected terminating ' character\nat line:%d\n\x1B[0m",yylineno);
    }
    else if(!strcmp(type,"String Literal")){
        if(yytext[yyleng-1] != '"')
            printf("\n\x1B[31merror! expected terminating \" character\nat line:%d\n\x1B[0m",yylineno);      
    }
    else if(!strcmp(type,"Identifier")){
        if(yyleng > 10)
            printf("\n\x1B[31merror! max length exceeded for Identifier \nat line:%d\x1B[0m\n",yylineno);
    }
    // else{
    //     printf("\n< %s : %s >",yytext,type);
    // }
    else{
    // printf("\n lookup called\n");
    tokenNode *head = hashTable[index];
    tokenNode *temp = head->next;
    //if already exists update lineno
    int is_exist = 0;
    
    while(temp){

        // mistake: we cant compare 2 string using ==  operator
        if(!(strcmp(temp->name,yytext))){

            is_exist = 1;
            Ref *head = temp->lineOfRef;
            Ref *new = (Ref*)malloc(sizeof(Ref));
            new->lineNo = yylineno;
            new->next = head->next;
            head->next = new;
            // printf("\n leaving while loop\n");
            break;
        }
        temp = temp->next;
    }

    if(!is_exist){
        // printf("\n if not present\n");
        tokenNode *new = (tokenNode*)malloc(sizeof(tokenNode));
        strcpy(new->name,yytext);
        strcpy(new->type,type);
        new->length = yyleng;
        new->scope = 1;

        Ref *lineHead = (Ref*)malloc(sizeof(Ref));
        lineHead->lineNo = yylineno;
        lineHead->next = NULL;
        new->lineOfRef = lineHead;

        new->next = head->next;
        head->next = new;

    }
    }

    return ;
    //not exists in symbol table create a new entry

}

// print symbol table
void printTable(tokenNode *hashTable[]){
    for(int i = 0;i < 14;i++){
        tokenNode *temp = hashTable[i]->next;
        while(temp){
            printf("\n\t%s\t\t%d\t%d\t",temp->name,temp->length,temp->scope);
            Ref * lineHead = temp->lineOfRef;
            while(lineHead){
                printf("%d ",lineHead->lineNo);
                lineHead = lineHead->next;
            }
            printf("\t\t %s\n",temp->type);
            temp = temp->next;
        }
    }
}

// validate multiline comment
void validateMultilineComment(char com[],int yyleng){
    if(com[yyleng-1] != '/' && com[yyleng-2] != '*')
        printf("\n\x1B[31merror! multiline comment starting at line %d not terminated with'*/'\x1B[0m\n",yylineno);
}