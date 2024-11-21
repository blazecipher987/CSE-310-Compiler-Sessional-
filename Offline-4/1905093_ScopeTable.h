#pragma once
#include<iostream>
#include<string>
#include<fstream>
#include "1905093_SymbolInfo.h"
using namespace std;

class ScopeTable{
private:
    int TotalBuckets;
    ScopeTable * parent;
    ScopeTable * child;
    int numOfChilds;
    int myNum;
    string ID;
    SymbolInfo ** Hashtable;

public:

static unsigned long sdbmHash(string s)
    {
        char * ch = new char[s.size() + 1];
        copy(s.begin(), s.end(), ch);
        ch[s.size()] = '\0';
        unsigned long h = 0;
        int c;
        while (c = *ch++){
            h = c + (h << 6) + (h << 16) - h;
        }
        return h;
    }

    static unsigned long HashFunc(int bucketNo , SymbolInfo *s ){

        unsigned long h = sdbmHash(s->getName()) % bucketNo;

        return h;
    }

    ScopeTable(int bucketNo, ScopeTable *p){
        Hashtable = new SymbolInfo*[bucketNo];
        for(int i=0;i<bucketNo;i++){
            Hashtable[i] = nullptr;
        }
        this->parent = p;       //setting the parent pointer
        this->TotalBuckets = bucketNo; //Setting the bucket no

        this->numOfChilds = 0;      //currently hs no childred
        if(p==nullptr){
                       myNum = 1;
            ID = to_string(myNum);
        }
        else{


             p->setChild(this);
            myNum = ++(p->numOfChilds);
            ID = (p->ID) + "." + to_string(myNum);
        }


    }

    ~ScopeTable(){
        SymbolInfo* prevSIP;
        for(int i=0;i<getTotalBuckets();i++){
            SymbolInfo* currSIP = Hashtable[i];
            while(currSIP!=nullptr){
                prevSIP = currSIP;
                currSIP = currSIP->getNext();
                delete prevSIP;
            }
        }
    }

        bool InsertSymbol(SymbolInfo *s){

        unsigned long index = HashFunc(TotalBuckets , s);
        SymbolInfo* currSIP = Hashtable[index];
        
        if(currSIP != nullptr){
          


            SymbolInfo* prevSIP;
                while(currSIP!=nullptr){
                if(currSIP->getName()==s->getName()){

                        delete s;
                        return false;
                    }

                    prevSIP = currSIP;
                    currSIP = currSIP->getNext();
                }
                currSIP = (new SymbolInfo(*s));
                prevSIP ->setNext(currSIP);
                return true;
        }
        else{
                  Hashtable[index] =  (new SymbolInfo(*s));
            return true;
        }
    }

        int getTotalBuckets(){
        return TotalBuckets;
    }

    ScopeTable * getParent(){
        return parent;
    }




        ScopeTable * getChild(){
        return child;
    }
    void setChild(ScopeTable *c){
        child = c;
    }

  

    bool deleteSymbolInfo(SymbolInfo *s){
        SymbolInfo temp(s->getName(),"...");
        int index = HashFunc( getTotalBuckets() , &temp );
        SymbolInfo* currSIP = Hashtable[index];
        SymbolInfo* prevSIP = nullptr;

        while(currSIP!=nullptr){
            if(currSIP->getName() == s->getName()){
                deleteUtilFunc(currSIP, prevSIP, index);
                return true;
            }
            prevSIP = currSIP;
            currSIP = currSIP ->getNext();
        }
        return false;
    }

      SymbolInfo* searchString(string str){
        SymbolInfo temp(str,"...");
        int index = HashFunc(getTotalBuckets() , &temp);
        SymbolInfo* currSIP = Hashtable[index];

        while(currSIP!=nullptr){
            if(currSIP->getName() == str){
                //success found
                return currSIP;
            }
            //keep itwerating
            currSIP = currSIP ->getNext();
        }
        //not found
        return currSIP;
    }


    bool deleteString(string str){
        SymbolInfo temp(str,"...");
        int index = HashFunc( getTotalBuckets() , &temp );

        SymbolInfo* currSIP = Hashtable[index];
        SymbolInfo* prevSIP = nullptr;

        while(currSIP!=nullptr){
            if(currSIP->getName() == str){
                deleteUtilFunc(currSIP, prevSIP, index);
                return true;
            }
            prevSIP = currSIP;
            currSIP = currSIP ->getNext();
        }
        return false;

    }


    

    string getID(){
        return ID;
    }

    void deleteUtilFunc(SymbolInfo* currSIP, SymbolInfo* prevSIP, int index){
        if(prevSIP == nullptr){
            Hashtable[index] = currSIP->getNext();
            delete currSIP;
            return;
        }
        else{
            prevSIP->setNext(currSIP->getNext());
            delete currSIP;
            return;
        }
    }




};

