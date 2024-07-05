;;;; -*- Mode: Lisp -*-

;;;; jsonparse.lisp --

;;;; JSON-Parser in Lisp

;;;; Mattia Ingrassia  879204
;;;; Alessandro Isceri 879309
;;;; Universita` degli Studi di Milano Bicocca

;;; if JSONString is a JSONObject (starts with { )
;;; apply the function jsonparse-obj on the rest of the input string
;;; else if JSONString is a JSONARRAY (starts with [ )
;;; apply the function jsonparse-array on the rest of the input string.

(defun jsonparse (JSONString)
  (let ((JSONCharList (remove-blanks (coerce JSONString 'list))))
    (cond ((equal (first JSONCharList) #\{)
	   (nth-value 0 (read-from-string
			 (coerce (first (jsonparse-obj (cdr JSONCharList)))
				 'string))))
	  ((equal (first JSONCharList) #\[)
	   (nth-value 0 (read-from-string
			 (coerce (first (jsonparse-array (cdr JSONCharList)))
				 'string))))
	  (T (error
	      "Syntax error: jsonparse(input), input must start with { or [.")))))

;;; jsonparse-keyvalue returns a list (Pairs, Rest-of-input)
;;; (first ret) -> K-V Pairs of the obj as a list (("k" v) ("k1" v1) ...)
;;; (second ret) -> Rest-of-input
;;; jsonparse-obj returns a list (JSONOBJ, Rest-of-input)
;;; where JSONOBJ is (JSONOBJ (first ret))

(defun jsonparse-obj (JSONCharList)
  (let ((ret (jsonparse-keyvalue JSONCharList)))
    (cond
      ((equal (first (second ret)) #\})
       (list (append (coerce "(JSONOBJ " 'list)
		     (first ret)
		     (coerce ")" 'list))
	     (cdr (second ret))))
      (T (error
	  "Syntax error: jsonparse-obj(input) input must finish with }")))))

;;; get-array-values returns a list (Array-Elements, Rest-of-input)
;;; (first ret) -> Values (ELements) of the array as a list (v1 v2 v3 ...)
;;; (second ret) -> Rest-of-input
;;; jsonparse-array returns a list (JSONARRAY, Rest-of-input)
;;; where JSONARRAY is (JSONARRAY (first ret))

(defun jsonparse-array (JSONCharList)
  (let ((ret (get-array-values JSONCharList)))
    (cond 
      ((equal (first (second ret)) #\])
       (list (append (coerce "(JSONARRAY " 'list)
		     (first ret)
		     (coerce ")" 'list))
	     (cdr (second ret)))) 
      (T (error
	  "Syntax error: jsonparse-array(input) input must finish with ]")))))

;;; jsonparse-keyvalue returns a list (Pairs, Rest-of-input)
;;; where Pairs is a list (("k" v) ("k1" v1) ...) and rest-of-input
;;; are all the remaining (not analysed yet) chars of the input.
;;; get-key returns a list (Key, Rest-of-input)
;;; currentKey = (first key) 
;;; if after the key (rest-of-input) there is ":", then we get the current
;;; value using the function get-value which returns the same output as
;;; get-key.
;;; get-value returns a list (Value, rest-of-input)
;;; currentValue = (first Value) 
;;; if the following char of the value is } (base case) then the function
;;; returns a list (Pair, rest-of-input) where Pair is the list containing
;;; the last pair key-value of the object.
;;; Otherwise, if the following char of the value is "," the function makes
;;; a recursive call on the rest of the input (all other pairs)
;;; then the function returns a list (Pairs, rest-of-input).
;;; the output is built recursively by appending the pairs starting from
;;; the end of the obj

(defun jsonparse-keyvalue (JSONCharList)
  (let ((CheckEmptyOBJ (remove-blanks JSONCharList)))
    (cond ((equal (first CheckEmptyOBJ)
		  #\})
	   (list NIL CheckEmptyOBJ))
	  (T (let ((Ret (get-key (remove-blanks JSONCharList))))
	       (let ((currentKey (first Ret))
		     (CharListAfterKey (remove-blanks (second Ret))))
		 (cond ((equal (first CharListAfterKey) #\:)
			(let ((RetValue
			       (get-value (remove-blanks (cdr CharListAfterKey)))))
			  (let ((currentValue (first RetValue))
				(CharListAfterValue (remove-blanks (second RetValue))))
			    (cond ((equal (first CharListAfterValue) #\})
				   (list (append (coerce "(" 'list)
						 currentKey
						 '(#\space)
						 currentValue
						 (coerce ")" 'list))
					 CharListAfterValue))
				  ((and (equal (first CharListAfterValue) #\,)
					(not (equal (first (remove-blanks (cdr CharListAfterValue))) #\})))
				   (let ((RetRec
					  (jsonparse-keyvalue (cdr CharListAfterValue))))
				     (list (append (coerce "(" 'list)
						   currentKey
						   '(#\space)
						   currentValue
						   (coerce ")" 'list)
						   '(#\space)
						   (first RetRec))
					   (second RetRec))))
				  ((null CharListAfterValue) RetValue)
				  (T (error
				      "Syntax error: jsonparse-keyvalue(input) pairs must be separated ~
                                       by , or } must be the last char of ~
                                       the object"))))))
		       (T (error
			   "Syntax error: jsonparse-keyvalue(input) key and value must be ~
                           separated by : .")))))))))

;;; (get-array-values 1, 2, 3]) -> "1 2 3"
;;; get-array-values (input) returns a list (arrayValues, rest-of-input) 
;;; where arrayValues is a list that contains all the elements of the array 
;;; get-value and currentValue are used as in jsonparse-keyvalue
;;; if the following char of the value is ] (base case) then the function
;;; returns a list (currentValue, rest-of-input).
;;; Otherwise, if the following char of the value is "," the function makes
;;; a recursive call on the rest of the input (all other elements)
;;; the output is built recursively by appending the values (elements)
;;; starting from the end of the array

(defun get-array-values (JSONCharList)
  (let ((CheckEmptyArray (remove-blanks JSONCharList)))
    (cond ((equal (first CheckEmptyArray)
		  #\])
	   (list NIL CheckEmptyArray))
	  (T
	   (let ((RetValue (get-value (remove-blanks JSONCharList))))
	     (let ((currentValue (first RetValue))
		   (CharListAfterValue (remove-blanks (second RetValue))))
	       (cond ((equal (first CharListAfterValue) #\])
		      (list
		       currentValue
		       CharListAfterValue))
		     ((and (equal (first CharListAfterValue) #\,)
			   (not (equal (first (cdr (remove-blanks CharListAfterValue))) #\])))
		      (let ((RetRec (get-array-values (cdr CharListAfterValue))))
			(list (append
			       currentValue 
			       '(#\space)
			       (first RetRec))
			      (second RetRec))))
		     ((null CharListAfterValue) RetValue)
		     (T (error
			 "Syntax error: get-array-values(input) elements must be separated by ~
                          , or ] must be the last char of the array")))))))))

;;; get-key applies the function get-string which returns
;;; a list (currentKey, rest-of-input)

(defun get-key (JSONCharList)
  (cond ((not (equal (first JSONCharList) #\"))
	 (error "Syntax error: get-key(input), keys must start with \""))
        (T (get-string JSONCharList))))

;;; get-value returns a list (Value, rest-of-input)
;;; get-value checks the first char of the value, 
;;; if the first char is " then the function get-string is applied to
;;; the input and it returns the value as a string.
;;; if the first char is { then the function jsonparse-obj is applied to
;;; the input and it returns (JSONOBJ (k v) ...).
;;; if the first char is [ then the function jsonparse-array is applied to
;;; the input and it returns (JSONARRAY v1 v2 ...).
;;; if the first char is a digit or -, E, e, ., + the function get-number is
;;; applied and it returns the value of the number (also in scientific
;;; notation)
;;; check-boolean returns a list (bool, rest-of-input)
;;; where bool is a list of char that can contain (null, false or true)
;;; bool is the empty list if the current value is not a boolean
;;; if bool (first check-boolean) is not an empty list,
;;; it returns (bool, rest-of-input)

(defun get-value (JSONCharList)
  (let ((checkBoolean (check-boolean JSONCharList)))
    (cond ((equal (first JSONCharList) #\")
	   (get-string JSONCharList))
          ((equal (first JSONCharList) #\{)
	   (jsonparse-obj (cdr JSONCharList)))
          ((equal (first JSONCharList) #\[)
	   (jsonparse-array (cdr JSONCharList)))
          ((or (and (< (char-code (first JSONCharList)) 58) 
                    (> (char-code (first JSONCharList)) 47)) 
               (equal (char-code (first JSONCharList)) 45) 
               (equal (char-code (first JSONCharList)) 69) 
               (equal (char-code (first JSONCharList)) 101) 
               (equal (char-code (first JSONCharList)) 43)) 
           (get-number JSONCharList))
          ((not (null (first checkBoolean))) checkBoolean)
          (T
	   (error
	    "Syntax error: get-value(input), the value must be a boolean, ~
             an object, an array, a string or a number")))))

;;; remove-blanks(input) returns the input without the white-spaces
;;; (space, \t, \n, \r) 
;;; at the beginning of the input string (it stops when it reads
;;; something that is not a white-space)

(defun remove-blanks (input)
  (cond ((or (equal (first input) #\Space) 
             (equal (first input) #\Tab) 
             (equal (first input) #\Linefeed) 
             (equal (first input) #\Return))
         (remove-blanks (cdr input)))
        (T input)))

;;; get-string (input quotes acc) 
;;; quotes = 0 -> the function hasn't read the (open) quotes
;;; quotes = 1 -> the function has already read the (open) quotes
;;; if quotes = 0 and the next char of input is a ",
;;; the string starts from the next char.
;;; if quotes = 1 and the next char of input is a ",
;;; the string is finished -> return a list (acc rest-of-input)
;;; where acc contains all the chars of the string.
;;; if quotes = 1 and the next char of input is not a " and not \,
;;; is a "normal char" so the function is called recursevely on the rest
;;; of the input and the char is added in the accumulator.
;;; if quotes = 1 and the next char of input is a \,
;;; the function is called recursevely on the rest of the input and the
;;; special char (\n, \t, ...) is added in the accumulator.

(defun get-string (input &optional (quotes 0) (acc '()))
  (cond ((and (= quotes 0)
	      (equal (first input) #\"))
	 (get-string (cdr input) 1 '(#\")))
	((and (= quotes 1)
	      (equal (first input) #\LineFeed))
	 (error "Syntax error: get-string(input), string can not be ~
                on multiple lines"))
        ((and (= quotes 1)
	      (equal (first input) #\"))
	 (list (append acc '(#\")) (cdr input)))
        ((and (= quotes 1)
	      (not (equal (first input) #\"))
	      (not (equal (first input) #\\)))
	 (get-string (cdr input) quotes (append acc (list (first input)))))
        ((and (= quotes 1)
	      (equal (first input) #\\))
	 (get-string (cdr (cdr input)) quotes (append acc (add-backslash input))))
        (T (error
	    "Syntax error: get-string(input), string must be between quotes"))))

;;; add-backslash(input), it takes the first char of input, if it is a \, it
;;; returns the same list of chars with one more \ for escaping it later

(defun add-backslash (CharList)
  (cond
    ((and (equal (first CharList) #\\)
	  (equal (second CharList) #\"))
     (append '(#\\ #\\ #\\) (list (second CharList))))
    ((equal (first CharList) #\\)
     (append '(#\\ #\\) (list (second CharList))))))


;;; get-number(input) parses a number and returns a list
;;; (number, rest-of-input), where number is the parsed number
;;; (floating point/integer/scientific notation) the function works
;;; recursively by reading chars until the char read is something different
;;; from +, -, e, E, ., 0-9
;;; when it reads another char it checks if the number is well formatted
;;; using the function parse-float and if it is, the number is returned

(defun get-number (input &optional (acc '()))
  (cond 
    ((and (null acc)
	  (equal (first input) #\+))
     (error "get-number(input), numbers can't start with +"))
    ((or (and (< (char-code (first input)) 58) 
              (> (char-code (first input)) 47)) 
         (equal (first input) #\.)
	 (equal (first input) #\-)
	 (equal (first input) #\+)
	 (equal (first input) #\e)
	 (equal (first input) #\E))
     (get-number (cdr input) (append acc (list (first input)))))
    (T (cond ((integerp (read-from-string (coerce acc 'string)))
	      (list acc input))
	     ((floatp (read-from-string (coerce acc 'string)))
	      (list acc input))
	     (T (error
		 "Syntax error: get-number(input), number is not well formatted"))))))

;;; the function check-boolean(input) returns a list(bool, rest-of-input)
;;; where bool can be true, false, null or empty list
;;; it checks the first n chars, and returns the read value
;;; if it's not a boolean, it returns an empty list

(defun check-boolean (input)
  (cond ((and (equal (first input) #\t)
	      (equal (second input) #\r)
	      (equal (third input) #\u)
	      (equal (fourth input) #\e))
	 (list (coerce "true" 'list) (cdr (cdr (cdr (cdr input))))))
        ((and (equal (first input) #\n)
              (equal (second input) #\u)
              (equal (third input) #\l)
              (equal (fourth input) #\l)) 
         (list (coerce "null" 'list) (cdr (cdr (cdr (cdr input))))))
        ((and (equal (first input) #\f)
              (equal (second input) #\a)
              (equal (third input) #\l)
              (equal (fourth input) #\s)
              (equal (fifth input) #\e)) 
         (list (coerce "false" 'list) (cdr (cdr (cdr (cdr (cdr input)))))))
        (T '(() ()))))

;;; jsonread(filename) reads the file and returns the JSON-parsed content

(defun jsonread (filename)
  (with-open-file (in filename
		      :direction :input
		      :if-does-not-exist :error)
    (jsonparse (read-file-json in))))

;;; read-file-json(input-stream) reads from the input stream
;;; line by line until it reaches EOF

(defun read-file-json (input-stream)
  (let ((line (read-line input-stream nil)))
    (cond ((null line) NIL)
          (T (concatenate 'string
			  line
			  (coerce '(#\LineFeed) 'string)
			  (read-file-json input-stream))))))

;;; jsonaccess
;;; jsonaccess(JSON fields)
;;; jsonaccess returns the value identified by the fields list
;;; if JSON is an array and the first value of fields is a number n, the
;;; function nth is applied to the input to get the (n+1)th element
;;; if JSON is an object (starts with JSONOBJ) the function is applied
;;; recursevelyon the rest of the list then the function checks if the first
;;; value of fields is equal to the "current" key of the object and if it is,
;;; it retuns the "current" value, otherwise, the function is called
;;; recursevely on the other pairs key-value of the object

(defun jsonaccess (JSON &rest fields)  
  (cond ((null (first fields)) JSON)
        ((and (numberp (first fields)) (equal (first JSON) 'JSONARRAY)) 
         (let ((nElement (nth (+ (first fields) 1) JSON)))
           (cond ((null nElement)
		  (error
		   "jsonaccess(JSON fields), unable to access nth-element of the array."))
                 (T (apply 'jsonaccess nElement (cdr fields))))))
        ((stringp (first fields))
	 (cond ((equal (first JSON) 'JSONOBJ)
		(apply 'jsonaccess (cdr JSON) fields))
	       ((equal (first fields)
		       (first (nth 0 JSON)))
		(apply 'jsonaccess (second (nth 0 JSON)) (cdr fields)))
	       ((not (null JSON))
		(apply 'jsonaccess (cdr JSON) fields))))
	(T (error
	    "jsonaccess(JSON fields), unable to access the specified element of ~
             the JSON-object.")))) 

;;; jsondump(JSON filename) -> writes on filename the parsed JSON 
(defun jsondump (JSON filename)
  (with-open-file (out filename
		       :direction :output
		       :if-exists :supersede
		       :if-does-not-exist :create)
    (format out (coerce (parse-reverse JSON) 'string)))
  (return-from jsondump filename))

;;; parse-reverse(JSON nTab)
;;; JSON is a list containing the parsed object, the function reads the list
;;; and builds a well formatted string containing the corresponding
;;; JSON element.
;;; if JSON is an array, it calls the function parse-reverse-array
;;; if JSON is an object, it calls the function parse-reverse-obj

(defun parse-reverse (JSON &optional (nTab 0))
  (cond ((equal (first JSON) 'JSONARRAY)
	 (append '(#\[)
		 '(#\LineFeed)
		 (parse-reverse-array (cdr JSON) (+ nTab 1))
		 '(#\LineFeed)
		 (insert-tab nTab)
		 '(#\])))
        ((equal (first JSON) 'JSONOBJ)
	 (append '(#\{)
		 '(#\LineFeed)
		 (parse-reverse-obj (cdr JSON) (+ nTab 1))
		 '(#\LineFeed)
		 (insert-tab nTab)
		 '(#\})))))

;;; parse-reverse-array(JSONList nTab)
;;; the function returns the corresponding JSON string
;;; of the array passed in input.
;;; the string is built by adding \n and the "current" tabulation (\t) then 
;;; if the element is a string it adds quotes, the function checks if the
;;; "current" value is the last one
;;; if it's the last one, it doesn't add a comma
;;; if the value is an array or an object, the function parse-reverse
;;; is called on the value 

(defun parse-reverse-array (JSONList nTab)
  (let ((checkBoolean (first (check-boolean (coerce
					     (string-downcase (write-to-string (first JSONList)))
					     'list)))))
    (append (insert-tab nTab)
	    (cond ((null JSONList) NIL)
		  ((null (second JSONList))
		   (cond ((stringp (first JSONList))
			  (append '(#\")
				  (coerce (first JSONList) 'list)
				  '(#\")
				  (parse-reverse-array (cdr JSONList) nTab)))
			 ((numberp (first JSONList))
			  (append (coerce (write-to-string (first JSONList)) 'list)
				  (parse-reverse-array (cdr JSONList) nTab)))
			 ((not (null checkBoolean))
			  (append checkBoolean
				  (parse-reverse-array (cdr JSONList) nTab)))
			 (T (append (parse-reverse (first JSONList) nTab)
				    (parse-reverse-array (cdr JSONList) nTab)))))
		  ((stringp (first JSONList))
		   (append '(#\")
			   (coerce (first JSONList) 'list)
			   '(#\" #\, #\LineFeed)
			   (parse-reverse-array (cdr JSONList) nTab)))
		  ((numberp (first JSONList))
		   (append (coerce (write-to-string (first JSONList)) 'list)
			   '(#\, #\LineFeed)
			   (parse-reverse-array (cdr JSONList) nTab)))
		  ((not (null checkBoolean))
		   (append checkBoolean
			   '(#\, #\LineFeed)
			   (parse-reverse-array (cdr JSONList) nTab)))
		  (T (append (parse-reverse (first JSONList) nTab)
			     '(#\, #\LineFeed)
			     (parse-reverse-array (cdr JSONList) nTab)))))))

;;; parse-reverse-obj(JSONList nTab)
;;; the function returns the corresponding JSON string of the object
;;; passed in input, the string is built by adding \n and the "current"
;;; tabulation (\t) then the "current" key and the colons (:) then if
;;; the element is a string it adds quotes, the function checks if the
;;; "current" value is the last one:
;;; if it's the last one, it doesn't add a comma
;;; if the value is an array or an object, the function parse-reverse is
;;; called on the value 

(defun parse-reverse-obj (JSONList nTab)
  (let ((firstPair (first JSONList)) (restOfTheList (cdr JSONList)))
    (let ((key (first firstPair)) (value (second firstPair)))
      (let ((checkBoolean
	     (first (check-boolean
		     (coerce (string-downcase (write-to-string value)) 'list)))))
        (cond ((null firstPair) NIL)
              ((stringp key) 
	       (append (insert-tab nTab)
		       '(#\")
		       (coerce key 'list)
		       '(#\" #\Space #\: #\Space)
		       (cond ((null restOfTheList)
			      (cond ((stringp value)
				     (append '(#\")
					     (coerce value 'list)
					     '(#\")
					     (parse-reverse-obj restOfTheList nTab)))
				    ((numberp value)
				     (append (coerce (write-to-string value) 'list)
					     (parse-reverse-obj restOfTheList nTab)))
				    ((not (null checkBoolean))
				     (append checkBoolean
					     (parse-reverse-obj restOfTheList nTab)))
				    (T (append (parse-reverse value nTab)
					       (parse-reverse-obj restOfTheList nTab)))))
			     ((stringp value)
			      (append '(#\")
				      (coerce value 'list)
				      '(#\" #\, #\LineFeed)
				      (parse-reverse-obj restOfTheList nTab)))
			     ((numberp value)
			      (append (coerce (write-to-string value) 'list)
				      '(#\, #\LineFeed)
				      (parse-reverse-obj restOfTheList nTab)))
			     ((not (null checkBoolean))
			      (append checkBoolean
				      '(#\, #\LineFeed)
				      (parse-reverse-obj restOfTheList nTab)))
			     (T (append (parse-reverse value nTab)
					'(#\, #\LineFeed)
					(parse-reverse-obj restOfTheList nTab))))))
	      (T (error
		  "Syntax error: (parse-reverse-obj(input), key must be a string.")))))))

;;; insert-tab(n) -> the function returns a list of
;;; chars containing n-times the char \t

(defun insert-tab (n)
  (cond ((= n 0) NIL)
        ((> n 0) (append '(#\Tab) (insert-tab (- n 1))))))


;;;; end of file -- jsonparse.lisp --
