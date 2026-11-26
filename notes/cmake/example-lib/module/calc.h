#ifndef CALC_H
#define CALC_H

/* 给 C++ 调用时保持 C 的名字修饰，避免链接时找不到符号 */
#ifdef __cplusplus
extern "C" {
#endif

int calc_add(int a, int b);

#ifdef __cplusplus
}
#endif

#endif
