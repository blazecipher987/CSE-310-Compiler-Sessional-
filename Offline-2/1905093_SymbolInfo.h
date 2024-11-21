#include <bits/stdc++.h>
#include<cstring>
using namespace std;

class SymbolInfo
{
private:
    string name;
    string type;
    SymbolInfo* next;
public:


SymbolInfo(){

}

SymbolInfo(string name, string type)
{
    this->name= name;
    this->type= type;
}

SymbolInfo(string name, string type, SymbolInfo *next){     //constructor for when the slotted position already has an element
        this->name = name;
        this->type = type;
        this->next = next;

    }

    SymbolInfo(SymbolInfo *x, SymbolInfo *next){
        this->name = x->name;
        this->type = x->type;
        this->next = x->next;
    }

~SymbolInfo()
{
}

SymbolInfo * getNext(){
    return next;
}

void setNext(SymbolInfo *next){
    this->next = next;
}

string getName(){
    return name;
}

void setName(string name){
    this->name= name;
}

string getType(){
    return type;
}

void setType(string type){
    this->type= type;
}



};