## 如何将课程代码提交至平台？

正常情况下，存放策略的 Strategy 目录应至少含有如下文件：

```plain
Strategy
├── Judge.cpp
├── Judge.h
├── Point.h
├── Strategy.cpp
└── Strategy.h
```

如果想要将文件提交到网站上，需要先点击「下载游戏包」按钮下载游戏 SDK，SDK 内的内容如下：

```plain
.
├── Makefile
└── sdk
    ├── ai_client.hpp
    ├── json
    └── main.cpp
```

选手需要将自己的策略与SDK 放在同一个文件夹下，如下是一个合理的目录结构：

```plain
.
├── Judge.cpp
├── Judge.h
├── Makefile
├── Point.h
├── Strategy.cpp
├── Strategy.h
└── sdk
```

`Makefile` 文件中已经写好了编译时 SDK 中必须要用到的文件，选手需要自行添加编译所需要的其他依赖文件和编译选项。之后将该目录打包成 `zip` 压缩包，提交至网站上。提交的时候选择提交语言类型为 `C++ with Makefile [.zip]`，评测机会运行 `make` 命令进行编译得到可执行文件 `main`。若编译错误，则网站会显示编译错误信息；如果编译通过，则该 AI 可以进行对战。

**SDK 内的代码不能更改，否则后果自负！**

### Windows 代码注意事项

Windows 代码需要额外注意两点：

首先，在 `Strategy.h` 和 `Strategy.cpp` 中，`getPoint` 和 `clearPoint` 定义如下：

```cpp
extern "C" __declspec(dllexport) Point* getPoint(const int M, const int N, const int* top, const int* _board, const int lastX, const int lastY, const int noX, const int noY);

extern "C" __declspec(dllexport) void clearPoint(Point* p);
```

在提交的时候需要去除 dll 相关内容，具体为将其改成

```cpp
extern "C" Point* getPoint(const int M, const int N, const int* top, const int* _board, const int lastX, const int lastY, const int noX, const int noY);

extern "C" void clearPoint(Point* p);
```

其次，由于服务器运行在 Linux 系统下，提交的代码请不要使用非 C++ 标准库，尤其是 `conio.h`、`atlstr.h` 等，否则会造成编译错误。

## 在线对战

除了排行榜和 AI 列表中的「快速人机对局」功能外。使用 Saiblo 平台的[房间系统](https://www.saiblo.net/rooms)也可以进行人机/机机/人人对战。

进入房间列表后，选择服务器 `ailab`，点击创建房间即可创建一个房间。在任意空座位上，你可以

- 添加 AI：点击「添加 AI」，选择自己的 AI 或者使用 AI Token 加入 AI（Token 可以在我的 AI 中找到并复制，也可以在排行榜上复制其他选手的 AI Token）。
- 在线游玩：点击「加入游戏」并点击准备，即可以人类身份开始游戏。

当所有位置上的 AI 准备好后，房主点击「开始游戏」按钮即可开始游戏，游戏结束后，会自动跳转到对局详情页面。

## 批量测试

我们提供了批量测试功能以便系统性的评估 AI 水平。具体地，在我的 AI 列表中编译成功的 AI 右边点击批量测试按钮，即可配置批量测试。点击提交后会跳转到批量测试详情页面，在这里可以查看本次批量测试的详细对局情况，包括胜、负、平和胜率。

由于批量测试规模较大，且一局四子棋评测往往耗时 3-5 分钟，极为消耗测评机资源，在批量测试时可能出现排队的情况，请耐心等待。此外，为了防止测评机负荷过大，限制每人每天可与不超过 100 个 AI 进行批量测试，每日凌晨某个时间刷新测试额度。

## 大作业最终评测

**派遣到课程小组“四子棋作业”比赛内的代码即为作业提交代码**，作用相当于“标记为最终版本”，DDL前可随时更改，DDL后无法再从网站更改。
AI 在运行时，限制每回合 3s 运行时间（以 CPU 时间为准）。此外，**与往年不同的是**，平台上限制峰值内存 1GB，由于**最终评测也在平台上进行**，请保证自己的程序运行时不会消耗过多内存从而出现 MLE（Memory Limit Exceeded）错误。

为了便于同学监控 AI 的每回合的运行情况，在对局详情页面，我们提供了回合级别的的 AI 运行时间与内存统计。

此外，根据往年经验，由于 Linux 下内存访问较为严格，其余平台下对指针操作存在 BUG 的代码（常见于指针删除逻辑）在 Linux 下运行时容易出现运行时错误。为了避免最终评测中出现意外情况，请在平台上**充分测试**(例如用批量测试功能与50个样例AI对战)。

**注意：**在回合内存统计的时候，我们使用 cgroup 的 `memory.max_usage_in_bytes` 参数统计程序使用内存。

> Another similar unexpected situation with --cg-mem is, for example, when you declare a big array but you use only a part of it - this is not going to trigger memory limits even with swap disabled because the full array is never mapped fully in physical memory, just the pages you are actually using.

简单来说，如果在程序中申请了一个应该一开始就 MLE 的大数组，在我们的统计中并不会立即显示出 MLE，而是实际使用多大就统计出多大。然而随着回合数增多，可能出现 MLE 的情况，在编写程序时请格外注意。

感谢 @肖光烜 同学的反馈。

## 调试

与 `cout` 类似，你可以使用 `cerr` 将调试信息输出到 `stderr` 从而在网站的对局详情页面中查看程序运行时输出的调试信息。注意输出的信息不要超过 Linux 管道的缓冲区大小 64KB，否则可能会出现阻塞而导致运行超时。

## 游戏天梯

我们自 2021 年春季学期开始取消了（曾经有的）作业天梯功能以防止排名（可能）引起的焦虑。

但游戏本身仍带有“全局排行榜”，这是对外开放的与作业无关的天梯，上面有一些（选课或非选课）同学自愿提交的自己的代码以及 50 个公开测例，它会按照一定的算法进行匹配并用 ELO 进行分数更新，直到达到内置算法认定的“收敛”。它的加入方法是在“我的代码”中点击“派遣”，如果你愿意可以加入其中和一些历来的高手对决并秀出自己的 AI，但请务必注意它不是作业提交点。

## 关于

Saiblo 是一个非常年轻的平台，主要开发人员也只是没有太多开发经验的大二大三学生，必然存在很多不完善的地方。如果您有任何建议，或者对平台有任何疑问，可以联系平台维护相关成员：曾奥涵（计86）、何广荣（计83）、饶淙元（计83）。

