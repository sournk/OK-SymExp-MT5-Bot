//+------------------------------------------------------------------+
//|                                 DS-NewsBrakeout-MT5-Research.mq5 |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"
#property version   "1.00"

#define CRARR(_arr) CreateArray(_arr)

#include <Arrays\ArrayLong.mqh>
#include <Math\Stat\Math.mqh>

#include "Include\DKStdLib\Common\DKDatetime.mqh"
#include "Include\DKStdLib\TradingManager\CDKSymbolInfo.mqh"





//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
  string one = "ONE";
  string arr[] = {"ZERO", one, "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE"}; 
  string fmt_dk = "dfs %0 fsdf %1 asdf %2 sdf %3 sadf %4 asdf asdf%5 %6, %7, %8, %9 ad";
  string fmt_mq = "dfs %s fsdf %s asdf %s sdf %s sadf %s asdf asdf%s %s, %s, %s, %s ad";
  
  int size = 1000000;
  string s;
  
  ulong tick = GetTickCount64();
  for(int i=0;i<size;i++) {
    s = StringConcat(fmt_mq, arr);
  }
  Print("StringConcat: ", GetTickCount64()-tick, " :", s);
  
  tick = GetTickCount64();
  for(int i=0;i<size;i++) {
    s = StringFormat(fmt_mq, arr[0], arr[1], arr[2], arr[3], arr[4], arr[5], arr[6], arr[7], arr[8], arr[9]);
  }
  Print("StringFormat: ", GetTickCount64()-tick, " :", s);
  
  tick = GetTickCount64();
  for(int i=0;i<size;i++) {
    s = StringFormatDK(fmt_dk, arr);
  }
  Print("StringFormatDK: ", GetTickCount64()-tick, " :", s);
  
  tick = GetTickCount64();
  for(int i=0;i<size;i++) {
    s = StringFormatDK_Find(fmt_dk, arr);
  }
  Print("StringFormatDK_Find: ", GetTickCount64()-tick, " :", s);
  
  tick = GetTickCount64();
  for(int i=0;i<size;i++) {
    s = StringFormatDK_Optimized(fmt_dk, CreateArray({"ZERO", one, "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE"}));
  }
  Print("StringFormatDK_Optimized: ", GetTickCount64()-tick, " :", s);
  
}

string StringFormatDK(const string _str, string& _arr[]){
  int arr_size = ArraySize(_arr);
  string res = "";
  
  string pat;
  string pat_1;
  string idx_str;
  int idx_int;
  
  int len = StringLen(_str);
  int i = 0;
  while (i < len) {
    pat = StringSubstr(_str, i, 2);
    pat_1 = StringSubstr(pat, 0, 1);
    if(pat_1 == "%") {
      idx_str = StringSubstr(pat, 1, 1);
      idx_int = (int)idx_str;
      if(idx_int < arr_size && (string)idx_int == idx_str) {
        res += _arr[idx_int];
        i += 2;
        continue;
      }
    }

    res += pat_1;
    i++;
  }
  
  return res;
}


string StringFormatDK_Find(const string _str, string& _arr[]){
  int arr_size = ArraySize(_arr);
  string res = _str;
  
  string idx_str;
  int idx_int;
  
  int pat_idx = 0;
  pat_idx = StringFind(res, "%", 0);
  while(pat_idx >= 0) {
    idx_str = StringSubstr(res, pat_idx+1, 1);
    idx_int = (int)idx_str;
    if(idx_int < arr_size && (string)idx_int == idx_str) {
      StringReplace(res, "%" + idx_str, _arr[idx_int]);
    }    
    pat_idx = StringFind(res, "%", pat_idx+1);
  }  
  return res;
}

string StringConcat(const string _str, string& _arr[]){
  return "dfs " + _arr[0] + " fsdf " + _arr[1] + "  asdf " + _arr[2] + " sdf " + _arr[3] + " sadf " + _arr[4] + " asdf asdf" + _arr[5] +
         " " + _arr[6] + ", " + _arr[7] + ", " + _arr[8] + ", " + _arr[9] +" ad";
}


string[] CreateArray(const string &arr[]) {
  string temp[];
  ArrayResize(temp, ArraySize(arr));
  for (int i = 0; i < ArraySize(arr); i++) {
    temp[i] = arr[i];
  }
  return temp;
}

string StringFormatDK_Optimized(const string _str, string& _arr[]) {
  int arr_size = ArraySize(_arr);
  int length = StringLen(_str);
  
  // Создаем буфер для результата
  char buffer[];
  ArrayResize(buffer, length * 2); // Резервируем место
  
  int pos = 0; // Текущая позиция в буфере

  for (int i = 0; i < length; i++) {
    // Если текущий символ - '%'
    if (StringGetCharacter(_str, i) == '%') {
      if (i + 1 < length) {
        int next_char = StringGetCharacter(_str, i + 1);
        if (next_char >= '0' && next_char <= '9') {
          int idx_int = next_char - '0'; // Получаем индекс
          if (idx_int < arr_size) {
            // Копируем строку из массива в буфер
            string replacement = _arr[idx_int];
            int repl_len = StringLen(replacement);
            ArrayResize(buffer, pos + repl_len);
            for (int j = 0; j < repl_len; j++) {
              buffer[pos++] = StringGetCharacter(replacement, j);
            }
            i++; // Пропускаем следующий символ
            continue;
          }
        }
      }
    }
    // Копируем текущий символ в буфер
    ArrayResize(buffer, pos + 1);
    buffer[pos++] = StringGetCharacter(_str, i);
  }

  // Преобразуем буфер в строку и возвращаем
  return CharArrayToString(buffer, 0, pos);
}



