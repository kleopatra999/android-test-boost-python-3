#include <iostream>
//#include <codecvt>
#include <Python.h>

using namespace std;

int main(int argc, char **argv) {
  //wstring_convert <codecvt_utf8_utf16 <wchar_t>, wchar_t>
  //  utf8_utf16;
  
  wchar_t *wargv[] = { L"/data/local/tmp/test", nullptr };

  //auto program_name = utf8_utf16.from_bytes(argv[0]);
  Py_SetProgramName(wargv[0]);//(program_name.c_str());
	Py_Initialize();
  PySys_SetArgv(1, wargv);
  //PyEval_InitThreads();

  auto main_py = "main.py";
  auto fd_main = fopen(main_py, "r");
  auto error_code = PyRun_SimpleFile(fd_main, main_py);
  if (PyErr_Occurred() != nullptr) {
    PyErr_Print();
    PyErr_Clear();
  }
  Py_Finalize();
  fclose(fd_main);

	return error_code;
}
