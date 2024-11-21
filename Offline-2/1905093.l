%option noyywrap


%x STRING_STATE
%x SINGLE_COMMENT_STATE
%x DOUBLE_COMMENT_STATE
%x STRING_MULTI
%x SKIP_LINES

%{
#include <bits/stdc++.h>
#include "1905093_SymbolTable.h"
using namespace std;

FILE *logout;
FILE *tokenout;


string str1;
string str2;

string str_com;

int intermediate_line_count= 0;
int line_count=1;
int error_count= 0;
bool flagString =false;

SymbolTable st(10);

%}



WHITESPACE [ \t\f\r\v]+
DIGIT [0-9]
LETTER [a-zA-Z]
NEWLINE \n

%%
{WHITESPACE} {}		            //do nothing
{NEWLINE} {line_count++;}		//increase line count

"if"	|

"for"   |

"do"    |

"int"   |

"float" |

"void"  |

"switch"    |

"default"   {
			string strName = string(yytext);
            transform(strName.begin(), strName.end(), strName.begin(), ::toupper);
            const char *s= strName.c_str();
			fprintf(tokenout,"<%s, %s>", s, yytext);
			fprintf(tokenout,"\n");
			fprintf(logout,"Line# %d: Token <%s> Lexeme %s found\n",line_count,s,yytext);
}

"else"  |

"while" |

"break" |

"char"  |

"double"    |

"return"    |

"case"  |

"continue"  {
            string strName = string(yytext);
            transform(strName.begin(), strName.end(), strName.begin(), ::toupper);
            const char *s= strName.c_str();
			fprintf(tokenout,"<%s, %s>", s, yytext);
			fprintf(tokenout,"\n");
			fprintf(logout,"Line# %d: Token <%s> Lexeme %s found\n",line_count,s,yytext);
		}
		
{DIGIT}+ 	{
				fprintf(tokenout,"<CONST_INT, %s>",yytext);
				fprintf(tokenout,"\n");
				fprintf(logout,"Line# %d: Token <CONST_INT> Lexeme %s found\n",line_count,yytext);
            
			}


{DIGIT}*("."{DIGIT}+)?([Ee][+-]?{DIGIT}+)?    {
                fprintf(tokenout,"<CONST_FLOAT, %s>",yytext);
				fprintf(tokenout,"\n");
				fprintf(logout,"Line# %d: Token <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
      
            }



({LETTER}|_)({LETTER}|{DIGIT}|_)*  {
                fprintf(tokenout,"<ID, %s>",yytext);
				fprintf(tokenout,"\n");
				fprintf(logout,"Line# %d: Token <ID> Lexeme %s found\n",line_count,yytext);
                if(st.lookUpCurrScope(yytext)!=NULL){       //SEE IF ID IS IN CURRENT SCOPE
                    fprintf(logout, "\t%s already exisits in the current ScopeTable\n", yytext);
                }
                else{               //INSERT ONLY IF IT DOESN'T EXIST
                    st.insert(yytext, "ID");
                    st.printAllScopeTables(logout);
                }
        }

'{LETTER}'  {               //FOR CHAR VALUES
                string str;
                str= str+ yytext[1];
                fprintf(tokenout,"<CONST_CHAR, %s>",str.c_str());
				fprintf(tokenout,"\n");
				fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %s found\n",line_count,str.c_str());
              
            }




"+"		|

"-"		{
			fprintf(tokenout,"<ADDOP, %s>",yytext);
			fprintf(tokenout,"\n");
			fprintf(logout,"Line# %d: Token <ADDOP> Lexeme %s found\n",line_count,yytext);
           
		}

"*"     |
"/"     |
"%"     {
            fprintf(tokenout,"<MULOP, %s>",yytext);
			fprintf(tokenout,"\n");
			fprintf(logout,"Line# %d: Token <MULOP> Lexeme %s found\n",line_count,yytext);
        }

"++"    |
"--"    {
            fprintf(tokenout,"<INCOP, %s>",yytext);
			fprintf(tokenout,"\n");
			fprintf(logout,"Line# %d: Token <INCOP> Lexeme %s found\n",line_count,yytext);
        }
"<"     |
"<="    |
">"     |
">="    |
"=="    |
"!="    {
            fprintf(tokenout,"<RELOP, %s>",yytext);
			fprintf(tokenout,"\n");
			fprintf(logout,"Line# %d: Token <RELOP> Lexeme %s found\n",line_count,yytext);
        }

"="     {
            fprintf(tokenout,"<ASSIGNOP, %s>",yytext);
			fprintf(tokenout,"\n");
			fprintf(logout,"Line# %d: Token <ASSIGNOP> Lexeme %s found\n",line_count,yytext);
        }

"&&"    |
"||"    {
            fprintf(tokenout,"<LOGICOP, %s>",yytext);
            fprintf(tokenout,"\n");
			fprintf(logout,"Line# %d: Token <LOGICOP> Lexeme %s found\n",line_count,yytext);
        }

"&"     |
"|"     |
"^"     |
"<<"    |
">>"    {
            fprintf(tokenout,"<BITOP, %s>",yytext);
			fprintf(tokenout,"\n");
			fprintf(logout,"Line# %d: Token <BITOP> Lexeme %s found\n",line_count,yytext);
        }

"!"     {
            fprintf(tokenout,"<NOT, %s>",yytext);
			fprintf(tokenout,"\n");
			fprintf(logout,"Line# %d: Token <NOT> Lexeme %s found\n",line_count,yytext);
        }

"("     {
            fprintf(tokenout,"<LPAREN, %s>",yytext);
			fprintf(tokenout,"\n");
			fprintf(logout,"Line# %d: Token <LPAREN> Lexeme %s found\n",line_count,yytext);
        }

")"     {
            fprintf(tokenout,"<RPAREN, %s>",yytext);
			fprintf(tokenout,"\n");
			fprintf(logout,"Line# %d: Token <RPAREN> Lexeme %s found\n",line_count,yytext);
        }

"{"     {
            st.EnterScope();            //NEW SCOPE ENTERED
            fprintf(tokenout,"<LCURL, %s>",yytext);
			fprintf(tokenout,"\n");
			fprintf(logout,"Line# %d: Token <LCURL> Lexeme %s found\n",line_count,yytext);
        }

"}"     {
            st.ExitScope();             //LEAVING CURRENT SCOPE
            fprintf(tokenout,"<RCURL, %s>",yytext);
			fprintf(tokenout,"\n");
			fprintf(logout,"Line# %d: Token <RCURL> Lexeme %s found\n",line_count,yytext);
        }

"["     {
            fprintf(tokenout,"<LSQUARE, %s>",yytext);
			fprintf(tokenout,"\n");
			fprintf(logout,"Line# %d: Token <LSQUARE> Lexeme %s found\n",line_count,yytext);
        }

"]"     {
            fprintf(tokenout,"<RSQUARE, %s>",yytext);
			fprintf(tokenout,"\n");
			fprintf(logout,"Line# %d: Token <RSQUARE> Lexeme %s found\n",line_count,yytext);
        }

","     {
            fprintf(tokenout,"<COMMA, %s>",yytext);
			fprintf(tokenout,"\n");
			fprintf(logout,"Line# %d: Token <COMMA> Lexeme %s found\n",line_count,yytext);
        }

";"     {
            fprintf(tokenout,"<SEMICOLON, %s>",yytext);
			fprintf(tokenout,"\n");
			fprintf(logout,"Line# %d: Token <SEMICOLON> Lexeme %s found\n",line_count,yytext);
        }
		

'\\\''        {
                string str= "\'";
                fprintf(tokenout,"<CONST_CHAR, %s>",str.c_str());
				fprintf(tokenout,"\n");
				fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %s found\n",line_count,str.c_str());

            } 

'\\\"'        {
                string str= "\"";
                fprintf(tokenout,"<CONST_CHAR, %s>",str.c_str());
				fprintf(tokenout,"\n");
				fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %s found\n",line_count,str.c_str());

            } 

'\\n'        {
                string str= "\n";
                fprintf(tokenout,"<CONST_CHAR, %s>",str.c_str());
				fprintf(tokenout,"\n");
				fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %s found\n",line_count,str.c_str());
   
            }  

'\\t'        {
                string str= "\t";
                fprintf(tokenout,"<CONST_CHAR, %s>",str.c_str());
				fprintf(tokenout,"\n");
				fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %s found\n",line_count,str.c_str());
    
            }            

'\\\\'        {
                string str= "\\";
                fprintf(tokenout,"<CONST_CHAR, %s>",str.c_str());
				fprintf(tokenout,"\n");
				fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %s found\n",line_count,str.c_str());
         
            }

'\\a'        {
                string str= "\a";
                fprintf(tokenout,"<CONST_CHAR, %s>",str.c_str());
				fprintf(tokenout,"\n");
				fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %s found\n",line_count,str.c_str());
   
            } 

'\\f'        {
                string str= "\f";
                fprintf(tokenout,"<CONST_CHAR, %s>",str.c_str());
				fprintf(tokenout,"\n");
				fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %s found\n",line_count,str.c_str());

            } 

'\\r'        {
                string str= "\r";
                fprintf(tokenout,"<CONST_CHAR, %s>",str.c_str());
				fprintf(tokenout,"\n");
				fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %s found\n",line_count,str.c_str());

            } 

'\\b'        {
                string str= "\b";
                fprintf(tokenout,"<CONST_CHAR, %s>",str.c_str());
				fprintf(tokenout,"\n");
				fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %s found\n",line_count,str.c_str());

            } 

'\\v'        {
                string str= "\v";
                fprintf(tokenout,"<CONST_CHAR, %s>",str.c_str());
				fprintf(tokenout,"\n");
				fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %s found\n",line_count,str.c_str());
 
            } 

'\\0'        {
                string str= "\0";
                fprintf(tokenout,"<CONST_CHAR, %s>",str.c_str());
				fprintf(tokenout,"\n");
				fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %s found\n",line_count,str.c_str());
 
            } 



			
\"		{           //DOUBLE QUOTE DETECTED HENCE WE START THE STRING STATE
				str1.clear();
				str2.clear();
				intermediate_line_count= 0;
				str1 += "\"";
				BEGIN STRING_STATE;
		}

<STRING_STATE>\\n	{ str1 += "\\n"; str2 += "\n";  }
<STRING_STATE>\\t	{ str1 += "\\t"; str2 += "\t" ; }
<STRING_STATE>\\\\	{ str1 += "\\\\"; str2 += "\\" ; }
<STRING_STATE>\\\'	{ str1 += "\\\'"; str2 += "\'";  }
<STRING_STATE>\\\"	{ str1 += "\\\""; str2 += "\"";  }
<STRING_STATE>\\a	{ str1 += "\\a"; str2 += "\a";  }
<STRING_STATE>\\f	{ str1 += "\\f"; str2 += "\f";  }
<STRING_STATE>\\r	{ str1 += "\\r"; str2 += "\r";  }
<STRING_STATE>\\b	{ str1 += "\\b"; str2 += "\b";  }
<STRING_STATE>\\v	{ str1 += "\\v"; str2 += "\v";  }
<STRING_STATE>\\0	{ str1 += "\\0"; str2 += "\0";  }

<STRING_STATE>\\\r\n {
					intermediate_line_count++;
					str1 += "\\\r\n"; 
                   flagString = true;
                   BEGIN STRING_MULTI;      //IF NEWLINE IS ENCOUNTERED WHILE WITHIN STRING,SWITCH TO MULTILINE STRING
				}

<STRING_STATE>\\\n {
					intermediate_line_count++;
					str1 += "\\\n"; 
                     flagString = true;
                     BEGIN STRING_MULTI;    //IF NEWLINE IS ENCOUNTERED WHILE WITHIN STRING,SWITCH TO MULTILINE STRING
				}

<STRING_STATE>\"   {					//String has ended
					str1 += "\"";
					//str2 += "\"";
                    // if(flagString==true)
					// {
                    //     fprintf(logout, "Line# %d: Token <MULTI LINE STRING> Lexeme %s found\n", line_count, str1.c_str());
                    //     fprintf(tokenout,"<MULTI LINE STRING, %s>",str2.c_str());
                    //     }
                    // if(flagString==false){
                    //     fprintf(logout, "Line# %d: Token <SINGLE LINE STRING> Lexeme %s found\n", line_count, str1.c_str());
                    //     fprintf(tokenout,"<SINGLE LINE STRING, %s>",str2.c_str());
                    // }
                    fprintf(logout, "Line# %d: Token <SINGLE LINE STRING> Lexeme %s found\n", line_count, str1.c_str());
                        fprintf(tokenout,"<SINGLE LINE STRING, %s>",str2.c_str());
                    
					fprintf(tokenout,"\n");
                    line_count+= intermediate_line_count;
                    intermediate_line_count= 0;
					BEGIN INITIAL;	
				}
<STRING_STATE>[\r]?\n    {
                                       
                    error_count++;
                    fprintf(logout, "Error at line# %d: UNFINISHED_STRING %s\n", line_count, str1.c_str());
                    intermediate_line_count++;
                    line_count+= intermediate_line_count;
                    intermediate_line_count= 0;
                    BEGIN INITIAL;
                }

<STRING_STATE>.	{ str1 += yytext[0]; str2 += yytext[0];}

\/\/       {
                str_com.clear();
                intermediate_line_count= 0;
                str_com+= "//";
                BEGIN SINGLE_COMMENT_STATE;         //START THE // COMMENT STATE,AKA SINGLE LINE COMMENT
            }

<STRING_MULTI>\\n	{ str1 += "\\n"; str2 += "\n";  }
<STRING_MULTI>\\t	{ str1 += "\\t"; str2 += "\t" ; }
<STRING_MULTI>\\\\	{ str1 += "\\\\"; str2 += "\\" ; }
<STRING_MULTI>\\\'	{ str1 += "\\\'"; str2 += "\'";  }
<STRING_MULTI>\\\"	{ str1 += "\\\""; str2 += "\"";  }
<STRING_MULTI>\\a	{ str1 += "\\a"; str2 += "\a";  }
<STRING_MULTI>\\f	{ str1 += "\\f"; str2 += "\f";  }
<STRING_MULTI>\\r	{ str1 += "\\r"; str2 += "\r";  }
<STRING_MULTI>\\b	{ str1 += "\\b"; str2 += "\b";  }
<STRING_MULTI>\\v	{ str1 += "\\v"; str2 += "\v";  }
<STRING_MULTI>\\0	{ str1 += "\\0"; str2 += "\0";  }


<STRING_MULTI>\\\r\n {
					intermediate_line_count++;
					str1 += "\\\r\n"; 
                   flagString = true;
				}

<STRING_MULTI>\\\n {
					intermediate_line_count++;
					str1 += "\\\n"; 
                     flagString = true;
				}

<STRING_MULTI>\"   {					//String has ended
					str1 += "\"";
					//str2 += "\"";
                    // if(flagString==true)
					// {
                    //     fprintf(logout, "Line# %d: Token <MULTI LINE STRING> Lexeme %s found\n", line_count, str1.c_str());
                    //     fprintf(tokenout,"<MULTI LINE STRING, %s>",str2.c_str());
                    //     }
                    // if(flagString==false){
                    //     fprintf(logout, "Line# %d: Token <SINGLE LINE STRING> Lexeme %s found\n", line_count, str1.c_str());
                    //     fprintf(tokenout,"<SINGLE LINE STRING, %s>",str2.c_str());
                    // }
                    fprintf(logout, "Line# %d: Token <MULTI LINE STRING> Lexeme %s found\n", line_count, str1.c_str());
                         fprintf(tokenout,"<MULTI LINE STRING, %s>",str2.c_str());
                    
					fprintf(tokenout,"\n");
                    line_count+= intermediate_line_count;
                    intermediate_line_count= 0;
					BEGIN INITIAL;	
				}

<STRING_MULTI>[\r]?\n    {
                                       
                    error_count++;
                    fprintf(logout, "Error at line# %d: UNFINISHED_STRING %s\n", line_count, str1.c_str());
                    intermediate_line_count++;
                    line_count+= intermediate_line_count;
                    intermediate_line_count= 0;
                    BEGIN INITIAL;

                }

<STRING_MULTI>.	{ str1 += yytext[0]; str2 += yytext[0];}


<SINGLE_COMMENT_STATE>\\\r\n  {
                intermediate_line_count++;
                str_com+= "\\\r\n";

            }

<SINGLE_COMMENT_STATE>\\\n  {
                intermediate_line_count++;
                str_com+= "\\\n";

            }

<SINGLE_COMMENT_STATE>\\   {
                str_com+= "\\";
                }

<SINGLE_COMMENT_STATE>[\r]?\n {
                intermediate_line_count++;
                fprintf(logout, "Line# %d: Token <SINGLE LINE COMMENT> Lexeme %s found\n", line_count, str_com.c_str());
                line_count+= intermediate_line_count;
                intermediate_line_count=0;
                BEGIN INITIAL; 
            }     

<SINGLE_COMMENT_STATE><<EOF>> {
                fprintf(logout, "Line# %d: Token <SINGLE LINE COMMENT> Lexeme %s found\n", line_count, str_com.c_str());
                line_count+= intermediate_line_count;
                intermediate_line_count=0;
                BEGIN INITIAL; 
            }


<SINGLE_COMMENT_STATE>. { str_com+= yytext[0];}


\/\*    {
            str_com.clear();
            intermediate_line_count= 0;
            str_com+= "/*";
            BEGIN DOUBLE_COMMENT_STATE;     
}



<DOUBLE_COMMENT_STATE>\*\/    {
            str_com+= "*/";
            fprintf(logout, "Line# %d: Token <MULTI LINE COMMENT> Lexeme %s found\n", line_count, str_com.c_str());
            line_count+= intermediate_line_count;
            intermediate_line_count= 0;
            BEGIN INITIAL;
}

<DOUBLE_COMMENT_STATE><<EOF>> {
            error_count++;
            line_count=line_count+ intermediate_line_count;
            fprintf(logout, "Error at line# %d: UNFINISHED_COMMENT %s\n", line_count, str_com.c_str());
            
            intermediate_line_count= 0;
            BEGIN INITIAL;
}

<DOUBLE_COMMENT_STATE>\r            { str_com += "\r";} 

<DOUBLE_COMMENT_STATE>\n            { intermediate_line_count++; str_com += "\n";} 

<DOUBLE_COMMENT_STATE>.   {
            str_com+= yytext[0];
}





{DIGIT}*"."{DIGIT}*"."({DIGIT}|".")*  {
        error_count++;
        fprintf(logout, "Error at line# %d: TOO_MANY_DECIMAL_POINTS %s\n", line_count, yytext); 
}

{DIGIT}*("."{DIGIT}+)?([Ee][+-]?{DIGIT}*"."{DIGIT}*)    {
        error_count++;
        fprintf(logout, "Error at line# %d: ILLFORMED_NUMBER %s\n", line_count, yytext); 
}

{DIGIT}+({LETTER}|_)({LETTER}|{DIGIT}|_)+   {
        error_count++;
        fprintf(logout, "Error at line# %d: INVALID_ID_SUFFIX_NUM_PREFIX %s\n", line_count, yytext);
}

'{LETTER}[^\n]+' {
        error_count++;
        fprintf(logout, "Error at line# %d: MULTICHAR_CONST_CHAR %s\n", line_count, yytext);
}


'\\'     {
        error_count++;
        fprintf(logout, "Error at line# %d: UNFINISHED_COMMENT %s\n", line_count, yytext);
        }
'\\[nt\\afrbv0] {
        error_count++;
        fprintf(logout, "Error at line# %d: UNFINISHED_STRING %s\n", line_count, yytext);
}

''      {
        error_count++;
        fprintf(logout, "Error at line# %d: EMPTY_STRING_CONSTANT %s\n", line_count, yytext);
        }

'[^\'\n]+     {
        error_count++;
        fprintf(logout, "Error at line# %d: UNFINISHED_CHAR %s\n", line_count, yytext);
}

.   {
        error_count++;
        fprintf(logout, "Error at line# %d: UNRECOGNIZED_CHAR %s\n", line_count, yytext);    
}


%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout= fopen("1905093_log.txt","w");
	tokenout= fopen("1905093_token.txt","w");

	yyin= fin;
	yylex();
    st.printAllScopeTables(logout);
    fprintf(logout, "Total lines: %d\n", line_count);
    fprintf(logout, "Total errors: %d", error_count);
    fprintf(logout,"\n");
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}
