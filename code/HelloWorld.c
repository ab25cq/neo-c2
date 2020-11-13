#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <malloc.h>

inline void xassert(char* msg, bool exp) 
{
    printf("%s...", msg);

    if(exp) {
        puts("yes");
    }
    else {
        puts("no");
        exit(2);
    }
}

inline char*% xsprintf(char* msg, ...)
{
    va_list args;
    va_start(args, msg);
    char* tmp;
    int len = vasprintf(&tmp, msg, args);
    va_end(args);

    return dummy_heap tmp;
}

inline char* ncstrncpy(char* des, char* src, int size)
{
    char* result;

    result = strncpy(des, src, size-1);
    des[size-1] = 0;

    return result;
}

inline void*% ncmalloc(long long size)
{
    void* result = malloc(size);

    if(result == NULL) {
        fprintf(stderr, "can't get heap memory. size %d. ncmalloc\n", size);
        exit(2);
    }

    return dummy_heap result;
}

inline void*% nccalloc(long long num, long long nsize)
{
    void* result = calloc(num, nsize);

    if(result == NULL) {
        fprintf(stderr, "can't get heap memory. nccalloc num %d nsize %d\n", num, nsize);

        exit(2);
    }

    memset(result, 0, num*nsize);

    return dummy_heap result;
}

inline void*% ncrealloc(void *block, long long int size)
{
#ifdef __DARWIN__
    void* result = calloc(1, size);
    memcpy(result, block, size);
    free(block);

    if(result == NULL) {
        fprintf(stderr, "can't get heap memory. realloc size %d. realloc memory %p\n", size, block);
        exit(2);
    }

    return dummy_heap result;
#else
    void* result = realloc(block, size);

    if(result == NULL) {
        fprintf(stderr, "can't get heap memory. realloc size %d. realloc memory %p\n", size, block);
        exit(2);
    }

    return dummy_heap result;
#endif
}

inline long long ncmalloc_usable_size(void* block)
{
#ifdef __DARWIN__
    return malloc_size(block);
#else
    return malloc_usable_size(block);
#endif
}

inline void*% ncmemdup(void*% block)
{
#ifdef __DARWIN__
    long long size = malloc_size(block);
#else
    long long size = malloc_usable_size(block);
#endif

    if (!block) return (void*)0;

    void*% ret = ncmalloc(size);

    if (ret) {
        char* p = ret;
        char* p2 = block;
        while(p - ret < size) {
            *p = *p2;
            p++;
            p2++;
        }
    }

    return ret;
}


struct sData;
typedef struct sData sDataType;

sDataType* gSData;

#define AAAAA 12345

long int gAAAAAA = AAAAA;
typedef long unsigned int size_t;

int puts(char* str);

int exit(int rc);
int printf(char* str, ...);
void*% calloc(size_t nmemb, size_t size);
void free(void *ptr);
int atoi(const char* str);
int atoi(const char* str);
int strcmp(const char* str1, const char* str2);

int funXXX() {
int a = 0;
int b = 1/a;
    puts("called fun");
    return 2;
}


int int::fun(int self) {
    puts("called int::fun");
    printf("self %d\n", self);

    return 123;
}

bool const_test(const char* str) 
{
    puts(str);
    return true;
}

extern char* strcpy(char* str, char* str2);
extern int strlen(char* str);
extern char* strcat(char* str, char* str2);

inline char*% string(char* str) 
{
    char*% result = new char[strlen(str) + 1];

    strcpy(result, str);

    return result;
}

char*% string2(char*% str) 
{
    char*% result = new char[strlen(str) + 6];

    strcpy(result, str);
    strcat(result, "+ABC");

    return result;
}

char*% string_test1(char*% var) 
{
    char*% a = new char[128];

    strcpy(a, var);

    puts(a);

    return a;
}

struct Data {
    int a;
    int b;
};

union Data2 {
    int a;
    long b;
};

struct GenericsData!<T> {
    T a;
    T b;
};

int GenericsData!<T>::show(GenericsData!<T> self)
{
    T a;
    a = 555;
    T b = 666;

    self.a = a;
    self.b = b;

    printf("%d %d\n", self.a, self.b);

    int (*xxx)(int) = int lambda(int c) { return 555 + c; };

    xassert("generics lambda test", xxx(1) == self.a + 1);

    return a;
}

struct GenericsData2!<T> {
    T a;
};

void GenericsData2!<T>::fun(GenericsData2!<T>* self)
{
    GenericsData!<int> data;
    data.a = 123;
    data.b = 234;
    data.show();
}


template !<M> M fun2(M a) {
    return a + 1;
}

template !<M> M fun3(M (*aaa)(char*), char* bbb) {
    return aaa(bbb);
}

template !<M> M GenericsData!<T>::map(GenericsData!<T> self, M (*aaa)(T))
{
    self.a = 123;
    return aaa(self.a);
}

void inheritFun()
{
    puts("inheritFun version 1");
}

inherit void inheritFun()
{
    inherit();
    puts("inheritFun version 2");
}

struct GenericsData3!<T> {
    T a;
    T b;
};

void GenericsData3!<T>::fun(GenericsData3!<T> self)
{
    puts("GenericsData3!<T>::fun version1");
    GenericsData2!<int>* xyz = new GenericsData2!<int>;

    xyz.fun();
}

inherit void GenericsData3!<T>::fun(GenericsData3!<T> self)
{
    self.inherit();
    puts("GenericsData3!<T>::fun version2");
    GenericsData2!<int>* xyz = new GenericsData2!<int>;

    xyz.fun();
}

int gA;
int gB = 123;

enum { kA, kB, kC };

enum { kA2 = 123, kB2, kC2 };

struct Data3 {
    int a:8;
    int b:4;
};

int gArray[3] = { 1, 2, 3 };

char gArray2[3] = "AB";

int gArray3[] = { 1, 2, 3 };

int gArray4[3][3][3] = {
    { 1,2,3,
    2,3,4,
    5,6,7 },

    { 1,2,3,
    1,2,3,
    1,2,3 },

    { 11,12,13,
    14,15,16,
    17, 18, 19 }
};




#ifndef NULL
#define NULL ((void*)0)
#endif

int main() 
{
    puts("HELLO WORLD");

    char*% start_str = string("AAA");

    int start_a = 111;
    printf("a %d\n", start_a);

    xassert("test1", true);

    xassert("message passing test", 3.fun() == 123);
    xassert("const test", const_test("ABC"));

    char*% b = string_test1(string2(string("ABC")));

    puts(b);

    int xxx = 123;

    xassert("eqeq test", xxx == 123);

    int (*aaa)(int) = int lambda(int c) { puts("FUN"); printf("xxx %d\n", xxx); return xxx + c; };

    xassert("function pointer test", aaa(1) == 124);

    xassert("eqeq test", xxx == 123);

    Data data;

    data.a = 123;
    data.b = 234;

    xassert("load field and store test", data.a == 123 && data.b == 234);

//    gSData = NULL;

    GenericsData!<int> data2;

    data2.a = 123;
    data2.b = 234;

    xassert("load field and store test2", data2.a == 123 && data2.b == 234);
    xassert("generics fun test", data2.show() == 555);

    xassert("method generics fun test", fun2(123) == 124);

    xassert("method generics fun test2", fun3(int lambda(char* str) { return atoi(str); }, "123") == 123);

    xassert("map test", data2.map(int lambda(int c) { return c + 1; }) == 124);

    inheritFun();

    GenericsData2!<int>* xyz = new GenericsData2!<int>;
    xyz.fun();

    GenericsData3!<int> xyz2;

    xyz2.fun();

    gA = 1;

    xassert("global variable", gA == 1);
    xassert("global variable2", gB == 123);

    xassert("enum test", kA == 0 && kB==1 && kC == 2);
    xassert("enum test2", kA2 == 123 && kB2== 124 && kC2 == 125);

    struct { int a; int b; } anonyumous_struct_data;

    anonyumous_struct_data.a = 123;
    anonyumous_struct_data.b = 234;

    xassert("anonymous struct test", anonyumous_struct_data.a == 123 && anonyumous_struct_data.b == 234);

    union { int a; int b; } anonyumous_union_data;

    anonyumous_union_data.a = 123;

    xassert("anonyumous_union_data test" ,anonyumous_union_data.b == 123);

    Data3 data3;

    data3.a = 123;
    data3.b = 234;

    xassert("struct bit test", data3.a == 123 && data3.b == 234);

    xassert("gt lt ge le", 1 > 0 && 2 <= 2 && 3 < 4 && 1 <= 1);

    xassert("shift", (2 >> 1) == 1 && (2 << 1) == 4);
    xassert("and or xor", (1 & 1) && (1 | 0) && (1 ^ 0));

    Data3*% data3_2 = new Data3;

    data3_2->a = 234;
    data3_2->b = 345;

    xassert("struct bit test2", data3_2->a == 234 && data3_2->b == 345);

    xassert("logical denial", !0);

    char compl_a = 0xFFFE;
    xassert("complement ", ~compl_a == 1);

    int data4 = 123;
    int* p_data4 = &data4;

    xassert("pointer", *p_data4 == 123);

    int** pp_data4 = &p_data4;

    xassert("pointer2", **pp_data4 == 123);

    char*% str2 = new char[128];
    strcpy(str2, "ABC");
    (*str2) ++;

    xassert("inc test", strcmp(str2, "BBC") == 0);

    (*str2) --;

    xassert("inc test2", strcmp(str2, "ABC") == 0);

    (*str2) += 2;

    xassert("inc test3", strcmp(str2, "CBC") == 0);

    int comma = 1, 2;

    xassert("comma test", comma == 2);

    int plus_plus = 1;

    xassert("plus_plus test", ++plus_plus == 2);
    xassert("plus_plus test", plus_plus == 2);

    xassert("minus minus test test", --plus_plus == 1 && plus_plus == 1);

    int mult_eq = 12;

    mult_eq *= 2;

    xassert("mult eq test", mult_eq == 24);

    char array[100];

    strcpy(array, "ABC");


    xassert("array test", strcmp(array, "ABC") == 0);

    int array_num = 128;
    char array2[array_num];

    strcpy(array2, "ABC");

    xassert("array test2", strcmp(array2, "ABC") == 0);

    int array3[3];

    array3[0] = 123;

    xassert("array test3", array3[0] == 123);

    int array4[3][3];

    array4[1][2] = 123;

    xassert("array test4", array4[1][2] == 123);

    char array5[10][100];

    strcpy(array5[0], "ABC");
    strcpy(array5[1], "DEF");

    xassert("array test5", strcmp(array5[0], "ABC") == 0 && strcmp(array5[1], "DEF") == 0);

    xassert("array initializer test", gArray[0] == 1 && gArray[1] == 2 && gArray[2] == 3);

    gArray[1] = 123;

    xassert("global array test", gArray[1] == 123);

    int array6[3] = { 1, 2, 3 };

    xassert("array initializer test2", array6[0] == 1 && array6[1] == 2 && array6[2] == 3);

    char array7[3] = "AB";

    xassert("array initializer test3", strcmp(array7, "AB") == 0);

    xassert("array initializer test4", strcmp(gArray2, "AB") == 0);

    xassert("array initializer test5", gArray3[0] == 1 && gArray3[1] == 2 && gArray3[2] == 3);

    int array8[] = { 1, 2, 3 };

    xassert("array initializer test6", array8[0] == 1 && array8[1] == 2 && array8[2] == 3);

    char ccc = '\n';
    char ccc2 = 'a';
    char ccc3 = '\0';

    xassert("char test", ccc == '\n' && ccc2 == 'a' && ccc3 == '\0');

    for(int i=0; i<3; i++) {
        printf("i %d\n", i);
    }

    int i=0;
    while(i<3) {
        printf("i %d\n", i);
        i++;
    }

    i = 0;
    do {
        printf("i %d\n", i);
        i++;
    } while( i < 3);

    switch(1) {
        case 2:
        case 1:
            puts("1 or 2");
            break;

        case 3:
            puts("3");
            break;

        default:
            puts("default");
            break;
    }

    int aaaaaa = gArray4[0][1][2];

    xassert("global array initializer test", aaaaaa == 4);

    xassert("array initializer test", gArray4[1][1][1] == 2 && gArray4[2][0][1] == 12);

    int ay[2][2][3] = { 
        { 1,2,3 }, { 4,5,6 },
        { 7,8,9 }, { 11,12,13 }
    };

    xassert("local array initializer test", ay[0][1][2] == 6);

    ay[0][1][2] = 123;

    xassert("local array test", ay[0][1][2] == 123);

    char* aa[2] = { "AAA", "BBB" };

    xassert("local cstring array initializer test", strcmp(aa[0], "AAA") == 0 && strcmp(aa[1], "BBB") == 0);

    int nnnnn = 123;

    char* bbbbbbbbb = (char*)nnnnn;

    int mmmmm = (int)bbbbbbbbb;

    xassert("cast test", mmmmm == 123);

    xassert("sizeof test", sizeof(int) == 4);

    int a[2];
    xassert("sizeof test", sizeof(a) == 8);

    long aaaaaaa = 123;
    long unsigned int bbbbbbbb = 123;

    //funXXX();

    int conditional = 1;

    xassert("conditional", (conditional == 1 ? 2:0) == 2);

    int api_level = 1;
    xassert("conditional2", (api_level == 1 ? api_level: -1) == 1);

    int asss = 1;
    int bsss = 2;

    xassert("xsprintf", strcmp(xsprintf("%d %d", asss, bsss), "1 2") == 0);

    char ades[1024];
    char* des = ades;

    int dessize = 1;

    des[dessize-1] = '\0';

    xassert("char* equals", "AAA".equals("AAA"));

    return 0;
}


/*
    for(int i=0; i<3; i++) {
        printf("i %d\n", i);

        if(i == 2) {
            continue;
        }
    }
*/
/*
*/
