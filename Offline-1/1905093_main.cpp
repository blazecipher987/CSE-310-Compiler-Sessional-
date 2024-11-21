#include <bits/stdc++.h>
#include "1905093_symboltable.h"
using namespace std;

int modder;
//COLLECTED FROM ASSIGNMENT SPECIFICATION
int SDBMHash(string str)
{
    long long int hash = 0;
    long long int i = 0;
    long long int len = str.length();

    for (i = 0; i < len; i++)
    {
        hash = (str[i]) + ((hash << 6)) + ((hash << 16)) - hash;
    }

    return hash % modder;
}


//HELPER FUNCTION TO PRINT ACCODING TO THE FORMAT
void printHelper(string command, int counter, string x = "", string concat1 = "", string y = "", string concat2 = "")
{
    cout << "Cmd " << counter << ": " << command << concat1 << x << concat2 << y << endl;
}


//HELPER FUNCTION TO PRINT ACCORDINT TO FORMAT WHEN THE PARAMETERS ARE MISMATCHED
void printHelperForDelete(string command, int counter, string str[], int i)
{
    cout << "Cmd " << counter << ": " << command;

    for (int x = 1; x <= i; x++)
    {
        cout << " ";
        cout << str[x];
    }
    cout << endl;
}


int main()
{
    //FILE STREAM
    freopen("input.txt", "r", stdin);
    freopen("output.txt", "w", stdout);


    int bucketSize;
    cin >> bucketSize;
    modder=bucketSize;      //USED IN THE HASH FUNCTION

    string ins;
    string spaces = " ";
    int counter = 1;
    symbolTable *sym = new symbolTable(bucketSize, SDBMHash);
    cout << "\tScopeTable# 1 created" << endl;

    while (cin >> ins)
    {
        string name, type;

        if (ins.compare("I1") == 0)
        {

            // cout<<"Insider2"<<endl;
            cin >> name >> type;
            printHelper(ins, counter, name, spaces, type, spaces);
            sym->insertElement(symbolinfo(name, type));
        }

        else if (ins.compare("I") == 0)
        {
            //* for case when there is no parameter at all
            if (cin.peek() == '\n')
            {
                // cout<<i<<endl;
                printHelper(ins, counter);
                cout << "\tNumber of parameters mismatch for the command I" << endl;
                counter++;
                continue;
            }

            int i;
            string str[100];
            for (i = 1;;)
            {
                cin >> str[i];
                // cout<<str[i]<<" BOO"<<endl;
                if (cin.peek() == '\n')
                {
                    // cout<<i<<endl;
                    break;
                }
                i++;
            }
            if (i == 2)
            {
                printHelper(ins, counter, str[1], spaces, str[2], spaces);
                sym->insertElement(symbolinfo(str[1], str[2]));
            }

            //*when there is more than one parameter
            else
            {
                // printHelper(ins,counter, name);
                printHelperForDelete(ins, counter, str, i);
                cout << "\tNumber of parameters mismatch for the command I";
            }
        }

        else if (ins.compare("L") == 0)
        {
            //* for case when there is no parameter at all
            if (cin.peek() == '\n')
            {
                // cout<<i<<endl;
                printHelper(ins, counter);
                cout << "\tNumber of parameters mismatch for the command L" << endl;
                counter++;
                continue;
            }

            int i;
            string str[100];
            for (i = 1;;)
            {
                cin >> str[i];
                // cout<<str[i]<<" BOO"<<endl;
                if (cin.peek() == '\n')
                {
                    // cout<<i<<endl;
                    break;
                }
                i++;
            }
            if (i == 1)
            {
                printHelper(ins, counter, str[1], spaces);
                sym->search(str[1]);
            }

            //*when there is more than one parameter
            else
            {
                // printHelper(ins,counter, name);
                printHelperForDelete(ins, counter, str, i);
                cout << "\tNumber of parameters mismatch for the command L";
            }
        }

        else if (ins.compare("P") == 0)
        {
            cin >> name;
            // cout<<"Insider1"<<endl;

            if (name.compare("C") == 0)
            {
                // cout << "Insider" << endl;
                printHelper(ins, counter, name, spaces);
                sym->printCurrScope();
            }

            if (name.compare("A") == 0)
            {

                printHelper(ins, counter, name, spaces);
                sym->printAllScope();
            }
        }

        else if (ins.compare("D") == 0)
        {

            //* for case when there is no parameter at all
            if (cin.peek() == '\n')
            {
                // cout<<i<<endl;
                printHelper(ins, counter);
                cout << "\tNumber of parameters mismatch for the  command D" << endl;
                counter++;
                continue;
            }

            int i;
            string str[100];
            for (i = 1;;)
            {
                cin >> str[i];
                // cout<<str[i]<<" BOO"<<endl;
                if (cin.peek() == '\n')
                {
                    // cout<<i<<endl;
                    break;
                }
                i++;
            }
            if (i == 1)
            {
                printHelper(ins, counter, str[1], spaces);
                sym->removeElement(str[1]);
            }

            //*when there is more than one parameter
            else
            {
                // printHelper(ins,counter, name);
                printHelperForDelete(ins, counter, str, i);
                cout << "Number of parameters mismatch for the command D";
            }
        }

        else if (ins.compare("S") == 0)
        {

            printHelper(ins, counter);
            sym->enterScope();
        }

        else if (ins.compare("E") == 0)
        {

            printHelper(ins, counter);
            sym->exitScope();
        }

        else if (ins.compare("Q") == 0)
        {
            
            printHelper(ins, counter);
            sym->deleteBaseScope();
            return 0;
        }

        counter++;
        if (ins.compare("P") != 0)
            cout << endl;
        ins.clear();
    }
}