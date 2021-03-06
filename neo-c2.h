#define USE_REGEX 1

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

inline char* xstrncpy(char* des, char* src, int size)
{
    char* result;

    result = strncpy(des, src, size-1);
    des[size-1] = 0;

    return result;
}

inline char* xstrncat(char* des, char* str, int size)
{
    char* result;

    result = strncat(des, str, size-1);
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

inline void*% nccalloc(long long num, long long nsize, char* type_name)
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

inline void ncfree(void* mem, char* type_name)
{
    if(mem) {
        free(mem);
    }
}

inline void*% ncmemdup(void*% block)
{
    managed block;

#ifdef __DARWIN__
    long long size = malloc_size(block);
#else
    long long size = malloc_usable_size(block);
#endif

    if (!block) return (void*)0;

    void*% ret = nccalloc(1, size, "memdupe");

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

typedef char*% string;
typedef wchar_t*% wstring;

inline string string(char* str)
{
    int len = strlen(str);

    string result = new char[len + 1];

    strcpy(result, str);

    return result;
}

inline wstring wstring(char* str)
{
    int len = strlen(str);

//wstring a = new wchar_t[1];
// I can't understand. this requires for s309x apline linux,... hmm is it my mistake?

    wstring wstr = new wchar_t[len+1];

    int ret = mbstowcs(wstr, str, len+1);
    wstr[ret] = '\0';

    if(ret < 0) {
        wstr[0] = 0;
    }

    return wstr;
}

inline string string_from_wchar_t(wchar_t* wstr, char* default_value)
{
    int len = MB_LEN_MAX*(wcslen(wstr)+1);

    string result = new char[len];

    if(wcstombs(result, wstr, len) < 0) 
    {
        xstrncpy(result, default_value, len);
    }

    return result;
}

inline wstring wstring_from_wchar_t(wchar_t* str)
{
    int len = wcslen(str);

    wstring wstr = new wchar_t[len + 1];

    wcscpy(wstr, str);

    return wstr;
}

inline string xbasename(char* path)
{
    char* p = path + strlen(path);
    
    while(p >= path) {
        if(*p == '/') {
            break;
        }
        else {
            p--;
        }
    }
    
    if(p < path) {
        return string(path);
    }
    else {
        return string(p+1);  
    }
}

inline string xrealpath(char* path)
{
    char* result = realpath(path, NULL);

    string result2 = string(result);

    free(result);

    return result2;
}

inline void p(char* str)
{
    puts(str);
}

//////////////////////////////
/// char
//////////////////////////////
inline bool char::equals(char left, char right)
{
    return left == right;
}

inline int char::get_hash_key(char value)
{
    return value;
}

inline string char::to_string(char value) 
{
    return xsprintf("%c", value);
}

inline int char::compare(char left, char right) 
{
    if(left < right) {
        return -1;
    }
    else if(left > right) {
        return 1;
    }
    else {
        return 0;
    }
}

//////////////////////////////
/// short
//////////////////////////////
inline bool short::equals(short left, short right)
{
    return left == right;
}

inline int short::get_hash_key(short value)
{
    return value;
}

inline string short::to_string(short value) 
{
    return xsprintf("%d", value);
}

inline int short::compare(short left, short right) 
{
    if(left < right) {
        return -1;
    }
    else if(left > right) {
        return 1;
    }
    else {
        return 0;
    }
}

//////////////////////////////
/// int
//////////////////////////////
inline bool int::equals(int left, int right) 
{
    return left == right;
}

inline int int::get_hash_key(int value)
{
    return value;
}

inline string int::to_string(int value) 
{
    return xsprintf("%d", value);
}

inline int int::compare(int left, int right) 
{
    if(left < right) {
        return -1;
    }
    else if(left > right) {
        return 1;
    }
    else {
        return 0;
    }
}

//////////////////////////////
/// long
//////////////////////////////
inline bool long::equals(long left, long right) 
{
    return left == right;
}

inline int long::get_hash_key(long value)
{
    return value;
}

inline string long::to_string(long value) 
{
    return xsprintf("%ld", value);
}

inline int long::compare(long left, long right) 
{
    if(left < right) {
        return -1;
    }
    else if(left > right) {
        return 1;
    }
    else {
        return 0;
    }
}

//////////////////////////////
/// char* 
//////////////////////////////
inline bool char*::equals(char* left, char* right)
{
    return strcmp(left, right) == 0;
}

inline int char*::get_hash_key(char* value)
{
    int result = 0;
    char* p = value;
    while(*p) {
        result += (*p);
        p++;
    }
    return result;
}

inline string char*::to_string(char* value) 
{
    return string(value);
}

inline int char*::compare(char* left, char* right) 
{
    return strcmp(left, right);
}

inline int char*::length(char* str)
{
    return strlen(str);
}

inline wstring char*::to_wstring(char* value) 
{
    return wstring(value);
}

//////////////////////////////
/// string
//////////////////////////////
inline bool string::equals(string& left, string& right)
{
    return strcmp(left, right) == 0;
}

inline int string::get_hash_key(string& value)
{
    int result = 0;
    char* p = value;
    while(*p) {
        result += (*p);
        p++;
    }
    return result;
}

inline string string::to_string(string& value) 
{
    return string(value);
}

inline int string::compare(string& left, string& right) 
{
    return strcmp(left, right);
}

inline int string::length(string& str)
{
    return strlen(str);
}

inline wstring string::to_wstring(string& value) 
{
    return wstring(value);
}

//////////////////////////////
/// buffer
//////////////////////////////
struct buffer 
{
    char* buf;
    int len;
    int size;
};

inline buffer*% buffer::initialize(buffer*% self)
{
    self.size = 128;
    self.buf = malloc(self.size);
    self.buf[0] = '\0';
    self.len = 0;

    return self;
}

inline void buffer::finalize(buffer* self) 
{
    free(self.buf);
}

inline int buffer::length(buffer* self) 
{
    return self.len;
}

inline void buffer::append(buffer* self, char* mem, size_t size)
{
    if(self.len + size + 1 + 1 >= self.size) {
        int new_size = (self.size + size + 1) * 2;
        self.buf = realloc(self.buf, new_size);
        self.size = new_size;
    }

    memcpy(self.buf + self.len, mem, size);
    self.len += size;

    self.buf[self.len] = '\0';
}

inline void buffer::append_char(buffer* self, char c)
{
    if(self.len + 1 + 1 + 1 >= self.size) {
        int new_size = (self.size + 10 + 1) * 2;
        self.buf = realloc(self.buf, new_size);
        self.size = new_size;
    }

    self.buf[self.len] = c;
    self.len++;

    self.buf[self.len] = '\0';
}

inline void buffer::append_str(buffer* self, char* str)
{
    self.append(str, strlen(str));
}

inline void buffer::append_nullterminated_str(buffer* self, char* str)
{
    self.append(str, strlen(str));
    self.append_char('\0');
}

inline string buffer::to_string(buffer* self)
{
    return (string(self.buf));
}

//////////////////////////////
/// list
//////////////////////////////
struct list_item!<T>
{
    T& item;
    struct list_item!<T>* prev;
    struct list_item!<T>* next;
};

struct list!<T>
{
    list_item!<T>* head;
    list_item!<T>* tail;
    int len;
};

list!<T>*% list!<T>::initialize(list!<T>*% self) 
{
    self.head = null;
    self.tail = null;
    self.len = 0;

    return self;
}

void list!<T>::finalize(list!<T>* self) 
{
    list_item!<T>* it = self.head;
    while(it != null) {
        if(isheap(T)) {
            delete it.item;
        }
        list_item!<T>* prev_it = it;
        it = it.next;
        delete prev_it;
    }
}

void list!<T>::reset(list!<T>* self) 
{
    list_item!<T>* it = self.head;
    while(it != null) {
        if(isheap(T)) {
            delete it.item;
        }
        list_item!<T>* prev_it = it;
        it = it.next;
        delete prev_it;
    }

    self.head = null;
    self.tail = null;

    self.len = 0;
}

void list!<T>::push_back(list!<T>* self, T item) 
{
    managed item;

    if(self.len == 0) {
        list_item!<T>* litem = borrow new list_item!<T>;
        litem.prev = null;
        litem.next = null;
        litem.item = item;
        
        self.tail = litem;
        self.head = litem;
    }
    else if(self.len == 1) {
        list_item!<T>* litem = borrow new list_item!<T>;

        litem.prev = self.head;
        litem.next = null;
        litem.item = item;
        
        self.tail = litem;
        self.head.next = litem;
    }
    else {
        list_item!<T>* litem = borrow new list_item!<T>;

        litem.prev = self.tail;
        litem.next = null;
        litem.item = item;
        
        self.tail.next = litem;
        self.tail = litem;
    }

    self.len++;
}

T& list!<T>::item(list!<T>* self, int position, T& default_value) 
{
    if(position < 0) {
        position += self.len;
    }

    list_item!<T>* it = self.head;
    int i = 0;
    while(it != null) {
        if(position == i) {
            return it.item;
        }
        it = it.next;
        i++;
    }

    return default_value;
}

T list!<T>::pop_back(list!<T>* self, T& default_value)
{
    if(self.len == 0) {
        return dummy_heap default_value;
    }
    else if(self.len == 1) {
        T result = (T)self.head.item;

        delete self.head;

        self.head = null;
        self.tail = null;

        self.len--;

        if(isheap(T)) {
            return clone result;
        }
        else {
            return dummy_heap result;
        }
    }
    else if(self.len == 2) {
        T result = (T)self.tail.item;

        delete self.tail;

        self.tail = self.head;
        self.head.next = null;
        self.head.prev = null;

        self.len--;

        if(isheap(T)) {
            return clone result;
        }
        else {
            return dummy_heap result;
        }
    }
    else {
        T result = (T)self.tail.item;

        list_item!<T>* it = self.tail;

        self.tail = self.tail.prev;
        self.tail.next = null;

        delete it;

        self.len--;

        if(isheap(T)) {
            return clone result;
        }
        else {
            return dummy_heap result;
        }
    }
}

list!<T>*% list!<T>::clone(list!<T>* self) {
    list!<T>*% result = new list!<T>.initialize();

    list_item!<T>* it = self.head;
    while(it != null) {
        if(isheap(T)) {
            result.push_back(clone it.item);
        }
        else {
            result.push_back(dummy_heap it.item);
        }

        it = it.next;
    }

    return result;
}

void list!<T>::insert(list!<T>* self, int position, T item)
{
    if(position < 0) {
        position += self.len + 1;
    }
    if(position < 0) {
        position = 0;
    }
    if(self.len == 0 || position >= self.len) 
    {
        self.push_back(item);
        return;
    }

    managed item;

    if(position == 0) {
        list_item!<T>* litem = borrow new list_item!<T>;

        litem.prev = null;
        litem.next = self.head;
        litem.item = item;
        
        self.head.prev = litem;
        self.head = litem;

        self.len++;
    }
    else if(self.len == 1) {
        list_item!<T>* litem = borrow new list_item!<T>;

        litem.prev = self.head;
        litem.next = self.tail;
        litem.item = item;
        
        self.tail.prev = litem;
        self.head.next = litem;

        self.len++;
    }
    else {
        list_item!<T>* it = self.head;
        int i = 0;
        while(it != null) {
            if(position == i) {
                list_item!<T>* litem = borrow new list_item!<T>;

                litem.prev = it.prev;
                litem.next = it;
                litem.item = item;

                it.prev.next = litem;
                it.prev = litem;

                self.len++;
            }

            it = it.next;
            i++;
        }
    }
}

void list!<T>::delete(list!<T>* self, int position)
{
    if(position < 0) {
        position += self.len + 1;
    }

    if(position >= 0 && position < self.len)
    {
        if(self.len == 1) {
            if(isheap(T)) {
                delete self.head.item;
            }
            delete self.head;

            self.head = null;
            self.tail = null;

            self.len = 0;
        }
        else if(self.len == 2) {
            if(position == 0) {
                list_item!<T>* it = self.head;

                self.head = it.next;

                self.head.prev = null;
                self.head.next = null;

                self.tail = self.head;

                if(isheap(T)) {
                    delete it.item;
                }
                delete it;

                self.len--;
            }
            else {
                list_item!<T>* it = self.tail;

                self.head.next = null;
                self.head.prev = null;

                self.tail = self.head;

                if(isheap(T)) {
                    delete it.item;
                }
                delete it;

                self.len--;
            }
        }
        else {
            list_item!<T>* it = self.head;
            int i = 0;
            while(it != null) {
                if(position == i) {
                    if(i == 0) {
                        self.head = it.next;
                        self.head.prev = null;

                        if(isheap(T)) {
                            delete it.item;
                        }
                        delete it;

                        self.len--;
                    }
                    else if(i == self.len-1)
                    {
                       self.tail = it.prev;
                       self.tail.next = null;
                       if(isheap(T)) 
                       {
                            delete it.item;
                        }
                        delete it;

                        self.len--;
                    }
                    else {
                        it.prev.next = it.next;
                        it.next.prev = it.prev;
                        if(isheap(T)) {
                            delete it.item;
                        }
                        delete it;

                        self.len--;
                    }
                    break;
                }

                it = it.next;
                i++;
            }
        }
    }
}

void list!<T>::delete_range(list!<T>* self, int head, int tail)
{
    if(head < 0) {
        head += self.len;
    }
    if(tail < 0) {
        tail += self.len + 1;
    }

    if(head > tail) {
        int tmp = tail;
        tail = head;
        head = tmp;
    }

    if(head < 0) {
        head = 0;
    }

    if(tail > self.len) {
        tail = self.len;
    }

    if(head == tail) {
        return;
    }

    if(head == 0 && tail == self.len) 
    {
        self.reset();
    }
    else if(head == 0) {
        list_item!<T>* it = self.head;
        int i = 0;
        while(it != null) {
            if(i < tail) {
                if(isheap(T)) {
                    delete it.item;
                }
                list_item!<T>* prev_it = it;

                it = it.next;
                i++;

                delete prev_it;

                self.len--;
            }
            else if(i == tail) {
                self.head = it;
                self.head.prev = null;
                break;
            }
            else {
                it = it.next;
                i++;
            }
        }
    }
    else if(tail == self.len) {
        list_item!<T>* it = self.head;
        int i = 0;
        while(it != null) {
            if(i == head) {
                self.tail = it.prev;
                self.tail.next = null;
            }

            if(i >= head) {
                if(isheap(T)) {
                    delete it.item;
                }
                list_item!<T>* prev_it = it;

                it = it.next;
                i++;

                delete prev_it;

                self.len--;
            }
            else {
                it = it.next;
                i++;
            }
        }
    }
    else {
        list_item!<T>* it = self.head;

        list_item!<T>* head_prev_it = null;
        list_item!<T>* tail_it = null;

        int i = 0;
        while(it != null) {
            if(i == head) {
                head_prev_it = it.prev;
            }
            if(i == tail) {
                tail_it = it;
            }

            if(i >= head && i < tail) 
            {
                if(isheap(T)) {
                    delete it.item;
                }
                list_item!<T>* prev_it = it;

                it = it.next;
                i++;

                delete prev_it;

                self.len--;
            }
            else {
                it = it.next;
                i++;
            }
        }

        if(head_prev_it != null) {
            head_prev_it.next = tail_it;
        }
        if(tail_it != null) {
            tail_it.prev = head_prev_it;
        }
    }
}

T list!<T>::pop_front(list!<T>* self, T& default_value)
{
    if(self.len == 0) {
        return dummy_heap default_value;
    }
    else if(self.len == 1) {
        T result = (T)self.head.item;

        delete self.head;

        self.head = null;
        self.tail = null;

        self.len = 0;

        if(isheap(T)) {
            return clone result;
        }
        else {
            return dummy_heap result;
        }
    }
    else if(self.len == 2) {
        T result = (T)self.head.item;

        list_item!<T>* head_before = self.head;

        self.head = self.head.next;
        self.head.prev = null;
        self.head.next = null;
        
        delete head_before;

        self.len--;

        if(isheap(T)) {
            return clone result;
        }
        else {
            return dummy_heap result;
        }
    }
    else {
        T result = (T)self.head.item;

        list_item!<T>* head_before = self.head;

        self.head = self.head.next;
        self.head.prev = null;
        
        delete head_before;

        self.len--;

        if(isheap(T)) {
            return clone result;
        }
        else {
            return dummy_heap result;
        }
    }
}

void list!<T>::replace(list!<T>* self, int position, T item)
{
    managed item;

    if(position < 0) {
        position += self.len;
    }

    list_item!<T>* it = self.head;
    int i = 0;
    while(it != null) {
        if(position == i) {
            if(isheap(T)) {
                delete it.item;
            }

            it.item = item;
            break;
        }
        it = it.next;
        i++;
    }
}

void list!<T>::each(list!<T>* self, void (*block_)(T&,int,bool*)) {
    list_item!<T>* it_ = self.head;
    int i_ = 0;
    while(it_ != null) {
        bool end_flag_ = false;
        block_(it_.item, i_, &end_flag_);

        if(end_flag_ == true) {
            break;
        }
        it_ = it_.next;
        i_++;
    }
}

list!<T>*% list!<T>::sublist(list!<T>* self, int begin, int tail) {
    list!<T>*% result = new list!<T>.initialize();

    if(begin < 0) {
        begin += self.len;
    }

    if(tail < 0) {
        tail += self.len + 1;
    }

    if(begin < 0) {
        begin = 0;
    }

    if(tail >= self.len) {
        tail = self.len;
    }


    list_item!<T>* it = self.head;
    int i = 0;
    while(it != null) {
        if(i >= begin && i < tail) {
            if(isheap(T)) {
                result.push_back(clone it.item);
            }
            else {
                result.push_back(dummy_heap it.item);
            }
        }
        it = it.next;
        i++;
    }

    return result;
}

int list!<T>::length(list!<T>* self)
{
    return self.len;
}

list!<T>*% list!<T>::reverse(list!<T>* self) {
    list!<T>*% result = new list!<T>.initialize();

    list_item!<T>* it = self.tail;
    while(it != null) {
        if(isheap(T)) {
            result.push_back(clone it.item);
        }
        else {
            result.push_back(dummy_heap it.item);
        }
        it = it.prev;
    }

    return result;
}

string list!<T>::join(list!<string>* self, char* separator) {
    buffer*% buf = new buffer.initialize();

    list_item!<T>* it = self.head;
    int i = 0;
    while(it != null) {
        if(i == self.length() - 1) {
            buf.append_str(it.item);
        }
        else {
            buf.append_str(it.item);
            buf.append_str(separator);
        }

        it = it.next;
        i++;
    }

    return string(buf.buf);
}

list!<T>*% list!<T>::merge_list(list!<T>* left, list!<T>* right) 
{
    list!<T>*% result = new list!<T>.initialize();

    list_item!<T>* it = left.head;
    list_item!<T>* it2= right.head;

    while(true) {
        if(it && it2) {
            if(it.item == null) {
                it = it.next;
            }
            else if(it2.item == null) {
                it2 = it2.next;
            }
            else if(it.item.compare(it2.item) <= 0) 
            {
                if(isheap(T)) {
                    result.push_back(clone it.item);
                }
                else {
                    result.push_back(dummy_heap it.item);
                }

                it = it.next;
            }
            else {
                if(isheap(T)) {
                    result.push_back(clone it2.item);
                }
                else {
                    result.push_back(dummy_heap it2.item);
                }


                it2 = it2.next;
            }
        }

        if(it == null) {
            if(it2 != null) {
                while(it2 != null) {
                    if(isheap(T)) {
                        result.push_back(clone it2.item);
                    }
                    else {
                        result.push_back(dummy_heap it2.item);
                    }

                    it2 = it2.next;
                }
            }
            break;
        }
        else if(it2 == null) {
            if(it != null) {
                while(it != null) {
                    if(isheap(T)) {
                        result.push_back(clone it.item);
                    }
                    else {
                        result.push_back(dummy_heap it.item);
                    }

                    it = it.next;
                }
            }
            break;
        }
    }

    return result;
}

list!<T>*% list!<T>::merge_sort(list!<T>* self) {
    if(self.head == null) {
        return clone self;
    }
    if(self.head.next == null) {
        return clone self;
    }

    list!<T>*% list1 = new list!<T>.initialize();
    list!<T>*% list2 = new list!<T>.initialize();

    list_item!<T>* it = self.head;

    while(true) {
        if(isheap(T)) {
            list1.push_back(clone it.item);
        }
        else {
            list1.push_back(dummy_heap it.item);
        }

        if(isheap(T)) {
            list2.push_back(clone it.next.item);
        }
        else {
            list2.push_back(dummy_heap it.next.item);
        }

        if(it.next.next == null) {
            break;
        }

        it = it.next.next;

        if(it.next == null) {
            if(isheap(T)) {
                list1.push_back(clone it.item);
            }
            else {
                list1.push_back(dummy_heap it.item);
            }
            break;
        }
    }

    return list1.merge_sort().merge_list( list2.merge_sort());
}

list!<T>*% list!<T>::sort(list!<T>* self) {
    list!<T>*% result = self.merge_sort();
    return result;
}

template !<R> list!<R>*% list!<T>::map(list!<T>* self, R (*block_)(T&))
{
    list!<R>*% result_ = new list!<R>.initialize();

    list_item!<T>* it_ = self.head;
    while(it_ != null) {
        result_.push_back(block_(it_.item));

        it_ = it_.next;
    }

    return result_;
}

list!<T>*% list!<T>::uniq(list!<T>* self) {
    list!<T>*% result = new list!<T>.initialize();

    if(self.length() > 0) {
        T& item_before = self.item(0, null);

        if(isheap(T)) {
            result.push_back(clone item_before);
        }
        else {
            result.push_back(dummy_heap item_before);
        }

        self.sublist(1,-1).each (
            void lambda(T it, int it2, bool* it3) {
                if(!it.equals(item_before)) {
                    if(isheap(T)) {
                        result.push_back(clone it);
                    }
                    else {
                        result.push_back(dummy_heap it);
                    }
                }

                item_before = it; 
            }
        );
    }

    return result;
}

int list!<T>::find(list!<T>* self, T& item, int default_value) {
    int result = default_value;
    self.each (void lambda(T it, int it2, bool* it3) {
        if(it.equals(item)) {
            result = it2;
            *it3 = true;
            return;
        }
    });

    return result;
}

bool list!<T>::equals(list!<T>* left, list!<T>* right)
{
    if(left.len != right.len) {
        return false;
    }

    list_item!<T>* it = left.head;
    list_item!<T>* it2 = right.head;

    while(it != null) {
        if(!it.item.equals(it2.item)) {
            return false;
        }

        it = it.next;
        it2 = it2.next;
    }

    return true;
}

list!<T>*% list!<T>::filter(list!<T>* self, bool (*block_)(T&))
{
    list!<T>*% result_ = new list!<T>.initialize();

    list_item!<T>* it_ = self.head;
    while(it_ != null) {
        if(block_(it_.item)) {
            if(isheap(T)) {
                result_.push_back(clone it_.item);
            }
            else {
                result_.push_back(dummy_heap it_.item);
            }
        }

        it_ = it_.next;
    }

    return result_;
} 

//////////////////////////////
/// vector
//////////////////////////////
struct vector!<T> 
{
    T*& items;
    int len;
    int size;
};

vector!<T>*% vector!<T>::initialize(vector!<T>*% self) 
{
    self.size = 16;
    self.len = 0;
    self.items = borrow new T[self.size];

    return self;
}

void vector!<T>::finalize(vector!<T>* self)
{
    if(isheap(T)) {
        for(int i=0; i<self.len; i++) 
        {
            delete self.items[i];

        }
    }

    delete self.items;
}

void vector!<T>::push_back(vector!<T>* self, T item) {
    managed item;

    if(self.len == self.size) {
        int new_size = self.size * 2;
        T*& items = self.items;

        self.items = borrow new T[new_size];

        int i;
        for(i=0; i<self.size; i++) {
            self.items[i] = items[i];
        }

        self.size = new_size;

        delete items;
    }

    self.items[self.len] = item;
    self.len++;
}

T& vector!<T>::item(vector!<T>* self, int index, T& default_value) 
{
    if(index < 0) {
        index += self.len;
    }

    if(index >= 0 && index < self.len)
    {
        return self.items[index];
    }

    return default_value;
}

vector!<T>*% vector!<T>::clone(vector!<T>* self) 
{
    vector!<T>*% result = new vector!<T>.initialize();

    for(int i=0; i<self.len; i++) {
        T& it = self.items[i];
        if(isheap(T)) {
            result.push_back(clone it);
        }
        else {
            result.push_back(dummy_heap it);
        }
    }

    return result;
}

int vector!<T>::length(vector!<T>* self)
{
    return self.len;
}

void vector!<T>::each(vector!<T>* self, void (*block_)(T&,int,bool*)) 
{
    for(int i_=0; i_<self.len; i_++) {
        bool end_flag_ = false;
        block_(self.items[i_], i_, &end_flag_);
        if(end_flag_ == true) {
            break;
        }
    }
}

int vector!<T>::find(vector!<T>* self, T& item, int default_value) 
{
    int result = default_value;
    self.each (void lambda(T it, int it2, bool* it3) {
        if(it.equals(item)) {
            result = it2;
            *it3 = true;
            return;
        }
    });

    return result;
}

T vector!<T>::pop_back(vector!<T>* self, T& default_value)
{
    if(self.len == 0) {
        return dummy_heap default_value;
    }

    T result = (T)self.items[self.len-1];

    self.len--;

    return result;
}

template !<R> vector!<R>*% vector!<T>::map(vector!<T>* self, R (*block_)(T&))
{
    vector!<R>*% result_ = new vector!<R>.initialize();

    for(int i_=0; i_<self.len; i_++) {
        result_.push_back(block_(self.items[i_]));
    }

    return result_;
}

bool vector!<T>::equals(vector!<T>* left, vector!<T>* right)
{
    if(left.len != right.len) {
        return false;
    }

    for(int i=0; i<left.len; i++) {
        if(!(left.items[i].equals(right.items[i])))
        {
            return false;
        }
    }

    return true;
}

bool vector!<T>::replace(vector!<T>* self, int index, T value) 
{
    managed value;

    if(index < 0) {
        index += self.len;
    }

    if(index >= 0 && index < self.len)
    {
        if(isheap(T)) {
            delete self.items[index];
        }

        self.items[index] = value;

        return true;
    }

    return false;
}

list!<T>*% vector!<T>::to_list(vector!<T>* self) {
    list!<T>*% result = new list!<T>.initialize();
    
    self.each(void lambda(T it, int it2, bool* it3) {
        if(isheap(T)) {
            result.push_back(clone it);
        }
        else {
            result.push_back(dummy_heap it);
        }
    });
    
    return result;
}

vector!<T>*% list!<T>::to_vector(list!<T>* self) {
    vector!<T>*% result = new vector!<T>.initialize();
    
    self.each (void lambda(T it, int it2, bool* it3) {
        if(isheap(T)) {
            result.push_back(clone it);
        }
        else {
            result.push_back(dummy_heap it);
        }
    });
    
    return result;
}

vector!<T>*% vector!<T>::initialize_with_values(vector!<T>*% self, int len, T& value) 
{
    self.size = len;
    self.len = len;
    self.items = borrow new T[self.size];

    for(int i=0; i<len; i++) {
        if(isheap(T)) {
            self.items[i] = borrow clone value;
        }
        else {
            self.items[i] = value;
        }
    }

    return self;
}

//////////////////////////////
// tuple
//////////////////////////////
struct tuple1!<T>
{
    T v1;
};

bool tuple1!<T>::equals(tuple1!<T>* left, tuple1!<T>* right)
{
    if(!left.v1.equals(right.v1)) {
        return false;
    }

    return true;
}

struct tuple2!<T, T2>
{
    T v1;
    T2 v2;
};

bool tuple2!<T,T2>::equals(tuple2!<T, T2>* left, tuple2!<T, T2>* right)
{
    if(!left.v1.equals(right.v1)) {
        return false;
    }
    if(!left.v2.equals(right.v2)) {
        return false;
    }

    return true;
}

struct tuple3!<T, T2, T3>
{
    T v1;
    T2 v2;
    T3 v3;
};

bool tuple3!<T,T2,T3>::equals(tuple3!<T, T2, T3>* left, tuple3!<T, T2, T3>* right)
{
    if(!left.v1.equals(right.v1)) {
        return false;
    }
    if(!left.v2.equals(right.v2)) {
        return false;
    }
    if(!left.v3.equals(right.v3)) {
        return false;
    }

    return true;
}

struct tuple4!<T, T2, T3, T4>
{
    T v1;
    T2 v2;
    T3 v3;
    T4 v4;
};

bool tuple4!<T,T2,T3,T4>::equals(tuple4!<T, T2, T3, T4>* left, tuple4!<T, T2, T3, T4>* right)
{
    if(!left.v1.equals(right.v1)) {
        return false;
    }
    if(!left.v2.equals(right.v2)) {
        return false;
    }
    if(!left.v3.equals(right.v3)) {
        return false;
    }
    if(!left.v4.equals(right.v4)) {
        return false;
    }

    return true;
}

//////////////////////////////
// map
//////////////////////////////

#define MAP_TABLE_DEFAULT_SIZE 128

struct map!<T, T2>
{
    T*& keys;
    bool* item_existance;
    T2*& items;
    int size;
    int len;
};

map!<T,T2>*% map!<T,T2>::initialize(map!<T,T2>*% self) 
{
    self.keys = borrow new T[MAP_TABLE_DEFAULT_SIZE];
    self.items = borrow new T2[MAP_TABLE_DEFAULT_SIZE];
    self.item_existance = borrow new bool[MAP_TABLE_DEFAULT_SIZE];

    for(int i=0; i<MAP_TABLE_DEFAULT_SIZE; i++)
    {
        self.item_existance[i] = false;
    }

    self.size = MAP_TABLE_DEFAULT_SIZE;
    self.len = 0;

    return self;
}

void map!<T,T2>::finalize(map!<T,T2>* self) 
{
    for(int i=0; i<self.size; i++) {
        if(self.item_existance[i]) {
            if(isheap(T2)) {
                delete self.items[i];
            }
        }
    }
    delete self.items;

    for(int i=0; i<self.size; i++) {
        if(self.item_existance[i]) {
            if(isheap(T)) {
                delete self.keys[i];
            }
        }
    }
    delete self.keys;

    delete self.item_existance;
}

void map!<T,T2>::each(map!<T, T2>* self, void (*block_)(T&,T2&,bool*)) 
{
    for(int i_=0; i_<self.size; i_++) {
        if(self.item_existance[i_]) {
            bool end_flag_ = false;
            block_(self.keys[i_], self.items[i_], &end_flag_);
            if(end_flag_ == true) {
                break;
            }
        }
    }
}

map!<T, T2>*% map!<T,T2>::clone(map!<T, T2>* self)
{
    map!<T,T2>*% result = new map!<T,T2>.initialize();

    self.each (void lambda(T& it, T2& it2, bool it3) {
        if(isheap(T)) {
            if(isheap(T2)) {
                result.insert(clone it, clone it2);
            }
            else {
                result.insert(clone it, dummy_heap it2);
            }
        }
        else {
            if(isheap(T2)) {
                result.insert(dummy_heap it, clone it2);
            }
            else {
                result.insert(dummy_heap it, dummy_heap it2);
            }
        }
    });

    return result;
}

void map!<T,T2>::rehash(map!<T,T2>* self) 
{
    int size = self.size * 3;
    T*& keys = borrow new T[size];
    T2*& items = borrow new T2[size];
    bool* item_existance = borrow new bool[size];

    int len = 0;

    self.each (void lambda(T& it, T2& it2, bool* it3) {
        int hash = it.get_hash_key() % size;
        int n = hash;

        while(true) {
            if(item_existance[n]) {
                n++;

                if(n >= size) {
                    n = 0;
                }
                else if(n == hash) {
                    fprintf(stderr, "unexpected error in map.rehash(1)\n");
                    exit(2);
                }
            }
            else {
                item_existance[n] = true;
                keys[n] = it;
                items[n] = it2;

                len++;
                break;
            }
        }
    });

    delete self.items;
    delete self.item_existance;
    delete self.keys;

    self.keys = keys;
    self.items = items;
    self.item_existance = item_existance;

    self.size = size;
    self.len = len;
}

bool map!<T,T2>::find(map!<T, T2>* self, T& key) 
{
    int hash = ((T)key).get_hash_key() % self.size;
    int it = hash;

    while(true) {
        if(self.item_existance[it]) {
            if(self.keys[it].equals(key)) {
                return true;
            }

            it++;

            if(it >= self.size) {
                it = 0;
            }
            else if(it == hash) {
                return false;
            }
        }
        else {
            return false;
        }
    }

    return false;
}

T2& map!<T,T2>::at(map!<T, T2>* self, T& key, T2& default_value) 
{
    int hash = ((T)key).get_hash_key() % self.size;
    int it = hash;

    while(true) {
        if(self.item_existance[it]) {
            if(self.keys[it].equals(key)) {
                return self.items[it];
            }

            it++;

            if(it >= self.size) {
                it = 0;
            }
            else if(it == hash) {
                return default_value;
            }
        }
        else {
            return default_value;
        }
    }

    return default_value;
}

void map!<T,T2>::insert(map!<T,T2>* self, T key, T2 item) 
{
    managed key;
    managed item;

    if(self.len*2 >= self.size) {
        self.rehash();
    }

    int hash = ((T)key).get_hash_key() % self.size;
    int it = hash;

    while(true) {
        if(self.item_existance[it]) {
            if(self.keys[it].equals(key)) {
                if(isheap(T)) {
                    delete dummy_heap self.keys[it];
                }
                if(isheap(T2)) {
                    delete dummy_heap self.items[it];
                }
                self.keys[it] = key;
                self.items[it] = item;

                break;
            }

            it++;

            if(it >= self.size) {
                it = 0;
            }
            else if(it == hash) {
                fprintf(stderr, "unexpected error in map.insert\n");
                exit(2);
            }
        }
        else {
            self.item_existance[it] = true;
            self.keys[it] = key;
            self.items[it] = item;

            self.len++;

            break;
        }
    }
}

bool map!<T,T2>::equals(map!<T, T2>* left, map!<T, T2>* right)
{
    if(left.len != right.len) {
        return false;
    }

    bool result = true;
    left.each (void lambda(T& it, T2& it2, bool* it3) {
        if(right.find(it)) {
            T2& default_value;
            T2 item = right.at(it, default_value);
            if(!it2.equals(item)) {
                result = false;
            }
        }
        else {
            result = false;
        }
    });

    return result;
}

int map!<T,T2>::length(map!<T, T2>* self) 
{
    return self.len;
}

//////////////////////////////
// wchar_t
//////////////////////////////
/*
inline bool wchar_t*::equals(wchar_t* left, wchar_t* right)
{
    return wcscmp(left, right) == 0;
}

inline int wchar_t*::length(wchar_t* str)
{
    return wcslen(str);
}

inline int wchar_t*::get_hash_key(wchar_t* value)
{
    int result = 0;
    wchar_t* p = value;
    while(*p) {
        result += (*p);
        p++;
    }
    return result;
}

inline string wchar_t*::to_string(wchar_t* wstr, char* default_value) 
{
    size_t len = wcslen(wstr) + 1;
    int len2 = MB_LEN_MAX * len;

    string result = new char[len2];

    if(wcstombs(result, wstr, len2) < 0) 
    {
        xstrncpy(result, default_value, len2);
    }

    return result;
}

inline wstring wchar_t*::to_wstring(wchar_t* str) 
{
    int len = wcslen(str);

    wstring wstr = new wchar_t[len + 1];

    wcscpy(wstr, str);

    return wstr;
}

inline int wchar_t*::compare(wstring& left, wstring& right) 
{
    return wcscmp(left, right);
}
*/

//////////////////////////////
// wstring
//////////////////////////////
inline bool wstring::equals(wstring& left, wstring& right)
{
    return wcscmp(left, right) == 0;
}

inline int wstring::length(wstring& str)
{
    return wcslen(str);
}

inline int wstring::get_hash_key(wstring& value)
{
    int result = 0;
    wchar_t* p = value;
    while(*p) {
        result += (*p);
        p++;
    }
    return result;
}

inline string wstring::to_string(wstring& wstr, char* default_value) 
{
    size_t len = wcslen(wstr) + 1;
    int len2 = MB_LEN_MAX * len;

    string result = new char[len2];

    if(wcstombs(result, wstr, len2) < 0) 
    {
        xstrncpy(result, default_value, len2);
    }

    return result;
}

inline int wstring::compare(wstring& left, wstring& right) 
{
    return wcscmp(left, right);
}

/*
/// wchar_t ////
inline bool wchar_t::equals(wchar_t left, wchar_t right)
{
    return left == right;
}

inline int wchar_t::get_hash_key(wchar_t value)
{
    return value;
}

inline string wchar_t::to_string(wchar_t value) 
{
    return xsprintf("%lc", value);
}

inline int wchar_t::compare(wchar_t left, wchar_t right) 
{
    if(left < right) {
        return -1;
    }
    else if(left > right) {
        return 1;
    }
    else {
        return 0;
    }
}
*/

//////////////////////////////
// string core
//////////////////////////////
inline string string::reverse(string& str) 
{
    int len = strlen(str);
    string result = new char[len + 1];

    for(int i=0; i<len; i++) {
        result[i] = str[len-i-1];
    }

    result[len] = '\0';

    return result;
}

inline string string::substring(string& str, int head, int tail)
{
    if(str == null) {
        return string("");
    }

    int len = strlen(str);

    if(head < 0) {
        head += len;
    }
    if(tail < 0) {
        tail += len + 1;
    }

    if(head > tail) {
        return string(str).substring(tail, head).reverse();
    }

    if(head < 0) {
        head = 0;
    }

    if(tail >= len) {
        tail = len;
    }

    if(head == tail) {
        return string("");
    }

    if(tail-head+1 < 1) {
        return string("");
    }

    string result = new char[tail-head+1];

    memcpy(result, str + head, tail-head);
    result[tail-head] = '\0';

    return result;
}

inline int string::index(string& str, char* search_str, int default_value)
{
    char* head = strstr(str, search_str);

    if(head == null) {
        return default_value;
    }

    return head - str;
}

inline int string::rindex(string& str, char* search_str, int default_value)
{
    int len = strlen(search_str);
    char* p = str + strlen(str) - len;

    while(p >= str) {
        if(strncmp(p, search_str, len) == 0) {
            return p - str;
        }

        p--;
    }

    return default_value;
}

inline string& string::delete(string& str, int position) 
{
    int len = strlen(str);
    
    if(position < 0) {
        position += len;
    }

    if(position < 0) {
        position = 0;
    }

    if(position >= len) {
        position = len -1;

        if(position < 0) {
            return str;
        }
    }
    
    string sub_str = string(str).substring(position+1, -1);

    memcpy(str + position, sub_str, sub_str.length()+1);

    return str;
}

inline string& string::delete_range(string& str, int head, int tail) 
{
    int len = strlen(str);

    if(strcmp(str, "") == 0) {
        return str;
    }
    
    if(head < 0) {
       head += len;
    }
    
    if(tail < 0) {
       tail += len + 1;
    }

    if(head < 0) {
        head = 0;
    }

    if(tail < 0) {
        return str;
    }

    if(tail >= len) {
        tail = len;
    }
    
    string sub_str = string(str).substring(tail, -1);

    memcpy(str + head, sub_str, sub_str.length()+1);

    return str;
}

inline string string::printable(string& str)
{
    int len = str.length();
    string result = new char[len*2+1];

    int n = 0;
    for(int i=0; i<len; i++) {
        char c = str[i];

        if((c >= 0 && c < ' ') 
            || c == 127)
        {
            result[n++] = '^';
            result[n++] = c + 'A' - 1;
        }
        else {
            result[n++] = c;
        }
    }

    result[n] = '\0';

    return result;
}

inline buffer*% string::to_buffer(string& self) 
{
    buffer*% result = new buffer.initialize();

    result.append_str(self);

    return result;
}

inline list!<string>*% string::split_char(string& self, char c) 
{
    list!<string>*% result = new list!<string>.initialize();

    buffer*% str = new buffer.initialize();

    for(int i=0; i<self.length(); i++) {
        if(self[i] == c) {
            result.push_back(string(str.buf));
            str = new buffer.initialize();
        }
        else {
            str.append_char(self[i]);
        }
    }
    if(str.length() != 0) {
        result.push_back(string(str.buf));
    }

    return result;
}

inline char string::item(string& self, int index, char default_value)
{
    int len = strlen(self);

    if(strcmp(self, "") == 0) {
        return default_value;
    }
    
    if(index < 0) {
       index += len;
    }

    if(index < 0 || index >= len) {
        return default_value;
    }
    
    return self[index];
}

inline string& string::replace(string& self, int index, char c) 
{
    int len = strlen(self);

    if(strcmp(self, "") == 0) {
        return self;
    }
    
    if(index < 0) {
       index += len;
    }

    if(index >= len) {
        index = len-1;
    }

    if(index < 0) {
        index = 0;
    }
    
    self[index] = c;

    return self;
}

//////////////////////////////
// wstring
//////////////////////////////
inline wstring wstring::reverse(wstring& str) 
{
    int len = wcslen(str);
    wstring result = new wchar_t[len + 1];

    for(int i=0; i<len; i++) {
        result[i] = str[len-i-1];
    }

    result[len] = '\0';

    return result;
}

inline wstring wstring::substring(wstring& str, int head, int tail)
{
    if(str == null) {
        return wstring("");
    }

    int len = wcslen(str);

    if(head < 0) {
        head += len;
    }
    if(tail < 0) {
        tail += len + 1;
    }

    if(head > tail) {
        return wstring_from_wchar_t(str).substring(tail, head).reverse();
    }

    if(head < 0) {
        head = 0;
    }

    if(tail >= len) {
        tail = len;
    }

    if(head == tail) {
        return wstring("");
    }

    if(tail-head+1 < 1) {
        return wstring("");
    }

    wstring result = new wchar_t[tail-head+1];

    memcpy(result, str + head, sizeof(wchar_t)*(tail-head));
    result[tail-head] = '\0';

    return result;
}

inline int wstring::index(wstring& str, wchar_t* search_str, int default_value)
{
    wchar_t* head = wcsstr(str, search_str);

    if(head == null) {
        return default_value;
    }

    return ((head - str) / sizeof(wchar_t));
}

inline int wstring::rindex(wstring& str, wchar_t* search_str, int default_value)
{
    int len = wcslen(search_str);

    wchar_t* p = str + wcslen(str) - len;

    while(p >= str) {
        if(wcsncmp(p, search_str, len) == 0) {
            return ((p - str) / sizeof(wchar_t));
        }

        p--;
    }

    return default_value;
}

inline wstring& wstring::delete(wstring& str, int position) 
{
    int len = wcslen(str);
    
    if(position < 0) {
        position += len;
    }

    if(position < 0) {
        position = 0;
    }

    if(position >= len) {
        position = len -1;

        if(position < 0) {
            return str;
        }
    }

    wstring sub_str = wstring_from_wchar_t(str).substring(position+1, -1);

    memcpy(str + position, sub_str, sizeof(wchar_t)*(sub_str.length()+1));
    
    return str;
}

inline wstring& wstring::delete_range(wstring& str, int head, int tail) 
{
    int len = wcslen(str);

    if(len == 0) {
        return str;
    }
    
    if(head < 0) {
       head += len;
    }
    
    if(tail < 0) {
       tail += len + 1;
    }

    if(head < 0) {
        head = 0;
    }

    if(tail < 0) {
        return str;
    }

    if(tail >= len) {
        tail = len;
    }
    
    wstring sub_str = wstring_from_wchar_t(str).substring(tail, -1);

    memcpy(str + head, sub_str, sizeof(wchar_t)*(sub_str.length()+1));

    return str;
}

inline wstring wstring::printable(wstring& str)
{
    int len = wstring_from_wchar_t(str).length();
    wstring result = new wchar_t[len*2+1];

    int n = 0;
    for(int i=0; i<len; i++) {
        wchar_t c = str[i];

        if((c >= 0 && c < ' ') 
            || c == 127)
        {
            result[n++] = '^';
            result[n++] = c + 'A' - 1;
        }
        else {
            result[n++] = c;
        }
    }

    result[n] = '\0';

    return result;
}

inline wstring& wstring::replace(wstring& self, int index, wchar_t c) 
{
    int len = wcslen(self);

    if(wcscmp(self, wstring("")) == 0) {
        return self;
    }
    
    if(index < 0) {
       index += len;
    }

    if(index >= len) {
        index = len-1;
    }

    if(index < 0) {
        index = 0;
    }
    
    self[index] = c;

    return self;
}

inline wchar_t wstring::item(wstring& self, int index, wchar_t default_value)
{
    int len = wcslen(self);

    if(wcscmp(self, wstring("")) == 0) {
        return default_value;
    }
    
    if(index < 0) {
       index += len;
    }

    if(index < 0 || index >= len) {
        return default_value;
    }
    
    return self[index];
}

#if USE_REGEX == 1

struct regex_struct {
    string str;
    pcre* regex;

    bool ignore_case;
    bool multiline;
    bool global;
    bool extended;
    bool dotall;
    bool anchored;
    bool dollar_endonly;
    bool ungreedy;

    int options;
};

typedef regex_struct*% nregex;

inline nregex regex(char* str, bool ignore_case, bool multiline, bool global, bool extended, bool dotall, bool anchored, bool dollar_endonly, bool ungreedy)
{
    nregex result = new regex_struct;

    const char* err;
    int erro_ofs;

    int options = PCRE_UTF8 | (ungreedy ? PCRE_UNGREEDY:0);
    //int options = PCRE_UTF8 | (ignore_case ? PCRE_CASELESS:0) | (multiline ? PCRE_MULTILINE : 0) | (extended ? PCRE_EXTENDED :0) | (dotall ? PCRE_DOTALL :0) | (dollar_endonly ? PCRE_DOLLAR_ENDONLY:0) | (ungreedy ? PCRE_UNGREEDY:0);

    //result.regex = pcre_compile(str, options, &err, &erro_ofs, NULL);

    result.str = string(str);
    result.ignore_case = ignore_case;
    result.multiline = multiline;
    result.global = global;
    result.extended = extended;
    result.dotall = dotall;
    result.anchored = anchored;
    result.dollar_endonly = dollar_endonly;
    result.ungreedy;
    result.options = options;

    return result;
}

#define REGEX(o, o2) regex(o, false, false, o2, false, false, false, false, false)

inline int string::index_regex(string& self, nregex reg, int default_value)
{
    int ovec_max = 16;
    int start[ovec_max];
    int end[ovec_max];
    int ovec_value[ovec_max * 3];

    int result = default_value;
    
    int offset = 0;

    const char* err;
    int erro_ofs;

    int options = reg.options;
    char* str = reg.str;

    pcre* re = pcre_compile(str, options, &err, &erro_ofs, null);

    while(true) {
        int options = PCRE_NEWLINE_LF;
        int len = strlen(self);
        int regex_result = pcre_exec(re, 0, self, len, offset, options, ovec_value, ovec_max*3);

        for(int i=0; i<ovec_max; i++) {
            start[i] = ovec_value[i*2];
        }
        for(int i=0; i<ovec_max; i++) {
            end[i] = ovec_value[i*2+1];
        }

        /// match and no group strings ///
        if(regex_result == 1 || regex_result > 0) 
        {
            result = start[0];
            break;
        }
        /// no match ///
        else
        {
            break;
        }
    }

    free(re);

    return result;
}

inline int string::rindex_regex(string& self, nregex reg, int default_value)
{
    const char* err;
    int erro_ofs;

    int options = reg.options;
    char* str = reg.str;

    pcre* re = pcre_compile(str, options, &err, &erro_ofs, null);

    string self2 = string(self).reverse();
    
    int ovec_max = 16;
    int start[ovec_max];
    int end[ovec_max];
    int ovec_value[ovec_max * 3];

    int result = default_value;
    
    int offset = 0;

    while(true) {
        int options = PCRE_NEWLINE_LF;
        int len = strlen(self2);
        int regex_result = pcre_exec(re, 0, self2, len, offset, options, ovec_value, ovec_max*3);

        for(int i=0; i<ovec_max; i++) {
            start[i] = ovec_value[i*2];
        }
        for(int i=0; i<ovec_max; i++) {
            end[i] = ovec_value[i*2+1];
        }

        /// match and no group strings ///
        if(regex_result == 1 || regex_result > 0) 
        {
            result = strlen(self) -1 - start[0];
            break;
        }
        else 
        /// no match ///
        {
            break;
        }
    }

    free(re);

    return result;
}

inline string string::sub(string& self, nregex reg, char* replace, list!<string>* group_strings)
{
    int offset = 0;

    int ovec_max = 16;
    int start[ovec_max];
    int end[ovec_max];
    int ovec_value[ovec_max * 3];

    const char* err;
    int erro_ofs;

    int options = reg.options;
    char* str = reg.str;

    pcre* re = pcre_compile(str, options, &err, &erro_ofs, NULL);

    buffer*% result = new buffer.initialize();

    while(true) {
        int options = PCRE_NEWLINE_LF;
        int len = strlen(self);
        int regex_result = pcre_exec(re, 0, self, len, offset, options, ovec_value, ovec_max*3);

        for(int i=0; i<ovec_max; i++) {
            start[i] = ovec_value[i*2];
        }
        for(int i=0; i<ovec_max; i++) {
            end[i] = ovec_value[i*2+1];
        }

        /// match and no group strings ///
        if(regex_result == 1 || (group_strings == null && regex_result > 0)) 
        {
            string str = string(self).substring(offset, start[0]);

            result.append_str(str);
            result.append_str(replace);

            if(offset == end[0]) {
                offset++;
            }
            else {
                offset = end[0];
            }

            if(!reg.global) {
                string str = string(self).substring(offset, -1);
                result.append_str(str);
                break;
            }
        }
        /// group strings ///
        else if(regex_result > 1) {
            string str = string(self).substring(offset, start[0]);
            result.append_str(str);
            result.append_str(replace);

            if(offset == end[0]) {
                offset++;
            }
            else {
                offset = end[0];
            }

            if(!reg.global) {
                group_strings.reset();
            }

            for(int i = 1; i<regex_result; i++) {
                string match_string = string(self).substring(start[i], end[i]);
                group_strings.push_back(match_string);
            }

            if(!reg.global) {
                string str = string(self).substring(offset, -1);
                result.append_str(str);
                break;
            }
        }
        else
        /// no match ///
        {
            string str = string(self).substring(offset, -1);
            result.append_str(str);
            break;
        }
    }

    free(re);

    return result.to_string();
}

inline bool string::match(string& self, nregex reg, list!<string>* group_strings)
{
    int offset = 0;

    int ovec_max = 16;
    int start[ovec_max];
    int end[ovec_max];
    int ovec_value[ovec_max * 3];

    const char* err;
    int erro_ofs;

    int options = reg.options;
    char* str = reg.str;

    pcre* re = pcre_compile(str, options, &err, &erro_ofs, NULL);

    while(true) {
        int options = PCRE_NEWLINE_LF;
        int len = strlen(self);
        int regex_result = pcre_exec(re, 0, self, len, offset, options, ovec_value, ovec_max*3);

        for(int i=0; i<ovec_max; i++) {
            start[i] = ovec_value[i*2];
        }
        for(int i=0; i<ovec_max; i++) {
            end[i] = ovec_value[i*2+1];
        }

        /// match and no group strings ///
        if(regex_result == 1 || (group_strings == null && regex_result > 0)) 
        {
            free(re);
            return true;
        }
        /// group strings ///
        else if(regex_result > 1) {
            group_strings.reset();
            for(int i = 1; i<regex_result; i++) {
                string match_string = string(self).substring(start[i], end[i]);
                group_strings.push_back(match_string);
            }

            free(re);
            return true;
        }
        else
        /// no match ///
        {
            free(re);
            return false;
        }
    }

    free(re);

    return false;
}

inline list!<string>*% string::scan(string& self, nregex reg)
{
    list!<string>*% result = new list!<string>.initialize();

    int offset = 0;

    int ovec_max = 16;
    int start[ovec_max];
    int end[ovec_max];
    int ovec_value[ovec_max * 3];

    const char* err;
    int erro_ofs;

    int options = reg.options;
    char* str = reg.str;

    pcre* re = pcre_compile(str, options, &err, &erro_ofs, NULL);

    while(true) {
        int options = PCRE_NEWLINE_LF;
        int len = strlen(self);
        int regex_result = pcre_exec(re, 0, self, len, offset, options, ovec_value, ovec_max*3);

        for(int i=0; i<ovec_max; i++) {
            start[i] = ovec_value[i*2];
        }
        for(int i=0; i<ovec_max; i++) {
            end[i] = ovec_value[i*2+1];
        }

        /// match and no group strings ///
        if(regex_result == 1)
        {
            string str = string(self).substring(start[0], end[0]);
            result.push_back(str);

            if(offset == end[0]) {
                offset++;
            }
            else {
                offset = end[0];
            }
        }
        /// group strings ///
        else if(regex_result > 1) {
            string str = string(self).substring(start[0], end[0]);
            result.push_back(str);

            if(offset == end[0]) {
                offset++;
            }
            else {
                offset = end[0];
            }

            for(int i= 1; i<regex_result; i++) {
                string match_string = string(self).substring(start[i], end[i]);
                result.push_back(match_string);
            }
        }
        else
        /// no match ///
        {
            break;
        }
    }

    free(re);

    return result;
}

inline list!<string>*% string::split(string& self, nregex reg)
{
    const char* err;
    int erro_ofs;

    int options = reg.options;
    char* str = reg.str;

    pcre* re = pcre_compile(str, options, &err, &erro_ofs, NULL);

    list!<string>*% result = new list!<string>.initialize();

    int offset = 0;

    int ovec_max = 16;
    int start[ovec_max];
    int end[ovec_max];
    int ovec_value[ovec_max * 3];

    while(true) {
        int options = PCRE_NEWLINE_LF;
        int len = strlen(self);

        int regex_result = pcre_exec(re, 0, self, len, offset, options, ovec_value, ovec_max*3);

        for(int i=0; i<ovec_max; i++) {
            start[i] = ovec_value[i*2];
        }
        for(int i=0; i<ovec_max; i++) {
            end[i] = ovec_value[i*2+1];
        }

        /// match and no group strings ///
        if(regex_result == 1)
        {
            string str = string(self).substring(offset, start[0]);
            result.push_back(str);

            if(offset == end[0]) {
                offset++;
            }
            else {
                offset = end[0];
            }
        }
        /// group strings ///
        else if(regex_result > 1) {
            string str = string(self).substring(offset, start[0]);
            result.push_back(str);

            if(offset == end[0]) {
                offset++;
            }
            else {
                offset = end[0];
            }

            for(int i=1; i<regex_result; i++) {
                string match_str = string(self).substring(start[i], end[i]);
                result.push_back(match_str);
            }
        }
        else
        /// no match ///
        {
            break;
        }
    }

    if(offset < self.length()) {
        string str = string(self).substring(offset, -1);
        result.push_back(str);
    }

    free(re);

    return result;
}

inline nregex string::to_regex(string& self) 
{
    return regex(self, false, false, false, false, false, false, false, false);
}

#endif


/*
    list<T>*% merge_list2(list<T>* left, list<T>* right, int (*compare)(T&,T&)) {
        var result = new list<T>.initialize();

        list_item<T>*? it = left.head;
        list_item<T>*? it2= right.head;

        while(true) {
            if(it && it2) {
                if(it.item == null) {
                    it = it.next;
                }
                else if(it2.item == null) {
                    it2 = it2.next;
                }
                else if(compare(it.item, it2.item) <= 0) 
                {
                    if(isheap(T)) {
                        result.push_back(clone it.item);
                    }
                    else {
                        result.push_back(dummy_heap it.item);
                    }

                    it = it.next;
                }
                else {
                    if(isheap(T)) {
                        result.push_back(clone it2.item);
                    }
                    else {
                        result.push_back(dummy_heap it2.item);
                    }


                    it2 = it2.next;
                }
            }

            if(it == null) {
                if(it2 != null) {
                    while(it2 != null) {
                        if(isheap(T)) {
                            result.push_back(clone it2.item);
                        }
                        else {
                            result.push_back(dummy_heap it2.item);
                        }

                        it2 = it2.next;
                    }
                }
                break;
            }
            else if(it2 == null) {
                if(it != null) {
                    while(it != null) {
                        if(isheap(T)) {
                            result.push_back(clone it.item);
                        }
                        else {
                            result.push_back(dummy_heap it.item);
                        }

                        it = it.next;
                    }
                }
                break;
            }
        }

        return result;
    }
    list<T>*% merge_sort2(list<T>* self, int (*compare)(T&,T&)) {
        if(self.head == null) {
            return clone self;
        }
        if(self.head.next == null) {
            return clone self;
        }

        var list1 = new list<T>.initialize();
        var list2 = new list<T>.initialize();

        list_item<T>* it = self.head;

        while(true) {
            if(isheap(T)) {
                list1.push_back(clone it.item);
            }
            else {
                list1.push_back(dummy_heap it.item);
            }

            if(isheap(T)) {
                list2.push_back(clone it.next.item);
            }
            else {
                list2.push_back(dummy_heap it.next.item);
            }

            if(it.next.next == null) {
                break;
            }

            it = it.next.next;

            if(it.next == null) {
                if(isheap(T)) {
                    list1.push_back(clone it.item);
                }
                else {
                    list1.push_back(dummy_heap it.item);
                }
                break;
            }
        }

        return list1.merge_sort2(compare).merge_list2( list2.merge_sort2(compare), compare);
    }
    list<T>*% sort_block(list<T>* self, int (*compare)(T&,T&)) {
        return self.merge_sort2(compare);
    }
}
*/
