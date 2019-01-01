#include "StdAfx.h"

//#include "lib1.h"
//#include "lib2.h"

int main()
{
	std::cout << INT_GLOB << " " << INT_SYS << std::endl;
	std::cout << lib1::fun1( 1, 2 ) << " " << lib2::fun2( 3, 4 ) << std::endl;
	//i + 3;
	return 0;
}