#pragma
#ifndef SCOPETABLE_H
#define SCOPETABLE_H

#include <bits/stdc++.h>
#include "SymbolInfo.h"
using namespace std;


class ScopeTable {
    unsigned long bucketNo;
    SymbolInfo** buckets;
    ScopeTable* parentScope;
    int number;
    
    unsigned scopeCount;
    
public:
    static int order;

    ScopeTable(unsigned long bucketNo, ScopeTable* parentScope) {
        this->bucketNo = bucketNo;
        buckets = new SymbolInfo*[bucketNo];
        for(unsigned long i=0; i<bucketNo; i++) {
            buckets[i] = nullptr;
        }
        this->parentScope = parentScope;
        this->scopeCount = 1;

        if(parentScope == nullptr) {        //BASE SCOPETABLE
            number =1;
        } else {
            number = parentScope->number + 1;
        }

        // cout << "New ScopeTable with id " + number + " created\n";
    }

    ScopeTable(unsigned long bucketNo, ScopeTable* parentScope, int number) {

        this->number = number;      //USED FOR NUMBERING THE SCOPETABLES 

        //BUCKETCOUNT FOR HASH FUNCTION
        this->bucketNo = bucketNo;      

        //INITALIZE A SERIES OF BUCKETS TO HOLD THE ITERMS IN PLACE
        buckets = new SymbolInfo*[bucketNo];
        for(unsigned long i=0; i<bucketNo; i++) {
            buckets[i] = nullptr;
        }

        //SET PARENT POINTER
        this->parentScope = parentScope;

        //INITIAL SCOPECOUNT
        this->scopeCount = 1;

        if(parentScope == nullptr) {
            number =1;
        } else {
            number = parentScope->number + 1;
        }

    }



    ~ScopeTable() {
//        cout << "Destroying the ScopeTable\n";
        SymbolInfo *itr, *prev;
        for (unsigned long i=0; i<bucketNo; i++) {
            if(buckets[i] == nullptr) continue;

            prev = buckets[i];
            itr = prev->getNext();
            while(itr != nullptr) {
                delete prev;
                prev = itr;
                itr = prev->getNext();
            }
            delete prev;
        }
        delete [] buckets;
    }


//FROM THE SPECIFICATION LINK OF OFFLINE-1
    int SDBMHash(string str)
{
    long long int hash = 0;
    long long int i = 0;
    long long int len = str.length();

    for (i = 0; i < len; i++)
    {
        hash = (str[i]) + ((hash << 6)) + ((hash << 16)) - hash;
    }

    return hash % bucketNo;
}

    bool insert(string name, string type) {
        SymbolInfo* symbol = new SymbolInfo(name, type);

        unsigned long index = SDBMHash(&name[0]);       //GET HASHING POSITION

        //IF HASHED POSITOION CHAIN IS EMPTY THEN RETURN FALSE
        if(buckets[index] == nullptr) {     
            buckets[index] = symbol;
            return true;
        }

        //CHECK IF THE FIRST ELEMENT OF THE CHAIN IS OUR DESIRED ELEMENT
        if(buckets[index]->getName() == name) { //NO DOUBLE INSETIONS ALLOWED SO DESTROY THE TEMP SYMBOLINFO POINTER
            delete symbol;
            return false;
        }


        //ITERATE THROUGH THE CHAIN TO SEE IF THERE IS ANY ELEMENT OF THE SAME NAME 
        SymbolInfo* prev = buckets[index];
        SymbolInfo* itr = prev->getNext();
        unsigned secondaryIndex = 1;
        while(itr != nullptr) {
            if(itr->getName() == name) {
                return false;
            }
            prev = itr;
            itr = itr->getNext();
            secondaryIndex++;
        }
        prev->setNext(symbol);
        return true;
    }
















































    bool insert(SymbolInfo* symbol) {
        string name = symbol->getName();
        unsigned long index = SDBMHash(&name[0]);

        if(buckets[index] == nullptr) {
            buckets[index] = symbol;
            return true;
        }

        if(buckets[index]->getName() == name) {


            return false;
        }

        SymbolInfo* prev = buckets[index];
        SymbolInfo* itr = prev->getNext();
        unsigned secondaryIndex = 1;
        while(itr != nullptr) {
            if(itr->getName() == name) {
                return false;
            }
            prev = itr;
            itr = itr->getNext();
            secondaryIndex++;
        }
        prev->setNext(symbol);
        return true;
    }

    SymbolInfo* lookup(string name) {
        unsigned long index = SDBMHash(&name[0]);       //GET INDEX USING THE FUNCTION
        SymbolInfo* itr = buckets[index];               //GET THE CORRESPONDING SYMBOLINFO IN THE POSITION
        unsigned X = 0;

        //IF CURR POSITION ISN'T NULL THEN THERE ARE ELEMENTS IN THAT POSITION, NOW WE NEED
        //TO GO THROUGH THAT CHAIN AND SEARCHFOR THAT SYMBOLINFO
        while(itr != nullptr) {
            if(itr->getName() == name) {    //MATCHED
                return itr;
            }
            itr = itr->getNext();       //ITERATE THROUGH THE CHAIN
            X++;                        //INCEMENT THE INDEX AS WELL AS WE TRAVERSE THE LIST
        }

        //WE HAVEN'T FOUND THE MATCHED SYMBOLINFO THUS RETURN NULLPTR
        return nullptr;      
    }

    
    //GET THE CURRENT PARENT POINTER
     ScopeTable *getParentScope() const {
        return parentScope;
    }

    

    void print(ofstream &logOut) {
        //logOut << "\tScopeTable # " << x << endl;
        logOut << "\tScopeTable# " << number << endl;
        SymbolInfo* itr;

        string toBePrinted;
        bool gotSomething = false;
        for(unsigned long i=0; i<bucketNo; i++) {
            string toBePrinted = "\t" + to_string(i+1) + "--> ";

            itr = buckets[i];
            while(itr != nullptr) {
                gotSomething = true;
                toBePrinted += "<" + itr->getName() + ", ";
                
                if(itr->getType() == "int" || itr->getType() == "float" || itr->getType() == "void" || itr->getType() == "FUNCTION") {
                    //toBePrinted += "ID > ";
                    if(itr->isArray()){
                        toBePrinted+= "ARRAY, ";
                    }
                    string x = itr->getType();
                    //toBePrinted += itr->getType();
                    std::transform(x.begin() , x.end() , x.begin() , ::toupper);
                    toBePrinted+= x + "> ";
          
                } else {
                    toBePrinted += itr->getType() + "> ";
                }

                itr = itr->getNext();
            }

            if(gotSomething) {
                logOut << toBePrinted << endl;
                gotSomething = false;
            }
        }
    }

   



    // static int getStat(){
    //     return order;
    // }

    // static void setStat(){
    //     order++;
    // }

    int getNumber(){
        return number;
    }
    void setNumber(int x){
        number = x;
    }
};

// int ScopeTable::order = 1;

#endif //SCOPETABLE_H

