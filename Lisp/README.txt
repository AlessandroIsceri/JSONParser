Progetto realizzato da:
- Mattia Ingrassia  879204
- Alessandro Isceri 879309

Il programma prende la stringa in input e la converte in una lista di caratteri.
Per l'implementazione del programma sono state create le seguenti funzioni:

- jsonparse:
    Prende in input una stringa in formato json e restituisce il corrispettivo
    oggetto parsato, riportando un errore in caso l'input non seguisse gli 
    standard sintattici di JSON.

- jsonparse-obj:
    Viene chiamata da jsonparse per gestire gli oggetti.

- jsonparse-array:
    Viene chiamata da jsonparse per gestire gli array.

- jsonparse-keyvalue:
    Viene chiamata da jsonparse-obj per gestire le coppie chiave-valore.

- get-array-values:
    Viene chiamata da jsonparse-array per gestire gli elementi dell'array.

- get-key:
    Viene chiamata da jsonparse-keyvalue e restituisce la chiave della coppia.

- get-value:
    Viene chiamata da jsonparse-keyvalue e restituisce il valore della coppia.

- remove-blanks:
    Viene utilizzata per rimuovere i "whitespaces" in eccesso al di fuori 
    delle stringhe.

- get-string:
    Viene utilizzata per gestire le stringhe da get-key (o da get-value 
    qualora value fosse una stringa).

- add-backslash:
    Viene utilizzata per gestire i caratteri di escape all'interno delle
    stringhe.

- get-number:
    Viene utilizzata per gestire i numeri da get-value.

- check-boolean:
    Viene utilizzata per gestire i booleani (true, false, null) da get-value.

- jsonread:
    Prende in input il nome di un file e chiama jsonparse sul contenuto di esso.

- read-file-json:
    Utilizzato da jsonread, legge il file riga per riga e ritorna il contenuto
    del file.

- jsonaccess:
    Dato un un oggetto JSON (derivato da jsonparse) e una serie di "campi", 
    recupera l'oggetto corrispondente.

- jsondump:
    Prende in input il nome di un file e un oggetto JSON (derivato da 
    jsonparse) e scrive l'oggetto in sintassi JSON sul file.

- parse-reverse:
    Prende in input un oggetto parsato e restituisce la corrispettiva stringa
    in formato JSON, aggiungendo la formattazione.

- parse-reverse-array:
    Viene chiamata da parse-reverse per gestire gli array.

- parse-reverse-obj:
    Viene chiamata da parse-reverse per gestire gli oggetti.

- insert-tab:
    Prende in input un numero intero e restituisce altrettanti \t.