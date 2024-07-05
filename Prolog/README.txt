Progetto realizzato da:
- Mattia Ingrassia  879204
- Alessandro Isceri 879309

Il programma prende la stringa in input e la manipola tramite l'utilizzo di atomi
e grazie all'operatore UNIV (=..).
Per l'implementazione del programma sono stati creati i seguenti predicati:

- value/1:
    Risulta vero se l'input e' una stringa, un numero o un booleano rappresentato
    come atomo (true, false, null).

- jsonparse/2:
    Prende in input una stringa in formato json e restituisce il corrispettivo
    oggetto parsato, riportando un errore in caso l'input non seguisse gli 
    standard sintattici di JSON.

- jsonparse_keyvalue/2:
    Viene chiamato da jsonparse per gestire le coppie chiave-valore.

- jsonparse_array/2:
    Viene chiamato da jsonparse per gestire gli array.

- jsonaccess/3:
    Dato un un oggetto JSON (derivato da jsonparse) e una serie di "campi", 
    recupera l'oggetto corrispondente.

- objsearch/3
    Viene chiamato da jsonaccess, cerca la coppia la cui chiave corrisponde
    a quella richiesta.

- listsearch/3
    Viene chiamato da jsonaccess, cerca l'n-esimo elemento dell'array.

- jsonread/2:
    Prende in input il nome di un file e chiama jsonparse sul contenuto di esso.

- jsondump/2:
    Prende in input il nome di un file e un oggetto JSON (derivato da 
    jsonparse) e scrive l'oggetto in sintassi JSON sul file.

- jsonparse_reverse/3:
    Prende in input un oggetto parsato e restituisce la corrispettiva stringa
    in formato JSON, aggiungendo la formattazione.

- jsonparse_reverse_array/3:
    Viene chiamato da jsonparse_reverse per gestire gli array.

- print_tab/2:
    Prende in input un numero intero e restituisce altrettanti \t.

- check_escapes/2 e replace/2:
    Vengono utilizzati per gestire i caratteri di escape all'interno delle
    stringhe.