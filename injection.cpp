#include <stdio.h>

#define BYTE_TO_BINARY_PATTERN "%c%c%c%c%c%c%c%c"
#define BYTE_TO_BINARY(byte)  \
  (byte & 0x80 ? '1' : '0'), \
  (byte & 0x40 ? '1' : '0'), \
  (byte & 0x20 ? '1' : '0'), \
  (byte & 0x10 ? '1' : '0'), \
  (byte & 0x08 ? '1' : '0'), \
  (byte & 0x04 ? '1' : '0'), \
  (byte & 0x02 ? '1' : '0'), \
  (byte & 0x01 ? '1' : '0') 

unsigned char f(unsigned char var, unsigned char fp, unsigned char toggle_start, unsigned char toggle_end) {
    
    unsigned char mask;
    if(fp < toggle_start || fp >= toggle_end) {
        mask = 0;
    } else { 
        mask = 1 << (fp - toggle_start);
    }
    
    return var ^ mask;
}

unsigned char f_oper_log(unsigned char var1, unsigned char var2, unsigned char fp, unsigned char toggle_start, unsigned char toggle_end, unsigned char oper) {
    
    unsigned char result;
    bool flag[] = {false, false, false};
    
    for(int i=0; i<3; i++){
      if(i >= oper)
        flag[i]=true;
    }
    if(fp < toggle_start || fp >= toggle_end) {
        switch (oper){
          case 0:
            result= var1 && var2;
            break;
          case 1:
            result= var1 || var2;
            break;
          case 2:
            result= !var1;
            break;
          }

    } else { 
       switch (fp-toggle_start){
          case 0:
            if(flag[fp-toggle_start])
              result= var1 || var2;
            else
              result= var1 && var2;
            break;
          case 1:
            if(flag[fp-toggle_start])
              result= !var1;
            else
              result= var1 || var2;
            break;
          }
    }
    
    return result;
}


unsigned char f_oper(unsigned char var1, unsigned char var2, unsigned char fp, unsigned char toggle_start, unsigned char toggle_end, unsigned char oper) {
    
    unsigned char result;
    bool flag[] = {false, false, false, false};
    
    for(int i=0; i<4; i++){
      if(i >= oper)
        flag[i]=true;
    }

    if(fp < toggle_start || fp >= toggle_end) {
        switch (oper){
          case 0:
            result= var1+var2;
            break;
          case 1:
            result= var1-var2;
            break;
          case 2:
            result= var1*var2;
            break;
          case 3:
            result= var1/var2;
            break;
 //         default:
   //         result =0;
     //       break;
      } 

    } else { 
        switch (fp-toggle_start){
          case 0:
            if(flag[fp-toggle_start])
              result= var1-var2;
            else
              result= var1+var2;
            break;
          case 1:
            if(flag[fp-toggle_start])
              result= var1*var2;
            else
              result= var1-var2;
            break;
          case 2:
            if(flag[fp-toggle_start])
              result= var1/var2;
            else
              result= var1*var2;
            break;
      ///    case 3:
         //   if(flag[oper])
      //        result= var1var2;
      //      else
    //          result= var1var2;
    //        break;
     //     default:
       //     result =0;
         //   break;
    }
  }
    
    return result;
}


bool f_oper_rel(unsigned char var1, unsigned char var2, unsigned char fp, unsigned char toggle_start, unsigned char toggle_end, unsigned char oper) {
    
    bool result;
    bool flag[] = {false, false, false, false, false, false};
    
    for(int i=0; i<6; i++){
      if(i >= oper)
        flag[i]=true;
    }

    if(fp < toggle_start || fp >= toggle_end) {
        switch (oper){
          case 0:
            result= var1 > var2;
            break;
          case 1:
            result= var1 >= var2;
            break;
          case 2:
            result= var1 < var2;
            break;
          case 3:
            result= var1 <= var2;
            break;
          case 4:
            result= var1 == var2;
            break;
          case 5:
            result= var1 != var2;
            break;
 //         default:
   //         result =0;
     //       break;
      } 

    } else { 
        switch (fp-toggle_start){
          case 0:
            if(flag[fp-toggle_start])
              result= var1>=var2;
            else
              result= var1>var2;
            break;
          case 1:
            if(flag[fp-toggle_start])
              result= var1<var2;
            else
              result= var1>=var2;
            break;
          case 2:
            if(flag[fp-toggle_start])
              result= var1<=var2;
            else
              result= var1<var2;
            break;
            case 3:
            if(flag[fp-toggle_start])
              result= var1==var2;
            else
              result= var1<=var2;
            break;
            case 4:
            if(flag[fp-toggle_start])
              result= var1!=var2;
            else
              result= var1==var2;
            break;
      ///    case 3:
         //   if(flag[oper])
      //        result= var1var2;
      //      else
    //          result= var1var2;
    //        break;
     //     default:
       //     result =0;
         //   break;
    }
  }
    
    return result;
}




int main()
{
    unsigned char fp;
    unsigned char a = 10, b = 5;
    unsigned char sum = a * b;
    
    printf("Senza guasti\n");
   // printf("a="BYTE_TO_BINARY_PATTERN " b="BYTE_TO_BINARY_PATTERN " sum="BYTE_TO_BINARY_PATTERN "\n", 
    //    BYTE_TO_BINARY(a), BYTE_TO_BINARY(b), BYTE_TO_BINARY(sum));
    printf("a=%i, b=%i, risultato sottrazione = %i ",a,b,sum);
    
    for(fp = 0; fp < 5; fp++) {
        printf("\nGuasto #%d\n", fp);
        unsigned char oper_fault = f_oper(a,b, fp, 0, 3, 3);
        printf("a= %i b=%i risultato= %i \n", a,b,oper_fault);
    }
    
    return 0;
}