#pragma once

#include <string>
#include <vector>
#include <iostream>

#include <inc_global.h>
#include <inc_sys.h>

#include <lib1.h>
#include <lib2.h>

#ifdef LIB1_CD
inline bool is_lib1() { return true; };
#endif

#ifdef PROJ_CD
inline bool is_proj() { return true; };
#endif

#ifdef GLOB_CD
inline bool is_glob_cd() { return true; };
#endif

#ifdef GLOB_CD_ADD
inline bool is_glob_cd_add() { return true; }
#endif