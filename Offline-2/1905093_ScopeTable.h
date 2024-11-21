#include <bits/stdc++.h>
#include "1905093_SymbolInfo.h"
using namespace std;

class ScopeTable
{
private:
    
    int size;
    SymbolInfo** arr;
    function<int(string)> func;     //TO PASS THE HASH FUNCTION
    int id;
    ScopeTable *parentPointer;

public:
    static int stat;        //TO KEEP TRACK OF THE SCOPETABLE NUMBER


ScopeTable(){

}

ScopeTable(int size, function<int(string)> func)
{
    this->size= size;
    arr= new SymbolInfo* [size];
    for(int i=0; i<size; i++)       //  INITIALIZING EACH POSITION TO NULL
        arr[i]= NULL;
    this->id = 1;                   //STARTING ID 1 FOR THE BASE SCOPETABLE
    this->parentPointer = NULL;
    this->func = func;
    
}


~ScopeTable()
{
    for(int i=0; i<size; i++)       //FREEING EACH MEMORY ASSOCIATED WITH THE CHANIN AND THEN THE CHAIN ITSELF
    {  
        while(arr[i] != NULL){
            SymbolInfo* temp= arr[i];
            arr[i]= temp->getNext();
            delete temp;
        } 
    }
    delete[] arr;
    arr= NULL;
}

bool insertSymbol(SymbolInfo *x){
    SymbolInfo *temp = new SymbolInfo(x->getName(), x->getType(), NULL);
    int hashedValue= func(x->getName());
    SymbolInfo *p= arr[hashedValue];


    while(p != NULL){
        if(p->getName()== x->getName()){
        
            delete temp;
            return false;
        }
        p= p->getNext();
    }

    if(arr[hashedValue]== NULL){
        arr[hashedValue]= temp;
    }

    else{
        SymbolInfo *p= arr[hashedValue];
        while(p->getNext() != NULL){
            p= p->getNext();
        }
        p->setNext(temp);
    }
    return true;
}


SymbolInfo* lookUpSymbol(string str, int x=0){
    int index= func(str);
    SymbolInfo *obj= arr[index];

    if(obj==NULL){          //  NOT FOUND SINCE INDEX IS EMPTY
        return NULL;
    }
    while(obj != NULL){     //INDEX IS NOT EMPTY SO GO THROUGH THE CHAIN TO SEE IF ELEMENT EXISTS
        if(obj->getName().compare(str)== 0){
            return obj;
        }
        obj= obj->getNext();
    }
    
    return NULL;

}


void printScopeTable(FILE *fp)
    {

        fprintf(fp, "\tScopeTable# %d\n",id);
        int i = 0;

        while (i < size)
        {
            int counter=0;


            SymbolInfo *temp = arr[i];
            if(temp!=NULL)
                {fprintf(fp, "\t%d--> ",i+1);}

            // EACH POSITION TOKENS
            while (temp != NULL)
            {
                if(temp->getName().length()>0){
                fprintf(fp,"<%s,%s> " , temp->getName().c_str(), temp->getType().c_str() );
                }
                temp = temp->getNext();
                counter++;
            }
            
            // if(i!=size)
            if(i<size && arr[i]!=NULL )
                    {fprintf(fp,"\n");}
            i++;
        }
    }


bool deleteSymbol(string str){

    int hashedValue= func(str);
    SymbolInfo *obj= arr[hashedValue];
    SymbolInfo *prev= NULL;

    //AT THE BEGINING OF THE HASHED POSITION
    if(obj != NULL && obj->getName()== str){
        arr[hashedValue]= obj->getNext();
        delete obj;
        return true;
    }

    else{
        while (obj != NULL && obj->getName() != str)    //GO THROUGH CHAIN UNTILL STR MATCHES OR NULL IS FOUND
        {
            prev= obj;
            obj= obj->getNext();
        }
        if(obj == NULL){        //NOT FOUND
            return false;
        }
        prev->setNext(obj->getNext()) ; //FOUND, REARRANGE POINTERS
        delete obj;

        return true;
    }

}

int getSize()
{
    return this->size;
}

void setSize(int size){
    this->size = size;
}

int getId(){
    return this->id;
}

void setId(int id){
    this->id = id;
}

ScopeTable* getParentPointer(){
    return this->parentPointer;
}

void setParentPointer(ScopeTable *parentPointer){
    this->parentPointer = parentPointer;
}

static int getStat(){
        return stat;
    }

    static void setStat(){
        stat++;
    }

};
int ScopeTable::stat=1;