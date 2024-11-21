%option noyywrap
%option yylineno
%x MULCOMM

%{
#include <bits/stdc++.h>
#include "1905093_SymbolInfo.h"
#include "1905093_ScopeTable.h"
#include "1905093_SymbolTable.h"
#include <fstream>
#include "y.tab.h"
using namespace std;


SymbolInfo* tempSymbolInfo;
string token;
string temp;
string multicomm;
unsigned long lineNo = 1;
extern SymbolTable* ST; 
string str = "";

void yyerror(char *);
extern YYSTYPE yylval;
%}



AlphaNumeric [a-zA-Z0-9]
IDbegin [a-zA-Z_]
Alpha [a-zA-Z]

digit [0-9]
digits {digit}+
firstOp [+-]?
numBegin ({digits})
newline (\r\n|\n)
nostar [^*]
starnoslash \*[^/]

%%
(\/\*) {
    multicomm = "";
    multicomm += yytext;
    BEGIN MULCOMM;
}

<MULCOMM>(({nostar})*|({starnoslash})*)* {
    multicomm += yytext;
} 
<MULCOMM>(\*\/) {
    multicomm += yytext;
    char s3[multicomm.length()+1];  
    strcpy(s3,multicomm.c_str());
    char *s2 = s3;
    int countnewline = 0;
    while(*s2!='\0'){
        if(*s2 == '\n'){
            countnewline++;
        }
        s2++;
    }
    token = "COMMENT";
    BEGIN INITIAL;
}
<MULCOMM><<EOF>> {
    char s3[multicomm.length()+1];  
    strcpy(s3,multicomm.c_str());
    char *s2 = s3;
    int countnewline = 0;
    while(*s2!='\0'){
        if(*s2 == '\n'){
            countnewline++;
        }
        s2++;
    }

    return 0;
}


\/\/([^\n]*(\\{newline})?)* {
    char *s2 = yytext;
    int countnewline = 0;
    while(*s2!='\0'){
        if(*s2 == '\n'){
            countnewline++;
        }
        s2++;
    }
    if(*(s2-1) == 13){
        *(s2-1) = '\0';
    }
}




(\")([^\\\n\"]*(\\(({newline})|({AlphaNumeric})|[\\\"\']))*)*(\") {
    char *s2 = yytext;
    int countnewline = 0;
    while(*s2!='\0'){
        if(*s2 == '\n'){
            countnewline++;
        }
        s2++;
    }
    
    int fl=0;
    char *s = yytext;
    char *ans = new char[10000];
    char *res = ans;
    string temp = yytext;
    for(int i=0;i<temp.length();i++){
        while(*s){
            if(*s == '\\'){
                if(*(s+1) == 'n'){
                    s++;
                    *ans = '\n';
                }
                else if(*(s+1) == 't'){
                    s++;
                    *ans = '\t';
                }
                else if(*(s+1) == 'a'){
                    s++;
                    *ans = '\a';
                }
                else if(*(s+1) == 'f'){
                    s++;
                    *ans = '\f';
                }
                else if(*(s+1) == 'b'){
                    s++;
                    *ans = '\b';
                }
                else if(*(s+1) == 'v'){
                    s++;
                    *ans = '\v';
                }
                else if(*(s+1) == 'r'){
                    s++;
                    *ans = '\r';
                }
                else if(*(s+1) == '\"'){
                    s++;
                    *ans = '\"';
                }
                else if(*(s+1) == '\\'){
                    s++;
                    *ans = '\\';
                }
                else if(*(s+1) == '\''){
                    s++;
                    *ans = '\'';
                }
                else if(*(s+1) == '\n'){
                    ans--;
                }
                else if(*(s+1) == '\r'){
                    ans--;
                }
                else{
                    fl++;
                }

            }
            else{
                if(*s == 10 || *s == 13){
                    
                    ans--;
                    if(*ans == '\r'){
                        ans--;
                    }
                }
                else{
                    
                    *ans = *s;
                }
            }
            ans++;
            s++;
        }
    }
    *ans = '\0';

    temp = res;
}


"if" 				{
                            yylval.SI = new SymbolInfo(yytext, "IF");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
                        return IF;
					}
"else" 				{
    yylval.SI = new SymbolInfo(yytext, "ELSE");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
                        return ELSE;
					}
"for"  				{
    yylval.SI = new SymbolInfo(yytext, "IF");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
                        return FOR;
					}

"while" 			{
    yylval.SI = new SymbolInfo(yytext, "WHILE");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
                        return WHILE;
					}

"do"  				{
    yylval.SI = new SymbolInfo(yytext, "DO");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
                        return DO;
					}	

"break" 			{
    yylval.SI = new SymbolInfo(yytext, "BREAK");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
                        return BREAK;
					}
"int"  				{
    yylval.SI = new SymbolInfo(yytext, "INT");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
                        return INT;
					}

"char" 				{
    yylval.SI = new SymbolInfo(yytext, "CHAR");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
                        return CHAR;
					}

"float"  			{
    yylval.SI = new SymbolInfo(yytext, "IF");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
                        return FLOAT;
					}
"double" 			{
    yylval.SI = new SymbolInfo(yytext, "DOUBLE");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
                        return DOUBLE;
					}
"void"  			{
    yylval.SI = new SymbolInfo(yytext, "VOID");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
                        return VOID;
					}	
"return" 			{
    yylval.SI = new SymbolInfo(yytext, "RETURN");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
                        return RETURN;
					}
"continue" 			{
    yylval.SI = new SymbolInfo(yytext, "CONTINUE");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
                        return CONTINUE;
					}
"println" 			{
    yylval.SI = new SymbolInfo(yytext, "PRINTLN");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
                        return PRINTLN;
					}
[ \t\r\n]+ {}


{numBegin} {


   yylval.SI = new SymbolInfo(yytext, "CONST_INT");
    yylval.SI->setVal(yytext);
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
    return CONST_INT;
}
[0-9]+"."[0-9]*"E"[+-]?[0-9]+ {

    
   yylval.SI = new SymbolInfo(yytext, "CONST_FLOAT");
   yylval.SI->setVal(yytext);
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
    return CONST_FLOAT;
}
[0-9]+"E"[+-]?[0-9]+ {

   yylval.SI = new SymbolInfo(yytext, "CONST_FLOAT");
   yylval.SI->setVal(yytext);
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
    return CONST_FLOAT;
}
[0-9]+"."[0-9]* {

    
   yylval.SI = new SymbolInfo(yytext, "CONST_FLOAT");
   yylval.SI->setVal(yytext);
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
    return CONST_FLOAT;
}
"."[0-9]+"E"[+-]?[0-9]+ {

    
   yylval.SI = new SymbolInfo(yytext, "CONST_FLOAT");
   yylval.SI->setVal(yytext);
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
    return CONST_FLOAT;
}
"."[0-9]+ {

    
   yylval.SI = new SymbolInfo(yytext, "CONST_FLOAT");
   yylval.SI->setVal(yytext);
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
    return CONST_FLOAT;
}


'[^'\\\a\n\r\b\v\t\f\0]' {
    
    str = yytext;

    yytext[0] = yytext[1];
    yytext[1] = '\0';


   yylval.SI = new SymbolInfo(yytext, "CONST_CHAR");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
    return CONST_CHAR;


}

'\\\\' {
    str = yytext;

    yytext[0] = yytext[2];
    yytext[1] = '\0';
    
   yylval.SI = new SymbolInfo(yytext, "CONST_CHAR");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
    return CONST_CHAR;
}
'\\\'' {
    str = yytext;

    yytext[0] = yytext[2];
    yytext[1] = '\0';
   yylval.SI = new SymbolInfo(yytext, "CONST_CHAR");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
    return CONST_CHAR;
}

'\\n' {
    str = yytext;

    yytext[0] = '\n';
    yytext[1] = '\0';

   yylval.SI = new SymbolInfo(yytext, "CONST_CHAR");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
    return CONST_CHAR;
}
'\\t' {
    str = yytext;

    yytext[0] = '\t';
    yytext[1] = '\0';

   yylval.SI = new SymbolInfo(yytext, "CONST_CHAR");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
    return CONST_CHAR;
}
'\\a' {
    str = yytext;
    
    yytext[0] = '\a';
    yytext[1] = '\0';

   yylval.SI = new SymbolInfo(yytext, "CONST_CHAR");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
    return CONST_CHAR;
}
'\\f' {
    str = yytext;

    yytext[0] = '\f';
    yytext[1] = '\0';

   yylval.SI = new SymbolInfo(yytext, "CONST_CHAR");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
    return CONST_CHAR;
}
'\\r' {
    str = yytext;

    yytext[0] = '\r';
    yytext[1] = '\0';

   yylval.SI = new SymbolInfo(yytext, "CONST_CHAR");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
    return CONST_CHAR;
}
'\\b' {
    str = yytext;
    
    yytext[0] = '\b';
    yytext[1] = '\0';

   yylval.SI = new SymbolInfo(yytext, "CONST_CHAR");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
    return CONST_CHAR;
}
'\\v' {
    str = yytext;

    yytext[0] = '\v';
    yytext[1] = '\0';
   yylval.SI = new SymbolInfo(yytext, "CONST_CHAR");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
    return CONST_CHAR;
}
'\\0' {
    str = yytext;

    yytext[0] = '\0';
    yytext[1] = '\0';

   yylval.SI = new SymbolInfo(yytext, "DECOP");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
    return CONST_CHAR;
}


{IDbegin}({AlphaNumeric}|_)* 	{
                               yylval.SI = new SymbolInfo(yytext, "ID");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;

                            
                                return ID;
                            }

"++" {
   yylval.SI = new SymbolInfo(yytext, "INCOP");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
    return INCOP;
}
"--" {

   yylval.SI = new SymbolInfo(yytext, "DECOP");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
    return DECOP;
}
"<="|">="|"=="|"!="|">"|"<" {

   yylval.SI = new SymbolInfo(yytext, "RELOP");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
    return RELOP;
}
"&&"|"||" {

   yylval.SI = new SymbolInfo(yytext, "LOGICOP");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
    return LOGICOP;
}
"&"|"|"|"^"|"<<"|">>" {

    yylval.SI = new SymbolInfo(yytext, "BITOP");

    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;


    return BITOP;}
"+"|"-" {

   yylval.SI = new SymbolInfo(yytext, "ADDOP");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
    return ADDOP;
}
"*"|"/"|"%" {

   yylval.SI = new SymbolInfo(yytext, "MULOP");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
    return MULOP;
}
"=" {
    
    yylval.SI = new SymbolInfo(yytext, "ASSIGNOP");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;


    return ASSIGNOP;
}
"!" {
    
    yylval.SI = new SymbolInfo(yytext, "NOT");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;

    return NOT;
}
"(" {
       
    yylval.SI = new SymbolInfo(yytext, "ASSIGNOP");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
    return LPAREN;
}
")" {
        
    yylval.SI = new SymbolInfo(yytext, "RPAREN");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;

    return RPAREN;
}
"[" {
     
    yylval.SI = new SymbolInfo(yytext, "LSQUARE");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;

    return LTHIRD;
}
"]" {
        
    yylval.SI = new SymbolInfo(yytext, "RSQUARE");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;

    return RTHIRD;
}
"," {

       
    yylval.SI = new SymbolInfo(yytext, "COMMA");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;

    return COMMA;
}
";" {
    
    yylval.SI = new SymbolInfo(yytext, "SEMICOLON");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
    return SEMICOLON;
}
"{" {

    
     
    yylval.SI = new SymbolInfo(yytext, "LCURL");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;
    
    return LCURL;
}
"}" {
       
    yylval.SI = new SymbolInfo(yytext, "RCURL");;
    yylval.SI->beginTime = lineNo;
    yylval.SI->endTime = lineNo;
    yylval.SI->isLeaf = true;

    return RCURL;
}









<<EOF>>               {
    
    return 0;
    }



%%

