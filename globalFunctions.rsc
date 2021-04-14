# Due to mikrotik's scripting languages, types are not necessarily exclusive.
# In example, a variable can be both a string and a number.


################################################################################
################################################################################
##                                                                            ##
##   CONSTANTS                                                                ##
##                                                                            ##
################################################################################
################################################################################

:global "NIL";
:global "TRUE" true;
:global "FALSE" false;
:global "N" "\r\n";
:global "ASCII_UC" {"A";"B";"C";"D";"E";"F";"G";"H";"I";"J";"K";"L";"M"; \
                    "N";"O";"P";"Q";"R";"S";"T";"U";"V";"W";"X";"Y";"Z"};
:global "ASCII_LC" {"a";"b";"c";"d";"e";"f";"g";"h";"i";"j";"k";"l";"m"; \
                    "n";"o";"p";"q";"r";"s";"t";"u";"v";"w";"x";"y";"z"};
:global "ASCII_D" {"0";"1";"2";"3";"4";"5";"6";"7";"8";"9"};
:global "ASCII_WS" {"\t";"\n";"\r";" "};


################################################################################
################################################################################
##                                                                            ##
##   OVERHEAD FUNCTIONS                                                       ##
##                                                                            ##
################################################################################
################################################################################

:global funcName do={
# funcName [$0]
#   converts function name to string and strips $-symbol.
  :if ([:typeof $1]="lookup") do={
    :local fn [:tostr $1];
    :if ([:pick $fn 0]="\$") do={:return [:pick $fn 1 [:len $fn]]};
  };
  :global NIL;
  :return $NIL;
};
:global Err do={
# Err [variant] [function] [optional parameter] [optional message]
#   logs an error message
  :global "NIL";
  :global "funcName";
  
  :local msg "$[$1] in function '$[$funcName $2]'";
  :if ($3!=$NIL) do={:set msg ($msg . " for parameter '$[$3]'")};
  :if ($4!=$NIL) do={:set msg ($msg . ": \"$[$4]\"")};
  :put $msg;
  :log error $msg;
};
:global TypeErr do={
# TypeErr [function] [optional parameter] [optional message]
#   log a TypeError, return $NIL
  :global "NIL";
  :global "Err";
  
  [$Err "TypeError" $1 $2 $3];
  :return $NIL;
};
:global ValueErr do={
# ValueErr [function] [optional parameter] [optional message]
#   logs a ValueError, and returns $NIL
  :global "NIL";
  :global "Err";
  
  [$Err "ValueError" $1 $2 $3];
  :return $NIL;
};
:global ParamErr do={
# ParamErr [function] [optional parameter] [optional message]
#   logs a ParameterError, and returns $NIL
  :global "NIL";
  :global "Err";
  
  [$Err "ParameterError" $1 $2 $3];
  :return $NIL;
};
:global opt do={
# opt [parameter] [default]
#   returns the first parameter if it's not $NIL, otherwise the default.
  :global "NIL";
  :if ($1!=$NIL) do={:return $1};
  :return $2;
};


################################################################################
################################################################################
##                                                                            ##
##   BASIC TYPE VERIFICATION FUNCTIONS                                        ##
##                                                                            ##
################################################################################
##                                                                            ##
##   is<Type>    return TRUE if $1 is the required type, FALSE otherwise      ##
##   isN<Type>   return TRUE if $1 is the required type, or NIL               ##
##                                                                            ##
################################################################################
################################################################################

################################################################################
##   nil                                                                      ##
################################################################################
:global isNil do={
  :global NIL;
  :return (($1=$NIL) or \
           ([:typeof $1]="nil") or \
           ([:typeof $1]="nothing"));
};

################################################################################
##   bool                                                                     ##
################################################################################
:global isBool do={
  :return ([:typeof $1]="bool");
};
:global isNBool do={
  :global isNil;
  :global isBool;
  :return (([$isNil $1]) or ([$isBool $1]));
};

################################################################################
##   int                                                                      ##
################################################################################
:global isInt do={
  :return (([:typeof $1]="num") or \
           ($1="0") or \
           ($1~"^-\?[1-9]{1}[0-9]*\$"));
};
:global isNInt do={
  :global isNil;
  :global isInt;
  :return (([$isNil $1]) or ([$isInt $1]));
};

################################################################################
##   float                                                                    ##
################################################################################
:global isFloat do={
  :return (($1~"^-\?[0-9]*\\.[0-9]*\$") and \
           (!($1~"^\\.\$")) and \
           (!($1~"^-0*\\.0*\$")) and \
           (!($1~"^-\?00")) and \
           (!($1~"^-\?0+[1-9]")));
};
:global isNFloat do={
  :global isNil;
  :global isFloat;
  :return (([$isNil $1]) or ([$isFloat $1]));
};

################################################################################
##   numeric                                                                  ##
################################################################################
:global isNumeric do={
  :global isInt;
  :global isFloat;
  :return (([$isInt $1]) or ([$isFloat $1]));
};
:global isNNumeric do={
  :global isNil;
  :global isNumeric;
  :return (([$isNil $1]) or ([$isNumeric $1]));
};

################################################################################
##   str                                                                      ##
################################################################################
:global isStr do={
  :return ([:typeof $1]="str");
};
:global isNStr do={
  :global isNil;
  :global isStr;
  :return (([$isNil $1]) or ([$isStr $1]));
};

################################################################################
##   array                                                                    ##
################################################################################
:global isArr do={
  :return ([:typeof $1]="array");
};
:global isNArr do={
  :global isNil;
  :global isArr;
  :return (([$isNil $1]) or ([$isArr $1]));
};

################################################################################
##   function                                                                 ##
################################################################################
:global isFunc do={
  :global FALSE;
  :global isArr;
  :if (![$isArr $1]) do={:return $FALSE};
  :return ([:pick [:tostr $1] 0 7]=";(eval ");
};
:global isNFunc do={
  :global isNil;
  :global isFunc;
  :return (([$isNil $1]) or ([$isFunc $1]));
};

################################################################################
##   lookup                                                                   ##
################################################################################
:global isLookup do={
  :return ([:typeof $0]="lookup");
};
:global isNLookup do={
  :global isNil;
  :global isLookup;
  :return (([$isNil $1]) or ([$isLookup $1]));
};


################################################################################
################################################################################
##                                                                            ##
##   ARRAY FUNCTIONS                                                          ##
##                                                                            ##
################################################################################
################################################################################

# Testing within an array
#   allArr [arr] [validator]
#       Returns TRUE if each element in arr complies to the boolean-returning
#       validator function
#   anyArr [arr] [validator]
#       Returns TRUE if any element in arr complies to the boolean-returning
#       validator function
# 
# example to test if all elements in array are integers:
#   :local myarr {2; 4; 20}; :put [$allArr $myarr $isInt];
#   :local myarr {2; "hello"; 20}; :put [$allArr $myarr $isInt];

:global allArr do={
  :global TypeErr;
  :global isBool;
  :global isArr;
  :global isFunc;
  
  :local vc do={:return (!$1)};
  :if ($any) do={:set vc do={:return ($1)}};
  
  :if (![$isArr $1 "arr"]) do={:return [$TypeErr $0 "arr"]};
  :if (![$isFunc $2 "func"]) do={:return [$TypeErr $0 "func"]};
  
  :local val;
  :foreach i,v in=$1 do={
    :set val [$2 $v $i];
    :if (![$isBool $val]) do={:return [$TypeErr "func" "return not boolean"]};
    :if ([$vc $val]) do={:return $val};
  };
  :return $val;
};
:global anyArr do={
  :global allArr;
  :return [$allArr $1 $2 any=(true)]
};
:global inArr do={
  :global TypeErr;
  :global isArr;
  
  :if (![$isArr $1]) do={:return [$TypeErr $0 "arr"]};
  :foreach v in=$1 do={:if ($v=$2) do={:return (true)}};
  :return (false);
};
:global range do={
# range [from] [to] [optional step]
#   returns an array of integers from [from] to [to] in [step] increments
  :global TypeErr;
  :global ValueErr;
  :global opt;
  :global isInt;
  :global isNInt;
  
  :if (![$isInt $1]) do={:return [$TypeErr $0 "from"]};
  :if (![$isInt $2]) do={:return [$TypeErr $0 "to"]};
  :if (![$isNInt $3]) do={:return [$TypeErr $0 "step"]};
  :if ($3=0) do={:return [$ValueErr $0 "step" "must be non-zero"]};
  
  :local i [:tonum $1];
  :local j [:tonum $2];
  :local s [$opt $3 1];
  :local r [:toarr ""];
  :local cmp do={:return ($1<$2)};
  :if ($s<0) do={:set cmp do={:return ($1>$2)}};
  :while ([$cmp $i $j]) do={
    :set r ($r, {$i});
    :set i ($i + $s);
  };
  :return $r;
};
:global indices do={
# indices [optional from] [optional to] [optional length] [optional step]
#   Returns array with stepped indices from [from] to [to].
#   Negative indices supported when [length] provided.
  :global TypeErr;
  :global ValueErr;
  :global ParamErr;
  :global opt;
  :global isNil;
  :global isNInt;
  :global range;
  
  :if (![$isNInt $1]) do={:return [$TypeErr $0 "from"]};
  :if (![$isNInt $2]) do={:return [$TypeErr $0 "to"]};
  :if (![$isNInt $3]) do={:return [$TypeErr $0 "length"]};
  :if (![$isNInt $4]) do={:return [$TypeErr $0 "step"]};
  
  :if ([$isNil $3]) do={
    :if ([$isNil $1]) do={
      :if (![$isNil $4] and $4<0) do={
        :return [$ParamErr $0 "from" "length required with open-ended index"];
      };
    } else={
      :if ($1<0) do={
        :return [$ParamErr $0 "from" "length required with negative index"];
      };
    };
    :if ([$isNil $2]) do={
      :if (![$isNil $4] and $4>0) do={
        :return [$ParamErr $0 "to" "length required with open-ended index"];
      };
    } else={
      :if ($2<0) do={
        :return [$ParamErr $0 "to" "length required with negative index"];
      };
    };
  } else {
    :if ($3<0) do={
      :return [$ValueErr $0 "length" "must be non-negative"];
    };
  };
  :if (![$isNil $4] and $4=0) do={
    :return [$ValueErr $0 "step" "must be non-zero"];
  };
  
  :local i $1;
  :local j $2;
  :local l $3;
  :local s [$opt $4 1];
  
  :if (![$isNil $i] and $i<0) do={:set i ($l+$i)};
  :if (![$isNil $j] and $j<0) do={:set j ($l+$j)};
  
  :if ($s>0) do={
    :if ([$isNil $i]) do={:set i 0};
    :if ([$isNil $j]) do={:set j $l};
    :if ($i<0) do={:set i 0};
    :if (![$isNil $l] and $j>$l) do={:set j $l};
  } else={
    :if ([$isNil $i]) do={:set i ($l-1)};
    :if ([$isNil $j]) do={:set j -1};
    :if (![$isNil $l] and $i>($l-1)) do={:set i ($l-1)};
    :if ($j<-1) do={:set j -1};
  };
  :return [$range $i $j $s];
};

:global append do={
# append [array] [val] [optional key]
#   Returns the array with the value appended.
  :global TypeErr;
  :global isNil;
  :global isArr;
  
  :if (![$isArr $1]) do={:return [$TypeErr $0 "array"]};
  
  :if ([$isNil $3]) do={
    :return ($1, {$2});
  } else={
    :local r $1;
    :set ($r->$3) $2;
    :return $r;
  };
};
:global extend do={
# extend [array 1] [array 2]
#   Returns the joined array.
  :global TypeErr;
  :global isArr;
  
  :if (![$isArr $1]) do={:return [$TypeErr $0 "array 1"]};
  :if (![$isArr $2]) do={:return [$TypeErr $0 "array 2"]};
  
  :return ($1, $2);
};
:global transpose do={
# transpose [2D array]
#   Returns an array of arrays with rows and columns swapped
  :global TypeErr;
  :global isArr;
  
  :if (![$isArr $1]) do={:return [$TypeErr $0 "array"]};
  
  :local rows [:len $1];
  :local cols 0;
  :local rlen 0;
  
  :foreach i,row in=$1 do={
    :if (![$isArr $row]) do={:return [$TypeErr $0 ("array->" . $i)]};
    :set rlen [:len $row];
    :if ($rlen>$cols) do={:set cols $rlen};
  };
  
  :local trarr [:toarr ""];
  :local trrow [:toarr ""];
  :local c 0;
  :while ($c<$cols) do={
    :set trrow [:toarr ""];
    :foreach row in=$1 do={:set trrow ($trrow, {$row->$c})};
    :set c ($c+1);
    :set trarr ($trarr, {$trrow});
  };
  :return $trarr;
};
:global map do={
# map [array] [func]
#   Returns an array where values are transformed through [$func $val [$key]].
  :global TypeErr;
  :global isNil;
  :global isArr;
  :global isFunc;
  :global append;
  
  :if (![$isArr $1]) do={:return [$TypeErr $0 "arr"]};
  :if (![$isFunc $2]) do={:return [$TypeErr $0 "func"]};
  
  :local r [:toarr ""];
  :local i 0;
  
  :foreach k,v in=$1 do={
    :if (![$isNil $i] and ($i=$k)) do={
      :set i ($i+1);
      :set r [$append $r [$2 $v $k]];
    } else={
      :set i;
      :set r [$append $r [$2 $v $k] $k];
    };
  };
  :return $r;
};
:global filter do={
# filter [array] [func]
#   Returns an array with only the elements for which [$func $val] or
#   [$func $val $key] returns $TRUE.
  :global TypeErr;
  :global isNil;
  :global isArr;
  :global isFunc;
  :global append;
  
  :if (![$isArr $1]) do={:return [$TypeErr $0 "array"]};
  :if (![$isFunc $2]) do={:return [$TypeErr $0 "func"]};
  
  :local r [:toarr ""];
  :local i 0;
  
  :foreach k,v in=$1 do={
    :if (![$isNil $i] and ($i=$k)) do={
      :set i ($i+1);
      :if ([$2 $v]) do={:set r [$append $r $v]};
    } else={
      :set i;
      :if ([$2 $v $k]) do={:set r [$append $r $v $k]};
    };
  };
  :return $r;
};
:global reduce do={
# reduce [array] [func]
#   Returns the result from [$func $prev_result $element [$key]] iterated over
#   the array. On the first element $prev_result will be $NIL.
  :global NIL;
  :global TypeErr
  :global isArr;
  :global isFunc;

  :if (![$isArr $1]) do={:return [$TypeErr $0 "array"]};
  :if (![$isFunc $2]) do={:return [$TypeErr $0 "func"]};
  
  :local r $NIL;
  :foreach k,v in=$1 do={:set r [$2 $r $v $k]};
  :return $r;
};
:global slice do={
# slice [array] [from] [to] [optional step]
#   Returns a slice from an array. Negative indices will wrap around.
  :global TypeErr;
  :global isArr;
  :global indices;
  
  :if (![$isArr $1]) do={:return [$TypeErr $0 "array"]};
  
  :local ixs [$indices $2 $3 [:len $1] $4];
  :local r [:toarr ""];
  
  :foreach i in=$ixs do={:set r ($r, {($1->$i)})};
  :return $r;
};


################################################################################
################################################################################
##                                                                            ##
##   BASIC MATH FUNCTIONS                                                     ##
##                                                                            ##
################################################################################
################################################################################

# Returns the sign of a numeric value. (-1, 0, 1)
:global sign do={
  :global TypeErr;
  :global isNumeric;
  :if (![$isNumeric $1]) do={:return [$TypeErr $0 "value" "arg not numeric"]};
  :if ([:pick $1 0 1]="-") do={:return -1};
  :if ($1~"^[0\\.]+\$") do={:return 0};
  :return 1;
};
# Returns the absolute value of a numeric value
:global abs do={
  :global isInt;
  :global sign;
  :if ([$sign $1]>=0) do={:return $1};
  :if ([$isInt $1]) do={:return (-1 * [:tonum $1])};
  :return ([:pick $1 1 [:len $1]]);
};
# Returns the absolute value of a numeric value multiplied by negative 1
:global neg do={
  :global isInt;
  :global sign;
  :if ([$sign $1]<=0) do={:return $1};
  :if ([$isInt $1]) do={:return (-1 * [:tonum $1])};
  :return ("-" . $1);
};
# Returns TRUE if $1 is a numerical value v >  0
:global isAbs do={
  :global sign;
  :return ([$sign $1]>0);
};
# Returns TRUE if $1 is a numerical value v >= 0
:global isZAbs do={
  :global sign;
  :return ([$sign $1]>=0);
};
# Returns TRUE if $1 is a numerical value v <= 0
:global isZNeg do={
  :global sign;
  :return ([$sign $1]<=0);
};
# Returns TRUE if $1 is a numerical value v <  0
:global isNeg do={
  :global sign;
  :return ([$sign $1]<0);
};
:global min do={
  :global reduce;
  :local cmp do={
    :global TypeErr;
    :global isInt;
    :if (![$isInt $2]) do={:return [$TypeErr $0 "arr" "element " . $3 . " not int"]};
    :if ($3=0) do={:return $2};
    :if ($2<$1) do={:return $2};
    :return $1;
  };
  :return [$reduce $1 $cmp];
};
:global max do={
  :global reduce;
  :local cmp do={
    :global TypeErr;
    :global isInt;
    :if (![$isInt $2]) do={:return [$TypeErr $0 "arr" "element " . $3 . " not int"]};
    :if ($3=0) do={:return $2};
    :if ($2>$1) do={:return $2};
    :return $1;
  };
  :return [$reduce $1 $cmp];
};
:global lim do={
# lim [value] [lower limit] [upper limit]
  :global TypeErr;
  :global isInt;
  :global min;
  :global max;
  :if (![$isInt $1]) do={:return [$TypeErr $0 "value"]};
  :if (![$isInt $2]) do={:return [$TypeErr $0 "lower limit"]};
  :if (![$isInt $3]) do={:return [$TypeErr $0 "upper limit"]};
  :return [$min ({[$max ({$1; $2})]; $3})];
};

################################################################################
################################################################################
##                                                                            ##
##   STRING FUNCTIONS                                                         ##
##                                                                            ##
################################################################################
################################################################################

:global lower do={
# lower [string]
#   Returns the string with ascii alphabetical characters set to their
#   lowercase version.
  :global "ASCII_UC";
  :global "ASCII_LC";
  :global TypeErr;
  :global isStr;
  
  :local cl do={
    :global "ASCII_UC";
    :global "ASCII_LC";
    :for i from=0 to=25 do={
      :if ($1=($"ASCII_UC"->$i)) do={:return ($"ASCII_LC"->$i)};
    };
    :return $1;
  };
  
  :if (![$isStr $1]) do={:return [$TypeErr $0 "string"]};
  :local r "";
  :for i from=0 to=([:len $1]) do={:set r ($r . [$cl [:pick $1 $i]])};
  :return $r;
};
:global upper do={
# upper [string]
#   Returns the string with ascii alphabetical characters set to their
#   uppercase version.
  :global "ASCII_UC";
  :global "ASCII_LC";
  :global TypeErr;
  :global isStr;
  
  :local cu do={
    :global "ASCII_UC";
    :global "ASCII_LC";
    :for i from=0 to=25 do={
      :if ($1=($"ASCII_LC"->$i)) do={:return ($"ASCII_UC"->$i)};
    };
    :return $1;
  };
  
  :if (![$isStr $1]) do={:return [$TypeErr $0 "string"]};
  :local r "";
  :for i from=0 to=([:len $1]) do={:set r ($r . [$cu [:pick $1 $i]])};
  :return $r;
};
:global lpick do={
# lpick [string] [chars]
#   Returns a substring from the start of a string
#   If param chars is positive, it will return that number of characters. If
#   negative, it will strip them from the end.
  :global TypeErr;
  :global ValueErr;
  :global isInt;
  :global isStr;
  :if (![$isStr $1]) do={:return [$TypeErr $0 "string"]};
  :if (![$isInt $2]) do={:return [$TypeErr $0 "chars"]};
  :if ($2=0) do={:return [$ValueErr $0 "chars" "value 0 is ambiguous"]};
  :if ($2>0) do={:return [:pick $1 0 $2]};
  :return [:pick $1 0 ([:len $1] + $2)]
};
:global rpick do={
# rpick [string] [chars]
#   Returns a substring from the end of a string
#   If param chars is positive, it will return that number of characters. If
#   negative, it will strip them from the start.
  :global TypeErr;
  :global ValueErr;
  :global isInt;
  :global isStr;
  :if (![$isStr $1]) do={:return [$TypeErr $0 "string"]};
  :if (![$isInt $2]) do={:return [$TypeErr $0 "chars"]};
  :if ($2=0) do={:return [$ValueErr $0 "chars" "value 0 is ambiguous"]};
  :if ($2>0) do={:return [:pick $1 ([:len $1] - $2) [:len $1]]};
  :return [:pick $1 [$abs $2] [:len $1]]
};
:global xpick do={
# xpick [string] [from] [to] [optional step]
#   Returns a substring from a string. Negative indices will wrap around.
  :global TypeErr;
  :global isStr;
  :global indices;
  
  :if (![$isStr $1]) do={:return [$TypeErr $0 "string"]};
  
  :local ixs [$indices $2 $3 [:len $1] $4];
  :local r "";
  
  :foreach i in=$ixs do={:set r ($r . [:pick $1 $i])};
  :return $r;
};

:global findInStr do={
# findInStr [string] [substring] [optional overlap]
  :global TypeErr;
  :global isNBool;
  :global isStr;
  
  :if (![$isStr $1]) do={:return [$TypeErr $0 "string"]};
  :if (![$isStr $2]) do={:return [$TypeErr $0 "substring"]};
  :if (![$isNBool $3]) do={:return [$TypeErr $0 "overlap"]};
  
  :local jump [:len $2];
  :if ($3=(true)) do={:set jump 1};
  
  :local m [:toarr ""];
  :local i 0;
  :local n [:len $2];
  :local j ([:len $1] - [:len $2]);
  
  :while ($i <= $j) do={
    :if ([:pick $1 $i ($i + $n)]=$2) do={
      :set m ($m, $i);
      :set i ($i + $jump);
    } else={
      :set i ($i + 1);
    };
  };
  :return $m
};
:global countInStr do={
# countInStr [string] [substring] [overlap=false]
  :global findInStr;
  :return [:len [$findInStr $1 $2 $3]]
};
:global join do={
# join [array of strings] [optional joiner]
#   Links each array element together using a space or other joiner if supplied
  :global TypeErr;
  :global opt;
  :global isNStr;
  :global isArr;
  
  :if (![$isArr $1]) do={:return [$TypeErr $0 "array"]};
  :if (![$isNStr $2]) do={:return [$TypeErr $0 "joiner"]};
  :local s;
  :local j [$opt $2 " "];
  :local f (true);
  :foreach k,v in=$1 do={
    :if (![$isStr $v]) do={:return [$TypeErr $0 ("array->" . $k)]};
    :if ($f) do={
      :set s $v;
      :set f (false);
    } else={
      :set s ($s . $j . $v);
    };
  };
  :return $s
};
:global split do={
# split [string] [optional split-string]
  :global TypeErr;
  :global opt;
  :global isStr;
  :global isNStr;
  :global findInStr;
  
  :if (![$isStr $1]) do={:return [$TypeErr $0 "string"]};
  :if (![$isNStr $2]) do={:return [$TypeErr $0 "split-string"]};
  
  :local s [$opt $2 " "];
  :local indices ([$findInStr $1 $s], [:len $1]);
  :local r [:toarr ""];
  :local i 0;
  :foreach j in=$indices do={
    :set r ($r, [:pick $1 $i $j]);
    :set i ($j + 1);
  };
  :return $r;
};



#:global findInStrRe do={
## findInStrRe [string] [pattern] [overlap=false]
#  :if (![$isStr $1]) do={:return [$TypeErr $0 "string"]};
#  :if (![$isStr $2]) do={:return [$TypeErr $0 "substring"]};
#  :if (![$isNBool $3]) do={:return [$TypeErr $0 "overlap"]};
#  
#  :local slen [:len $1];
##  Variant below doesn't work due to bug. Array isn't de-allocated after
##  exiting function
##  :local matches ({});
#  :local matches [:toarray ("")];
#  :local lbound ([$lpick $2 1]="^");
#  :local rbound ([$rpick $2 1]="\$");
#  :if ($lbound and $rbound) do={
#    :if ($1~$2) do={:set matches ($matches , {{0; $slen}})};
#    :return $matches;
#  };
#  
#  :local overlap ($3=$TRUE);
#  :local pattern $2;
#  :if (!$lbound) do={:set pattern ("^" . $pattern)}
#  :if (!$rbound) do={:set pattern ($pattern . "\$")}
#  
#  :local i 0;
#  :local j $slen;
#  :local cont true;
#  :if ($lbound or $rbound) do={
#    :while ($cont and ($i < $j)) do={
#      :if ([:pick $1 $i $j]) do={
#        :set matches ($matches, {{$i; $j}});
#        :set cont $overlap;
#      };
#      :if ($lbound) do={:set j ($j - 1)};
#      :if ($rbound) do={:set i ($i + 1)};
#    };
#    :return $matches;
#  };
#  
#  :while ($cont and ($i < $j)) do={
#    :while () do={
#    };
#    :set i ($i + 1);
#    :set j $slen;
#  };
#  
#  
#  :if ($lbound) do={:return "lbound"};
#  :if ($rbound) do={:return "rbound"};
#  :return "blaaah";
#};
#:global countInStrRe do={
## countInStrRe [string] [pattern] [overlap=false]
#  :return [:len [$findInStrRe $1 $2 $3]]
#};




################################################################################
################################################################################
##                                                                            ##
##   DATE-TIME FUNCTIONS                                                      ##
##                                                                            ##
################################################################################
################################################################################

:global trmonth do={
# trmonth [month]
#   Translates a three-letter month name into an integer or vice versa
  :global TypeErr;
  :global ValueErr;
  :global isInt;
  :global isStr;
  :global lower;
  
  :local months {"jan"; "feb"; "mar"; "apr"; "may"; "jun"; \
                 "jul"; "aug"; "sep"; "oct"; "nov"; "dec"};
  :if ([$isInt $1]) do={
    :if ($1<1) do={:return [$ValueErr $0 "month" "value too low"]};
    :if ($1>12) do={:return [$ValueErr $0 "month" "value too high"]};
    :return ($months->($1-1));
  };
  :if ([$isStr $1]) do={
    :local parmonth [$lower $1];
    :foreach m,month in=$months do={
      :if ($parmonth=$month) do={:return ($m+1)};
    };
    :return [$ValueErr $0 "month" ("name '".$1."' unknown")];
  };
  :return [$TypeErr $0 "month"];
};
:global trweekday do={
# trweekday [weekday]
#   Translates a three-letter day name into an integer or vice versa
  :global TypeErr;
  :global ValueErr;
  :global isInt;
  :global isStr;
  :global lower;
  
  :local weekdays {"mon"; "tue"; "wed"; "thu"; "fri"; "sat"; "sun"};
  :if ([$isInt $1]) do={
    :if ($1<0) do={:return [$ValueErr $0 "weekday" "value too low"]};
    :if ($1>6) do={:return [$ValueErr $0 "weekday" "value too high"]};
    :return ($weekdays->([:tonum $1]));
  };
  :if ([$isStr $1]) do={
    :local parweekday [$lower $1];
    :foreach wd,weekday in=$weekdays do={
      :if ($parweekday=$weekday) do={:return $wd};
    };
    :return [$ValueErr $0 "weekday" ("name '".$1."' unknown")];
  };
  :return [$TypeErr $0 "weekday"];
};
:global getDate do={
  :global split;
  :global trmonth;
  :local mdy [$split [/system clock get date] "/"];
  :return ({[:tonum ($mdy->2)]; [$trmonth ($mdy->0)]; [:tonum ($mdy->1)]});
};
:global getTime do={
  :global split;
  :local hms [$split [:tostr [/system clock get time]] ":"];
  :return ({[:tonum ($hms->0)]; [:tonum ($hms->1)]; [:tonum ($hms->2)]});
};
:global getTZOffset do={
  :return [/system clock get gmt-offset];
};
:global getDateTime do={
  :global getDate;
  :global getTime;
  :global getTZOffset;
  
  :local xd;
  :local xo;
  :local d [$getDate];
  :local t;
  :local o [$getTZOffset];
  :while (($xd!=$d) or ($xo!=$o)) do={
    :set xd $d;
    :set xo $o;
    :set t [$getTime];
    :set d [$getDate];
    :set o [$getTZOffset];
  };
  :return ($d, $t, $o);
};

:global leapyear do={
# leapyear [optional year]
#   Returns whether the provided year is a leap year or not. If no year is
#   provided, the current (localized) system year is used.
  :global TypeErr;
  :global opt;
  :global isNInt;
  :global getDate;
  :if (![$isNInt $1]) do={:return [$TypeErr $0 "year" "must be integer"]};
  :local y [$opt $1 ([$getDate]->0)];
  
  :if ($y%4!=0) do={:return $FALSE};
  :if ($y%100!=0) do={:return $TRUE};
  :if ($y%400!=0) do={:return $FALSE};
  :return $TRUE;
};

:global isDateArr do={
  :global 
  :if (![$isArr $1]) do={:return $FALSE};
  :if ([:len $1] != 3) do={:return $FALSE};
  :if ([$nallArr $1 $isInt]) do={:return $FALSE};
  :local y ($1->0);
  :local m ($1->1);
  :local d ($1->2);
  :if (($m<1) or ($m>12) or ($d<1) or ($d>31)) do={:return $FALSE};
  :if ([$inArr ({4; 6; 9; 11}) $m] and ($d>30)) do={:return $FALSE};
  :if (($m=2) and ($d>28)) do={:return ([$leapyear $y] and ($d=29))};
  :return $TRUE;
};
:global isNDateArr do={:return (([$isNil $1]) or ([$isDateArr $1]))};
:global isDateArr do={:return (!([$isDateArr $1]))};
:global isNDateArr do={:return (!([$isNDateArr $1]))};

:global isTimeArr do={
  :if (![$isArr $1]) do={:return $FALSE};
  :if ([:len $1] != 3) do={:return $FALSE};
  :if ([$nallArr $1 $isInt]) do={:return $FALSE};
  :local h ($1->0);
  :local m ($1->1);
  :local s ($1->2);
  :if (($h<0) or ($m<0) or ($s<0)) do={:return $FALSE};
  :if (($h<24) and ($m<60) and ($s<60)) do={:return $TRUE};
  :if (($h=23) and ($m=59)) do={:return ($s<=62)};
  :if (($h=23) and ($m=60)) do={:return ($s<=2)};
  :if (($h=24) and ($m=0)) do={:return ($s<=2)};
  :return $FALSE;
};
:global isNTimeArr do={:return (([$isNil $1]) or ([$isTimeArr $1]))};
:global isTimeArr do={:return (!([$isTimeArr $1]))};
:global isNTimeArr do={:return (!([$isNTimeArr $1]))};

:global isDateTimeArr do={
  :if (![$isArr $1]) do={:return $FALSE};
  :if ([:len $1] != 7) do={:return $FALSE};
  :if ([$nallArr $1 $isInt]) do={:return $FALSE};
  :return ([$isDateArr ({$1->0; $1->1; $1->2})] and \
           [$isTimeArr ({$1->3; $1->4; $1->5})]);
};
:global isNDateTimeArr do={:return (([$isNil $1]) or ([$isDateTimeArr $1]))};
:global isDateTimeArr do={:return (!([$isDateTimeArr $1]))};
:global isNDateTimeArr do={:return (!([$isNDateTimeArr $1]))};

# Returns TRUE if $1 is a string formatted as a date.
:global isDateStr do={
  :if (!($1~"^[a-zA-Z]{3}/[0-9]{1,2}/[0-9]+\$")) do={:return $FALSE};
  :local mdy [$split $1 "/"];
  :local y [:tonum ($mdy->2)];
  :local m [$trmonth ($mdy->0)];
  :local d [:tonum ($mdy->1)];
  :return [$isDateArr ({$y; $m; $d})];
};
:global isNDateStr do={:return (([$isNil $1]) or ([$isDateStr $1]))};
:global isDateStr do={:return (!([$isDateStr $1]))};
:global isNDateStr do={:return (!([$isNDateStr $1]))};

# Returns TRUE if $1 is a time object or string formatted as a time.
:global isTimeStr do={
  :if (!($1~"^[0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2}\$")) do={:return $FALSE};
  :local t [:tostr $1]
  :local hms [$split $t ":"];
  :local h [:tonum ($hms->0)];
  :local m [:tonum ($hms->1)];
  :local s [:tonum ($hms->2)];
  :return [$isTimeArr ({$h; $m; $s})];
};
:global isNTimeStr do={:return (([$isNil $1]) or ([$isTimeStr $1]))};
:global isTimeStr do={:return (!([$isTimeStr $1]))};
:global isNTimeStr do={:return (!([$isNTimeStr $1]))};


:global getTZOffset do={
  :return [/system clock get gmt-offset];
};
:global getDateTime do={
  :local xd;
  :local xo;
  :local d [$getDate];
  :local t;
  :local o [$getTZOffset];
  :while (($xd!=$d) or ($xo!=$o)) do={
    :set xd $d;
    :set xo $o;
    :set t [$getTime];
    :set d [$getDate];
    :set o [$getTZOffset];
  };
  :return ([$d], [$t], [$o]);
};


:global getOrdinalDate do={
  :if (![$isNDateArr $1]) do={:return [$TypeErr $0 "date" "must be DateArr"]};
  
  :local ymd [$opt $1 [$getDate]];
  
  :local d (({0;31;59;90;120;151;181;212;243;273;304;334})->(($ymd->1)-1));
  :set d ($d + ($ymd->2));
  :if ([$leapyear ($ymd->0)]) do={:set d ($d + 1)};
  :return $d;
};

:global getEpochDays do={
  :if (![$isNDateArr $1]) do={:return [$TypeErr $0 "date" "must be DateArr"]};
  :local ymd [$opt $1 [$getDate]];
  
  :local d ((($ymd->0) - 1970) * 365);
  :for yr from=($ymd->0) to=1969 step=1 do={
    :if ([$leapyear $yr]) do={:set d ($d - 1)};
  };
  :for yr from=1970 to=(($ymd->0)-1) step=1 do={
    :if ([$leapyear $yr]) do={:set d ($d + 1)};
  };
  
  :return ($d + [$getOrdinalDate $ymd] - 1);
};

:global getTimestamp do={
  :if (![$isNDateTimeArr $1]) do={:return [$TypeErr $0 "datetime" "must be DateTimeArr"]};
  :local dt [$opt $1 [$getDateTime]];
  
  :local ts ([$getEpochDays ({$dt->0; $dt->1; $dt->2})] * 86400);
  :return ($ts + (($dt->3)*3600) + (($dt->4)*60) + ($dt->5) - ($dt->6));
};

:global getWeekday do={
  :if (![$isNDateArr $1]) do={:return [$TypeErr $0 "date" "must be DateArr"]};
  :local ymd [$opt $1 [$getDate]];
  
  :return (([$getEpochDays $ymd] + 3) % 7);
};

