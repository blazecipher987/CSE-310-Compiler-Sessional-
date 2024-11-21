#include <bits/stdc++.h>
#include "1905093_scopetable.h"
using namespace std;

class symbolTable
{

private:
    int size;               //STORE THE SIZE OF THE HASHTABLE
    int hashValue;
    scopeTable *scopetable;
    function<int(string)> func;         //FUNCTION TEMPLATE TO PASS THE SBDM HASH FUNCTION

public:
    symbolTable(int size, function<int(string)> func)
    {
        this->size = size;
        this->func = func;
        scopetable = new scopeTable(size, func);
        // cout<<"lol"<<scopetable<<endl;
    }

    ~symbolTable()
    {
        while(scopetable!=NULL){
            scopeTable *temp = scopetable->getParentPointer();
            delete scopetable;
            scopetable = temp;
        }
    }

    void printCurrScope()       //PRINT THE CURRENT SCOPE TABLE
    {
        scopetable->printScopeTable();
    }

    void printAllScope()        //PRINT ALL THE SCOPE TABLES STARTING FROM THE NUMBER 1
    {

        scopeTable *temp = scopetable;

        while (temp != NULL)
        {
            temp->printScopeTable();
            temp = temp->getParentPointer();
        }
    }

    symbolinfo *search(string str)      //SEARCH FOR A STRING TOKEN
    {
        bool flag = false;
        scopeTable *temp = scopetable;

        while (temp != NULL)
        {

            symbolinfo *s = temp->search(str);

            if (s != NULL)
            { // found in the position
                flag = true;
                cout << "\t'" << str << "' found in ScopeTable# " << temp->getId() << " at position " << s->getHashedValue() + 1 << ", " << s->getHashedPos() + 1;
            }

            if (flag)               //FLAG TRUE THUS FOUND
            {
                return s;
            }

            temp = temp->getParentPointer();
        }

        {
            // cout<<"donda"<<endl;
            cout << "\t'" << str << "'"
                 << " not found in any of the ScopeTables";
            return NULL;
        }
    }

    void enterScope()               
    { // create a new scope for the variables

        scopeTable *temp = new scopeTable(size, func);
        temp->setParentPointer(scopetable);
        scopetable = temp;

        scopeTable *x = temp->getParentPointer();
        if (x != NULL)
        {
            //&extention
            temp->setId(1+ scopeTable::getStat());
            scopeTable::setStat();
        }
//
        cout << "\tScopeTable# " << temp->getId() << " created";
    }

    void exitScope()                //EXIT CURRENT SCOPE AND ALSO DEALLOCATE THE MEMORY
    {

        scopeTable *x;

        if (scopetable->getId() == 1)
        {
            cout << "\tScopeTable# 1 cannot be removed";
        }

        else if (scopetable != NULL && scopetable->getId() != 1)
        { // if the current scope has space allocated then we can delete it

            cout << "\tScopeTable# " << scopetable->getId() << " removed";
            x = scopetable;
            scopetable = scopetable->getParentPointer();      // since last scope is deleted,now the currnet scope will be the parent of the deleted scope
            delete x;                                         // Deallocate memory
        }
    }

    void deleteBaseScope(){             //SPECIAL FUNCTION FOR DELETEING THE BASE SCOPE WITH ID 1,CALLED WHEN Q IS CALLED

        scopeTable *x;
        bool flag=false;
        while(!flag){

        if (scopetable->getId() == 1)
        {
            cout<<endl;
            cout << "\tScopeTable# " << scopetable->getId() << " removed";
            cout<<endl;
            flag=true;
            delete scopetable;
        }

        else if (scopetable != NULL && scopetable->getId() != 1)
        { // if the current scope has space allocated then we can delete it

            cout << "\tScopeTable# " << scopetable->getId() << " removed";
            cout<<endl;
            x = scopetable;
            scopetable = scopetable->getParentPointer();      // since last scope is deleted,now the currnet scope will be the parent of the deleted scope
            //scopetable->setCount(scopetable->getCount() + 1); //
            delete x;                                         // Deallocate memory
        }
        
        }
        
    }

    bool insertElement(symbolinfo x)            //INSERT A NEW SYMBOL INTO THE SYMBOLTABLE
    {

        symbolinfo *s = scopetable->search(x.getName());
        // cout<<"insider"<<endl;

        if (s == NULL)
        {
            scopetable->insertElement(x);
            symbolinfo *y = scopetable->search(x.getName());
            cout << "\tInserted in ScopeTable# " << scopetable->getId() << " at position " << y->getHashedValue() + 1 << ", " << y->getHashedPos() + 1;
            return true;
        }
        else
        {
            cout << "\t'" << x.getName() << "' already exists in the current ScopeTable";
            return false;
        }
    }

    bool removeElement(string str)              //SEARCH AND REMOVE AN ELEMENT FROM THE SYMBOLTABLE
    {

        symbolinfo *s = scopetable->search(str);

        if (s == NULL)
        {
            cout << "\tNot found in the current ScopeTable";
            return false;
        }
        else
        {
            cout << "\tDeleted "
                 << "'" << s->getName() << "' from ScopeTable# " << scopetable->getId() << " at position " << s->getHashedValue() + 1 << ", " << s->getHashedPos() + 1;
            scopetable->deleteElement(str);
            return true;
        }
    }
};