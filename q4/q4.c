#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<dlfcn.h>   // The POSIX Dynamic Linking Header

// Defining the type of mathematical functions we are using (input is 2 integers and return value is also an int)
typedef int (*math_op_function)(int, int);

int main() {
    char input[256];
    char op[7];
    char lib_path[256];
    int a,b;

    // Loop to rad input continuously from stdin
    while (fgets(input, sizeof(input), stdin)!=NULL) {

        // Parsing the input string into 3 parts - operation name, and the two numbers
        // %5s  ensures we don't experience overflow of 'op' as hte max length is 5
        if (sscanf(input, "%5s %d %d", op, &a, &b)!=3) {
            fputs("Invalid Input Format!\n", stderr);
            continue; // Considering invalid input format as garbage and ignoring it
        }

        // Building the library file name in the current directory
        strcpy(lib_path, "./lib");
        strcat(lib_path, op);
        strcat(lib_path, ".so");

        // Loading the file name (shared library) into the memory
        void *lib_handle = dlopen(lib_path, RTLD_LAZY);
        if (!lib_handle) {
            fputs (dlerror(), stderr);
            fputs("\n", stderr);
            continue;
        }

        // CLearing any existing/previous dynamic linker errors
        dlerror();

        // Looking up the specific function inside the loaded library
        math_op_function operation = (math_op_function)dlsym(lib_handle, op);

        // If error is present, cleaning the memory and then continuing
        const char *error_msg = dlerror();
        if (error_msg!=NULL) {
            fputs (error_msg, stderr);
            fputs("\n", stderr);
            dlclose(lib_handle);
            continue;
        }

        // Executing the function and printing the result
        int result = operation(a, b);
        printf("%d\n",result);

        // Unloading the library from the memory after finishing in order to meet the Memory Constraints
        dlclose(lib_handle);
    }
    return 0;
}