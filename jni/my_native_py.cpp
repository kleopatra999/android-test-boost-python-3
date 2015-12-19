// Distributed under the Boost Software License, Version 1.0. (See
// accompanying file LICENSE_1_0.txt or copy at
// http://www.boost.org/LICENSE_1_0.txt)

#include <boost/python.hpp>
#include <boost/python/module.hpp>
#include <boost/python/def.hpp>
#include <boost/python/object.hpp>
#include <boost/python/class.hpp>

#include <iostream>

using namespace boost::python;

struct Greeter
{
    Greeter() {}
};

void greet(Greeter& greeter)
{
    std::cout << "Hello from my_native_py.cpp!" << std::endl;
}


BOOST_PYTHON_MODULE(libmy_native_py)
{
    class_<Greeter>("Greeter", init<>());
    def("greet", greet);
}
