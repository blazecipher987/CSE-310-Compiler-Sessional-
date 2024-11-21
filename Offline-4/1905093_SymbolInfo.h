#pragma once
#include<iostream>
#include<string>
#include<bits/stdc++.h>


using namespace std;

class SymbolInfo {
  private:
    string *name;
    string *type; //tokenType;
    SymbolInfo *next;
    //only for token type ID
    int varType=0; // 0 == variable, 1 == array, 2 == funcDeclaration, 3 == funcDefinition
    int size=0; // for array type, else don't use.
    string *dataType; //int or  float or void(func only)
    int global=0;//for global variables and arrays;

    //NECESSARY VARIABLES FOR ICG
    int dataSize = 2; //2 BYTES DATA SIZE
    int stackPos = 0; //RELATIVE POSTITON ACCODING TO THE BASE POINTER
    int retPos; //FOR RESTORING THE STACK POINTER AFTER THE FUNCTION ENDS WITH ALL IT'S VALUES
    string *value; //for storing int type values;
    string *mainCode;


  public:
      int beginTime;      //TO GET STARTLINE
    int endTime;        //TO GET ENDLINE
    bool isLeaf;        //CHECK IF THE CURR SYMBOLINFO IS A TERMINAL

    vector<SymbolInfo*> functionParams;
    ///constructors
    SymbolInfo(){
        next = nullptr;
        name = new string("");
        type = new string("");
        dataType = new string("");
        value = new string("");
        mainCode = new string("");
         
    }
    SymbolInfo(string n, string t){
        name = new string(n);
        type = new string(t);
        next = nullptr;
        dataType = new string("");
        value = new string("");
        mainCode = new string(""); 
    }
    SymbolInfo(const SymbolInfo &x){
        name = new string(*(x.name));
        type = new string(*(x.type));
        next = x.next;
        dataType = new string(*(x.dataType));
        varType = x.varType;
        functionParams = x.functionParams;
        size = x.size;
        global = x.global;
        value = new string(*(x.value));
        dataSize = x.dataSize;
        retPos = x.retPos;
        stackPos = x.stackPos;
        mainCode = new string(*(x.mainCode)); 
    }
    ///Destructor
    ~SymbolInfo(){
        delete name;
        delete type;
        delete dataType;
        delete value;
    }
    //VariableType
    int getVarType(){
        return varType;
    }
    void setVarType(int x){
        varType = x;
    }

    ///DataType
    string getDataType(){
        return *dataType;
    }
    void setDataType(string t){
        *dataType = t;
    }

    ///Name
    string getName(){
        //cout<<"name"<<endl;
        return *name;
    }
    void setName(string n){
        *name = n;
    }


    ///Type
    string getType(){
        return *type;
    }
    void setType(string t){
        *type = t;
    }

    //Size
    int getSize(){
        return size;
    }
    void setSize(int x){
        size = x;
    }
    //global
    void setGlobal(){
        global = 1;
    }
    void resetGlobal(){
        global = 0;
    }
    int getGlobal(){
        return global;
    }

    ///next
    SymbolInfo* getNext(){
        return next;
    }

    void setNext(SymbolInfo* s){
        next = s;
    }

     int getBeginTime() const{
        return beginTime;
    }

    void setBeginTime(int x){
        beginTime = x;
    }

    int getEndTime() const {
        return endTime;
    }

    void setEndTime(int x){
        endTime = x;
    }


    //funcparamschecks
    int uniqFunc(SymbolInfo* SI){
        //SIZE NOT MATCHED
        if(SI ->functionParams.size() != functionParams.size()){
            return 1;
        }
        
        //DIFFERENT RETURN TYPES
        if(SI->getDataType()!= getDataType()){
            //cout<<"Return Type mismatch"<<endl;
            return 3;
        }

        //DIFFERENT PARAMETER TYPES
        for(int i=0;i<functionParams.size();i++){
            if(SI ->functionParams[i]->getDataType()!=functionParams[i]->getDataType()){
                //cout<<"Param DataType Mismatch"<<endl;
                return 2;
            }
        }

        return 0;
    }


    void addParam(SymbolInfo* SI){
        functionParams.push_back(SI);
    }


    //For ICG

    int getDataSize(){
        return dataSize;
    }

    void setStackPos(int sp){   //
        stackPos = sp;
    }
    int getStackPos(){
        return stackPos;
    }

    void setVal(string x){
        value = new string(x);
    }

    string getVal(){
        return *value;
    }
    int getValInt(){
        return stoi(*value);
    }



};



