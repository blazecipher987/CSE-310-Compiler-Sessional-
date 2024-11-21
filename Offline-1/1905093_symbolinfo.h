#include<bits/stdc++.h>
using namespace std;

class symbolinfo{

private:
    string name;    //name of the identifier
    string type;    //type of the identifier
    int hashedValue;
    int hashedPos;
    symbolinfo *next;       //TO CREATE A CHAIN OF SYMBOL TOKENS

public:

    symbolinfo(){   //default constructor
    }

    symbolinfo(string name, string type){   //constructor for when the slotted position is empty
        this->name = name;
        this->type = type;
    }

    symbolinfo(string name, string type, symbolinfo *next){     //constructor for when the slotted position already has an element
        this->name = name;
        this->type = type;
        this->next = next;

    }

    symbolinfo(symbolinfo *x, symbolinfo *next){
        this->name = x->name;
        this->type = x->type;
        this->next = x->next;
    }

    int getHashedValue(){
        return hashedValue;
    }

    void setHashedValue(int hashedValue){
        this->hashedValue = hashedValue;
    }

    int getHashedPos(){
        return hashedPos;
    }

    void setHashedPos(int hashedPos){
        this->hashedPos = hashedPos;
    }

    string getName(){
        return name;
    }

    string getType(){
        return type;
    }

    void setName(string name){
        this->name = name;
    }

    void setType(string type){
        this->type = type;
    }

    symbolinfo* getSymbolInfo(){
        return next;
    }

    void setSymbolInfo(symbolinfo* next){
        this->next = next;
    }


};