#include<iostream>
#include<sstream>
#include<fstream>
#include "1905093_ScopeTable.h"

using namespace std;

int bucket= 10;


//FROM OFFLINE1 SPECIFICATIONS
int SDBMHash(string str)
{
    long long int hash = 0;
    long long int i = 0;
    long long int len = str.length();

    for (i = 0; i < len; i++)
    {
        hash = (str[i]) + ((hash << 6)) + ((hash << 16)) - hash;
    }

    return hash % bucket;
}


class SymbolTable
{
private:
    ScopeTable* sym;
    int size;
public:

SymbolTable(){

}
    

SymbolTable(int size)
{
    this->size = size;
    bucket = size;
    sym= new ScopeTable(size,SDBMHash);
    sym->setId(1);
}

~SymbolTable()      //DESTRUCTOR
{
    
    while(sym->getParentPointer() != NULL){     //DELETE ALL SCOPETABLES
        ScopeTable* temp= sym;
        sym= temp->getParentPointer();
        temp->setParentPointer(NULL);
        delete temp;
    }
    
    delete sym;
    sym= NULL;
}


void EnterScope(){      //IS CALLLED WHEN A LCURL IS ENCOUNTERED
    ScopeTable *sc= new ScopeTable(bucket,SDBMHash);
    sc->setParentPointer(sym);
    sym= sc;
    
    sym->setId(1+ ScopeTable::getStat());           //MAINTAINING THE SCOPETABLE NUMBER INTEGRITY TRHOUGH STATIC VARIABLE
    ScopeTable::setStat();

}


void ExitScope(){       //IS CALLED WHEN A RCURL IS ENCOUNTERED
    ScopeTable* temp = sym;
    sym= temp->getParentPointer();
    temp->setParentPointer(NULL);
    delete temp;
}

bool insert(string str1, string str2)   //ONLY APPLICABLE FOR ID LITERALS
{
    SymbolInfo *temp = new SymbolInfo(str1,str2);
    if(sym->insertSymbol(temp))     //see if it returns true for the execution to proceed
        return true;
    else
        return false;
}


void printCurrentScopeTable(FILE *fp){      //  PRINT ONLY THE CURRENT SCOPETABLE
    sym->printScopeTable(fp);
}

void printAllScopeTables(FILE *fp){         //PRINT ALL THE SCOPETABLES
    ScopeTable *temp;
    temp= sym;
    while(temp != NULL){
        temp->printScopeTable(fp);
        temp= temp->getParentPointer();
    }
}

SymbolInfo* lookUpAllScope(string str)          //SEARCH FOR AN ELEMENT IN ALL OF THE SCOPETABLES
{
    ScopeTable *temp = sym;
    SymbolInfo* smb;

    while(temp != NULL){
        smb= temp->lookUpSymbol(str,0);
        if(smb != NULL)
        {
            return smb;
        }
        temp= temp->getParentPointer();
    }
    return NULL;
}

SymbolInfo* lookUpCurrScope(string str)         //SEARCH FOR AN ELEMENT ONLY IN THE CURRENT SCOPETABLE
{
    ScopeTable *temp = sym;
    SymbolInfo* smb= temp->lookUpSymbol(str,0);
        if(smb != NULL)
        {
            return smb;
        }
    
    return NULL;
}

bool remove(string str){                        //REMOVE AN ELEMENT FROM THE SCOPETABLE
    bool flag = sym->deleteSymbol(str);
    if(flag==true)
        return true;
    else
        return false;
}





};