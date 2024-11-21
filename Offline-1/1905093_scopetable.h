#include <bits/stdc++.h>
#include "1905093_symbolinfo.h"
using namespace std;

class scopeTable
{

private:
    int hashValue;              //THE VALUE WHICH HASH FUNCTION RETURNS AFTER HASHING
    int size;                  // HASHTABLE SIZE
    scopeTable *parentPointer; // ARRAY TO HOLD MULTIPLE SCOPES
    symbolinfo **arr;          // 2D ARRAY SO THAT WE CAN HOLD THE CHAINS OF SYMBOL TOKENS
    function<int(string)> func;     //THE HASH FUNCTION WHICH WILL BE PASSED AS PARAMETER
    int id;                     //UNIQUE ID FOR EACH SCOPETABLE

    //& extentions
    static int stat;            //TO KEEP TRACK OF THE ORDER OF THE SCOPETABLES
    

public:
    scopeTable(int size, function<int(string)> func)
    { // Initialization

        arr = new symbolinfo *[size];
        for (int i = 0; i < size; i++)
        {
            arr[i] = NULL;
        }
        this->size = size;
        this->hashValue = hashValue;
        parentPointer = NULL;
        this->id = 1;
        this->func = func;
    }

    void printing(string s, int c)
    {
        cout << s << ":" << c << endl;
    }

    ~scopeTable()
    { // Destructor

        for(int i=0; i<size ; i++){
            symbolinfo *curr = arr[i];

            while (curr!=NULL)
            {
                symbolinfo *temp = curr->getSymbolInfo();   //DELETE THE CHAIN BY TRAVERSING IT
                delete curr;
                curr=temp;
            }
            
        }
    }

    int getId()
    {
        return id;
    }

    void setId(int id)
    {
        this->id = id;
    }

    scopeTable *getParentPointer()          //PARENT POINTER OF THE CURRENT SCOPTABLE
    {
        return parentPointer;
    }

    void setParentPointer(scopeTable *getParentPointer)         //SET THE PARENTPOINTER OF THE CURRENT SCOPETABLE
    {
        this->parentPointer = getParentPointer;
    }

    bool insertElement(symbolinfo x)
    {

        
        symbolinfo *temp = new symbolinfo(x.getName(), x.getType(), NULL);// Creating a new symbolinfo object
        int pos = func(x.getName());                    // GET HASHVALUE USING HASH-FUNCTION
        int counter = 0;                                // FOR KEEPING TRACK OF THE POS IN THE CHAIN 
        temp->setHashedValue(pos);

        if (arr[pos] == NULL)                           // if the hashed position is empty then place the newly created object in that position
        {
            arr[pos] = new symbolinfo();
            arr[pos] = temp;
            temp->setHashedPos(counter);
            return true;
        }

        else                                            // if hashed position is not empty
        {                            
            symbolinfo *y = arr[pos]; // temporary object
            int track = counter;
            do
            {
                if (y->getName() == x.getName())         // check if the chain contains the given key already
                {
                    return NULL;                        // not successful hense false
                }

                if (track != 0)
                    y = y->getSymbolInfo();
                track = track + 1;                      // keep increamenting the track number for future usecase

            } while (y->getSymbolInfo() != NULL);

            // If execution reaches this stage then there was no duplicate hence we place the new object at the end of the chain
            y->setHashedPos(track);
            y->setSymbolInfo(temp);
            return true;
        }
    }


    symbolinfo *search(string str, int x = 0)
    {

        int hashedValue1 = func(str);       //GET THE HASHED-VALUE USING THE HASH FUNCTION
        int hashedPos1 = x;

        symbolinfo *s = arr[hashedValue1];

        if (s == NULL)                          //HASHEDVALUE EMPTY THUS NOT FOUND
        {
            return NULL;
        }

        else                                    //HASHEDVALUE CONTAINS LETTERS NOW 
        {
            symbolinfo *y = s;                  //NOW WE BASICALLY CHECK IF str IS CONTAINED ANYWHERE IN THE CHAIN OF THE HASHED-VALUE
            while (y != NULL)
            {
                if (y->getName() == str)        //SEARCH SUCCESSFUL
                {
                    y->setHashedPos(hashedPos1);
                    return y;
                }
                y = y->getSymbolInfo();
                hashedPos1++;
            }

            return NULL;                        //CHAIN FULLY TRAVERSED,SEARCH UNSUCCESSFUL
        }
    }


    bool deleteElement(string x)
    {

        symbolinfo *temp = arr[func(x)];                //GET THE POINTER OF THE HASHED-VALUE OF STR
        symbolinfo *prev = NULL;

        while (temp != NULL)                            //IF HASHEDVALUE IS NOT EMPTY,CHANCE OF x BEING PRESENT
        {
            if (temp->getName() == x)                   //x FOUND,NOW WE JUST ADJUST THE POINTERS FOR DELETION PURPOSE 
            {
                symbolinfo *y = temp->getSymbolInfo();

                if (prev != NULL)                       // MEANING x IS NOT THE FIRST ENTRY IN THE HASH TABLE CHAIN
                { 
                    prev = y;
                }
                else                                     // x IS THE FIRST ENTRY
                {
                    arr[func(x)] = y;
                }

                delete temp;                             // DEALLOCATION
                return true;
            }

            prev = temp;
            temp = temp->getSymbolInfo();
        }

        return false;                                   // reached end of the chain but didn't find the element so deletion was not possible
    }

    // print all the tokens that are in the current scope
    void printScopeTable()
    {

        cout << "\tScopeTable# " << id << endl;

        int i = 0;

        // PRINTING FOR EACH SCOPETABLE
        while (i < size)
        {
            cout << "\t" << i + 1 << "--> ";

            symbolinfo *temp = arr[i];

            // EACH POSITION TOKENS
            while (temp != NULL)
            {
                cout << "<";
                cout << temp->getName() << "," << temp->getType() << "> ";
                temp = temp->getSymbolInfo();
            }
            i++;
            // if(i!=size)
            cout << endl;
        }
    }

    static int getStat(){
        return stat;
    }

    static void setStat(){
        stat++;
    }
};

int scopeTable::stat=1;