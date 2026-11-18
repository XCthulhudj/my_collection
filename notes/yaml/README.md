# YAML 笔记

[← 返回笔记索引](../README.md)

YAML 常见于配置文件：CI、Ansible、Docker Compose、Kubernetes、Linux 设备树 binding 等。这里重点记语法符号、缩进规则和多行字符串，其他格式细节按需再补。

## 1. 语法符号速查

| 符号 | 作用 | 示例 |
|---|---|---|
| `:` | 键值分隔符 | `name: LED` |
| `-` | 表示列表元素 | `- LED` |
| `[]` | 行内表示列表 | `[1, 2, 3]` |
| `{}` | 行内表示映射 | `{name: LED}` |
| `#` | 注释 | `# 注释内容` |
| `---` | 文档开始 | `---` |
| `...` | 文档结束 | `...` |
| `\|` | 多行字符串，保留换行 | `description: \|` |
| `>` | 多行字符串，折叠换行 | `description: >` |
| `&` / `*` | 锚点定义 / 引用 | `base: &base ...`、`<<: *base` |
| `?` | 复杂键（少用） | `? [a, b]` |

其中 `:` 和 `-` 才是 YAML 语法层面的东西——它们决定结构；`[]`、`{}`、引号只是书写风格。

## 2. 三种基本结构

| 结构 | 写法 | 说明 |
|---|---|---|
| 标量（scalar） | `name: LED` | 字符串、数字、布尔、null，单个值 |
| 映射（mapping） | 一行一个 `key: value` | 等价于 JSON 的 object |
| 列表（sequence） | 行首 `- ` | 等价于 JSON 的 array |

列表里可以放映射，映射里可以放列表，靠缩进表达层级。

## 3. 缩进与书写规则

- **只能用空格，不能用 Tab**，用 Tab 缩进会直接报错。
- 同一层级缩进必须一致，习惯用 **2 个空格**。
- 冒号后面 **必须有一个空格**：`name: LED` 对，`name:LED` 会被当成普通字符串。
- 短横线后也要有空格：`- LED`，写成 `-LED` 是字符串。
- 大小写敏感，`true` / `false` / `null` 这类写法会被解析成对应类型而不是字符串，见下面「隐式类型解析」。
- 注释以 `#` 开头到行尾；值内部的 `#` 需要加引号才安全。

### 隐式类型解析作用在哪

YAML 没有类型声明，解析器看到一段**标量文本**就会按规则猜类型：数字样式→数字、`true/false`→布尔、`null/~`/空→空值。所以问题不在"冒号后面的文字"，而在**所有未被引号包起来的标量**，包括：

| 位置 | 例子 | 解析结果 |
|---|---|---|
| 值 | `enabled: yes` | 布尔 `True`（YAML 1.1） |
| 值 | `enabled: "yes"` | 字符串 `"yes"` |
| 列表项 | `- on` | 布尔 `True` |
| 键名 | `true: 1` | 键是布尔 `True`，不是字符串 `"true"` |
| 键名 | `2024-01-01: a` | 键会被解析成日期对象 |

其中 `yes` / `no` / `on` / `off`、`True` / `TRUE`、`~` 这些写法属于 **YAML 1.1** 的规则；严格按 **YAML 1.2** 实现的解析器只认 `true/false`（含首字母大写和全大写），把 `yes/on` 当普通字符串。PyYAML 默认按 1.1 解析，所以同一份文件在不同工具里可能得到不同类型——想让它一定是字符串，就加引号。

实测（PyYAML 6.0.3）：

```text
enabled: yes      -> True   (bool)
disabled: off     -> False  (bool)
flag: True        -> True   (bool)
nothing1: ~       -> None
nothing2:         -> None
ver: 1.10         -> 1.1    (float)   ← 版本号被当成小数
a: "yes"          -> 'yes'  (str)
```

## 4. 多行字符串：`|` 和 `>` 的区别

这是最容易搞混的一对：

| 写法 | 效果 |
|---|---|
| `\|` | **保留**所有换行（literal），原样输出 |
| `>` | **折叠**换行，单个换行变成空格，空行才保留成换行 |

```yaml
literal: |
  第一行
  第二行

folded: >
  第一行
  第二行
```

读取结果：

```text
literal = "第一行\n第二行\n"
folded  = "第一行 第二行\n"
```

补充写法：

| 写法 | 含义 |
|---|---|
| `\|-` / `>-` | 去掉末尾的换行符 |
| `\|+` / `>+` | 保留末尾所有空行 |

## 5. 文档分隔

```yaml
---
name: first
---
name: second
...
```

`---` 开始一个新文档，`...` 结束当前文档。单文档文件里 `---` 也可以省略，但很多工具（Ansible、K8s）习惯常驻一个 `---` 开头。

## 6. 示例：设备树 binding 的写法

```yaml
name: breath_led

properties:
  compatible:
    - xlnx,breath-led-1.0

  reg:
    - 0x43C00000
```

逐行看：

- `name: breath_led` —— 顶层键值对，值是字符串。
- `properties:` —— 值是映射，下面两个键都在这个映射里，所以要多缩进 2 格。
- `compatible:` 后面跟的是**列表**，列表项用 `- ` 开头，`xlnx,breath-led-1.0` 里的逗号是厂商前缀约定（vendor,device），所以不要加空格。
- `reg:` 同理，是寄存器地址列表；YAML 里 `0x43C00000` 会按 16 进制整数解析。
- 空行不影响语义，只影响可读性。

这类文件常见于 Linux 内核 `Documentation/devicetree/bindings/` 下的 YAML schema，用来校验 `.dts` 里的设备节点。

## 7. 锚点与引用

```yaml
defaults: &defaults
  retries: 3
  timeout: 10

service_a:
  <<: *defaults
  timeout: 30
```

`&defaults` 定义锚点，`*defaults` 引用它，`<<:` 把内容合并进来，后面的同名键会覆盖。

## 8. 常见坑

| 现象 | 原因 |
|---|---|
| `mapping values are not allowed here` | 冒号后少了空格，或缩进错位 |
| `found character '\t' that cannot start any token` | 用了 Tab 缩进 |
| 版本号被改：`1.10` → `1.1` | 被解析成浮点数，需要写成字符串 `"1.10"` |
| `yes` / `no` 变成 `true` / `false` | YAML 1.1 的布尔写法，建议显式加引号 |
| 日期变成日期对象 | `date: 2024-01-01` 会被解析成 `date`，要字符串就加引号 |
| 值里带 `:` 报错 | 如 `time: 12:30`，要写成 `"12:30"` |
| 中文出现乱码 | 文件编码用 UTF-8；YAML 规范要求 UTF-8 或 UTF-16 |
| 空值不知道怎么写 | `key:`、`key: null`、`key: ~` 都是空值 |

## 9. 与 JSON 的关系

- YAML 是 JSON 的超集（YAML 1.2 起），合法 JSON 基本都能被 YAML 解析。
- 常见转换：`python -c "import yaml,json,sys; print(json.dumps(yaml.safe_load(open('a.yaml')), ensure_ascii=False, indent=2))"`。
- 校验：`yamllint a.yaml`，或 VS Code 装 YAML 扩展（Red Hat 那个），能实时报缩进和 schema 错误。

## 10. 检查清单

写完一个 YAML 文件，快速过一遍：

1. 有没有 Tab？
2. 冒号、短横线后面有没有空格？
3. 多行字符串用 `|` 还是 `>`，末尾换行要不要留？
4. 数字、版本号、布尔值是不是需要加引号？
5. 列表里每个元素是否都用 `- ` 对齐？
