#include <cstdio>
#include <cstdlib>
#include <iostream>
//#include <codecvt>
#include <Python.h>

using namespace std;

int main(int argc, char **argv) {
  //wstring_convert <codecvt_utf8_utf16 <wchar_t>, wchar_t>
  //  utf8_utf16;
  
  wchar_t *wargv[] = { L"/data/local/tmp/lib/armeabi/test", nullptr };
  
  cout << "Hello from test.cpp!" << endl;

  //auto program_name = utf8_utf16.from_bytes(argv[0]);
  Py_SetProgramName(wargv[0]);//(program_name.c_str());
	Py_Initialize();
  PySys_SetArgv(1, wargv);
  PyEval_InitThreads();

  const char *main_py = getenv("MAIN_PY");
  main_py = main_py ? main_py : "../../assets/main.py";
  auto fd_main  = fopen(main_py, "r");
  if (!fd_main) {
    char cause[80];
    sprintf(cause, "fopen(\"%s\", \"r\")", main_py);
    perror(cause);
    return -1;
  }
  auto error_code = PyRun_SimpleFile(fd_main, main_py);
  if (PyErr_Occurred() != nullptr) {
    PyErr_Print();
    PyErr_Clear();
  }
  Py_Finalize();
  fclose(fd_main);

  return error_code;
}
