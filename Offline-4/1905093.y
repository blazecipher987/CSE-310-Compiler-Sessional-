%{
#include <bits/stdc++.h>
#include "1905093_SymbolInfo.h"
#include "1905093_ScopeTable.h"
#include "1905093_SymbolTable.h"
#include <fstream>
using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
extern int yylineno;
SymbolInfo* check;
SymbolTable *ST = new SymbolTable(11);
string non_token = "";
SymbolInfo* returnType = new SymbolInfo("","");

vector<SymbolInfo*> varstore;
vector<SymbolInfo*> paramstore;
vector<SymbolInfo*> paramstoretemp;
vector<SymbolInfo*> argstore;

SymbolInfo* symbol;

//ICG
int notCount=0;
int relOpCount = 0;
int logicOpCount = 0;
int ifCount = -1; //will be 0 indexed
int loopCount = -1; //will be 0 indexed
int paramOffset=2;
int argOffset=0; //for refreshing arguments
int varOffset = 0;
int spVarOffset = 0;
int retVal = 0;
int isConst = 0;
string* mainCode = new string("");
string* cd2 = new string("");
string funcName;
vector<string> ifLabels;
vector<string> loopLabels;
string recursiveFuncName;
string bonusComments;

//Optimize
vector<vector<string>> strings;
vector<string> linevect;



ofstream outputToFile1("1905093_file1.txt");
ofstream outputToFile2("1905093_file2.txt");


extern ofstream couterr;
void yyerror(char *s)
{
	//NO ERROR FOR THIS OFFLINE
}


void funcClear(){
	paramstore.clear();
	paramstoretemp.clear();
}

//Optimize

void utilSplitFunc(string s, char delim, char delim2, int lineno)
{
    int i = 0;
    int indexS = 0;
    int indexE = 0;
    linevect.clear();

	for(int i=0; i <=s.length() ; i++){
			if (s[i] == delim || s[i] == delim2 || i == s.length())
        {
            indexE = i;
            string sub = "";
            sub.append(s, indexS, indexE - indexS);
            //strings.push_back();
            //strings[lineno].push_back(subStr);
            linevect.push_back(sub);
           indexS = indexE + 1;
        }
	}
    strings.push_back(linevect);
}

%}
%union{
	SymbolInfo *SI;
} 

%token <SI> IF ELSE FOR WHILE DO BREAK CONTINUE BITOP ID LPAREN RPAREN SEMICOLON COMMA LCURL RCURL DOUBLE CHAR MAIN INT FLOAT VOID LTHIRD CONST_INT CONST_CHAR RTHIRD PRINTLN RETURN ASSIGNOP LOGICOP RELOP ADDOP MULOP CONST_FLOAT NOT INCOP DECOP 

%type <SI> start program unit var_declaration func_declaration func_definition type_specifier parameter_list compound_statement statements declaration_list statement expression_statement expression variable logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments dummy_if

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : { 
	//ICG
	cout<<"Where are they!!"<<endl;
	bonusComments = (";Line: " + to_string(yylineno)+ " - start : program\n");
	outputToFile1<<bonusComments;


	mainCode = new string("");
	*mainCode += ".CODE\n";
	outputToFile1<<*mainCode;

	//Global
	bonusComments = (";Line: " + to_string(yylineno)+ " - Initializations\n");
	outputToFile2<<bonusComments;

	cd2 = new string("");
	*cd2 += ".MODEL SMALL\n";
	*cd2 += ".STACK 1000H\n";
	*cd2 += ".DATA\n\n";

	*cd2 += "CR EQU 0DH\n";	
	*cd2 += "LF EQU 0AH\n\n";	

	*cd2 += "OUTPUT_STRING DB '00000$'\n";	
	*cd2 += "PRINTNEGFLAG DW ? ; PRINTNEGFLAG\n\n";
	outputToFile2<<*cd2;


	//ICG codes
	bonusComments = (";Line: " + to_string(yylineno)+ " - func definition : println\n");
	outputToFile1<<bonusComments;

	mainCode = new string("");
		*mainCode += "println PROC\n";
		*mainCode += "PUSH BP\n";
		*mainCode += "MOV BP , SP\n";
		*mainCode += "MOV AX , [BP+4]\n";

		*mainCode+= ("MOV PRINTNEGFLAG , 0\n"); 
    	*mainCode+= ("LEA SI , OUTPUT_STRING\n");
    	*mainCode+= ("ADD SI , 5\n");
    	*mainCode+= ("CMP AX , 0\n");
    	*mainCode+= ("JGE PRINT_LOOP\n");
    	*mainCode+= ("INC PRINTNEGFLAG\n");
    	*mainCode+= ("NEG AX\n");
    
    	*mainCode+= ("PRINT_LOOP:\n");
        *mainCode+= ("DEC SI\n");
        
        *mainCode+= ("MOV DX , 0\n");
        
        *mainCode+= ("MOV CX , 10\n");
        *mainCode+= ("DIV CX\n");
        
        *mainCode+= ("ADD DL , '0'\n");
        *mainCode+= ("MOV [SI] , DL\n");
        
        *mainCode+= ("CMP AX , 0\n");
        *mainCode+= ("JNE PRINT_LOOP\n");
    
    *mainCode+= ("CMP PRINTNEGFLAG , 0\n");
    *mainCode+= ("JE PRINTNUM\n");
    *mainCode+= ("MOV DX , '-'\n");
    *mainCode+= ("MOV AH , 2\n");
    *mainCode+= ("INT 21H\n");
    
    *mainCode+= ("PRINTNUM:\n");
    *mainCode+= ("MOV DX , SI\n");
    *mainCode+= ("MOV AH , 9\n");
    *mainCode+= ("INT 21H\n");
    
	//NEWLINE
	*mainCode+= ("MOV AH , 2\n");
	*mainCode+= ("MOV DL , CR\n");
	*mainCode+= ("INT 21H\n");
	*mainCode+= ("MOV DL , LF\n");
	*mainCode+= ("INT 21H\n");
	
		*mainCode += "POP BP\n";
		*mainCode += "RET 0\n";
		*mainCode += ("println ENDP\n");
		outputToFile1<<*mainCode;

} program
	{
	
		$$ = new SymbolInfo($2->getName() + " ", non_token);

	}
	;

program : program unit 	{
		$$ = new SymbolInfo($1->getName()+ " \n" + $2->getName(), non_token);

	}
	| unit {
		$$ = new SymbolInfo($1->getName(), non_token);

	}
	;
	
unit : var_declaration	{
		$$ = new SymbolInfo($1->getName(), non_token);

	}	
    | func_declaration	{
		$$ = new SymbolInfo($1->getName(), non_token);

	}
    | func_definition	{
		$$ = new SymbolInfo($1->getName()+ "\n", non_token);

	}
    ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {

		//GET THE TYPE FROM THE TYPESPECIFIER
		symbol = new SymbolInfo($2->getName(), "ID");
		symbol->setDataType($1->getName());	
		symbol->setVarType(2);					//2 for Func Declaration

		//PUT ALL THE PARAMETERS IN THE TEMPORARTY VARIABLE PAREAM LIST AS WELL
		for(int i=0;i<paramstore.size();i++){
				symbol->addParam(paramstore[i]);
			}
		ST->InsertSymbol(symbol);
		funcClear();

		$$ = new SymbolInfo($1->getName() + " " + $2->getName() + $3->getName() + $4->getName() + $5->getName() + $6->getName() , non_token);
	}
		| type_specifier ID LPAREN RPAREN SEMICOLON							{

		symbol = new SymbolInfo($2->getName(), "ID");
		symbol->setDataType($1->getName());		
		symbol->setVarType(2);					//2 for Func Declaration

		check = ST->searchAllScope(symbol->getName());
		ST->InsertSymbol(symbol);
		paramstore.clear();

		$$ = new SymbolInfo($1->getName() + " "+ $2->getName() +$3->getName() +$4->getName() , non_token);

		funcClear();
	};

func_definition : type_specifier ID LPAREN parameter_list RPAREN 
	{
		//ICG codes
		bonusComments = (";Line: " + to_string(yylineno)+ " - func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n");
		outputToFile1<<bonusComments;


		funcName =recursiveFuncName= $2->getName();


		mainCode = new string("");
		*mainCode += funcName + " PROC\n";		//FUNCTION DECLARATION
		*mainCode += "PUSH BP\n";						//PUSHING BASE STACK POINTER
		*mainCode += "MOV BP , SP\n";					//NOW READDRESSING THE BASE POINTER TO WHERE THE STACK IS POINTING

		if(funcName == "main"){		//FOR LOADING DATA WHEN THE MAIN FUNCTION BEGINS
			*mainCode += "MOV AX , @DATA\n";
			*mainCode += "MOV DS , AX\n";
		}

		outputToFile1<<*mainCode;
		spVarOffset = varOffset;	//FIX STACK -POINTER OFFSET
		varOffset = 0;				//RESET VARIABLE OFFSET

		retVal = paramstore.size() * 2;

	}
	compound_statement {

		string funcdatatype = $1->getName(); 
		symbol = new SymbolInfo($2->getName(), "ID");
		symbol->setDataType(funcdatatype);		
		symbol->setVarType(3);					//3 FOR FUNC DEFINITION
		
		//SET ALL THE FUNCTION PARAMETERS HERE ALSO
		for(int i=0;i<paramstore.size();i++){
				symbol->addParam(paramstore[i]);
			}


		//TO SEE IF THE FUNCTION IS UNIQUE 
		if(ST->searchAllScope(symbol->getName())==nullptr){

			ST->InsertSymbol(symbol);
			returnType ->setDataType("void");
			
		}
		else{

				int fl = symbol->uniqFunc(check);
				if(fl == 0){
					ST->RemoveSymbolInfo(check);
					ST->InsertSymbol(symbol);
					
				}
				else {
					 
				}
		}

		funcClear();
		$$ = new SymbolInfo($1->getName() + " " + $2->getName() + $3->getName() + $4->getName() + $5->getName() + $7->getName() , non_token);

		//ICG CODES
		mainCode = new string("");
		*mainCode += funcName + "_exit:\n";
		*mainCode += "SUB SP , " + to_string(varOffset) + "\t\t\t\t\t;Popping local variables\n";
		*mainCode += "POP BP\n";
		*mainCode += "POP DX\n";	
		*mainCode += "PUSH CX\n";	
		*mainCode += "PUSH DX\n";	


		//IF FUNCTION IS MAIN FUNCTION
		if(funcName == "main"){
			*mainCode += "MOV AH, 4CH\n";
			*mainCode += "INT 21H\n";
		}

		*mainCode += "RET 0\n";
		*mainCode += funcName + " ENDP\n";
		if(funcName == "main"){
			*mainCode += "END MAIN\n";

		}
		outputToFile1<<*mainCode;
	}
		| type_specifier ID LPAREN RPAREN 		//A PARAMETERLESS FUNCTION
		{
			//ICG CODES
			bonusComments = (";Line: " + to_string(yylineno)+ " - func_definition : type_specifier ID LPAREN RPAREN compound_statement\n");
			outputToFile1<<bonusComments;

			funcName = $2->getName();
			recursiveFuncName = $2->getName();

			mainCode = new string("");
			*mainCode += funcName + " PROC\n";			//THE FUNCTION NAME ALONG WITH THE PROC CALL
			*mainCode += "PUSH BP\n";
			*mainCode += "MOV BP , SP\n";

			if(funcName == "main"){		//IF THIS IS THE MAIN FUNCTION THEN NO NEED TO MAKE PROC CALL AND INSTEAD LOAD DATA
				*mainCode += "MOV AX , @DATA\n";
				*mainCode += "MOV DS , AX\n";
			}


			outputToFile1<<*mainCode;
			spVarOffset = varOffset;
			varOffset = 0;

			//EACH ONE IS 2 BYTES IN SIZE
			retVal = paramstore.size() * 2;

		}
		compound_statement						{


		string funcdatatype = $1->getName();
		symbol = new SymbolInfo($2->getName(), "ID");
		symbol->setDataType(funcdatatype);		
		symbol->setVarType(3);					//3 for Func DEFINITION
		for(int i=0;i<paramstore.size();i++){
				symbol->addParam(paramstore[i]);
			}

		check = ST->searchAllScope(symbol->getName());

		if(check!=nullptr){
			//check->print();
			if(check->getVarType() == 2){
				int fl = check->uniqFunc(symbol);
				//cout<<fl<<endl<<endl;
				if(fl == 0){
					ST->RemoveSymbolInfo(check);
					ST->InsertSymbol(symbol);
					//check->print();
				}
				
			}
			else{

			}
			
		}
		else{
			if(returnType->getDataType() == symbol->getDataType() || (symbol->getDataType() == "float") && (returnType->getDataType() == "int") || (symbol->getDataType() == "void" && returnType->getDataType() == "")){
				ST->InsertSymbol(symbol);
				returnType ->setDataType("void");
			}
			else{

			
			}

		}
		// paramstore.clear();
		// paramstoretemp.clear();

		funcClear();

		$$ = new SymbolInfo($1->getName() + " " + $2->getName() + "()" + $6->getName(), non_token);

		//ICG
		mainCode = new string("");
		*mainCode += funcName + "_exit:\n";
		*mainCode += "SUB SP , " + to_string(varOffset) + "\t\t\t\t\t;Popping local variables\n";
		*mainCode += "POP BP\n";
		*mainCode += "POP DX\n";
		*mainCode += "PUSH CX\n";
		*mainCode += "PUSH DX\n";


		if(funcName == "main"){
			*mainCode += "MOV AH, 4CH\n";
			*mainCode += "INT 21H\n";
		}

		*mainCode += "RET 0\n";
		*mainCode += funcName + " ENDP\n";


		if(funcName == "main"){
			*mainCode += "END MAIN\n";

		}
		outputToFile1<<*mainCode;

	}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID		{

		symbol = new SymbolInfo($4->getName(), "ID");
		symbol->setDataType($3->getName());

		//BECAUSE THE ID HERE IS A PART OF THE PARAMETER LIST
		paramstore.push_back(symbol);
		paramstoretemp.push_back(symbol);

		$$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName() + " " + $4->getName(), non_token);

	}
		| parameter_list COMMA type_specifier					{

		symbol = new SymbolInfo(" ", non_token);
		symbol->setDataType($3->getName());

		paramstore.push_back(symbol);
		paramstoretemp.push_back(symbol);


		$$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName(), non_token);

	}
 		| type_specifier ID										{
		
		symbol = new SymbolInfo($2->getName(), "ID");
		symbol->setDataType($1->getName());

		paramstore.push_back(symbol);
		paramstoretemp.push_back(symbol);

		$$ = new SymbolInfo($1->getName() + " " + $2->getName(), non_token);

	}
		| type_specifier										{
		
		symbol = new SymbolInfo(" ", non_token);
		symbol->setDataType($1->getName());

		paramstore.push_back(symbol);
		paramstoretemp.push_back(symbol);

		$$ = new SymbolInfo($1->getName(), non_token);

	}				
 		;

 		
compound_statement : LCURL makescope statements RCURL		{
			$$ = new SymbolInfo($1->getName()+  "\n" + $3->getName() + "\n" + $4->getName(), non_token);

			//ST->printAll2(coutf2);
			ST->deleteScope();
		}
 		    | LCURL RCURL						{
			$$ = new SymbolInfo( "\n{\n}", non_token);
			ST->enterScope();
			ST->deleteScope();

		}	

 		    ;
makescope : {
							ST->enterScope();
							//ENTER ALL THE VARIABLES IN THE CURRENT SCOPE STACK
							paramOffset = 2;								//POINTER VARIABLE 2 BYTES

							for(int i = paramstoretemp.size()-1; i>=0 ; i--){
								paramOffset+=2;								
								paramstoretemp[i]->setStackPos(paramOffset);		//SETTING THE STACK POSITION FOR EACH OF THE VARIABLES THAT ARTE IN THE CURRENT SCOPE
								symbol = new SymbolInfo(*(paramstoretemp[i]));
								ST->InsertSymbol(symbol);
							}

							paramstoretemp.clear();
						
			}   
var_declaration : type_specifier declaration_list SEMICOLON	{
		$$ = new SymbolInfo($1->getName() + " " + $2->getName() + $3->getName(), non_token);
		

	int varDecSPSub = 0;
		if(ST->getCurrID()=="1"){
			bonusComments = (";Line: " + to_string(yylineno)+ " - var_declaration : type_specifier declaration_list SEMICOLON (Gloabl)\n");
		}
		else{
			bonusComments = (";Line: " + to_string(yylineno)+ " - var_declaration : type_specifier declaration_list SEMICOLON (Local)\n");
		}
		outputToFile1<<bonusComments;

		for(int i=0;i<varstore.size();i++){
			symbol = new SymbolInfo(*varstore[i]);
			symbol->setDataType($1->getName());
	

			int flag1 = 0, flag2 = 0;
		
				//ICG codes
				if(ST->getCurrID() != "1"){
					
					//LOCAL
					if(symbol->getSize()>0) {
						varOffset -= (2*symbol->getSize());
						varDecSPSub += 2*symbol->getSize();
				
					}
					else{
						//ICGOptimize
						varDecSPSub += 2;
						varOffset-=2;

					}
					symbol->setStackPos(varOffset);
					ST->RemoveSymbolInfo(symbol);
					ST->InsertSymbol(symbol);

				}
				else{
					//GLOBAL
					varOffset = 0;
					symbol->setGlobal();

					if(symbol->getSize()>0) {
						cd2 = new string("");
						*cd2 += (symbol->getName() + " DW " + to_string(symbol->getSize()) + " DUP (0000H) \n");
						outputToFile2<<*cd2;
					}
					else{
						cd2 = new string("");
						*cd2 += (symbol->getName() + " DW " + to_string(symbol->getSize() + 1) + " DUP (0000H) \n");
						outputToFile2<<*cd2;
					}


					
				}
				ST->InsertSymbol(symbol);
			
			
		}
	//this means the thing which is
	//it takes the base pointer to the topper part where it should be originallty placed
		if(varDecSPSub>0){
			mainCode = new string("");
			*mainCode += ("SUB  SP , " + to_string(varDecSPSub)+ "\t\t\t\t\t\t;declaring variables  \n");
			outputToFile1<<*mainCode;
		}
		varstore.clear();

	}	
 		 ;
 		 
type_specifier	: INT 	{
		$$ = new SymbolInfo("int", "");

	}
 		| FLOAT			{
		$$ = new SymbolInfo("float", "");

	}
 		| VOID			{
		$$ = new SymbolInfo("void", "");

	};
 		
declaration_list : declaration_list COMMA ID{
		symbol = new SymbolInfo($3->getName(), $3->getType());
		symbol->setVarType(0);
		//PUSHING IT IN THE VECTORLIST SINCE IT IS VARIABLE
		varstore.push_back(symbol);

		//MAKING A NEW SYMBOLINFO
		$$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName(), non_token);

	}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD	{
			symbol = new SymbolInfo($3->getName(), $3->getType());
			symbol->setVarType(1);
			//TAKE THE VALUE OF THE CONST INT AND SET IT TO THE SYMBOL VALUE
			string szstr = $5->getName();
			symbol->setSize(stoi(szstr));
			//AGAIN PUSH I INTO THE VECTOR
			varstore.push_back(symbol);

		//MAKING A NEW SYMBOLINFO VARIABLE
		$$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName() + $4->getName() + $5->getName() + $6->getName(), non_token);

	}
 		  | ID{

			//MAKE A TEMPORARTY VARIBALE OF TYPE S.I.
			symbol = new SymbolInfo($1->getName(), $1->getType());
			symbol->setVarType(0);	//0 FOR ID TYPES

			//PUSH THE VALUE INTO THE VECTOR
			varstore.push_back(symbol);
			//MAKE A NEW SYMBOLINFO POINTER
			$$ = new SymbolInfo($1->getName(), "");

			
			
	}
 		  | ID LTHIRD CONST_INT RTHIRD{

			//THIS INDICATES THE ARRAY TYPE VARIABLES
			//NMAKE A TEMPORARTY VARIABLE OF S.I.
			symbol = new SymbolInfo($1->getName(), $1->getType());
			symbol->setVarType(1);//SET 1 FOR ARRAY TYPE VARIABLES
			symbol->setSize(stoi($3->getName()));
			//PUSH THE SYMBOL INTO THE VECTOR
			varstore.push_back(symbol);

			//MAKE A NEW SYMBOLINFO TYPE POINTER
			$$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName() + $4->getName(), non_token);

	};
 		  
statements : statement 	{
		$$ = new SymbolInfo($1->getName(), "");

	}
	   | statements statement{
		$$ = new SymbolInfo($1->getName() + " \n" + $2->getName() , "");

	};

//EXTRA STEPS FOR ICG
dummy_if : IF LPAREN expression RPAREN {
		
		bonusComments = (";Line: " + to_string(yylineno)+ " - IF LPAREN expression RPAREN statement\n");
		outputToFile1<<bonusComments;

		//STORE THE LABELS IN THE VECTOR FOR FUTURE USE
		ifLabels.push_back(to_string(ifCount++));

		mainCode = new string("");

		//WRITE THE IC FOR IF CONDITIONALS
		*mainCode += "POP CX\t\t\t\t\t\t;loading condition into CX\n";
		*mainCode += "JCXZ if_false" + ifLabels.back() + " \n";
		outputToFile1<<*mainCode;
}
statement
{
		//MAKE A NEW TEMPORARTY SYMBOLINFO POINTER
		$$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName() + $4->getName() +  "\n" + $6->getName() + "\n" , non_token);
		mainCode = new string("");

		//IC FOR STATEMENT
		*mainCode += "JMP if_end" + ifLabels.back() +" \n";
		*mainCode += "if_false" + ifLabels.back() + ": \n";
		outputToFile1<<*mainCode;
}

statement : var_declaration																	{
		$$ = new SymbolInfo($1->getName() , "");

	}
	  | expression_statement																{
		$$ = new SymbolInfo($1->getName() , "");

	}																						
	  | compound_statement																	{
		$$ = new SymbolInfo($1->getName() , "");

	}
	  | FOR {
		//INCREASE THE LOOP COUNT EACH TIME IT IS ENCOUNTERED
		loopCount++;	//WILL HELP WITH LABEL GENERARTION
		loopLabels.push_back(to_string(loopCount));
		bonusComments = (";Line: " + to_string(yylineno)+ " - statement : FOR LPAREN expression_statement expression RPAREN statement\n");

		outputToFile1<<bonusComments;
	  }
	  LPAREN expression_statement {
		mainCode = new string("");
		*mainCode += "loop" + loopLabels.back() + ": \n";	//PREVIOUS LOOPCOUNT IS USED HERE FOR LABEL PURPOSES
		outputToFile1<<*mainCode;
	  }
	  expression_statement {
		mainCode = new string("");
		//LOOPLABEL US USED AGAIN AS THE INTEGER FOR DIFFERENTIATION BETWEEN DIFFERENT LOOPS
		*mainCode += "JCXZ loop_end" + loopLabels.back() + "\n";
		*mainCode += "JMP loop_stmt" + loopLabels.back() + "\n";
		*mainCode += "loop_mid" + loopLabels.back() + ": \n";
		outputToFile1<<*mainCode;
	  }
	  expression RPAREN {
		mainCode = new string("");

		//POP CX AS WE HAVE REACHED THE END OF THE BLOCK FOR LOOP
		*mainCode += "POP CX\n";
		*mainCode += "JMP loop" + loopLabels.back() + "\n";
		*mainCode += "loop_stmt" + loopLabels.back() + ":\n";
		outputToFile1<<*mainCode;
	  }
	  statement	{
		$$ = new SymbolInfo("for(" + $4->getName() + $6->getName() + $8->getName() + ")\n" + $11->getName()  , non_token);


		mainCode = new string("");
		*mainCode += "JMP loop_mid" + loopLabels.back() + "\n";
		*mainCode += "loop_end" + loopLabels.back() + ":\n";
		outputToFile1<<*mainCode;
		loopLabels.pop_back();
	}
	  | dummy_if %prec LOWER_THAN_ELSE												{
		$$ = new SymbolInfo($1->getName() , non_token);


		//ICG
		mainCode = new string("");
		//GENERATE THE IF LABEL USING THE IF COUNT FOR UNIQUE LABELING
		*mainCode += "if_end" + ifLabels.back() + ": \n";
		outputToFile1<<*mainCode;
		ifLabels.pop_back();	//POP LABEL WHEN IT HAS BEEN DONE
	}
	  | dummy_if ELSE statement								{
		$$ = new SymbolInfo($1->getName() + "\n" + $2->getName() + "\n" + $3->getName() , non_token);


		//ICG
		mainCode = new string("");
		//GENERATE THE IF LABEL USING THE IF COUNT FOR UNIQUE LABELING
		*mainCode += "if_end" + ifLabels.back() + ": \n";
		outputToFile1<<*mainCode;
		ifLabels.pop_back();//POP LABEL WHEN IT HAS BEEN DONE

	}
	  | WHILE {
		//ICG
		bonusComments = (";Line: " + to_string(yylineno)+ " - WHILE LPAREN expression RPAREN statement\n");
		outputToFile1<<bonusComments;

		loopCount++;	//INCREMENT FOR UNIQYUE LOOP LABELS EACH TIME IN IC
		loopLabels.push_back(to_string(loopCount));		//KEEP TRACK OF IT BY STORING THE LABEL IN THE VECTOR
		mainCode = new string("");

		//GENERATE THE CODE
		*mainCode += "loop" + loopLabels.back() + ": \n";
		outputToFile1<<*mainCode;
	  }
	  LPAREN expression RPAREN	{
		//ICG
		mainCode = new string("");

		//POP CX FOR IC 
		*mainCode += "POP CX\t\t\t\t\t\t;Checking loop Condition \n";
		//RUN UNTIL THE LOOP CONDITION HAS BEEN MET WHICH COMES FROM THE PREVIOUS RULES
		*mainCode += "JCXZ loop_end" + loopLabels.back() + "\n";
		outputToFile1<<*mainCode;
		
	  } 
	  statement	{
		$$ = new SymbolInfo("while(" + $3->getName() + ")\n" + $7->getName(), non_token);


		mainCode = new string("");
		*mainCode += "JMP loop" + loopLabels.back() + "\n";
		*mainCode += "loop_end" + loopLabels.back() + ":\n";
		outputToFile1<<*mainCode;
		loopLabels.pop_back();

	}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON{
		bonusComments = (";Line: " + to_string(yylineno)+ " - PRINTLN LPAREN ID RPAREN SEMICOLON\n");
		outputToFile1<<bonusComments;

		//SEACHING ALL THE SCOPES
		symbol = ST->searchAllScope($3->getName());
		
		//MAKE A NEW SYMBOLINFO WITH THE RULE
		$$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName() + $4->getName() + $5->getName() +  "\n", non_token);



		//ICG
		 mainCode = new string("");
		
			if(symbol->getGlobal() != 1){		//IF IT IS NOT THE GLOBAL SCOPETABLE

				*mainCode += ("PUSH [BP+" + to_string(symbol->getStackPos()) + "]\t\t\t\t;pushing variable "+ symbol->getName() +"\n") ;
				//PUSHIONG THE LOCAL VARIABLES
			}
			else{		//IF IT IS THE GLOBAL SCOPETABLE
				*mainCode += ("PUSH " + symbol->getName() + "\t\t\t\t\t\t;pushing global variable "+ symbol->getName() +"\n") ;
				//PUSHING THE GLOABL VARIBALES
			}


		 *mainCode += "CALL println\n";
		 *mainCode += "ADD SP , 2\t\t\t\t\t;removing args\n";
		 outputToFile1<<*mainCode;


	}
	  | RETURN expression SEMICOLON															{
		$$ = new SymbolInfo("return " + $2->getName() + ";", non_token);

		returnType ->setDataType($2->getDataType());

		//ICG
		bonusComments = (";Line: " + to_string(yylineno)+ " - RETURN expression SEMICOLON\n");
		outputToFile1<<bonusComments;

		mainCode = new string("");
		*mainCode += "POP CX\t\t\t\t\t\t;Saving return value for stack push\n";
		*mainCode += "JMP " + funcName + "_exit\n";
		outputToFile1<<*mainCode;
	}
	  ;
	  
expression_statement 	: SEMICOLON		{
		$$ = new SymbolInfo(";", non_token);

	}			
			| expression SEMICOLON 		{
		$$ = new SymbolInfo($1->getName() + ";", non_token);
		$$->setDataType($1->getDataType());

		//ICG
		mainCode = new string("");
		*mainCode += "POP CX\t\t\t\t\t\t;Extra pop after final expression\n";
		outputToFile1<<*mainCode;
	}
			;
	  
variable : ID 							{
	$$ = new SymbolInfo($1->getName(), non_token);
		symbol = ST->searchCurrScope($1->getName());
		SymbolInfo* tempSI3 = ST->searchAllScope($1->getName());
		//symbol->print();
		if(symbol == nullptr){
			if(tempSI3 != nullptr){
				if(tempSI3->getVarType() == 0){

					$$=new SymbolInfo(*tempSI3);

				}
				else{
				}
			}
			else{
			}
			
		}
		else{

			$$=new SymbolInfo(*symbol);

		}

		
		isConst++;

	}
	 | ID LTHIRD expression RTHIRD 		{

		$$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName() + $4->getName(), non_token);
		SymbolInfo* tempSI3 = ST->searchAllScope($1->getName());
		symbol = ST->searchCurrScope($1->getName());
		if(symbol == nullptr){
			//  
			if(tempSI3 != nullptr && (tempSI3->getVarType() == 1)){
					$$=new SymbolInfo(*tempSI3);
			}
			else{

			}
		}
		else{

			$$=new SymbolInfo(*symbol);
		}

	}
	 ;
	 
expression : logic_expression					{
		$$ = new SymbolInfo($1->getName(), non_token);
		$$->setDataType($1->getDataType());
		$$->setVarType($1->getVarType());

	}
	   | variable ASSIGNOP logic_expression 	{
		$$ = new SymbolInfo($1->getName() +  $2->getName() + $3->getName(), non_token);

		$$->setVarType(0);
		if(($1->getDataType()=="void"||$3->getDataType()=="void") || ($1->getDataType()== $3->getDataType())){
			$$->setDataType($1->getDataType());
		}

		else if (($1->getDataType()== "float" && $3->getDataType() == "int") || ($1->getDataType()== "int" && $3->getDataType() == "float") ){
			$$->setDataType("float");
		}


		isConst++;

		mainCode = new string("");
		*mainCode += ("POP CX \t\t\t\t\t\t;popping logic_expn val from RHS\n");

		if($1->getGlobal()==1){//GLOBAL
			if($1->getSize()>0){//PARTIAL
					*mainCode += ("POP AX\t\t\t\t\t\t;assign to array "+ $1->getName() +", AX has index\n"); //
					*mainCode += ("XCHG AX , CX\t\t\t; swap so that CX has index and AX has RHS value\n");
					*mainCode += ("SAL CX , 1\t\t\t\t\t\t;*2 since per index , 2 bytes\n");
					*mainCode += ("MOV BX , CX\n");
					*mainCode += ("MOV PTR WORD " + $1->getName() +"[BX] , AX\n");
					*mainCode += ("MOV CX , AX\t\t\t\t\t\t;then push CX to ensure optimization\n");
			}
			else{
				*mainCode += ("MOV " + ($1->getName()) + ", CX \t\t\t;assigning value to global " + $1->getName() + "\n");
			}
		}
		else{//LOCAL
			if($1->getSize()>0){
					*mainCode += ("POP AX\t\t\t\t\t\t;assign to array "+ $1->getName() +", AX has index\n"); //
					*mainCode += ("XCHG AX , CX\t\t\t; swap so that CX has index and AX has RHS value\n");
					*mainCode += ("PUSH BP\t\t\t\t\t\t;need to change and reference BP, [BP+CX] cannot be dereferenced \n");
					*mainCode += ("SAL CX , 1\t\t\t\t\t\t;*2 since per index , 2 bytes\n");
					*mainCode += ("ADD CX , " +to_string( $1->getStackPos()) +"\t\t\t\t;access correct byte by adding offset\n");
					*mainCode += ("ADD BP , CX\t\t\t\t;Change BP to point to correct array elem \n");
					*mainCode += ("MOV PTR WORD [BP], AX\t\t;save value at place pointed to by BP\n");
					*mainCode += ("POP BP\t\t\t\t\t\t;restore old BP for pointer\n");
					*mainCode += ("MOV CX , AX\t\t\t\t\t\t;then push CX to ensure optimization\n");
			}
			else{
				*mainCode += ("MOV [BP+" + to_string($1->getStackPos()) + "], CX \t\t\t;assigning value to " + $1->getName() + "\n");
			}
		}
		*mainCode += ("PUSH CX\t\t\t\t\t\t;store value in stack, for further use\n");
		outputToFile1<<*mainCode;

	}
	   ;
			
logic_expression : rel_expression 					{
		$$ = new SymbolInfo($1->getName() , non_token);
		$$->setDataType($1->getDataType());
		$$->setVarType($1->getVarType());

	}
		 | rel_expression LOGICOP rel_expression 	{
		$$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName(), non_token);
		$$->setVarType(0);
		if($1->getDataType()=="void"||$3->getDataType()=="void"){
			$$->setDataType("void");
		}
		else{
			$$->setDataType("int");
		}

		string e = "LOGICOP_end" + to_string(logicOpCount);
		logicOpCount++;

		if($2->getName() == "&&"){
			//IGC
			isConst++;
			mainCode = new string("");
			*mainCode += "POP CX\t\t\t\t\t\t;starting &&\n";
			*mainCode += "POP AX\n";
			*mainCode += "JCXZ "+ e + "\n";
			*mainCode += "MOV CX , AX\n";
			*mainCode +=  e + ":\n";
			*mainCode += "PUSH CX\t\t\t\t\t\t;ending &&\n";
			outputToFile1<<*mainCode;
		}
		if($2->getName() == "||"){
			//ICG
			bonusComments = ";";
			bonusComments += ("Line: " + to_string(yylineno)+ " - ");
			bonusComments += "logic_expression : rel_expression LOGICOP rel_expression";
			bonusComments += "\n";
			outputToFile1<<bonusComments;

			isConst++;
			mainCode = new string("");
			*mainCode += "POP CX\t\t\t\t\t\t;starting ||\n";
			*mainCode += "POP AX\n"; 
			*mainCode += "CMP AX , 0\n";
			*mainCode += "JE "+ e + "\n"; //If AX ==0, out = CX; else out = AX = 1;
			*mainCode += "MOV CX , AX\n";
			*mainCode +=  e + ":\n";
			*mainCode += "PUSH CX\t\t\t\t\t\t;ending ||\n";
			outputToFile1<<*mainCode;
		}
		isConst++;
	}
		 ;
			
rel_expression	: simple_expression 				{
		$$ = new SymbolInfo($1->getName() , non_token);
		$$->setDataType($1->getDataType());
		$$->setVarType($1->getVarType());
		
	}
		| simple_expression RELOP simple_expression	{
		$$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName(), non_token);
		$$->setVarType(0);
		if($1->getDataType()=="void"||$3->getDataType()=="void"){
			$$->setDataType("void");
		}
		else{
			$$->setDataType("int");
		}

		string e = "RELOP_end" + to_string(relOpCount);
		relOpCount++;

		
		string relop;
		if($2->getName() == "<="){
			relop = "JLE";
			//$$->setVal(to_string(stoi($1->getVal())<=stoi($3->getVal())));
		}
		if($2->getName() == ">="){
			relop = "JGE";
			//$$->setVal(to_string(stoi($1->getVal())>=stoi($3->getVal())));
		}
		if($2->getName() == "=="){
			relop = "JE";
			//$$->setVal(to_string(stoi($1->getVal())==stoi($3->getVal())));
		}
		if($2->getName() == "!="){
			relop = "JNE";
			//$$->setVal(to_string(stoi($1->getVal())!=stoi($3->getVal())));
		}
		if($2->getName() == ">"){
			relop = "JG";
			//$$->setVal(to_string(stoi($1->getVal())>stoi($3->getVal())));
		}
		if($2->getName() == "<"){
			relop = "JL";
			//$$->setVal(to_string(stoi($1->getVal())<stoi($3->getVal())));
		}
		
		//IGC

		isConst++;
		mainCode = new string("");
		*mainCode += "POP CX\t\t\t\t\t\t;starting "+ relop +"\n";
		*mainCode += "POP AX\n";
		*mainCode += "CMP AX , CX\n";
		*mainCode += "MOV CX , 1\n";
		*mainCode += relop + " " + e + "\n" ;
		*mainCode += "MOV CX , 0\n" ;
		*mainCode +=  e + ":\n";
		*mainCode += "PUSH CX\t\t\t\t\t\t;ending "+ relop +"\n";
		outputToFile1<<*mainCode;
		//$$->print();
	}
		;
				
simple_expression : term 					{
		$$ = new SymbolInfo($1->getName() , non_token);
		$$->setDataType($1->getDataType());
		$$->setVarType($1->getVarType());

	}
		  | simple_expression ADDOP term 	{
		$$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName(), non_token);
		$$->setVarType(0);
		if($1->getDataType()=="void"||$3->getDataType()=="void"){
			$$->setDataType("void");
		}
		else if($1->getDataType()=="float"||$3->getDataType()=="float"){
			$$->setDataType("float");
		}
		else{
			$$->setDataType("int");
		}
		bonusComments = (";Line: " + to_string(yylineno)+ " - simple_expression : simple_expression ADDOP termn\n");
		outputToFile1<<bonusComments;

		if($2->getName() == "+"){		//FOR ADDITION
			//ICG
			mainCode = new string("");
			*mainCode += ("POP CX\t\t\t\t\t\t;starting +\n");
			*mainCode += ("POP AX\n");
			*mainCode += ("ADD CX , AX\n");
			*mainCode += ("PUSH CX\t\t\t\t\t\t;ending +\n");
			outputToFile1<<*mainCode;		}

		if($2->getName() == "-"){		//FOR SUBSTRACTION
			mainCode = new string("");
			*mainCode += ("POP CX\t\t\t\t\t\t;starting -\n");
			*mainCode += ("POP AX\n");
			*mainCode += ("SUB AX , CX\n");
			*mainCode += ("MOV CX , AX\n");
			*mainCode += ("PUSH CX\t\t\t\t\t\t;ending -\n");
			outputToFile1<<*mainCode;
		}
		isConst++;
	};
					
term :	unary_expression				{
		$$ = new SymbolInfo($1->getName() , non_token);
		$$->setDataType($1->getDataType());
		$$->setVarType($1->getVarType());

	}
     |  term MULOP unary_expression		{
		$$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName(), non_token);
		$$->setVarType(0);
		if($1->getDataType()=="void"||$3->getDataType()=="void"){
			$$->setDataType("void");
		}
		else if($1->getDataType()=="float"||$3->getDataType()=="float"){	
			$$->setDataType("float");
			if($2->getName()=="%"){
				$$->setDataType(" ");
			}
		}
		else{
			$$->setDataType("int");
		}
		bonusComments = (";Line: " + to_string(yylineno)+ " - term : term MULOP unary_expression\n");
		outputToFile1<<bonusComments;
 
		if($2->getName()=="%"){
			if(stoi($3->getName())==0){
				$$->setDataType(" ");
			}
			else{
				//ICG
				mainCode = new string("");
				*mainCode += ("POP CX\t\t\t\t\t\t;starting %\n");
				*mainCode += ("POP AX\n");
				*mainCode += ("CWD\n");
				*mainCode += ("IDIV CX\n");
				*mainCode += ("PUSH DX\t\t\t\t\t\t;ending %\n");
				outputToFile1<<*mainCode;
			}
		}
		

		if($2->getName()=="/"){
			if(stoi($3->getName())==0){
				$$->setDataType(" ");
			}
			else{
				//ICG
				mainCode = new string("");
				*mainCode += ("POP CX\t\t\t\t\t\t;starting /\n");
				*mainCode += ("POP AX\n");
				*mainCode += ("CWD\n");
				*mainCode += ("IDIV CX\n");
				*mainCode += ("PUSH AX\t\t\t\t\t\t;ending /\n");
				outputToFile1<<*mainCode;
			}
		}
		if($2->getName()=="*"){
			//ICG
			mainCode = new string("");
			*mainCode += ("POP CX\t\t\t\t\t\t;starting *\n");
			*mainCode += ("POP AX\n");
			*mainCode += ("IMUL CX\n");
			*mainCode += ("PUSH AX\t\t\t\t\t\t;ending *\n");
			outputToFile1<<*mainCode;
		}
		isConst++;

	}
     ;

unary_expression : ADDOP unary_expression  	{
		$$ = new SymbolInfo($1->getName() + $2->getName(), non_token);
		$$->setDataType($2->getDataType());
		$$->setVarType(0);

		//ICG
		bonusComments = (";Line: " + to_string(yylineno)+ " - unary_expression : ADDOP unary_expression\n");
		outputToFile1<<bonusComments;

		mainCode = new string("");
		if($1->getName() == "-"){

			mainCode = new string("");
			*mainCode += ("POP CX\t\t\t\t\t\t;negating\n");
			*mainCode += ("NEG CX\n");
			*mainCode += ("PUSH CX\n");
			outputToFile1<<*mainCode;
		}
		else{
			//$$->setVal($2->getVal());
		}

		//$$->print();
	}
		 | NOT unary_expression 			{
		$$ = new SymbolInfo("!" + $2->getName(), non_token);
		$$->setDataType($2->getDataType());
		$$->setVarType(0);

		//ICG
		bonusComments = (";Line: " + to_string(yylineno)+ " - unary_expression : NOT unary_expression\n");
		outputToFile1<<bonusComments;

		string z = "NOT_Zero" + to_string(notCount);
		string e = "NOT_end" + to_string(notCount);
		notCount++;

		mainCode = new string("");
		*mainCode += "POP CX\t\t\t\t\t\t		;starting NOT\n";
		*mainCode += "JCXZ " + z + "\n";
		*mainCode += "MOV CX , 0\n" ;
		*mainCode += "JMP " + e + "\n";
		*mainCode +=  z + ":\n";
		*mainCode += "MOV CX , 1\n" ;
		*mainCode +=  e + ":\n";
		*mainCode += "PUSH CX\t\t\t\t\t\t;	ending NOT\n";
		outputToFile1<<*mainCode;

	}
		 | factor 							{
		$$ = new SymbolInfo($1->getName(), non_token);
		$$->setDataType($1->getDataType());
		$$->setVarType($1->getVarType());
	}
		 ;
	
factor	: variable 						{


		$$ = new SymbolInfo(*((SymbolInfo*)$1));
		
		//IGC
		mainCode = new string();
		//if($$->getName() == $$->getVal()){
		if($1->getGlobal() == 1){
			if($1->getSize()>0){ //for array
			//PARTIAL
				*mainCode += ("POP CX\t\t\t;pushing array "+ $1->getName() +", CX has index\n"); 
				*mainCode += ("SAL CX , 1\t\t\t\t\t\t;*2 since per index , 2 bytes\n");
				*mainCode += ("MOV BX , CX\n");
				*mainCode += ("MOV CX , PTR WORD " + $1->getName() + "[BX]\t\t\t;load global array element\n");
				*mainCode += ("PUSH CX\t\t\t\t\t\t;store value in stack\n");
				
			}
			else{		
				*mainCode += ("PUSH " + $$->getName() + "\t\t\t\t\t\t;pushing global variable "+ $$->getName() +"\n") ;
			}
			
		}
		else{
			if($1->getSize()>0){ //for array
				*mainCode += ("POP CX\t\t\t;pushing array "+ $1->getName() +", CX has index\n"); //
				*mainCode += ("PUSH BP\t\t\t\t\t\t;need to change and reference BP, [BP+CX] cannot be dereferenced \n");
				*mainCode += ("SAL CX , 1\t\t\t\t\t\t;*2 since per index , 2 bytes\n");
				*mainCode += ("ADD CX , " +to_string( $1->getStackPos()) +"\t\t\t\t;access correct byte by adding offset\n");
				*mainCode += ("ADD BP , CX\t\t\t\t;Change BP to point to correct array elem \n");
				*mainCode += ("MOV CX , PTR WORD [BP]\t\t;load value pointed to by BP\n");
				*mainCode += ("POP BP\t\t\t\t\t\t;restore old BP for pointer\n");
				*mainCode += ("PUSH CX\t\t\t\t\t\t;store value in stack\n");
				
			}
			else{		
				*mainCode += ("PUSH [BP+" + to_string($$->getStackPos()) + "]\t\t\t\t;pushing variable "+ $$->getName() +"\n") ;
			}
		}
		outputToFile1<<*mainCode;
		isConst++;
	}
	| ID LPAREN argument_list RPAREN	{
		$$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName() + $4->getName(), non_token);

		int fl = 0;
		symbol = ST->searchAllScope($1->getName());

		if(symbol == nullptr){
			if( recursiveFuncName == $1->getName()){
				goto recurFuncLabel;
			}
			fl++;
			$$->setDataType(" ");
		}
		else if(symbol->getVarType() == 3 || symbol->getName() == recursiveFuncName){
			if((symbol ->functionParams.size() == 0 && argstore.size() == 1 && (argstore[0]->getDataType() == "void" || argstore[0]->getDataType() == "VOID")) || (argstore.size() == 0 && symbol->functionParams.size() == 1 && (symbol ->functionParams[0]->getDataType() == "void" || symbol ->functionParams[0]->getDataType() == "VOID"))){
            	fl=0;
        	}
			else{
			
			}


			if(fl==0){
				$$->setDataType(symbol->getDataType());
				$$->setVarType(symbol->getVarType());
				$$->setSize(symbol->getSize());

				//MAP ALL THE FUNCTION PARAMETERS
				for(int i=0;i<$1->functionParams.size();i++){
					$$->functionParams[i] = $1->functionParams[i];
				}

			}
			else{
				$$->setDataType(" ");
			}
		}
		else{
			$$->setDataType(" ");
		}
		isConst++;

		//ICG

		recurFuncLabel:					//FOR RECURSTION PURPOSES
		 mainCode = new string("");
		 *mainCode += "CALL " + $1->getName() + "\n";
		 *mainCode += "POP CX\n";
		 *mainCode += "ADD SP , " + to_string(argstore.size()*2)+ "\t\t\t\t\t;removing args\n";
		 *mainCode += "PUSH CX\n";
		 outputToFile1<<*mainCode;
		argstore.clear();
	}
	| LPAREN expression RPAREN			{
		$$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName(), non_token);

		$$->setDataType($2->getDataType());
		$$->setVarType($2->getVarType());

	}
	| CONST_INT 						{
		symbol = new SymbolInfo($1->getName(),$1->getType());
		symbol->setDataType("int");
		$$ = new SymbolInfo($1->getName(), non_token);
		$$->setDataType("int");

		isConst = 0;
		//IGC
		string temp = to_string(stoi($1->getVal()));
		$$->setVal(temp);
		mainCode = new string();
		*mainCode += ("PUSH " + ($$->getVal()) + "\t\t\t\t\t\t;pushing constant\n");
		outputToFile1<<*mainCode;
	}
	| CONST_FLOAT						{
		symbol = new SymbolInfo($1->getName(),$1->getType());
		symbol->setDataType("float");
		$$ = new SymbolInfo($1->getName(), non_token);
		$$->setDataType("float");
		
	}
	| variable INCOP{		//INCREMENT OPERATION
		mainCode = new string("");
		$$ = new SymbolInfo($1->getName() + "++", non_token);
		$$->setDataType($1->getDataType());
		$$->setVarType($1->getVarType());

		
		//INCREMENTING FOR ARRAY VARIABLES
		if($1->getSize()>0){
			*mainCode += ("POP CX\t\t\t\t;incrementing array "+ $1->getName() +", CX has index\n"); //
			*mainCode += ("PUSH BP\t\t\t\t\t\t;need to change and reference BP, [BP+CX] cannot be dereferenced \n");
			*mainCode += ("SAL CX , 1\t\t\t\t\t\t;*2 since per index , 2 bytes\n");
			*mainCode += ("ADD CX , " +to_string( $1->getStackPos()) +"\t\t\t\t;access correct byte by adding offset\n");
			*mainCode += ("ADD BP , CX\t\t\t\t;Change BP to point to correct array elem \n");
			*mainCode += ("MOV CX , PTR WORD [BP]\t\t;load value pointed to by BP\n");
			*mainCode += ("MOV AX , CX\n");
			*mainCode += ("ADD AX , 1\n");
			*mainCode += ("MOV PTR WORD [BP] , AX\t\t;load value pointed to by BP\n");
			*mainCode += ("POP BP\t\t\t\t\t\t;restore old BP for pointer\n");
			*mainCode += ("PUSH CX\t\t\t\t\t\t;store value in stack\n");
		}
		//INCREMENTING FOR REGULAR VARIABLES
		else{
		
			*mainCode += ("MOV CX , [BP+" + to_string($1->getStackPos()) + "]\t\t\t;IncOp for Variable\n");
			*mainCode += ("MOV AX , CX\n");
			*mainCode += ("ADD AX , 1\n");
			*mainCode += ("MOV [BP+" + to_string($1->getStackPos()) + "] , AX\t\t\t;IncOp for Variable\n");
			*mainCode += ("PUSH CX\n");

		}
		outputToFile1<<*mainCode;
		isConst++;
	}
	| variable DECOP{		//DECREMENT OPERATION
		$$ = new SymbolInfo($1->getName() + "--", non_token);
		$$->setDataType($1->getDataType());
		$$->setVarType($1->getVarType());

		mainCode = new string("");

		//ARRAY VARIABLES DECREMENT
		if($1->getSize()>0){
			*mainCode += ("POP CX\t\t\t\t;incrementing array "+ $1->getName() +", CX has index\n"); //
			*mainCode += ("PUSH BP\t\t\t\t\t\t;need to change and reference BP, [BP+CX] cannot be dereferenced \n");
			*mainCode += ("SAL CX , 1\t\t\t\t\t\t;*2 since per index , 2 bytes\n");
			*mainCode += ("ADD CX , " +to_string( $1->getStackPos()) +"\t\t\t\t;access correct byte by adding offset\n");
			*mainCode += ("ADD BP , CX\t\t\t\t;Change BP to point to correct array elem \n");
			*mainCode += ("MOV CX , PTR WORD [BP]\t\t;load value pointed to by BP\n");
			*mainCode += ("MOV AX , CX\n");
			*mainCode += ("SUB AX , 1\n");
			*mainCode += ("MOV PTR WORD [BP] , AX\t\t;load value pointed to by BP\n");
			*mainCode += ("POP BP\t\t\t\t\t\t;restore old BP for pointer\n");
			*mainCode += ("PUSH CX\t\t\t\t\t\t;store value in stack\n");
		}

		//VARIABLES DECREMENT
		else{
			*mainCode += ("MOV CX , [BP+" + to_string($1->getStackPos()) + "]\t\t\t;IncOp for Variable\n");
			*mainCode += ("MOV AX , CX\n");
			*mainCode += ("SUB AX , 1\n");
			*mainCode += ("MOV [BP+" + to_string($1->getStackPos()) + "] , AX\t\t\t;IncOp for Variable\n");
			*mainCode += ("PUSH CX\n");

		}
		outputToFile1<<*mainCode;
		isConst++;
	};
	
argument_list : arguments				{
		$$ = new SymbolInfo($1->getName(), non_token);

	}
		|  {
		symbol = new SymbolInfo("", non_token);
		symbol->setDataType("void");
		argstore.push_back(symbol);
		$$ = new SymbolInfo("", non_token);
	};
	
arguments : arguments COMMA logic_expression{
		$$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName() , non_token);
		symbol = new SymbolInfo($3->getName(), non_token);
		symbol->setDataType($3->getDataType());
		argstore.push_back(symbol);
	}
	    | logic_expression{
		$$ = new SymbolInfo($1->getName(), non_token);
		symbol = new SymbolInfo($1->getName(), non_token);
		symbol->setDataType($1->getDataType());
		argstore.push_back(symbol);

	};
 

%%
int main(int argc,char *argv[])
{

	yyin=fopen(argv[1],"r");
	yyparse();
	
	//
	outputToFile1.close();
	outputToFile2.close();
	ofstream outputToFile1("1905093_code.txt");		//THIS IS WHERE ALL OUT MAIN CODE WILL BE GENERATED
	ifstream outputToFile2("1905093_file2.txt");//FSADFGASDFSDF
	ifstream code3("1905093_file1.txt"); //DFAWDFSDAFASDF
  	string s;

	//TRAVERSIONG THROUGHT THE FIRST FILE WHICH CONTAINST SOME  EXTRA STUFF
	while(getline(outputToFile2, s)){ 
         outputToFile1<<s; 
         outputToFile1<<"\n";
    }

	//TRAVERSING THROUGH THE MAIN FILE
	while(getline(code3, s)){ 
         outputToFile1<<s;
         outputToFile1<<"\n";
    }

	outputToFile1.close();
	outputToFile2.close();
	code3.close();



	//OPTIMIZATION

	ifstream f1("1905093_code.txt");
    ofstream f2("1905093_optimizedcode.txt");
    ofstream f3("1905093_garbage.txt");

    string temp;


    vector<string> lines;
    while(getline(f1, temp)) {
        lines.push_back(temp);
    }
	//GET RID OF THE TABS FROM  THE FILE
    for(int i=0;i<lines.size();i++){
        utilSplitFunc(lines[i],' ','\t', i);	//A UTIL FUNCTION WE WROTE IN THE BEGINING
    }
    f1.close();		//WORK OF THIS IS DONE


    ifstream f4("1905093_code.txt");//NO WE USE THE MAIN CODE AGAIN FOR FURTHER OPTIMIZATION
    string tempStr;
	int i=0;

    while(i<strings.size()){

        int sempCorr = 0;

		//check for move redundancies
        if(strings[i][0] == "MOV"){
			sempCorr++;
			int y = i+1;
			string t2;
			getline(f4,t2);

			while(y<strings.size()){
				//IF THE FIRST CHAR IS A SEMICOLON MEANING IT IS A COMMENT
				if(strings[y][0][0] == ';'){
					y++;
					getline(f4,tempStr);
					f2<<tempStr;
					f2<<"\n";
				} 
				else break;
			}

			//NO OPTIMIZATION NEEDED, PRINTED AS IT IS
			if(y>=strings.size()){
				f2<<t2;
				f2<<"\n";
				i=y;
				//PRINTED AS IT IS IN THE OPTIMIZED FILE SECTION
			}

			//FOR CONDITION SUCH AS MOV AX,0 AND MOV 0,AX
			else if(strings[y][0] == "MOV" && strings[i][1] == strings[y][3] && strings[i][3] == strings[y][1]){
				f2<<t2;
				f2<<"\n";
				getline(f4,tempStr);
				f2<<";";	//COMMENTING THOSE CODES OUT
				f2<<tempStr<<endl;
				f2<<"\n";
				f3<<"Line "<< y <<": "<<tempStr<<"\n";	//PRINING AS A COMMENT IN THE GARBAGE FILE
				i = y;
            }
			else{
				//RESERT
				//NO OTIMIZATION NEEDED
				i=y-1;
				f2<<t2;
				f2<<"\n";
				//PRINTED AS IT IS IN THE OPTIMIZED FILE
			}


        }

		//CHECKING FOR PUSH REDUNDENCIES
        else if(strings[i][0] == "PUSH"){
			int y = i+1;
			string t2;
			getline(f4,t2);
			sempCorr++;
			while(y<strings.size()){

				//IF THE FIRST CHAR IS A SEMICOLON THEN IT IS A COMMENT
				if(strings[y][0][0] == ';'){
					y++;
					getline(f4,tempStr);
					f2<<tempStr;
					f2<<"\n";
				} 
				else break;
			}


			//CHECK IF THE SAME THING HAS BEEN PUSHED AND POPPED
			if(strings[y][0] == "POP" && strings[i][1] == strings[y][1]){//SAME THING HAS BEEN PUSHED AND POPPED, THUS REDUNDENT
				
				f2<<";";	//COMMENT TEH POP AND PUSH OPERATION SO THEY DON'T GET EXECUTED IN THE OPTIMIZED VERSION
				f2<<t2;
				f2<<"\n";

				f3<<"Line "<< i <<": "<<t2<<"\n";
				
				getline(f4,tempStr);
				f2<<";";		//COMMENTING THE LINE OF THE POP
				f2<<tempStr;
				f2<<"\n";

				f3<<"Line "<< y <<": "<<tempStr<<"\n";

				//RESET
				i = y;	
            }
			else if(y>=strings.size()){//IF SIZE IS EXCEEDED
					f2<<t2;
				f2<<"\n";
				i=y;
			}
			else{
				//THERE ARE LOTS OF THING GOING ON GERE
				//FIRST OF ALL WE RELOCATE THE VALUES OF I SO THEAT I T RECLEFCTS ON THE NEXT ITERATIN
				i=y-1;
				f2<<t2;
				f2<<"\n";
			}



        }
        if(sempCorr == 0){
				//NO OPTIMIZATION NEEDED THUS PRINT AS IT IS
                getline(f4,tempStr);
                f2<<tempStr;
                f2<<"\n";
        }

		i++;

    }
	f2.close();
	f3.close();
	f4.close();

	//REMOVE THE UNNECESSARY MIDDLE FILES
	remove("1905093_file2.txt");
	remove("1905093_file1.txt");

	fclose(yyin);

	return 0;
}

