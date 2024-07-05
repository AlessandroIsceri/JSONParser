%%%% -*- Mode: Prolog -*-

%%%% jsonparse.pl --

%%%% JSON-Parser in Prolog

%%%% Mattia Ingrassia  879204
%%%% Alessandro Isceri 879309
%%%% Universita` degli Studi di Milano Bicocca

%%% value/1
%%% checks if the value passed as a parameter is a String/ a Number/
%%% a boolean (treated as an atom).
%%% (objects and arrays are treated in a different way)

value(true).
value(false).
value(null).
value(X):-
    string(X),
    !.
value(X):-
    number(X),
    !.

%%% jsonparse/2
%%% Checks whether the parameter "String" is an array or an object, and calls
%%% the corresponding predicate.
%%% The Control is made with the Univ (=..) operator, which operates with
%%% atoms.
%%% For this reason, "String" must be converted from string to an atom.
%%% If the input parameter is an object, it is converted back to a String.
%%% The variable "Ret" is the parsed value


%%% case: "String" is an empty array (base case)
jsonparse('[]', jsonarray([])) :-
    !.

%%% case: "String" is an empty object (base case)
jsonparse('{}', jsonobj([])) :-
    !.

%%% case: unmatched parentheses
jsonparse(String, _Ret) :-
    catch(term_to_atom(_Atom, String), Err, true),
    nonvar(Err),
    !,
    fail.

%%% case: "String" is an object (it's surrounded by {})
jsonparse(String, jsonobj(Ret)) :-
    term_to_atom(Atom, String),
    Atom =.. [Symbol, Obj | []],
    Symbol = '{}',
    term_to_atom(Obj, ObjStr),
    !,
    jsonparse_keyvalue(ObjStr, RetTemp),
    flatten(RetTemp, Ret).

%%% case: "String" is an array (it's surrounded by [])
jsonparse(String, jsonarray(Ret)) :-
    term_to_atom(Atom, String),
    Atom =.. [Symbol, _FirstElement, _OtherElements | []],
    Symbol = '[|]',
    !,
    jsonparse_array(String, Ret).

%%% jsonparse_keyvalue/2
%%% Checks whether the "String" contains a single pair or multiple pairs
%%% If there are multiple pairs, the predicate calls recursevely itself
%%% Otherwise, if there is only one pair we are in the base case, so
%%% if the value/1 predicate returns true, the value is returned as it is
%%% Otherwise, the value is an array or an object and the predicate calls
%%% the jsonparse/2 predicate on the value

%%% case: "String" is a single key:value pair and the value is a number
%%% or a string or a boolean (base case).
jsonparse_keyvalue(String, (Key, Value)) :-
    term_to_atom(Atom, String),
    Atom =.. [Symbol, Key, Value | []],
    Symbol = ':',
    value(Value),
    !.

%%% case: "String" is a single key:value pair and the value is an array
%%% or an object (base case).
jsonparse_keyvalue(String, (Key, ParsedValue)) :-
    term_to_atom(Atom, String),
    Atom =.. [Symbol, Key, Value | []],
    Symbol = ':',
    !,
    term_to_atom(Value, ValueStr),
    jsonparse(ValueStr, ParsedValue).

%%% case: "String" contains multiple key:value pairs
jsonparse_keyvalue(String, [ParsedPair, OtherParsedPairs]) :-
    term_to_atom(Atom, String),
    Atom =.. [Symbol, FirstPair, OtherPairs | []],
    Symbol = ',',
    !,
    term_to_atom(FirstPair, FirstPairStr),
    term_to_atom(OtherPairs, OtherPairsStr),
    jsonparse_keyvalue(FirstPairStr, ParsedPair),
    jsonparse_keyvalue(OtherPairsStr, OtherParsedPairs).

%%% jsonparse_array/2
%%% the predicate calls recursevely jsonparse/2 and jsonparse_array/2
%%% on the elements of the array and returns the corresponding parsed array

%%% case: input is an empty array (base case)
jsonparse_array('[]', []) :- 
    !.

%%% case: "JSONString" is a list having a simple value as the first element,
%%% it returns the simple value as it is and the result of
%%% jsonparse_array/2 on the rest of the list
jsonparse_array(JSONString, [Element | Ret]) :-
    term_to_atom([Element | Others], JSONString),
    is_list([Element | Others]),
    value(Element),
    !,
    term_to_atom(Others, OthersStr),
    jsonparse_array(OthersStr, Ret).

%%% case: "JSONString" is a list having an array or an object as the first 
%%% element, it calls jsonparse/2 on the first element and jsonparse_array/2 
%%% on the rest of the list
jsonparse_array(JSONString, [Ret1 | Ret2]) :-
    term_to_atom([Element | Others], JSONString),
    is_list([Element | Others]),
    !,
    term_to_atom(Element, ElementStr),
    term_to_atom(Others, OthersStr),
    jsonparse(ElementStr, Ret1),
    jsonparse_array(OthersStr , Ret2).

%%% jsonaccess/3 
%%% jsonaccess(JSON, Fields, Value)
%%% the predicate searches in the JSON parameter the Value identified by
%%% the keys/numbers in the list Fields

%%% case: JSON is an object (JSONObj) and the Fields list is empty
%%% returns JSONObj (base case)
jsonaccess(JSONObj, [], JSONObj) :-
    JSONObj =.. [S, _List],
    S = 'jsonobj',
    !.

%%% case: JSON is an array (JSONArray) and the Fields list is empty
%%% fails because it is required by the project guidelines (base case)
jsonaccess(JSONArray, [], JSONArray) :-
    JSONArray =.. [S, _List],
    S = 'jsonarray',
    fail,
    !.

%%% case: JSON is an object (JSONObj) and the Field passed is a string
%%% calls objsearch/3 that returns the corresponding Value of the Key (Field)
jsonaccess(JSONObj, Field, Res) :-
    string(Field),
    !,
    JSONObj =.. [S, List],
    S = 'jsonobj',
    objsearch(List, Field, Res).

%%% case: JSON is an array (JSONArray) and the Field passed is a number
%%% calls listsearch/3 that returns the Value in position Field (0-based)
jsonaccess(JSONArray, Field, Res) :-
    number(Field),
    !,
    JSONArray =.. [S, List],
    S = 'jsonarray',
    listsearch(List, Field, Res).

%%% case: Field is a list with one element, it calls recusevely jsonaccess/3
%%% passing the element of the list as its value
jsonaccess(JSON, [Field], Res) :-
    !,
    jsonaccess(JSON, Field, Res).

%%% case: Field is a list with more than one element, it calls jsonaccess/3
%%% on the first element of the list and on the rest of the list
jsonaccess(JSON, [Field | Others], Res) :-
    !,
    jsonaccess(JSON, Field, TempRes),
    jsonaccess(TempRes, Others, Res).

%%% objsearch/3
%%% objsearch([Pairs], Field, Value)
%%% it searches the pair having as a Key the parameter Field and returns the
%%% corresponding Value

%%% case: Field is equal to the key of the pair,
%%% it returns the Value (base case)
objsearch([(Field, Res) | _Others], Field, Res) :-
    !.

%%% case: Field is not equal to the key of the pair, it calls recursevely the
%%% predicate on the rest of the list
objsearch([(_First, _Value) | Others], Field, Res) :-
    !,
    objsearch(Others, Field, Res).

%%% listsearch/3 
%%% listsearch([Values], N, Res)
%%% returns the N-th element of the array

%%% case: N is equal to 0, it returns the current Value (element)
listsearch([Field | _Others], 0, Field) :- 
    !.

%%% case: N is greater than 0, it calls recursevely the predicate with
%%% the rest of the list and N - 1 as parameters
listsearch([_Field | Others], Number, Res) :-
    Number > 0,
    !,
    NewNumber is Number - 1,
    listsearch(Others, NewNumber, Res).

%%% jsonread/2
%%% jsonread(Filename, JSON), opens the specified file in read mode and it
%%% returns the parsed input using the predicate jsonparse/2
jsonread(FileName, JSON) :-
    read_file_to_string(FileName, Result, []),
    jsonparse(Result, JSON).

%%% jsondump/2
%%% jsondump(JSON, FileName), parses from JSON-parsed value to standard-JSON
%%% it opens the specified file in write mode and it writes the standard-JSON
%%% output
jsondump(JSON, FileName) :-
    jsonparse_reverse(JSON, 0, JSONRet),
    open(FileName, write, Out),
    write(Out, JSONRet),
    close(Out).

%%% jsonparse_reverse/3
%%% jsonparse_reverse(JSONObj, Ntab, JSONString)
%%% The predicate assumes that JSONObj is well formatted, it parses the JSON 
%%% input from the JSON-parsed version to the standard-JSON (indented)
%%% Ntab is used for keeping track of the nested indentation

%%% case: JSON is an empty list, it returns an empty string (base case)
jsonparse_reverse([], _Ntab, ""):-
    !.

%%% case: JSON is an object, the predicate increments the number of tabs and
%%% calls recursevely itself with the content of the object as a parameter
jsonparse_reverse(JSONObj, Ntab, Ret) :-
    JSONObj =.. [S, List],
    S = 'jsonobj',
    !,
    NewNtab is Ntab + 1,
    jsonparse_reverse(List, NewNtab, Temp),
    print_tab(Ntab, TempTab),
    string_concat("{\n", Temp, Temp1),
    string_concat(Temp1, "\n", Temp2),
    string_concat(Temp2, TempTab, Temp3),
    string_concat(Temp3, "}", Ret).

%%% case: JSON is a list containing a single pair [(key, value)], it calls 
%%% recursevely itself with the pair as a parameter
jsonparse_reverse(JSON, Ntab, Ret) :-
    JSON =.. [S, Pair, []],
    S = '[|]',
    !,
    jsonparse_reverse(Pair, Ntab, Ret).

%%% case: JSON is a single pair, with a string Value
%%% it adds the \" escape char in order to preserve the quotes
jsonparse_reverse(JSONObj, Ntab, Ret) :-
    JSONObj =.. [S, Key, Value],
    S = ',',
    string(Value),
    !,
    print_tab(Ntab, TempTab),
    check_escapes(Key, NewKey),
    check_escapes(Value, NewValue),
    string_concat(TempTab, "\"", Temp),
    string_concat(Temp, NewKey, Temp1),
    string_concat(Temp1, "\" : \"", Temp2),
    string_concat(Temp2, NewValue, Temp3),
    string_concat(Temp3, "\"", Ret).

%%% case: JSON is a single pair, with a numeric/boolean Value
jsonparse_reverse(JSONObj, Ntab, Ret) :-
    JSONObj =.. [S, Key, Value],
    S = ',',
    value(Value),
    !,
    print_tab(Ntab, TempTab),
    check_escapes(Key, NewKey),
    string_concat(TempTab, "\"", Temp),
    string_concat(Temp, NewKey, Temp1),
    string_concat(Temp1, "\" : ", Temp2),
    string_concat(Temp2, Value, Ret).

%%% case: JSON is a single pair, with an Object as a value
jsonparse_reverse(JSONObj, Ntab, Ret1) :-
    JSONObj =.. [S, Key, Obj],
    S = ',',
    !,
    jsonparse_reverse(Obj, Ntab, Ret),
    print_tab(Ntab, TempTab),
    check_escapes(Key, NewKey),
    string_concat(TempTab, "\"", Temp),
    string_concat(Temp, NewKey, Temp1),
    string_concat(Temp1, "\" : ", Temp2),
    string_concat(Temp2, Ret, Ret1).

%%% case: JSON is a list of pairs [(key1, value1) (key2 value2) ...], it 
%%% calls recursevely itself on the first pair on the rest of the list,
%%% returning the concat. of the two results.
jsonparse_reverse(JSONObj, Ntab, Ret) :-
    JSONObj =.. [S, Pair, List],
    S = '[|]',
    !,
    jsonparse_reverse(Pair, Ntab, Res1),
    jsonparse_reverse(List, Ntab, Res2),
    string_concat(Res1, ",\n", Temp),
    string_concat(Temp, Res2, Ret).

%%% case: JSON is an array, the predicate increments the number of tabs and
%%% it calls jsonparse_reverse_array/3 with the content of the array
%%% as a parameter
jsonparse_reverse(JSONObj, Ntab, Ret) :-
    JSONObj =.. [S, List],
    S = 'jsonarray',
    !,
    NewNtab is Ntab + 1,
    jsonparse_reverse_array(List, NewNtab, Temp),
    print_tab(Ntab, TempTab),
    string_concat("[\n", Temp, Temp1),
    string_concat(Temp1, "\n", Temp2),
    string_concat(Temp2, TempTab, Temp3),
    string_concat(Temp3, "]", Ret).

%%% jsonparse_reverse_array/3
%%% jsonparse_reverse_array(Value, Ntab, Ret)
%%% Value is a list of elements/an element of the array
%%% The predicate assumes that Value is well formatted, it parses the Value 
%%% input from the JSON-parsed version to the standard-JSON (indented)

%%% case: Value is an empty list (base case)
jsonparse_reverse_array([], _Ntab, "") :-
    !.

%%% case: Value is a string
jsonparse_reverse_array(Value, _Ntab, Ret) :-
    string(Value),
    !,
    check_escapes(Value, NewValue),
    string_concat("\"", NewValue, Temp1),
    string_concat(Temp1, "\"", Ret).

%%% case: Value is a number or a boolean
jsonparse_reverse_array(Value, _Ntab, Value) :-
    value(Value),
    !.

%%% case: Value is a list with length = 1
%%% the Element of the List is an array or an object
jsonparse_reverse_array([First], Ntab, Ret) :-
    First =.. [S, _L],
    (
        S = 'jsonobj';
        S = 'jsonarray'
    ),
    !,
    jsonparse_reverse(First, Ntab, Ret1),
    print_tab(Ntab, TempTab),
    string_concat(TempTab, Ret1, Ret).

%%% case: the First element of the List is a number/string/boolean
jsonparse_reverse_array([First], Ntab, Ret) :-
    !,
    jsonparse_reverse_array(First, Ntab, Ret1),
    print_tab(Ntab, TempTab),
    string_concat(TempTab, Ret1, Ret).

%%% case: Value is a list containing multiple Values
%%% the First element of the List is an array or an object
jsonparse_reverse_array([First | Others], Ntab, Ret) :-
    First =.. [S, _L],
    (
        S = 'jsonobj';
        S = 'jsonarray'
    ),
    !,
    jsonparse_reverse(First, Ntab, Out1),
    jsonparse_reverse_array(Others, Ntab, Out2),
    print_tab(Ntab, TempTab),
    string_concat(TempTab, Out1, Temp),
    string_concat(Temp, ",\n", Temp1),
    string_concat(Temp1, Out2, Ret).

%%% case: Value is a list containing multiple Values
%%% the First element of the List is a number/string/boolean
jsonparse_reverse_array([First | Others], Ntab, Ret) :-
    !,
    jsonparse_reverse_array(First, Ntab, Out1),
    jsonparse_reverse_array(Others, Ntab, Out2),
    print_tab(Ntab, TempTab),
    string_concat(TempTab, Out1, Temp),
    string_concat(Temp, ",\n", Temp1),
    string_concat(Temp1, Out2, Ret).

%%% print_tab/2
%%% print_tab(N, Ret), it returns a list of chars containing
%%% N-times the char "\t"

%%% case: N = 0, it returns an empty string
print_tab(0, "") :- 
    !.
%%% case: N > 0, it adds a tab and it calls itself with N-1
%%% as the first parameter
print_tab(N, Ret) :-
    NewN is N - 1,
    print_tab(NewN, Temp),
    string_concat("\t", Temp, Ret).

%%% check_escapes/2
%%% check_escapes(String, Out)
%%% the predicate calls the predicate replace passing a list of chars as a 
%%% parameter and it returns the string with correctly escaped chars
check_escapes(String, Out) :-
    string_codes(String, Chars),
    replace(Chars, NewChars),
    string_codes(Out, NewChars).

%%% replace -> da \n a '\\n'
%%% replace/2 
%%% replace(List, OutList)
%%% the predicate adds a \ before all the escape chars 

%%% case: the input List is empty, it returns an empty list
replace([], []).

%%% case: FirstChar is \n
replace([FirstChar | CharsToCheck], [92, 110 | OtherChars]) :-
    FirstChar =:= 10,
    replace(CharsToCheck, OtherChars),
    !.

%%% case: FirstChar is \t
replace([FirstChar | CharsToCheck], [92, 116 | OtherChars]) :-
    FirstChar =:= 9,
    replace(CharsToCheck, OtherChars),
    !.

%%% case: FirstChar is \r
replace([FirstChar | CharsToCheck], [92, 114 | OtherChars]) :-
    FirstChar =:= 13,
    replace(CharsToCheck, OtherChars),
    !.

%%% case: FirstChar is \"
replace([FirstChar | CharsToCheck], [92, 34 | OtherChars]) :-
    FirstChar =:= 34,
    replace(CharsToCheck, OtherChars),
    !.

%%% recursive case: FirstChar is not an escape char
replace([FirstChar | CharsToCheck], [FirstChar | OtherChars]) :- 
    replace(CharsToCheck, OtherChars), 
    !.

%%%% end of file -- jsonparse.pl --
