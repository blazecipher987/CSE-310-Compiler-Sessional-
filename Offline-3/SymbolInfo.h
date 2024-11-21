#ifndef SYMBOLINFO_H
#define SYMBOLINFO_H

#include<bits/stdc++.h>
using namespace std;

class SymbolInfo {
public:

    string name;        //SYMBOLINFO NAME
    string type;        //WHAT TYPE SYMBOLINFO IT IS
    SymbolInfo* next;   //A POINTER USED FOR CHAINING INT THE HASHTABLE
    bool parenTrue;


    vector<SymbolInfo*> params; // FOR DECLARACTON LIST AND FUNCTIONS
    vector<SymbolInfo*> parse;  //FOR ADDING THE CHILDS OF THE CURRENT SYMNOL
    bool defined;           // CHECKING DOUBLE DEFINITION
    unsigned arraySize; // TO CHECK IF THE VARUABLE IS AN ARRAY

    int beginTime;      //TO GET STARTLINE
    int endTime;        //TO GET ENDLINE
    string dataType;    //FOR PRINTING THE DATATYPE OF THE RULE
    bool isLeaf;        //CHECK IF THE CURR SYMBOLINFO IS A TERMINAL
    string printerUtil;     //USED IN CASE OF ARRAY PRINTING MATCHING

//DEFAULT CONSTRUCTOR
    SymbolInfo() {
        name = "NOT DEFINED";
        type = "NOT DEFINED";
        next = nullptr;

        defined = false;
        arraySize = -1;
        parenTrue = false;
    }

//CONSTRUCTOR USED IN THE .Y FILE
    SymbolInfo(const string &name, const string &type, int beginTime, int endTime) {
        
        
        this->name = name;
        this->type = type;
        this->beginTime = beginTime;
        this->endTime = endTime;
        next = nullptr;

        defined = false;
        arraySize = -1;
        parenTrue = false;
    }

//WHEN ONLY NAME AND TYPE OF ARE CONCERN
    SymbolInfo(const string &name, const string &type) {
        this->name = name;
        this->type = type;
        next = nullptr;

        defined = false;
        arraySize = -1;
        parenTrue = false;
    }

//COPY A SYMBOLINFO VARIABLE ONTO ANOTHER SYMBOLINFO VARIABLE
    SymbolInfo* copySymbol(SymbolInfo* symbol) {
        name = symbol->name;
        type = symbol->type;
        next = symbol->next;

        params = symbol->params;
        defined = symbol->defined;
        arraySize = symbol->arraySize;

        return this;
    }

    void setLeaf(bool b){
        isLeaf = b;
    }

    bool getLeaf(){
        return isLeaf;
    }

    ~SymbolInfo() { //DESCTRUCTOR
        params.clear();
    }

    string getName() const {
        return name;
    }

    int getBeginTime() const{
        return beginTime;
    }

    void setBeginTime(int x){
        beginTime = x;
    }

    int getEndTime() const {
        return endTime;
    }

    void setEndTime(int x){
        endTime = x;
    }

    void setDataType(string s){
        this->dataType  = s;
    }

    string getDataType(){
        return dataType;
    }

    SymbolInfo* setName(const string &name) {
        this->name = name;
        return this;
    }

    string getType() const {
        return type;
    }

    SymbolInfo* setType(const string &type) {
        this->type = type;
        return this;
    }

    SymbolInfo *getNext() {
        return next;
    }

    SymbolInfo* setNext(SymbolInfo *next) {
        this->next = next;
        return this;
    }

    vector<SymbolInfo*> getParams() const {
        return this->params;
    }

    SymbolInfo* setParams(const vector<SymbolInfo*> &params) {
        this->params = params;
        return this;
    }

//TO ADD PARAMETERS TO THE CURR SYMBOLINFO, USED FOR STORING FUNCTION PARAMETERS
    SymbolInfo* addParam(SymbolInfo* param) {
        //cout<<"Called on "<<endl;
        params.push_back(param);
        return this;
    }


    SymbolInfo* addParam(SymbolInfo* param, int x,string str) {
        //cout<<"Called on "<<x<< "Line "<<str<<endl;
        params.push_back(param);
        return this;
    }

//SET THE CHILDERN IN THE CURR SYMBOLINFO, THIS IS BASICALLY THE SETTER FOR THE CHILDRENS 
    void setParseItems(vector<SymbolInfo*> v){

        for( SymbolInfo * x : v){
           // cout<<"We were here: "<<x->getName() <<endl;
            parse.push_back(x);
        }
        //THIS CHILDRENS WILL BE USED IN THE TERMINAL
    }


//THE MAIN PRINTING FUNCTION FOR THE PARSETREE, THIS IS CALLED FROM THE .Y FILE
    void parsetreePrint(ostream &os, int gap){
        
        int i=0;
        while(i<gap){   //FOR SETTING THE INDENTATION OF THE PARSETREE ITEMS
            os<<" ";
            i++;
        }

        // if(gap==75)
        // return;
        //cout<<name<<endl;
        //os<<dataType << " oo "<<":"<<"\t<Line: "<<beginTime<<">"<<endl;

        //PRINT ONLY THE STARTLINE IF THE POINTER IS A LEAF
        if(isLeaf==true){
            os<<dataType<<"\t<Line: "<<beginTime<<">"<<endl;
            return;
            
        }

        //PRINT BOTH START AND ENDLINES IF THE POINTER IS NOT A LEAF/NON-TERMINAL
        else{
            os<<dataType<<" \t<Line: "<<beginTime<<"-"<<endTime<<">"<<endl;
        }

        //AGAIN PARSE THE CHILDRENS OF THE CURR POINTER, CONTINUE LIKE THIS
        for(SymbolInfo *x: parse){
            x->parsetreePrint(os, gap+1);
        }

        //THIS FUNCTION IS BASICALLY A DFS WHICH USED THE STARTIME AND ENDTIME 
        //TO CORRESPOND TO THE BEGINLINE AND ENDLINE AND THE PARSE THE TREE

    }

    unsigned getArraySize() const {
        return arraySize;
    }

    SymbolInfo* setArraySize(unsigned arraySize) {
        this->arraySize = arraySize;
        return this;
    }

    bool isVariable() {
        // {
        //     cout<<"Here func "<<isFunction()<<" : array "<<isArray()<<endl;
        // }

        if(isFunction()){
            return false;
        }
        else{
            return true;
        }
        
    }

    bool isFunction() {
        if (type.find("FUNCTION") != string::npos) {
            return true;
        }
        return false;
    }

    SymbolInfo *getReturnType()
    {
        if (isFunction())       //      ONLY APPLICABLE FOR FUNCTIONS
        {

            return params[0];
        }
        return nullptr;
    }



    bool isDefined() {      //CHECK IF THE FUNCTION IS DEFINED BEFORE
        return defined;
    }

    SymbolInfo* setDefined() {
        this->defined = true;
    }

    bool isArray() {        //IF CURR SYMBOLINFO REPRESENTS AN ARRAY THEN THERE MUST A SIZE >=0;
        return arraySize != -1;
    }
    
};


#endif //SYMBOLINFO_H
