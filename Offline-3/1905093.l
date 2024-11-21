%option noyywrap

%x CHAR_STATE
%x STR
%x S_CMNT
%x M_CMNT

%{
#include <bits/stdc++.h>
#include "SymbolTable.h"
#include "y.tab.h"
using namespace std;

void yyerror(char *);

extern ofstream logOut;
extern ofstream errorOut;

unsigned long lineNo = 1;
unsigned long startLineNo;
unsigned long errorNo = 0;

string curr;
string currExact;

%}

whitespace [ \t\f\v\r]+
newline \r?\n
letter [a-zA-Z]
letter_ [_a-zA-Z]
digit [0-9]
signs [+-=/]

%%
{whitespace} {
}
{newline} {
    lineNo++;
}
"if" {
    logOut<<"Line# "<<lineNo<<": Token <IF> Lexeme if found"<<endl;

    yylval.symbol = new SymbolInfo(yytext, "IF");


    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "IF : if";

    return IF;}
"else" {
    logOut<<"Line# "<<lineNo<<": Token <ELSE> Lexeme else found"<<endl;

    yylval.symbol = new SymbolInfo(yytext, "ELSE");


    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "ELSE : else";

    return ELSE;}
"for" {
    logOut<<"Line# "<<lineNo<<": Token <FOR> Lexeme for found"<<endl;

    yylval.symbol = new SymbolInfo(yytext, "FOR");


    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "FOR : for";

    return FOR;}
"while" {
    logOut<<"Line# "<<lineNo<<": Token <WHILE> Lexeme while found"<<endl;

    yylval.symbol = new SymbolInfo(yytext, "WHILE");


    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "WHILE : while";

    return WHILE;}
"do" {
    logOut<<"Line# "<<lineNo<<": Token <DO> Lexeme do found"<<endl;

    yylval.symbol = new SymbolInfo(yytext, "DO");


    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "DO : do";

    return DO;}
"int" {
    logOut<<"Line# "<<lineNo<<": Token <INT> Lexeme int found"<<endl;

    yylval.symbol = new SymbolInfo(yytext, "INT");


    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "INT : int";

    return INT;}
"float" {
    logOut<<"Line# "<<lineNo<<": Token <FLOAT> Lexeme float found"<<endl;

    yylval.symbol = new SymbolInfo(yytext, "FLOAT");


    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "FLOAT : float";

    return FLOAT;}
"double" {
    logOut<<"Line# "<<lineNo<<": Token <DOUBLE> Lexeme double found"<<endl;

    yylval.symbol = new SymbolInfo(yytext, "DOUBLE");


    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "DOUBLR : double";

    return DOUBLE;}
"char" {
    logOut<<"Line# "<<lineNo<<": Token <CHAR> Lexeme char found"<<endl;

    yylval.symbol = new SymbolInfo(yytext, "CHAR");


    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "CHAR : char";

    return CHAR;}
"return" {
    logOut<<"Line# "<<lineNo<<": Token <RETURN> Lexeme return found"<<endl;

    yylval.symbol = new SymbolInfo(yytext, "RETURN");


    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "RETURN : return";

    return RETURN;}
"continue" {
    logOut<<"Line# "<<lineNo<<": Token <CONTINUE> Lexeme continue found"<<endl;

    yylval.symbol = new SymbolInfo(yytext, "CONTINUE");


    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "CONTINUE : continue";

    return CONTINUE;}
"void" {
    logOut<<"Line# "<<lineNo<<": Token <VOID> Lexeme void found"<<endl;

    yylval.symbol = new SymbolInfo(yytext, "VOID");


    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "VOID : void";

    return VOID;}

"println" {
    logOut<<"Line# "<<lineNo<<": Token <PRINTLN> Lexeme println found"<<endl;

    yylval.symbol = new SymbolInfo(yytext, "PRINTLN");


    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "PRINTLN : println";

    return PRINTLN;}
   
   

{letter_}({letter_}|{digit})* {
    // will be changing this "ID" type later
    logOut<<"Line# "<<lineNo<<": Token <ID> Lexeme "<<yytext <<" found"<<endl;
    yylval.symbol = new SymbolInfo(yytext, "ID");
    
    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "ID : ";
    yylval.symbol->dataType += yytext;

    return ID;
}
{digit}+ {
    logOut<<"Line# "<<lineNo<<": Token <CONST_INT> Lexeme "<<yytext <<" found"<<endl;
    yylval.symbol = new SymbolInfo(yytext, "CONST_INT");

    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "CONST_INT : ";
    yylval.symbol->dataType += yytext;


    return CONST_INT;
}
{digit}*(\.{digit}+)?(([eE][+-])?{digit}+)? {
    logOut<<"Line# "<<lineNo<<": Token <CONST_FLOAT> Lexeme "<<yytext <<" found"<<endl;
    yylval.symbol = new SymbolInfo(yytext, "CONST_FLOAT");

    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "CONST_FLOAT : ";
    yylval.symbol->dataType += yytext;

    
    return CONST_FLOAT;
}
({digit}*\.{digit}+(\.{digit}*)+)+ {
    errorOut <<"Line# " << lineNo << ": Too many decimal points" << yytext;
    errorNo++;

    yylval.symbol = new SymbolInfo(yytext, "ERROR_FLOAT");
    return ERROR_FLOAT;
}
({digit}*\.?{digit}*[eE][+-]?{digit}*\.{digit}*)|({digit}*\.([eE][+-]?{digit}*\.?{digit}*)?) {
    errorOut <<"Line# " << lineNo << ": Ill formed number " << yytext;
    errorNo++;

    yylval.symbol = new SymbolInfo(yytext, "ERROR_FLOAT");
    return ERROR_FLOAT;
}
{signs}+{digit}+{letter_}+ {
    errorOut <<"Line# " << lineNo << ": Invalid prefix on ID or invalid suffix on Number " << yytext;
    errorNo++;

    // considering this ID for error recovery
    yylval.symbol = new SymbolInfo(yytext, "ID");
     yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "ID : ";
    yylval.symbol->dataType += yytext;


    return ID;
}
"+"|"-" {
    logOut<<"Line# "<<lineNo<<": Token <ADDOP> Lexeme "<<yytext <<" found"<<endl;
    yylval.symbol = new SymbolInfo(yytext, "ADDOP");


    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "ADDOP : ";
    yylval.symbol->dataType += yytext;


    return ADDOP;
}
"*"|"/"|"%" {
    logOut<<"Line# "<<lineNo<<": Token <MULOP> Lexeme "<<yytext <<" found"<<endl;

    yylval.symbol = new SymbolInfo(yytext, "MULOP");

    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "MULOP : ";
    yylval.symbol->dataType += yytext;



    return MULOP;
}


"&"|"|"|"^"|"<<"|">>" {
    logOut<<"Line# "<<lineNo<<": Token <BITOP> Lexeme "<<yytext <<" found"<<endl;

    yylval.symbol = new SymbolInfo(yytext, "BITOP");

    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "BITOP : ";
    yylval.symbol->dataType += yytext;

    return BITOP;}

"++" {
    logOut<<"Line# "<<lineNo<<": Token <INCOP> Lexeme "<<yytext <<" found"<<endl;

    yylval.symbol = new SymbolInfo(yytext, "INCOP");

    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "INCOP : ";
    yylval.symbol->dataType += yytext;


    return INCOP;}
"--" {
    logOut<<"Line# "<<lineNo<<": Token <DECOP> Lexeme "<<yytext <<" found"<<endl;\
    yylval.symbol = new SymbolInfo(yytext, "DECOP");

    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "DECOP : ";
    yylval.symbol->dataType += yytext;


    return DECOP;}
"<"|"<="|">"|">="|"=="|"!=" {
    logOut<<"Line# "<<lineNo<<": Token <RELOP> Lexeme "<<yytext <<" found"<<endl;
    yylval.symbol = new SymbolInfo(yytext, "RELOP");

    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "RELOP : ";
    yylval.symbol->dataType += yytext;


    return RELOP;
}
"=" {
    yylval.symbol = new SymbolInfo(yytext, "ASSIGNOP");
    logOut<<"Line# "<<lineNo<<": Token <ASSIGNOP> Lexeme "<<yytext <<" found"<<endl;

    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "ASSIGNOP : ";
    yylval.symbol->dataType += yytext;


    return ASSIGNOP;}
"&&"|"||" {
    logOut<<"Line# "<<lineNo<<": Token <LOGICOP> Lexeme "<<yytext <<" found"<<endl;
    yylval.symbol = new SymbolInfo(yytext, "LOGICOP");

    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "LOGICOP : ";
    yylval.symbol->dataType += yytext;


    return LOGICOP;
}
"!" {
    yylval.symbol = new SymbolInfo(yytext, "NOT");
    logOut<<"Line# "<<lineNo<<": Token <NOT> Lexeme "<<yytext <<" found"<<endl;

    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "NOT : ";
    yylval.symbol->dataType += yytext;


    return NOT;}


"(" {
    logOut<<"Line# "<<lineNo<<": Token <LPAREN> Lexeme "<<yytext <<" found"<<endl;
    yylval.symbol = new SymbolInfo(yytext, "LPAREN");

    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "LPAREN : ";
    yylval.symbol->dataType += yytext;


    return LPAREN;}
")" {
    logOut<<"Line# "<<lineNo<<": Token <RPAREN> Lexeme "<<yytext <<" found"<<endl;
    yylval.symbol = new SymbolInfo(yytext, "RPAREN");

    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "RPAREN : ";
    yylval.symbol->dataType += yytext;


    return RPAREN;}
"{" {

    logOut<<"Line# "<<lineNo<<": Token <LCURL> Lexeme "<<yytext <<" found"<<endl;
    yylval.symbol = new SymbolInfo(yytext, "LCURL");

    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "LCURL : ";
    yylval.symbol->dataType += yytext;


    return LCURL;
}
"}" {

    logOut<<"Line# "<<lineNo<<": Token <RCURL> Lexeme "<<yytext <<" found"<<endl;

    yylval.symbol = new SymbolInfo(yytext, "RCURL");

    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "RCURL : ";
    yylval.symbol->dataType += yytext;


    return RCURL;
}
"[" {
    logOut<<"Line# "<<lineNo<<": Token <LSQUARE> Lexeme "<<yytext <<" found"<<endl;

    yylval.symbol = new SymbolInfo(yytext, "LSQUARE");

    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "LSQUARE : ";
    yylval.symbol->dataType += yytext;


    return LTHIRD;}
"]" {
    logOut<<"Line# "<<lineNo<<": Token <RSQUARE> Lexeme "<<yytext <<" found"<<endl;

    yylval.symbol = new SymbolInfo(yytext, "RSQUARE");

    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->dataType = "RSQUARE : ";
    yylval.symbol->dataType += yytext;
    yylval.symbol->isLeaf = true;


    return RTHIRD;}
"," {
    logOut<<"Line# "<<lineNo<<": Token <COMMA> Lexeme "<<yytext <<" found"<<endl;

    yylval.symbol = new SymbolInfo(yytext, "COMMA");

    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "COMMA : ";
    yylval.symbol->dataType += yytext;


    return COMMA;}
";" {
    logOut<<"Line# "<<lineNo<<": Token <SEMICOLON> Lexeme "<<yytext <<" found"<<endl;

    yylval.symbol = new SymbolInfo(yytext, "SEMICOLON");

    yylval.symbol->beginTime = lineNo;
    yylval.symbol->endTime = lineNo;
    yylval.symbol->isLeaf = true;
    yylval.symbol->dataType = "SEMICOLON : ";
    yylval.symbol->dataType += yytext;


    return SEMICOLON;}
\' {
    curr = "";
    currExact = "";
    BEGIN CHAR_STATE;
}
<CHAR_STATE>\\n {
    curr += '\n';
    currExact += "\\n";
}
<CHAR_STATE>\\t {
    curr += '\t';
    currExact += "\\t";
}
<CHAR_STATE>\\\\ {
    curr += '\\';
    currExact += "\\\\";
}
<CHAR_STATE>\\\" {
    curr += '\"';
    currExact += "\\\"";
}
<CHAR_STATE>\\\' {
    curr += '\'';
    currExact += "\\\'";    
}
<CHAR_STATE>\\a {
    curr += '\a';
    currExact += "\\a";
}
<CHAR_STATE>\\f {
    curr += '\f';
    currExact += "\\f";
}
<CHAR_STATE>\\r {
    curr += '\r';
    currExact += "\\r";
}
<CHAR_STATE>\\b {
    curr += '\b';
    currExact += "\\b";
}
<CHAR_STATE>\\v {
    curr += '\v';
    currExact += "\\v";
}
<CHAR_STATE>\\0 {
    curr += '\0';
    currExact += "\\0";
}
<CHAR_STATE><<EOF>> {
    errorOut <<"Line# " << lineNo << ": Unterminated character '" << currExact<<"'"<<endl; ;
    errorNo++;
    BEGIN INITIAL;
}
<CHAR_STATE>{newline} {
    errorOut <<"Line# " << lineNo << ": Unterminated character '" << currExact<<"'"<<endl; ;
    errorNo++;
    lineNo++;
    BEGIN INITIAL;
}
<CHAR_STATE>\' {
    if ((curr.length() == 1) || (curr.length() == 0 && currExact == "\\0")) {

    } else if(curr.length() == 0) {
        errorOut <<"Line# " << lineNo << ": Empty character constant error '" << currExact << "'" ;
        errorNo++;
    } else {
        errorOut <<"Line# " << lineNo << ": Multi character constant error '" << currExact << "'";
        errorNo++;
    }

    BEGIN INITIAL;
}
<CHAR_STATE>. {
    curr += yytext;
    currExact += yytext;
}
\" {
    curr = "";
    currExact = "";
    startLineNo = lineNo;
    BEGIN STR;
}
<STR>\\n {
    curr += '\n';
    currExact += "\\n";
}
<STR>\\t {
    curr += '\t';
    currExact += "\\t";
}
<STR>\\\\ {
    curr += '\\';
    currExact += "\\\\";
}
<STR>\\\" {
    curr += '\"';
    currExact += "\\\"";
}
<STR>\\\' {
    curr += '\'';
    currExact += "\\\'";
}
<STR>\\a {
    curr += '\a';
    currExact += "\\a";
}
<STR>\\f {
    curr += '\f';
    currExact += "\\f";
}
<STR>\\r {
    curr += '\r';
    currExact += "\\r";
}
<STR>\\b {
    curr += '\b';
    currExact += "\\b";
}
<STR>\\v {
    curr += '\v';
    currExact += "\\v";
}
<STR>\\0 {
    curr += '\0';
    currExact += "\\0";
}
<STR>\\\r\n {
    currExact += "\\\r\n";
    lineNo++;
}
<STR>\\\n {
    currExact += "\\\n";
    lineNo++;
}
<STR>{newline} {
    errorOut <<"Line# " << startLineNo << ": Unterminated String \"" << currExact;
    errorNo++;
    lineNo++;
    BEGIN INITIAL;
}
<STR><<EOF>> {
    errorOut <<"Line# " << startLineNo << ": Unterminated String \"" << currExact << "\"" ;
    errorNo++;
    BEGIN INITIAL;
}
<STR>\" {

    BEGIN INITIAL;
}
<STR>. {
    curr += yytext;
    currExact += yytext;
}
\/\/ {
    currExact = "";
    startLineNo = lineNo;
    BEGIN S_CMNT;
}
<S_CMNT>\\{newline} {
    currExact += yytext;
    lineNo++;
}
<S_CMNT>{newline} {
    lineNo++;
    BEGIN INITIAL;
}
<S_CMNT><<EOF>> {
    BEGIN INITIAL;
}
<S_CMNT>. {
    currExact += yytext;
}
\/\* {
    currExact = "";
    startLineNo = lineNo;
    BEGIN M_CMNT;
}
<M_CMNT>\*\/ {
    BEGIN INITIAL;
}
<M_CMNT><<EOF>> {
    errorOut <<"Line# " << startLineNo << ": Unterminated Comment /*" << currExact ;
    errorNo++;
    BEGIN INITIAL;
}
<M_CMNT>{newline} {
    currExact += yytext;
    lineNo++;
}
<M_CMNT>. {
    currExact += yytext;
}
. {
    logOut <<"Error at line# " << lineNo << ": UNRECOGNIZED CHAR '" << yytext << "'"<<endl ;
    errorNo++;
}
