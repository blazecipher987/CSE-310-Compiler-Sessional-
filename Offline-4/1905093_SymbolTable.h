#pragma once
#include<bits/stdc++.h>
#include "1905093_SymbolInfo.h"
#include "1905093_ScopeTable.h"

using namespace std;

class SymbolTable{
private:
    int TotalBuckets;
    ScopeTable* root;
    ScopeTable* currSIP;
public:
    SymbolTable(int bucketNo){
        root = new ScopeTable(bucketNo, nullptr);
        currSIP = root;
        TotalBuckets = bucketNo;
    }
    ~SymbolTable(){
        ScopeTable *temp;
        while(root!=currSIP){
            temp = currSIP;
            currSIP = currSIP->getChild();
            delete temp;
        }
        delete root;
    }
    int getTotalBuckets(){
        return TotalBuckets;
    }

    void enterScope(){
        ScopeTable *temp = new ScopeTable(TotalBuckets, currSIP);
        currSIP = temp;
    }

    void deleteScope(){
        ScopeTable* prevSIP = currSIP->getParent();
        if(currSIP->getID() == "1"){
            return;
        }
        if(prevSIP->getID() != "1"){
            
        }
        else{
            delete currSIP;
            currSIP = prevSIP;
            return;
        }
        delete currSIP;
        currSIP = prevSIP;
    }

    bool InsertSymbol(SymbolInfo *s){
        bool ans = currSIP->InsertSymbol(s);
        return ans;
    }
    
    bool RemoveSymbolInfo(SymbolInfo *s){
        return currSIP->deleteString(s->getName());
    }

    SymbolInfo * searchAllScope(string s){
        ScopeTable * temp = currSIP;
        SymbolInfo * ret = currSIP->searchString(s);
        while(ret==nullptr){
            temp = temp->getParent();
            if(temp == nullptr){
                return nullptr;
            }
            ret = temp->searchString(s);
        }
        if(currSIP == temp){
        }

        return ret;
    }

    SymbolInfo * searchCurrScope(string s){
        return currSIP->searchString(s);
    }
   
    string getCurrID(){
        return currSIP->getID();
    }
    

};
