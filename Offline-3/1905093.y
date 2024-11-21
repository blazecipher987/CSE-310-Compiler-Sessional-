%{
#include<bits/stdc++.h>
#include "SymbolTable.h"
#include "grammerUtil.h"
using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;

SymbolTable* st = new SymbolTable(11);
ofstream logOut;
ofstream errorOut;
ofstream parseOut;
ofstream testing;

extern unsigned long lineNo;
extern unsigned long errorNo;
bool flagChecker = true;


vector< pair <string, unsigned long> > calledFunctions; // TO CHECK FUNCTIONS HAVE BEEN DEFINED LATER



void yyerror(const char *s) {
	logOut << "Error at line no " << lineNo << " : " << s << endl;
    errorNo++;
}

void errorFilePrint(const char *s) {
	errorOut << "Line# " << lineNo << ": " << s << endl;
    errorNo++;
}

void yylog2(ofstream &logOut, unsigned long lineNo, string left, string right, string symbolName) {

    logOut <<left << ":" << right <<endl;
    
}



// void printTree(SymbolInfo *p , int gaps){

//     parseOut<<"Gaps for now: "<<gaps<<endl;

//     parseOut<< p->getName()<<endl;

//     for(SymbolInfo *x : p){
//         printTree(x, gaps+1);
//     }
// }


//%type is used for non-terminals, for terminals we use the %token
%}

%union {
    SymbolInfo* symbol;
}

%token<symbol> ID CONST_INT CONST_FLOAT ERROR_FLOAT PRINTLN BITOP 
%token<symbol> ADDOP MULOP RELOP LOGICOP RPAREN SEMICOLON LPAREN LCURL RCURL COMMA LTHIRD RTHIRD INCOP DECOP ASSIGNOP NOT IF ELSE FOR WHILE DO INT CHAR FLOAT DOUBLE  VOID RETURN CONTINUE 
%type<symbol> start program unit func_declaration func_definition parameter_list compound_statement var_declaration term unary_expression factor argument_list arguments  

%type<symbol> type_specifier declaration_list statements statement expression_statement variable expression logic_expression rel_expression simple_expression


%destructor{
    delete $$;
}<symbol>


%nonassoc LOWER_THAN_ELSE   
%nonassoc ELSE

%%

start : program {
        $$ =new SymbolInfo(($1->getName()), "start");       
        yylog(logOut, lineNo, "start", "program ", "");

        // check if every declared only (not defined) functions are defined later if that function was called
        for (pair<string, unsigned long> a : calledFunctions) {
            // these functions will always exist in the symbol table
            // no need to compare with nullptr
            if (st->lookup(a.first)->isDefined() == false) {
                errorFilePrint(("No definition found for function " + a.first + " at line " + to_string(a.second)).c_str());
            }
        }
        $$->dataType = "start : program";       //setting datatype for printing in the parsetree later
        //$$->setDataType($1->getName());
        $$->setBeginTime($1->getBeginTime());   //set begintime which is actually the starting lineNo of the unit
        $$->setEndTime($1->getEndTime());       //set endTime which is actualy the endding lineNo of the unit
        $$->setParseItems({$1});                //add all the items whcih are produced from the current parse Rule
        $$->setLeaf(false);                     //this is a non-terminal hence define it as false which is later used in the printParseTree function

        $$->parsetreePrint(parseOut, 0);        //recursively print the parseTree
        
        //printTree($$, 0);
	}
	;

program : program unit {
        $$ = new SymbolInfo(($1->getName() + $2->getName()), "PROGRAM");
       // $$->beginTime = $1->getBeginTime();

        $$->dataType = "program : program unit";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($2->getEndTime());
        $$->setParseItems({$1,$2});
        $$->setLeaf(false);
        //$$->endTime = $2->endTime;
        
        yylog(logOut, lineNo, "program", "program unit ", $$->getName());
    }
    | unit {
        $$ = new SymbolInfo(($1->getName() ), $1->getType());
        //$$->beginTime = $$->endTime = $1->beginTime;
        yylog(logOut, lineNo, "program", "unit ", $$->getName());

        $$->dataType = "program : unit";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);

        // $$->setBeginTime($1->getBeginTime());
        // $$->setEndTime($2->getEndTime());
    }
    ;

unit : var_declaration {
        $$ = new SymbolInfo($1->getName() + "\n", $1->getType());
        yylog(logOut, lineNo, "unit", "var_declaration  ", $$->getName());

        $$->dataType = "unit : var_declaration";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);
    }
    | func_declaration {
        $$ = new SymbolInfo($1->getName(), $1->getType());
        yylog(logOut, lineNo, "unit", "func_declaration ", $$->getName());

        $$->dataType= "unit : func_declaration";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);
    }
    | func_definition {
        $$ = new SymbolInfo($1->getName() + "\n", $1->getType());
        yylog(logOut, lineNo, "unit", "func_definition  ", $$->getName());

        $$->dataType="unit : func_definition";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);
    }
    | error {
        $$ = new SymbolInfo("", "UNIT");
    }
    ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + $3->getName() + $4->getName() + $5->getName() +  $6->getName() + "\n"), "FUNC_DECLARATION");
        yylog(logOut, lineNo, "func_declaration", "type_specifier ID LPAREN parameter_list RPAREN SEMICOLON ", $$->getName());

        

        funcDec2($1, $2, $4);

        //parseOut<<"We are here :: "<<$$->getName() <<endl;

        $$->dataType = "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($6->getEndTime());
        $$->setParseItems({$1,$2,$3,$4,$5,$6});
        $$->setLeaf(false);

    }
    | type_specifier ID LPAREN parameter_list error RPAREN SEMICOLON {
        

        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + $3->getName() + $4->getName() + $6->getName() +  $7->getName() + "\n"), "FUNC_DECLARATION");
        yylog(logOut, lineNo, "func_declaration", "type_specifier ID LPAREN parameter_list RPAREN SEMICOLON ", $$->getName());

        $$->dataType = "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($7->getEndTime());
        $$->setParseItems({$1,$2,$3, $4, $6, $7});
        $$->setLeaf(false);

        funcDec2($1, $2, $4);

    }
    | type_specifier ID LPAREN parameter_list RPAREN error {
        logOut<<"Error at line no "<<lineNo<<" : Syntax Error"<<endl;

        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + $3->getName() + $4->getName() + $5->getName() +"\n"), "FUNC_DECLARATION");
        yylog(logOut, lineNo, "func_declaration", "type_specifier ID LPAREN parameter_list RPAREN SEMICOLON " , $$->getName());


        $$->dataType = "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($5->getEndTime());
        $$->setParseItems({$1,$2, $3, $4, $5});
        $$->setLeaf(false);

        funcDec2($1, $2, $4);

    }
    | type_specifier ID LPAREN parameter_list error RPAREN error {
        logOut<<"Error at line no "<<lineNo<<" : Syntax Error"<<endl;

        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + $3->getName() + $4->getName() + $6->getName() + ";\n"), "FUNC_DECLARATION");
        yylog(logOut, lineNo, "func_declaration", "type_specifier ID LPAREN parameter_list RPAREN SEMICOLON ", $$->getName());


        $$->dataType = "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON" ; 
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($6->getEndTime());
        $$->setParseItems({$1,$2, $3, $4, $6});
        $$->setLeaf(false);

        funcDec2($1, $2, $4);

    }
	| type_specifier ID LPAREN RPAREN SEMICOLON {

        
        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName() + $3->getName() +$4->getName() + $5->getName() + "\n"), "FUNC_DECLARATION");
        yylog(logOut, lineNo, "func_declaration", "type_specifier ID LPAREN RPAREN SEMICOLON ", $$->getName());


        $$->dataType = "func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($5->getEndTime());
        $$->setParseItems({$1,$2 , $3, $4, $5});
        $$->setLeaf(false);

        funcDec1($1, $2);

    }
    | type_specifier ID LPAREN RPAREN error {
        logOut<<"Error at line no "<<lineNo<<" : Syntax Error"<<endl;

        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName() + $3->getName() +$4->getName() + ";\n"), "FUNC_DECLARATION");
        //yylog(logOut, lineNo, "func_declaration", "type_specifier ID LPAREN RPAREN SEMICOLON", $$->getName());


        $$->dataType ="func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($4->getEndTime());
        $$->setParseItems({$1,$2, $3, $4});
        $$->setLeaf(false);

        funcDec1($1, $2);

        //delete $1; delete $2;
    }| type_specifier ID LPAREN error RPAREN SEMICOLON {
        logOut<<"Error at line no "<<lineNo<<" : Syntax Error"<<endl;

        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName() + $3->getName() +$5->getName() + $6->getName() +"\n"), "FUNC_DECLARATION");
        //yylog(logOut, lineNo, "func_declaration", "type_specifier ID LPAREN RPAREN SEMICOLON", $$->getName());

        $$->dataType = "func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($6->getEndTime());
        $$->setParseItems({$1,$2,$3,$5,$6});
        $$->setLeaf(false);

        funcDec1($1, $2);

        //delete $1; delete $2; delete $3;   $5 ; delete $6;

    }| type_specifier ID LPAREN error RPAREN error {

        logOut<<"Error at line no "<<lineNo<<" : Syntax Error"<<endl;

        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName() +$3->getName() +$5->getName() +";\n"), "FUNC_DECLARATION");
        //yylog(logOut, lineNo, "func_declaration", "type_specifier ID LPAREN RPAREN SEMICOLON", $$->getName());


        $$->dataType = "func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($5->getEndTime());
        $$->setParseItems({$1,$2,$3,$5});
        $$->setLeaf(false);

        funcDec1($1, $2);

       // delete $1; delete $2;  $3; delete $5;
    }
	;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN { // compound_statement here

        funcDef1($1, $2, $3, $4, $5 ,false);
        //cout<<"We are here"<<endl;

    } compound_statement {

        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName() + $3->getName() + $4->getName() + $5->getName() + $7->getName()), "FUNC_DEFINITION");


        $$->dataType = "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($7->getEndTime());
        $$->setParseItems({$1,$2, $3,$4,$5, $7});
        $$->setLeaf(false);
        
        // print scopes and exit
        st->printLogFile(logOut);
        st->exitScope();

        yylog(logOut, lineNo, "func_definition", "type_specifier ID LPAREN parameter_list RPAREN compound_statement ", $$->getName());
        //parseOut<<"We are here :: "<<$$->getName() <<endl;
    }
    | type_specifier ID LPAREN parameter_list error RPAREN { // compound_statement here

        funcDef1($1, $2, $3, $4, $6 , true);

    } compound_statement {

        //logOut<<"Error at line no "<<lineNo<<" : Syntax Error"<<endl;
        errorOut<<"Line #"<<lineNo<<": Syntax error at parameter list of function definition"<<endl;

        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName() + $3->getName() + $4->getName() + $6->getName() + $8->getName()), "FUNC_DEFINITION");

        $$->dataType= "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($8->getEndTime());
        $$->setParseItems({$1,$2, $3, $4, $6 ,$8});
        $$->setLeaf(false);
        
        // print scopes and exit
        st->printLogFile(logOut);
        st->exitScope();

        //yylog(logOut, lineNo, "func_definition", "type_specifier ID LPAREN parameter_list RPAREN compound_statement ", $$->getName());

       
    }
    | type_specifier ID LPAREN RPAREN { // compound_statement here

        funcDef2($1, $2, $3, $4, false);

    } compound_statement {

        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + $3->getName() +$4->getName() + $6->getName()), "FUNC_DEFINITION");\
        
        $$->dataType = "func_definition : type_specifier ID LPAREN RPAREN compound_statement";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($6->getEndTime());
        $$->setParseItems({$1,$2,$3,$4, $6});
        $$->setLeaf(false);

        st->printLogFile(logOut);
        st->exitScope();

        yylog(logOut, lineNo, "func_definition", "type_specifier ID LPAREN RPAREN compound_statement", $$->getName());

    }
    | type_specifier ID LPAREN error RPAREN { // compound_statement here

        funcDef2($1, $2, $3, $5 , true);

    } compound_statement {

        //logOut<<"Error at line no "<<lineNo<<" : Syntax Error"<<endl;

        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + $3->getName()  +$5->getName()  + $7->getName()), "FUNC_DEFINITION");

        $$->dataType = "func_definition : type_specifier ID LPAREN RPAREN compound_statement";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($7->getEndTime());
        $$->setParseItems({$1,$2,$3,$5, $7});
        $$->setLeaf(false);

        // SCOPE HANDLING
        st->printLogFile(logOut);
        st->exitScope();

        //yylog(logOut, lineNo, "func_definition", "type_specifier ID LPAREN RPAREN compound_statement", $$->getName());

    }
    ;

parameter_list  : parameter_list COMMA type_specifier ID {
        $$ = new SymbolInfo(($1->getName() + $2->getName()+ $3->getName() + " "  + $4->getName()), "PARAMETER_LIST");

        funcParam1($$, $1, $2, $3, $4);

        $$->dataType = "parameter_list : parameter_list COMMA type_specifier ID";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($4->getEndTime());
        $$->setParseItems({$1,$2,$3,$4});
        $$->setLeaf(false);

        

        //delete $1; delete $3; delete $4; delete $2;
    }
    | parameter_list error COMMA type_specifier ID {

        //logOut<<"Error at line no "<<lineNo<<" : Syntax Error"<<endl;

        $$ = new SymbolInfo(($1->getName() + $3->getName()+ $4->getName() + " "  + $5->getName()), "PARAMETER_LIST");

        $$->dataType = "parameter_list : parameter_list COMMA type_specifier ID";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($5->getEndTime());
        $$->setParseItems({$1,$3,$4, $5});
        $$->setLeaf(false);

        funcParam1($$, $1, $3, $4, $5);

        //delete $1; delete $4; delete $5; delete $3;
    }
    | parameter_list COMMA type_specifier {
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), "PARAMETER_LIST");
        yylog(logOut, lineNo, "parameter_list ", "parameter_list COMMA type_specifier", $$->getName());


        $$->dataType = "parameter_list : parameter_list COMMA type_specifier";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($3->getEndTime());
        $$->setParseItems({$1,$2,$3});
        $$->setLeaf(false);

        // adding the params
        if(flagChecker==true)
        {$$->setParams($1->getParams());
        $$->addParam(new SymbolInfo("NOT DEFINED", $3->getName()));}

       // delete $1; delete $3; delete $2;
    }
    | parameter_list error COMMA type_specifier {        

        logOut<<"Error at line no "<<lineNo<<" : Syntax Error"<<endl;

        $$ = new SymbolInfo(($1->getName() + $3->getName() + $4->getName()), "PARAMETER_LIST");
        //yylog(logOut, lineNo, "parameter_list ", "parameter_list COMMA type_specifier", $$->getName());

        $$->dataType = " parameter_list : parameter_list COMMA type_specifier";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($4->getEndTime());
        $$->setParseItems({$1,$3,$4});
        $$->setLeaf(false);

        // adding the params
        if(flagChecker==true)
        {$$->setParams($1->getParams());
        $$->addParam(new SymbolInfo("NOT DEFINED", $4->getName()));
}
        //delete $1; delete $4; delete $3;
    }
    | type_specifier ID {
        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName()), "PARAMETER_LIST");
        yylog(logOut, lineNo, "parameter_list ", "type_specifier ID", $$->getName());

        $$->dataType = "parameter_list : type_specifier ID";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($2->getEndTime());
        $$->setParseItems({$1,$2});
        $$->setLeaf(false);
        flagChecker=true;

        // adding the params
        $$->addParam(new SymbolInfo($2->getName(), $1->getName()));

        //delete $1; delete $2;
    }
    | type_specifier {
        $$ = new SymbolInfo(($1->getName()), "PARAMETER_LIST");
        yylog(logOut, lineNo, "parameter_list ", "type_specifier", $$->getName());

        $$->dataType = "parameter_list : type_specifier";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);
        $$->parenTrue = true;
        flagChecker = true;

        // adding the params
        $$->addParam(new SymbolInfo("NOT DEFINED", $1->getName()));

        //delete $1;
    }
    
    ;

compound_statement : LCURL statements RCURL {
        
        $$ = new SymbolInfo(($1->getName() +  "\n" + $2->getName() +$3->getName() + "\n"), "COMPOUND_STATEMENT");
        yylog(logOut, lineNo, "compound_statement", "LCURL statements RCURL  ", $$->getName());


        $$->dataType = "compound_statement : LCURL statements RCURL";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($3->getEndTime());
        $$->setParseItems({$1,$2,$3});
        $$->setLeaf(false);

    }
    | LCURL RCURL {
        $$ = new SymbolInfo($1->getName() + $2->getName()+"\n", "COMPOUND_STATEMENT");
        yylog(logOut, lineNo, "compound_statement", "LCURL RCURL  ", $$->getName());

        $$->dataType = "compound_statement : LCURL RCURL";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($2->getEndTime());
        $$->setParseItems({$1,$2});
        $$->setLeaf(false);
    }
    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + $3->getName()), "VAR_DECLARATION");
        funcParam2($$, $1, $2 , false);        

        $$->dataType= "var_declaration : type_specifier declaration_list SEMICOLON";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($3->getEndTime());
        $$->setParseItems({$1,$2,$3});
        $$->setLeaf(false);

    }
    | type_specifier declaration_list error SEMICOLON {

        errorOut<<"Line# "<<lineNo<<"Syntax error at declaration list of variable declaration"<<endl;
        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + $4->getName() ), "VAR_DECLARATION");
        
        funcParam2($$, $1, $2 , true);

        $$->dataType= "var_declaration : type_specifier declaration_list SEMICOLON";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($4->getEndTime());
        $$->setParseItems({$1,$2,$4});
        $$->setLeaf(false);

    }
    | type_specifier error declaration_list SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + " " + $3->getName() + $4->getName() ), "VAR_DECLARATION");
        funcParam2($$, $1, $3 , true);

        $$->dataType= "var_declaration : type_specifier declaration_list SEMICOLON";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($4->getEndTime());
        $$->setParseItems({$1,$3,$4});
        $$->setLeaf(false);

    }
    ;
 		 
type_specifier : INT {
        $$ = new SymbolInfo($1->getName(), $1->getType());
        yylog2(logOut, lineNo, "type_specifier\t", " INT ", $$->getName()); 

        $$->dataType = "type_specifier : INT";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);

    }
    | FLOAT {
        $$ = new SymbolInfo($1->getName(), $1->getType());
        yylog2(logOut, lineNo, "type_specifier\t", " FLOAT ", $$->getName());

         $$->dataType = "type_specifier : FLOAT";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);

    }
    | VOID {
        $$ = new SymbolInfo($1->getName(), $1->getType());
        yylog2(logOut, lineNo, "type_specifier\t", " VOID", $$->getName());

         $$->dataType = "type_specifier : VOID";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);

    }
    ;
 		
declaration_list : declaration_list COMMA ID {
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), "DECLARATION_LIST");
        funcDec1($$, $1, $2, $3 , false);

        $$->dataType = "declaration_list : declaration_list COMMA ID";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($3->getEndTime());
        $$->setParseItems({$1,$2,$3});
        $$->setLeaf(false);

    }
    | declaration_list error COMMA ID {
        //logOut<<errorFilePrint<<"T"<<endl;
        $$ = new SymbolInfo(($1->getName() + $3->getName() + $4->getName()), "DECLARATION_LIST");
        
        funcDec1($$, $1, $3, $4, true);


        $$->dataType = "declaration_list : declaration_list COMMA ID";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($4->getEndTime());
        $$->setParseItems({$1,$3,$4});
        $$->setLeaf(false);


    }
    | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
        $$ = new SymbolInfo(($1->getName() + $2->getName()  + $3->getName() +  $4->getName() + $5->getName() + $6->getName() ), "DECLARATION_LIST");
        funcDec2($$, $1, $2, $3, $5, false);

        $$->dataType = "declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($6->getEndTime());
        $$->setParseItems({$1,$2,$3,$4,$5,$6});
        $$->setLeaf(false);

     
    }
    | declaration_list error COMMA ID LTHIRD CONST_INT RTHIRD {
        $$ = new SymbolInfo(($1->getName() + $3->getName()+ $4->getName() + $5->getName()  + $6->getName() + $7->getName() ), "DECLARATION_LIST");
        funcDec2($$, $1, $3, $4, $6 , true);

        logOut<<"Error : "<<lineNo<<endl;
        $$->dataType = "declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($7->getEndTime());
        $$->setParseItems({$1,$3,$4,$5,$6,$7});
        $$->setLeaf(false);

        // delete $1;
        // delete $3;
        // delete $4;
        // delete $5;
        // delete $7;
        // delete $4; delete $6;
    }
    | ID {
        $$ = new SymbolInfo($1->getName(), $1->getType());

        $$->dataType = "declaration_list : ID";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);


        // adding this id to declaration_list for assigning type later
        $$->addParam((new SymbolInfo())->copySymbol($1));

        yylog(logOut, lineNo, "declaration_list", "ID ", $$->getName());

        // delete $1;
    }
    | ID LTHIRD CONST_INT RTHIRD {
        $$ = new SymbolInfo(($1->getName() + $2->getName()  + $3->getName() + $4->getName() ), "DECLARATION_LIST");

        $$->dataType = "declaration_list : ID LSQUARE CONST_INT RSQUARE";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($4->getEndTime());
        $$->setParseItems({$1,$2,$3,$4});
        $$->setLeaf(false);

        // ADDING TO DEC LIST FOR LATER TYPE SETTING
        $$->addParam((new SymbolInfo())->copySymbol($1)->setArraySize(stoi($3->getName())));

        yylog(logOut, lineNo, "declaration_list", "ID LSQUARE CONST_INT RSQUARE ", $$->getName());

        // delete $1; delete $3;
    }
    ;
 		  
statements : statement {
        $$ = new SymbolInfo(($1->getName() ), $1->getType());
        yylog(logOut, lineNo, "statements", "statement  ", $$->getName());

        $$->dataType = "statements : statement";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);


    }
    | statements statement {
        $$ = new SymbolInfo(($1->getName() + $2->getName()), "STATEMENTS");
        yylog(logOut, lineNo, "statements", "statements statement  ", $$->getName());


        $$->dataType = "statements : statements statement";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($2->getEndTime());
        $$->setParseItems({$1,$2});
        $$->setLeaf(false);

        //delete $1; delete $2;
    }
    | statements error {
        $$ = new SymbolInfo(($1->getName()), $1->getType());
        // yylog(logOut, lineNo, "statements", "statements statement", $$->getName());

        $$->dataType = "statements : statements";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);

       // logOut << $$->getName() << endl << endl;        /////////////////////

    }
    ;
	   
statement : var_declaration {
        $$ = new SymbolInfo(($1->getName() + "\n"), $1->getType());
        yylog(logOut, lineNo, "statement", "var_declaration ", $$->getName());

        $$->dataType = "statement : var_declaration";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);

    }
    | expression_statement {
        $$ = new SymbolInfo(($1->getName() + "\n"), $1->getType());
        yylog(logOut, lineNo, "statement", "expression_statement  ", $$->getName());

        $$->dataType = "statement : expression_statement";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);

    }
    | func_declaration {
        $$ = new SymbolInfo(($1->getName()), $1->getType());

        $$->dataType = "statement : func_declaration";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);

        errorFilePrint("Function declaration is only allowed in the global scope");
        yylog(logOut, lineNo, "statement", "func_declaration", $$->getName());
    }
    | func_definition {
        $$ = new SymbolInfo(($1->getName()), $1->getType());

        $$->dataType = "statement : func_definition";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);

        errorFilePrint("Function definition is only allowed in the global scope");
        yylog(logOut, lineNo, "statement", "func_definition", $$->getName());
    }
    | {st->enterScope();} compound_statement {
        $$ = new SymbolInfo(($2->getName()), "STATEMENT");

        $$->dataType = "statement : compound_statement";
        $$->setBeginTime($2->getBeginTime());
        $$->setEndTime($2->getEndTime());
        $$->setParseItems({$2});
        $$->setLeaf(false);

        // print scopes and exit
        st->printLogFile(logOut);
        st->exitScope();

        yylog(logOut, lineNo, "statement", "compound_statement ", $$->getName());

        //delete $2;
    }
    | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
        $$ = new SymbolInfo(( $1->getName()+ $2->getName()  + $3->getName() + $4->getName() + $5->getName() + $6->getName()  + $7->getName()), "FOR_LOOP");
        yylog(logOut, lineNo, "statement", "FOR LPAREN expression_statement expression_statement expression RPAREN statement", $$->getName());

        $$->dataType = "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($7->getEndTime());
        $$->setParseItems({$1,$2,$3,$4,$5,$6,$7});
        $$->setLeaf(false);

        // delete $3; delete $4;
        // delete $1;
        // delete $2;
        // delete $3;
        // delete $6;  delete $5; delete $7;
    }
    | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
        $$ = new SymbolInfo(($1->getName()+ $2->getName()  + $3->getName() + $4->getName()  + $5->getName()), "IF");
        yylog(logOut, lineNo, "statement", "IF LPAREN expression RPAREN statement %prec THEN", $$->getName());

        $$->dataType = "statement : IF LPAREN expression RPAREN statement";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($5->getEndTime());
        $$->setParseItems({$1,$2,$3,$4,$5});
        $$->setLeaf(false);

        // delete $3; 
        // delete $1;
        // delete $2;
        // delete $5;delete $4;
    }
    | IF LPAREN expression RPAREN statement ELSE statement {
        $$ = new SymbolInfo(($1->getName()+ $2->getName()  + $3->getName() + $4->getName()  + $5->getName() + $6->getName() + "\n" + $7->getName()), "IF_ELSE");
        yylog(logOut, lineNo, "statement", "IF LPAREN expression RPAREN statement ELSE statement ", $$->getName());

        $$->dataType = "statement : IF LPAREN expression RPAREN statement ELSE statement";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($7->getEndTime());
        $$->setParseItems({$1,$2,$3,$4,$5, $6, $7});
        $$->setLeaf(false);


    }
    | WHILE LPAREN expression RPAREN statement {
        $$ = new SymbolInfo(($1->getName() + $2->getName()  + $3->getName() + $4->getName()  + $5->getName()), "WHILE_LOOP");
        yylog(logOut, lineNo, "statement", "WHILE LPAREN expression RPAREN statement", $$->getName());

        $$->dataType = "statement : WHILE LPAREN expression RPAREN statement";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($5->getEndTime());
        $$->setParseItems({$1,$2,$3,$4,$5});
        $$->setLeaf(false);

    }
    | PRINTLN LPAREN ID RPAREN SEMICOLON {
        $$ = new SymbolInfo(($1->getName()+ $2->getName()  + $3->getName() + $4->getName() + $5->getName() +"\n"), "PRINT_STATEMENT"); //....................


        $$->dataType = "statement : PRINTLN LPAREN ID RPAREN SEMICOLON";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($5->getEndTime());
        $$->setParseItems({$1,$2,$3,$4,$5});
        $$->setLeaf(false);    

        if (st->lookup($3->getName()) == nullptr) {
            errorFilePrint(("Undeclared variable '" + $3->getName() + "'").c_str());
        }
        
        yylog(logOut, lineNo, "statement", "PRINTLN LPAREN ID RPAREN SEMICOLON", $$->getName());

        // delete $3;
        // delete $1;
        // delete $2;
        // delete $4;
        // delete $5;
    }
    | RETURN expression SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + $2->getName() +$3->getName() + "\n"), "RETURN_STATEMENT");
        yylog(logOut, lineNo, "statement", "RETURN expression SEMICOLON", $$->getName());

        $$->dataType = "statement : RETURN expression SEMICOLON";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($3->getEndTime());
        $$->setParseItems({$1,$2,$3});
        $$->setLeaf(false);

        // delete $2;
        // delete $1;
        // delete $3;
    }
    // | error {
    //     $$ = new SymbolInfo("", "STATEMENT");
    // }
    ;
	  
expression_statement : SEMICOLON {
        $$ = new SymbolInfo($1->getName() , $1->getType());
        yylog(logOut, lineNo, "expression_statement", "SEMICOLON\t\t", $$->getName());

        $$->dataType = "expression_statement : SEMICOLON";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);

        //delete $1;
    }
    | expression SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + $2->getName() ), "EXPRESSION_STATEMENT");
        yylog2(logOut, lineNo, "expression_statement ", " expression SEMICOLON \t\t ", $$->getName());

        $$->dataType = "expression_statement : expression SEMICOLON";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($2->getEndTime());
        $$->setParseItems({$1,$2});
        $$->setLeaf(false);

        // delete $1;
        // delete $2;
    }
    | expression error SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + $3->getName() ), "EXPRESSION_STATEMENT");
        //yylog2(logOut, lineNo, "expression_statement ", " expression SEMICOLON \t\t ", $$->getName());
        errorOut<<"Line# "<<lineNo<<" Syntax error at expression of expression statement"<<endl;

        $$->dataType = "expression_statement : expression SEMICOLON";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($3->getEndTime());
        $$->setParseItems({$1,$3});
        $$->setLeaf(false);

        // delete $1;
        // delete $2;
    }
    ;

variable : ID {
        $$ = new SymbolInfo(($1->getName()  ), $1->getType());

        $$->dataType = "variable : ID";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);

        // CHECK FOR VARIABLE DECLARATION
        SymbolInfo* previous = st->lookup($1->getName());
       // cout<<"Yoooo: "<<previous->getType()<<endl;
        if (previous != nullptr) {
            $$->setType(previous->getType());
            if (previous->isVariable() == true) {
                // all is well
            } else {
                errorFilePrint(( $1->getName() + " is not a variable").c_str());
            }
        } 
        else {
            $$->setType("UNDEFINED");
            errorFilePrint(("Undeclared variable '" +$1->getName() + "'").c_str());
        }
        yylog(logOut, lineNo, "variable", "ID \t ", $$->getName());
    } 		
    | ID LTHIRD expression RTHIRD {
        $$ = new SymbolInfo(($1->getName() + $2->getName() + " " + $3->getName() + $4->getName() ), "ARRAY");

        $$->dataType = "variable : ID LSQUARE expression RSQUARE";
        $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($4->getEndTime());
        $$->setParseItems({$1,$2,$3,$4});
        $$->setLeaf(false);

        // check if array is declared
        SymbolInfo* prev = st->lookup($1->getName());
        if (prev != nullptr) {
            $$->setType(prev->getType());
            if (prev->isArray() == true) {

                //previous->setType("ARRAY,INT");
                prev->printerUtil = "Array,INT";
            } else {
                errorFilePrint(("'"+ $1->getName() + "'" + " is not an array").c_str());
            }
        } else {
            $$->setType("UNDEFINED");
            errorFilePrint(("Undeclared array '" + $1->getName() + "'").c_str());
        }

        // check if expression is INT
        if ($3->getType() != "CONST_INT") {
            if (st->lookup($3->getName()) == nullptr) {
                //cout<<"insider 1"<<" Line no: "<<lineNo<<endl;
                if ($3->getType() != "int") {
                    //cout<<"insider 2"<<" Line no: "<<lineNo<<"Type "<<$3->getType()<<endl;
                    errorFilePrint("Array subscript is not an integer");
                }
            } else {
                if (st->lookup($3->getName())->getType() != "int") {
                    //cout<<"insider 3"<<" Line no: "<<lineNo<<endl;
                    errorFilePrint("Array subscript is not an integer");
                } else {
                }
            }
        } else {
            // all is well
        }
        

        yylog(logOut, lineNo, "variable", "ID LSQUARE expression RSQUARE  \t ", $$->getName());

        //delete $1; delete $3;
    }
    ;
	 
expression : logic_expression {
        $$ = new SymbolInfo(($1->getName() ), $1->getType());
        //$$= $1;
        yylog2(logOut, lineNo, "expression \t", " logic_expression\t ", $$->getName());

        $$->dataType = "expression : logic_expression";
         $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);

    }	
    | variable ASSIGNOP logic_expression {
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), $3->getType());
        yylog2(logOut, lineNo, "expression \t", " variable ASSIGNOP logic_expression \t\t ", $$->getName());

        $$->dataType = "expression : variable ASSIGNOP logic_expression";
         $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($3->getEndTime());
        $$->setParseItems({$1,$2,$3});
        $$->setLeaf(false);

        // c++17 features - auto, tuple
        auto [success, changedSymbol] = typeCast($1->getType(), $3->getType());
        if (success) {
            // all is well
            $$->setType(changedSymbol->getType());
        } else {
            testing<<$1->getType()<<" : "<<$3->getType()<<endl;
            errorFilePrint("Warning: possible loss of data in assignment of FLOAT to INT");
            $$->setType("UNDEFINED");
        }

    }
    ;
			
logic_expression : rel_expression {
        $$ = new SymbolInfo(($1->getName()),$1->getType());
        //$$=$1;
        yylog(logOut, lineNo, "logic_expression", "rel_expression \t ", $$->getName());

        $$->dataType = "logic_expression : rel_expression";
         $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);

    } 	

    | rel_expression LOGICOP rel_expression {
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), "int");
        yylog2(logOut, lineNo, "logic_expression ", " rel_expression LOGICOP rel_expression \t \t ", $$->getName());

        $$->dataType = "logic_expression : rel_expression LOGICOP rel_expression";
         $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($3->getEndTime());
        $$->setParseItems({$1,$2,$3});
        $$->setLeaf(false);


        // check if both of them are int or not
        if (isType(1,$1->getType()) && isType(1,$3->getType())) {
            // all is well
        } else {
            //errorFilePrint("Type mismatch - LOGICOP expects int");
            $$->setType("UNDEFINED");
        }

        //delete $1; delete $2; delete $3;
    }
    ;
			
rel_expression : simple_expression {
        $$ = new SymbolInfo(($1->getName()),$1->getType());
        //$$=$1;
        yylog2(logOut, lineNo, "rel_expression\t", " simple_expression ", $$->getName());

        $$->dataType = "rel_expression : simple_expression";
         $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);

    }
    | simple_expression RELOP simple_expression	{
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), "int");
        yylog2(logOut, lineNo, "rel_expression\t", " simple_expression RELOP simple_expression\t  ", $$->getName());

        $$->dataType = "rel_expression : simple_expression RELOP simple_expression";
         $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($3->getEndTime());
        $$->setParseItems({$1,$2,$3});
        $$->setLeaf(false);


        // check if any of them are void
        if ($1->getType() == "void" || $3->getType() == "void") {
            errorFilePrint("Type mismatch - RELOP expects int");
            $$->setType("UNDEFINED");
        } else {
           // all is well
        }

       //delete $1; delete $2; delete $3;
    }
    ;
				
simple_expression : term {
        $$ = new SymbolInfo(($1->getName()),$1->getType());
       //$$=$1;
        yylog(logOut, lineNo, "simple_expression", "term ", $$->getName());

        $$->dataType = "simple_expression : term";
         $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);

    }
    | simple_expression ADDOP term {
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), $3->getType());
        yylog(logOut, lineNo, "simple_expression", "simple_expression ADDOP term  ", $$->getName());

        $$->dataType = "simple_expression : simple_expression ADDOP term";
         $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($3->getEndTime());
        $$->setParseItems({$1,$2,$3});
        $$->setLeaf(false);


        // type cast
        auto [success, changedSymbol] = implicitTypeCast($1->getType(), $3->getType());
        if (success) {
            // all is well
            $$->setType(changedSymbol->getType());
        } else {
            errorFilePrint("Type mismatch - void cannot be an operand of ADDOP");
            $$->setType("UNDEFINED");
        }

        //delete $1; delete $2; delete $3;
    }
    ;
					
term :	unary_expression {
        $$ = new SymbolInfo(($1->getName()), $1->getType());
        //$$=$1;
        yylog2(logOut, lineNo, "term ", "\tunary_expression ", $$->getName());

        $$->dataType = "term : unary_expression";
         $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);

    }
    | term MULOP unary_expression {
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), $3->getType());
        yylog2(logOut, lineNo, "term ", "\tterm MULOP unary_expression ", $$->getName());

        $$->dataType = "term : term MULOP unary_expression";
         $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($3->getEndTime());
        $$->setParseItems({$1,$2,$3});
        $$->setLeaf(false);


        // check for non-integers in modulus
        if ($2->getName() == "%") {
            if (compareVarTypes("int", $1->getType()) && compareVarTypes("int", $3->getType())) {
                // all is well
            } else {
                errorFilePrint("Operands of modulus must be integers ");
                $$->setType("UNDEFINED");
            }
        } else {
            // type cast
            auto [success, changedSymbol] = implicitTypeCast($1->getType(), $3->getType());
            if (success) {
                // all is well
                $$->setType(changedSymbol->getType());
            } else {
                errorFilePrint("Type mismatch - void cannot be an operand of MULOP");
                $$->setType("UNDEFINED");
            }
        }

        // CHECK FOR ZERO DIVISION
        if ($2->getName() == "/" || $2->getName() == "%") {
            if ($3->getType() == "CONST_INT" && $3->getName() == "0") {
                errorFilePrint("Warning: division by zero i=0f=1Const=0");
                $$->setType("UNDEFINED");
            } // how to check for expressions evaluating into 0? later
        }

    }
    ;

unary_expression : ADDOP unary_expression {
        $$ = new SymbolInfo(($1->getName() + $2->getName()), $2->getType());
        yylog(logOut, lineNo, "unary_expression", "ADDOP unary_expression  ", $$->getName());

        $$->dataType = "unary_expression : ADDOP unary_expression";
         $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($2->getEndTime());
        $$->setParseItems({$1,$2});
        $$->setLeaf(false);


        //delete $1; delete $2;
    } 
    | NOT unary_expression {
        $$ = new SymbolInfo(($1->getName() + $2->getName()), $2->getType());
        yylog2(logOut, lineNo, "unary_expression ", " NOT unary_expression  ", $$->getName());

        $$->dataType = "unary_expression : NOT unary_expression";
         $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($2->getEndTime());
        $$->setParseItems({$1,$2});
        $$->setLeaf(false);


        //elete $2;
    }
    | factor {
        $$ = new SymbolInfo(($1->getName()), $1->getType());
       //$$=$1;
        yylog(logOut, lineNo, "unary_expression", "factor ", $$->getName());

        $$->dataType = "unary_expression : factor";
         $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);

    }
    ;
	
factor : variable {
        $$ = new SymbolInfo(($1->getName()), $1->getType());
        yylog2(logOut, lineNo, "factor\t", " variable ", $$->getName());

        $$->dataType = "factor : variable";
         $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);

    }
	| ID LPAREN argument_list RPAREN {
        $$ = new SymbolInfo(($1->getName() + $2->getName()  + $3->getName() + $4->getName() ), "FUNCTION_CALL");        

        $$->dataType = "factor : ID LPAREN argument_list RPAREN";
         $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($4->getEndTime());
        $$->setParseItems({$1,$2,$3,$4});
        $$->setLeaf(false);


        // check if function is declared
        // assign the return type of function to this factor's type
        SymbolInfo* previous = st->lookup($1->getName());
        if (previous == nullptr) {
            $$->setType("UNDEFINED");
            errorFilePrint(("Undeclared function '" + $1->getName() + "'").c_str());
        } else {
            if (previous->isFunction()) {
                if (previous->getParams().size() > 0) {

                    testing<<previous->getParams().size()<<" : "<< $3->getParams().size()<<" Line no : "<<lineNo<<endl;

                    // for (int i = 1; i < previous->getParams().size(); i++) {
                            
                    //         if (compareVarTypes(previous->getParams()[i]->getType(), $3->getParams()[i-1]->getType())) {
                    //             // last iteration
                    //             if (i == (previous->getParams().size() - 1)) {
                    //                 // all is well
                    //                 calledFunctions.push_back(make_pair($1->getName(), lineNo));
                    //             }
                    //         } else {
                    //             errorFilePrint((  "Type mismatch for argument "+ to_string(i) + " of '" + $1->getName() + "'").c_str());
                    //             // according to sample log
                    //             // no need to look further if you got one mismatch
                    //             //break;
                    //         }
                    //     }

                    
                    // check if number of arguments matches
                    if ((previous->getParams().size() - 1) > $3->getParams().size()) {
                        errorFilePrint(("Too few arguments to function '" + $1->getName()+ "'").c_str());
                    } 
                    else if ((previous->getParams().size() - 1) < $3->getParams().size()) {
                        errorFilePrint(("Too many arguments to function '" + $1->getName()+ "'").c_str());
                    } 
                    else{
                        //check if types of arguments and parameters match
                        for (int i = 1; i < previous->getParams().size(); i++) {


                            if(lineNo==48){
                                    testing<<"No at line : "<<lineNo<< " , function name: "<<previous->getName()<<endl;
                                for(SymbolInfo *x : previous->params){
                                    testing<<x->getName()<<" : "<<x->getType()<<endl;
                                }

                                testing<<endl<<endl;
                                for(SymbolInfo *x : $3->params){
                                    testing<<x->getName()<<" : "<<x->getType()<<endl;
                                }

                            }
                            

                            
                            if (compareVarTypes(previous->getParams()[i]->getType(), $3->getParams()[i-1]->getType())) {
                                // last iteration
                                if (i == (previous->getParams().size() - 1)) {
                                    // all is well
                                    calledFunctions.push_back(make_pair($1->getName(), lineNo));
                                }
                            } else {
                                errorFilePrint((  "Type mismatch for argument "+ to_string(i) + " of '" + $1->getName() + "'").c_str());
     
                            }
                        }
                    }



                    // set previous's return type to it's type
                    if (previous->getReturnType()->getType() == "void") {
                        $$->setType("UNDEFINED");
                        errorFilePrint("Void cannot be used in expression ");
                    } else {
                        $$->setType(previous->getReturnType()->getType());
                    }
                } 
                
                else {
                    $$->setType("UNDEFINED");
                    errorFilePrint(("Function " + $1->getName() + " has no return type / parameters declared").c_str());
                }
            } else {
                $$->setType("UNDEFINED");
                errorFilePrint(("Type mismatch, " + $1->getName() + " is not a function").c_str());
            }
        }


        yylog2(logOut, lineNo, "factor\t", " ID LPAREN argument_list RPAREN  ", $$->getName());

    }
	| LPAREN expression RPAREN {
        $$ = new SymbolInfo(($1->getName()  + $2->getName() + $3->getName() ), $2->getType());
        yylog2(logOut, lineNo, "factor\t", " LPAREN expression RPAREN   ", $$->getName());

        $$->dataType = "factor : LPAREN expression RPAREN";
         $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($3->getEndTime());
        $$->setParseItems({$1,$2,$3});
        $$->setLeaf(false);


        //delete $2;
    }
	| CONST_INT {
        $$ = new SymbolInfo(($1->getName() ), $1->getType());
        //$$=$1;
        //cout<<$1->getType()<<endl;
        yylog2(logOut, lineNo, "factor\t", " CONST_INT   ", $$->getName());

        $$->dataType = "factor : CONST_INT";
         $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);

    }
	| CONST_FLOAT {
        $$ = new SymbolInfo(($1->getName() + "0"), $1->getType()); // just to match the samples
        yylog2(logOut, lineNo, "factor\t", " CONST_FLOAT   ", $$->getName());

        $$->dataType = "factor : CONST_FLOAT";
         $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);



    }
	| variable INCOP {
        $$ = new SymbolInfo(($1->getName() + $2->getName()), $1->getType());
        yylog2(logOut, lineNo, "factor\t", " variable INCOP   ", $$->getName());

        $$->dataType = "factor : variable INCOP";
         $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($2->getEndTime());
        $$->setParseItems({$1,$2});
        $$->setLeaf(false);


        //delete $1;
    }
	| variable DECOP {
        $$ = new SymbolInfo(($1->getName() + $2->getName()), $1->getType());
        yylog2(logOut, lineNo, "factor\t", " variable DECOP   ", $$->getName());

        $$->dataType = "factor : variable DECOP";
         $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($2->getEndTime());
        $$->setParseItems({$1,$2});
        $$->setLeaf(false);


        //delete $1;
    }
	;
	
argument_list : arguments {
        //$$=$1;
        //$$ = new SymbolInfo(($1->getName() ), $1->getType());
        $$= new SymbolInfo($1->getName() , $1->getType());
        $$->setParams($1->getParams());
        yylog(logOut, lineNo, "argument_list", "arguments  ", $$->getName());

        
        
        $$->dataType = "argument_list : arguments";
         $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);

        //$$=$1;

    }
    | {
        //$$ = new SymbolInfo($$->getName(), $$->getType());
        $$ = new SymbolInfo("", "VOID");
        yylog(logOut, lineNo, "argument_list", "", $$->getName());

        $$->dataType = "argument_list : ";
        $$->setBeginTime(lineNo);
        $$->setEndTime(lineNo);
        $$->setLeaf(false);

    }
    ;
	
arguments : arguments COMMA logic_expression {
        $$ = new SymbolInfo(($1->getName() + $2->getName()  + $3->getName()), $3->getType());
        // argument_list should have arguments in it's params vector
        for (SymbolInfo* s : $1->getParams()) {
            $$->addParam((new SymbolInfo())->copySymbol(s), lineNo, "acle");
        }
        $$->addParam((new SymbolInfo())->copySymbol($3)), lineNo;
        yylog(logOut, lineNo, "arguments", "arguments COMMA logic_expression ", $$->getName());

        $$->dataType = "arguments : arguments COMMA logic_expression";
         $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($3->getEndTime());
        $$->setParseItems({$1,$2,$3});
        $$->setLeaf(false);


        //delete $1; delete $3;
    }
    | logic_expression {
        $$ = new SymbolInfo(($1->getName() ), $1->getType());
        $$->addParam($1,lineNo,"le");
        yylog(logOut, lineNo, "arguments", "logic_expression", $$->getName());

        $$->dataType = "arguments : logic_expression";
         $$->setBeginTime($1->getBeginTime());
        $$->setEndTime($1->getEndTime());
        $$->setParseItems({$1});
        $$->setLeaf(false);

    }
    ;


%%
int main(int argc,char *argv[])
{
	if (argc < 2) {
        cout << "Specify input file" << endl;
        return 1;
    }

    logOut.open("1905093_log.txt");
    errorOut.open("1905093_error.txt");  
    parseOut.open("1905093_parseTree.txt");
    testing.open("1905093_testing.txt");

    yyin = fopen(argv[1], "r");
    if(yyin == NULL){
		cout << "Cannot open specified input file" << endl;
		return 1;
	}
    
	yyparse();      //each time we want to parse an input we call yyparse and it does the job for us
    fclose(yyin);

    //st->printLogFile(logOut);
    logOut << "Total Lines: " << lineNo << endl;
    logOut << "Total Errors: " << errorNo << endl;

    logOut.close();
    errorOut.close();
    parseOut.close();
    testing.close();
	
    delete st;

	return 0;
}

