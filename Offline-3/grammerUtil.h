#ifndef HANDLEGRAMMERS_H
#define HANDLEGRAMMERS_H

#include <bits/stdc++.h>
#include "SymbolTable.h"
#include "y.tab.h"
using namespace std;

//CALLED FROM .Y FILE TO HELP US WITH ERROR PRINTING
extern void errorFilePrint(const char *);

extern SymbolTable* st;     //FROM .Y FILE TO KEEP ALL INSTANCES IN ONE PLACE
extern ofstream logOut;
extern ofstream errorOut;
extern bool flagChecker;

extern unsigned long lineNo;





vector<string> intTypes{"int", "CONST_INT"};
vector<string> floatTypes{"float", "CONST_FLOAT"};



template<typename T>
bool search(const std::vector<T> &v, T t) {
	return find(v.begin(), v.end(), t) != v.end();
}



bool isType(int x, string s){
    if(x==1){
        return search(intTypes, s);
    }
    else{
        return search(floatTypes, s);
    }
}

bool compareVarTypes(string type1, string type2) {

    if((type1 =="UNDEFINED" || type2=="UNDEFINED") || (type1 == type2) || ((isType(1, type1)) && (isType(1, type2))) || ((isType(2, type1)) && (isType(2 ,type2))) )
        return true;

    else
        return false;
}


tuple<bool, SymbolInfo*> typeCast(string left, string right) { // ASSIGNOP
    bool successful = true;
    SymbolInfo* s = new SymbolInfo();

    if (left == "UNDEFINED" || right == "UNDEFINED") {
        s->setType("UNDEFINED");
    } else if (isType(2,left) && (right != "void")) {
        s->setType(left);
    } else if (isType(1,left) && isType(1,right)) {
        s->setType(left);
    } else { 
        successful = false;
    }


    return {successful, s};
}

tuple<bool, SymbolInfo*> implicitTypeCast(string left, string right) { // ADDOP MULOP
    bool successful = true;
    SymbolInfo* s = new SymbolInfo();

    if (left == "void" || right == "void") {
        successful = false;
    } else if (isType(2, left) || isType(2, right)) {
        s->setType("float");
    } else { // both int
        s->setType(left);
    }
    
    return {successful, s};
}



//FOR PRINTNG IN THE LOG FILE
void yylog(ofstream &logOut, unsigned long lineNo, string left, string right, string symbolName) {
    logOut <<left << " : " << right <<endl;
    
}

//USED FOR CHECKING IF THE PARAMETERS OF TWO SYMBOLINFO ARE EQUAL OR IF THEY HAVE ANY TYPE MISMATCH
bool matchParams(vector<SymbolInfo*> param1, vector<SymbolInfo*> param2) {

    for (int i = 0; i < param1.size(); i++) {
        if (param1[i]->getType() != param2[i]->getType())
        {
            return false;
        }
    }
    return true;
}


// parameter_list : parameter_list COMMA type_specifier ID      (int a, int a, int b)
void funcParam1(SymbolInfo* ss, SymbolInfo* s1,SymbolInfo* s2, SymbolInfo* s3, SymbolInfo* s4) {

    // adding the params
    ss->setParams(s1->getParams());
     yylog(logOut, lineNo, "parameter_list ", "parameter_list COMMA type_specifier ID", ss->getName());

    //CHECK FOR REDEFINITION OF THE SAME NAME IN THE PARAMETER LIST
    for (SymbolInfo* param : s1->getParams()) {
        if(param->getName() == s4->getName()) {
            errorFilePrint(("Redefinition of parameter '" + s4->getName() + "'").c_str());
            flagChecker =false;     //HALT ADDING OF FURTHER VARIABLES
            
            //cout<<"Brother this has been called : "<<s4->getName()<<endl<<endl;
        }
       
    }
   if(flagChecker==true)    //ONLY ADD PARAMETERS WHEN THERE IS NO REDEFINITION
    {
        //cout<<"This has been called too : "<< s4->getName()<<endl;
        ss->addParam(new SymbolInfo(s4->getName(), s3->getName()));
}
   
}

// var_declaration : type_specifier declaration_list SEMICOLON      int a, int b ;
void funcParam2(SymbolInfo* ss, SymbolInfo* s1, SymbolInfo* s2 , bool strr) {
    
    // inserting the variables into current scope
    for (SymbolInfo* var : s2->getParams()) {
        if(var->getName()!=","){
          
        // VARIABLE TYPE SPECIFIER CANNOT BE VOID
        if (s1->getName() == "void") {
            errorFilePrint(("Variable or field '" + var->getName() +  "' declared void").c_str());

        // CHECK FOR A FUNCTION WITH THE SAME NAME
        } else if (st->lookupGlobalScope(var->getName()) != nullptr && st->lookupGlobalScope(var->getName())->isFunction()) {
            errorFilePrint(("A function exists with the name " + var->getName()).c_str());

        //CHECK FOR ANY VARIABLE WITH THE SAME NAME
        } else if (st->insert((new SymbolInfo())->copySymbol(var)->setType(s1->getName())) == false) {      //??
            errorFilePrint(("Conflicting types for'" + var->getName()+"'").c_str());
        }
        }
        
    }

    if(strr==false)
       { yylog(logOut, lineNo, "var_declaration", "type_specifier declaration_list SEMICOLON  ", ss->getName());}
}

// func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
void funcDec2(SymbolInfo* s1, SymbolInfo* s2, SymbolInfo* s4) {

    // check if function already exists
    SymbolInfo* previous = st->lookup(s2->getName());
    if (previous != nullptr) {
        if (previous->isDefined()) {    //FUNCTION ID HAS PREVIOUSLY BEEN DEFINED(NOT CONCERTING WITH DEFINITION)
            errorFilePrint(("Function " + s2->getName() + " already defined").c_str());
        } 
        else {
            //WE ONLY ENTER HERE WHEN OUR FUNCTION ID ALREADY EXISTS IN THE SCOPETABLE BUT IS NOT DEINFED , THAT MEANS THIS IS THE MULTIPLE 
            //DECLARATION. THIS IS NOT AN ISSUE IF CURRENT DECLARATION MATHCES WITH PREVIOUS DEFINITION, WE ARE GOING TO CHECK THAT
            vector<SymbolInfo*> x;
            for (int i = 1; i < previous->getParams().size(); i++) {
                
            }

            int i=1;
            while(i<previous->getParams().size()){
                x.push_back(previous->getParams()[i]);
                i++;
            }
            
            if (previous->getReturnType()->getType() != s1->getName()) {    //CHECK IF CURRENT DECLARATION TYPE IS CONSISTENT WITH PREVIOUSLY DEFINED TYPE
                errorFilePrint(("Return type mismatch with function declaration in function " + s2->getName()).c_str());
            }
            else if (x.size() != s4->getParams().size()) { //CHECK IF SIZES OF BOTH PARAMETER LIST IS EQUAL
                errorFilePrint(("Total number of arguments mismatch with declaration in function " + s2->getName()).c_str());
            }
            else if(matchParams(x, s4->getParams()) == false) {    //CHECK IF TYPES OF ALL THE PARAMETER ITEMS ARE SAME
                errorFilePrint(("Function " + s2->getName() + " has different parameters from the previous declaration").c_str());
            }
            else {
            }
        }
    }
    

   //REACHING HERE MEANS THERE IS NO DOUBLE DEFINITION. SO WE NOW SET THE INFORMATIONS FOR FURTHER TASKING
    vector<SymbolInfo*> params;
    vector<SymbolInfo*> types;
    params.push_back(new SymbolInfo("RETURN_TYPE", s1->getName()));
    for (SymbolInfo* param : s4->getParams()) {
        params.push_back((new SymbolInfo())->copySymbol(param));
        
    }

    //FOR PROPER PRINTING PURPOSE OF MATCHING THE LOG FILE
    string sp = s1->getName();
    transform(sp.begin(), sp.end(), sp.begin(), ::toupper);

    //INSERT CURRENT FUNCTION IN SYMBOLTABLE TO DO CHECKING IN THE FUTURE
    st->insert((new SymbolInfo(s2->getName(), "FUNCTION, " + sp))->setParams(params));
}


// func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON
void funcDec1(SymbolInfo* s1, SymbolInfo* s2) {

    //SAME AS PREVIOUS FUNCDECLARATION CASE
    SymbolInfo* previous = st->lookup(s2->getName());
    if (previous != nullptr) {
        if (previous->isDefined()) {
            errorFilePrint(("Function " + s2->getName() + " already defined").c_str());
        } else {
   
            
            //TYPE CHECKING
            if (previous->getReturnType()->getType() != s1->getName()) {
                errorFilePrint(("Return type mismatch with function declaration in function " + s2->getName()).c_str());
            }

            //ONLY CHECKING FOR SIZE>1 BECAUSE THIS DECLARATION IS OF A PARAMETERLESS FUNCTION
            else if (previous->getParams().size() > 1) {
                errorFilePrint(("Function " + s2->getName() + " should not have any parameter from previous declaration").c_str());
            } else {
            }
        }
    }


    //INSERTING ID WITH FUNCTION CHARACTERISTICS IN THE SYMBOLTABLE AGAIN FOR FUTURE CHECKING
    //NO PARAMETERS IN THIS CASE
    string sp = s1->getName();
    transform(sp.begin(), sp.end(), sp.begin(), ::toupper);
    SymbolInfo *x = new SymbolInfo("RETURN_TYPE", s1->getName());

    st->insert((new SymbolInfo(s2->getName(), "FUNCTION, "  + sp) )->addParam(x));
}


void funcParam11(SymbolInfo* ss, SymbolInfo* s1,SymbolInfo* s2, SymbolInfo* s3, SymbolInfo* s4) {

    cout<<lineNo<<" "<<ss->parenTrue <<endl;
    // adding the params
    bool flag = false;
    ss->setParams(s1->getParams());
    if(ss->parenTrue)
    {ss->parenTrue = s1->parenTrue;}
     yylog(logOut, lineNo, "parameter_list ", "parameter_list COMMA type_specifier ID", ss->getName());
     cout<<"papaya : "<< ss->parenTrue<<endl;


   
        for (SymbolInfo* param : s1->getParams()) {
        if(param->getName() == s4->getName()) {
            errorFilePrint(("Redefinition of parameter '" + s4->getName() + "'").c_str());
            flag =true;
            ss->parenTrue=true;

            cout<<"Brother this has been called : "<<s4->getName()<<endl<<endl;
            //continue;
        }
       
    }
    

    // check if there was a parameter with same name before
    
   if(flag==false && ss->parenTrue ==false)
    {
        cout<<"This has been called too : "<< s4->getName()<<endl;
        ss->addParam(new SymbolInfo(s4->getName(), s3->getName()));
}
   cout<<endl;
}


// declaration_list : declaration_list COMMA ID
void funcDec1(SymbolInfo* ss, SymbolInfo* s1, SymbolInfo* s2 , SymbolInfo* s3 , bool strr) {

    // AADDING THE PARAMETERS FROM THE DECLARATION LIST
    for (SymbolInfo* var : s1->getParams()) {
        ss->addParam((new SymbolInfo())->copySymbol(var));
    }
    // ADDING THE CURRNET PARAMETERS
    ss->addParam((new SymbolInfo())->copySymbol(s2));
    ss->addParam((new SymbolInfo())->copySymbol(s3));

    if(strr==false)
        {yylog(logOut, lineNo, "declaration_list", "declaration_list COMMA ID  ", ss->getName());
}}

// declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
void funcDec2(SymbolInfo* ss, SymbolInfo* s1,SymbolInfo* s2, SymbolInfo* s3, SymbolInfo* s5 , bool strr) {
    // adding previous id/arrays first
    for (SymbolInfo* var : s1->getParams()) {
        ss->addParam((new SymbolInfo())->copySymbol(var));
    }

    ss->addParam((new SymbolInfo())->copySymbol(s2));
    
    // SETTING ARRAYSIZE AND ADDING IT TO THE SYMBOLTABLE
    int x = stoi(s5->getName());
    ss->addParam((new SymbolInfo())->copySymbol(s3)->setArraySize(x));

    if(strr==false)
        {yylog(logOut, lineNo, "declaration_list", "declaration_list COMMA ID LSQUARE CONST_INT RSQUARE ", ss->getName());}
}

// void handleError1(SymbolInfo *s1 , SymbolInfo *s2){
//     logOut<<"Error : "<<lineNo<<endl;
// }

// func_definition : type_specifier ID LPAREN parameter_list RPAREN     int a(int b, float b.....)
void funcDef1(SymbolInfo* s1, SymbolInfo* s2, SymbolInfo* s3 ,SymbolInfo* s4, SymbolInfo* s5, bool strr) {
    vector<SymbolInfo*> temp;

    // CROSSCHECK PARAMETER NAMES AND TUPES WITH PREVIOUS DECLARATION
    bool paramsInDefinitionHaveNames = true;
    for (int i=0; i<s4->getParams().size(); i++) {
        SymbolInfo* param = s4->getParams()[i];


        //CHECK IF FUNCTION PARAMETER NAME IS NOT GIVEN
        if (param->getName() == "NOT DEFINED") {
            errorFilePrint((to_string(i+1) + "th parameter's name not given in function definition of " + s2->getName()).c_str());
            //errorFilePrint("Syntax error at parameter list of function definition")
            paramsInDefinitionHaveNames = false;

        }

        //GO THROUGH GLOBAL SCOPE AND SEE IF THERE EXISTS ANOTHER FUNCTION WHICH CLASHES WITH THE CURRENT ON IN TERMS OF PARAMETERS
        else if (st->lookupGlobalScope(param->getName()) != nullptr && st->lookupGlobalScope(param->getName())->isFunction()) {
            errorFilePrint(("Parameter " + param->getName() + " clashes with a function").c_str());

        }

        //PARAMETERS ARE ALL GOOD SO INSERT
        else {
            temp.push_back(param);
        }

    }

    // CHECK IF THIS ID WAS USED BEFORE AS A FUNCTION , NO PROBLEM IF IT WAS A VARIABLE
    SymbolInfo *previous = st->lookup(s2->getName());

    //NOT BLANK SO DEFINATELY SOMETHING HERE
    if(previous != nullptr) {

        // CHECK IF IT IS A FUNCTION
        if (previous->isDefined()) {
            errorFilePrint(("Redefinition of " + s2->getName()).c_str());

        } 
        else if(previous->isFunction() == false) {
            errorFilePrint(("'" + s2->getName() + "' redeclared as different kind of symbol").c_str());

        // CHECK IF IT HAS BEEN DEFINED BEFORE
        } else {
            previous->setDefined();     //DEFINE IT WHICH WILL BE USED AS A MARKER FOR ALL TASKS LATER

            // check if the return type and params are the same
            // params is just for comparing, not inserting parameters
            SymbolInfo *returnType = previous->getReturnType();
            vector<SymbolInfo*> params;
            bool paramsInDeclarationHaveNames = true;
            for (int i = 1; i < previous->getParams().size(); i++) {
                params.push_back(previous->getParams()[i]);
                if(previous->getParams()[i]->getName() == "NOT DEFINED") {
                    paramsInDeclarationHaveNames = false;
                }
            }

            //CHECK FOR NAME AND SIZE CONFLICTONS
            if ((returnType->getType() != s1->getName()) || (params.size() != s4->getParams().size()) ) {
                errorFilePrint(("Conflicting types for '" + s2->getName() +"'").c_str());
            
            }
            //CHECK FOR PARAMETER DIFFERENCE CONFLICT
            else if(matchParams(params, s4->getParams()) == false) {
                errorFilePrint(("Function " + s2->getName() + " has different parameters from the previous definition").c_str());
            
            } else {
                if (!paramsInDeclarationHaveNames && paramsInDefinitionHaveNames) {     //THE DECALRATION NAMES ARE NOT DEFINED YET
                    // replace previous's params with s4's params
                    vector<SymbolInfo*> replaceParams;
                    for (SymbolInfo* p : s4->getParams()) {
                        replaceParams.push_back((new SymbolInfo())->copySymbol(p));
                    }
                    previous->setParams(replaceParams);
                } else if (paramsInDefinitionHaveNames!=false) {
                    // GOOD GOING
                } else {
                    
                }
            }
        }

    }
    else {

        // INSERT THE FUNCTION AS THERE IS NO PREVIOUS DEFINITION
        vector<SymbolInfo*> params;
        params.push_back(new SymbolInfo("RETURN_TYPE", s1->getName()));
        for (SymbolInfo* param : s4->getParams()) {
            params.push_back((new SymbolInfo())->copySymbol(param));
        }

        string sp = s1->getName();
        transform(sp.begin(), sp.end(), sp.begin(), ::toupper);

            if(strr==false)
            {st->insert((new SymbolInfo(s2->getName(), "FUNCTION, " +  sp))->setParams(params)->setDefined());}
    }

    // enter scope
    st->enterScope();

    //ADD THE PARAMETERS INTO THE SCOPETABLE
    for (SymbolInfo* param : temp) {
        st->insert(param);
    }
}

// func_definition : type_specifier ID LPAREN RPAREN    int a()
void funcDef2(SymbolInfo* s1, SymbolInfo* s2,SymbolInfo* s3,SymbolInfo* s4 , bool strr) {

    // checking whether this name has been used before
    SymbolInfo *previous = st->lookup(s2->getName());
    if(previous != nullptr) {

        // was that a function too
        if(previous->isFunction() == false) {
            errorFilePrint(("Multiple declaration of " + s2->getName()).c_str());

        // check for double definition
        } else if (previous->isDefined()) {
            errorFilePrint(("Redefinition of " + s2->getName()).c_str());

        } else {
            previous->setDefined();

            // check if the return type and params are the same
            // in this case params should be empty
            SymbolInfo *returnType = previous->getReturnType();

            if (returnType->getType() != s1->getName()) {
                errorFilePrint(("Conflicting types for '" + s2->getName() + "'").c_str());

            } else if(previous->getParams().size() != 1) {
                errorFilePrint(("Conflicting types for '" + s2->getName() +"'").c_str());
                                
            } else {

            }
        }

    } else {
        //NO CONFLICT THUS INSERTING THE FUNCTION ID IN THE SCOPETABLE
        string sp = s1->getName();
        transform(sp.begin(), sp.end(), sp.begin(), ::toupper);

        if(strr==false)
           { st->insert((new SymbolInfo(s2->getName(), "FUNCTION, " + sp ))->addParam(new SymbolInfo("RETURN_TYPE", s1->getName()))->setDefined());}

    }

    st->enterScope();   //SINCE THIS IS A DEFINITION AND A RCURL FOLLOW AFTER THIS RULE 
}



#endif // HANDLEGRAMMERS_H