add_library( l1 STATIC main.cpp )
target_include_directories( l1 PUBLIC ./include )
target_compile_definitions( l1 PUBLIC LIB1_CD )
target_compile_options( l1 PUBLIC -DLIB1_CO )