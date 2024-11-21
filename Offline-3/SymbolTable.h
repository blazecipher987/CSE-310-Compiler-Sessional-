#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#include<bits/stdc++.h>
#include "ScopeTable.h"
using namespace std;

class SymbolTable {
    ScopeTable* currScope;
    unsigned long totalBuckets;
    int count =1;

public:
    SymbolTable(unsigned long totalBuckets) {
        count=1;
        this->totalBuckets = totalBuckets;
        currScope = nullptr;
        enterScope();
    }

    ~SymbolTable() {
        delete currScope;
    }

    void enterScope() {
        ScopeTable* newScope = new ScopeTable(totalBuckets, currScope,count);
        count++;    //INCREMENT THE SCOPATABLE COUNT WHICH IS ULTIMATELY USED AS THE SCOPETABLE ID

        // newScope->setNumber(1+ScopeTable::getStat());
        // ScopeTable::setStat();
        currScope = newScope;
    }

    void exitScope() {

        //WHEN THERE IS NO SCOPETABLE CREATED
        if(currScope == nullptr) {
            return;
        }

        //GET THE PREVIOUS SCOPETBLE WHICH IS THE PARENT
        ScopeTable* temp = currScope->getParentScope();

        if(temp == nullptr) {
            //THE #1 SCOPETABLE CAN'T BE DELETED
        } else {
            delete currScope;    //FREE THE MEMORY
            currScope = temp;
        }
    }

    bool insert(string name, string type) {
        if(currScope == nullptr) enterScope();
        return currScope->insert(name, type);
    }

    bool insert(SymbolInfo* symbol) {
        if(currScope == nullptr) enterScope();
        return currScope->insert(symbol);
    }

   

    //SEARCH FOR A SYMBOLINFO NAME IN THE CURRENT SCOPE ONLY
    SymbolInfo* lookup(string name) {

        ScopeTable* itr = currScope;

        SymbolInfo* result = nullptr;

        while(itr != nullptr) {
            result = itr->lookup(name);
            if(result != nullptr) {
                return result;
            }
            itr = itr->getParentScope();
        }
        return nullptr;
    }
    
    //SEARCH FOR A SYMBOLINFO NAME IN THE GLOBAL SCOPE
    SymbolInfo* lookupGlobalScope(string name) {
        //NEEDED FOR FUNCTON AND VARIABLE NAME CHECKING THROUGHOUT THE WHOLE SCOPE
        ScopeTable* itr = currScope;
        while(itr->getParentScope() != nullptr) {
            itr = itr->getParentScope();
        }

        return itr->lookup(name);
    }

    //FOR PRINTING THE SCOPETABLES IN THE LOG FILE
    void printLogFile(ofstream &logOut) {

        //TOPMOST SCOPTABLE REACHED, END
        if(currScope == nullptr) {
            return;
        }

        //KEEP TRAVERSING BACKWARDS USING THE PARENT POINTERS
        ScopeTable* itr = currScope;
        while(itr != nullptr) {
            itr->print(logOut);
            itr = itr->getParentScope();

        }
    }
};


#endif //SYMBOLTABLE_H
