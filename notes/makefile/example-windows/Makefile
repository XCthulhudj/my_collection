# 基于 Windows 环境，使用 mingw32-make，而不是 make

CXX = g++
PROM = bin/main.exe
INC = inc

CCFLAGS = -Wall -I $(INC)

DEPS = $(wildcard $(INC)/*.h)   # wildcard 把它展开成实际的头文件列表；直接写 DEPS = $(INC)/*.h 则不会展开
OBJ = build/main.o build/mmath.o

# Make 会先检查目标文件是否存在，再决定要不要执行
# 不加伪目标时，如果目录里恰好存在名为 all 的文件，Make 认为目标已生成，就不执行了
# .PHONY 告诉 Make：all / clean / run 是动作名称，不是要生成的文件

.PHONY: all clean run

# GNU Make 默认执行第一个普通目标，所以把 all 放最前面，直接 make 就等于 make all
all: $(PROM)

$(PROM): $(OBJ)                 # $^ = 冒号后面的全部依赖，即 $(OBJ)
	if not exist bin mkdir bin
	$(CXX) $^ -o $@

build/main.o: main.cpp $(DEPS)  # $< = 第一个依赖，即 main.cpp
	if not exist build mkdir build
	$(CXX) $(CCFLAGS) -c $< -o $@

build/mmath.o: src/mmath.cpp $(DEPS)
	if not exist build mkdir build
	$(CXX) $(CCFLAGS) -c $< -o $@

clean:
	if exist build rmdir /s /q build
	if exist bin rmdir /s /q bin

run: $(PROM)
	.\$(PROM)
