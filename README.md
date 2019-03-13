# Architect

# 前言
从事 ios 开发 8 年多了，结合自己的经验记录我个人认为灵活的 ios 架构。由于我个人水平有限所写之处，必然有所疏漏，望斧正。 非常希望，大家提出自己的建议，或场景需求。我也将持续更新
这里，我将架构分成两块：1. 工程结构（ 目录结构） 2.架构。 因为，我们在开发之初就要确定目录结构，我发现这也非常重要。 我的讲解方式是 抛出问题，给出解决方案，最后给出代码，并分析我认为的这样写的原因。   
[工程代码GitHub](https://github.com/daviad/Architect.git)       
我用了子模块请使用 `git clone --recursive https://github.com/daviad/Architect.git` 下载     
我使用了Pod 请`pod install`


# 问题
1. 工程结构（ 目录结构）
对一个工程我们除了有源文件，还有其他辅助文件帮助我们管理文件。
源文件的获取，权限，管理， 工程的配置。

2. 模块增删
随这项目的发展，模块越来越多，有些文件变得越来越大，比如：AppDelegate。有些模块删除了，但是与之相关的代码却无法删除干净
每个模块都有个说明文档：module.md。 各个模块间的通讯，有条理，便于管理

3. mvvm的架构
5. test
4. 持续集成

# 解决思路和方案
## 工程结构
这里我用 workspace 结合cocopods、xcconfig配置文件、git git子模块、 脚本解决工程目录问题  

工程目录![Architect目录下的内容.jpg](https://upload-images.jianshu.io/upload_images/14843960-097292ba4d9f8527.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

* archived：打包后的文件
* doc：帮助说明文件
* configuration：工程配置文件
* script：脚本
* thirdParty：没有被Pod管理的第三方库。一般是 xxx.a\xxx.framework
* tools：一些工具比如：

###  代码放置位置
 | 源码 | 方式 | 优点 | 
 | :-------: | :-------: | :-------: | 
|  第三方库 | Podfile | 简单方便 |
| 第三方库不满足需求 | 私有pod | 便于控制 |
| 自己封装的库 | 私有pod | 便于管理 |
| 自己代码模块| git 子模块 | 便于控制，根据情况引入子模块 ，效率高|

详细说明：
1. 对于 比较稳定的 第三方库，我们可以直接用podfile 引入，
2. 第三方库有bug或不能满足我们自己项目的某些需求，二我们又必须修改第三方源码，就在本地（本地服务器）对第三方库修改，用pod引入我们自己的库。
3. 对于我们自己的代码，如果是比较稳定的我们可以做Pod私有库。  
4. 对于我们自己的某些模块化的，但并不足于做成库的（并且库太多影响程序启动的效率），我们可以用 git 子模块 引入。一般我们的 业务模块可以用这种方式。比如我们有a、b、c 三个模块，开发小组要开发一个新模块（业务功能），这个功能和b、c都无关、在发开发时，就可以只引入a模块。这样编译的效率就更高。
关于pod的私有库使用，可以参考[]()

这里多说两句，Podfile 可以指定Workspace，和Target 的目录。
git 要知道使用ignore文件。因为我发现好几个工作好多年的人不知道ignore是何物。

### 配置文件使用
直接使用xcode配置工程虽然简单，但是不够灵活，有时比较麻烦，比如，你想从新创建一个类似功能的工程，需要把相同的 库再加一遍谁做谁痛苦，用xccofing文件就能很好解决这个问题。所以我用xcconfig结合xcode一起配置工程。

## 具体的代码工程实现
##### xcode中使用配置文件
1. 新建后缀xcconfig文件（参考Pod的配置文件）这里我的是 Architect.debug.xcconfig 应该区分debug 和 release 的这里我简单点就用了同一个文件。
2.  根据需要填写配置文件
```
#include "./Pods/Target Support Files/Pods-Architect/Pods-Architect.debug.xcconfig"

```
3. 看图操作
![配置文件使用.jpg](https://upload-images.jianshu.io/upload_images/14843960-d158895781acfce7.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
##### 新建模块的脚本
创建Test模块。  cd 到 scripts 目录下 运行
```
python gen_module.py Test
```
##### git子模块的操作
详细操作网上有很多例子，这里列出我使用的命令
```
 git submodule add https://github.com/daviad/Chat.git src/Architect/GitSubmodule/Chat
```

## 模块管理
模块管理主要包括：加载、设置、模块间通信。 模块的删除在工程结构部分已经解决，基础固定模块一般做Pod库。

## 加载、设置
模块通过 ModuleProtocl  ModuleManager 进行管理。主要代码
```
protocol ModuleProtocl {
    // 为了避免模块顺序引起的bug。才有了load 和setup
    //加载模块，实质就是创建对象
    func load()
    //设置模块，此时所有的模块都已经load完成
    func setup()
    //数据库的相关操作。  需要数据库的模块才需要这个这个属性，按理说应该再建一个协议（DBModuleProtocl），但是那样写的话使用好麻烦，目前我没有找到一个更好的方式。就是说如何完成数组中的元素可以分别实现不同的协议。（Any ,继承协议，都需要强转，感觉泛型好像可以，学艺不精，没写出来）
    var dbModels: [DBModel]? { get }
}

extension ModuleProtocl {
    func setup() {}
    func load() {}
    var dbModels: [DBModel]? { return nil }
}

final class ModuleManager {
    static let shared = ModuleManager()
    private  init() {}
    
    //    TODO: 此处可以通过反射 写在配置文件生成  或不用反射 结合脚本生成代码  提高效率
    //    let modules: [ModuleProtocl] = [MainPageModule(),UserModule()]
    //    是否将 module 分类 比如 必须先加载的？
    private(set) var modules: [ModuleProtocl] = [ModuleProtocl]() 
    
    func loadModules() {
        let mainPage = MainPageModule()
        mainPage.load()
        modules.append(mainPage)
        
        let userModule = UserModule()
        userModule.load()
        modules.append(userModule)
        
        let dataBaseModule = DataBaseModule()
        dataBaseModule.load()
        modules.append(dataBaseModule)
        
        _ = modules.map{ $0.setup() }
    }
}
```
代码不多解释一看就能懂，主要说说这么做的好处和我的想法：
1. 定义协议，代码结构清晰。
2. 协议的 extension 可以实现默认实现
3. 可以统一管理module，以后不管module怎么变，我的框架这部分都不需要改代码。并且删除模块代码非常干净。
4. load() setup()主要是时机不同，处理了模块加载顺序依赖问题。
有的模块需要响应 appdelegate 的事件，为了模块分离，所以定义了这个协议方法，
关于模块的注册，可以用一个plist 文件，可可以直接写，可以用脚本生成代码
代码分离性更高  代码易懂效率高 要写脚本使用不连贯 但在这里我认为影响都不大因为模块不会很多。

###### 目前不够完美的地方：
  var dbModels: [DBModel]? { get }
> dbModels 是 数据库的相关操作。  需要数据库的模块才需要这个这个属性，按理说应该再建一个协议（DBModuleProtocl），但是那样写的话使用好麻烦，目前我没有找到一个更好的方式。就是说如何完成数组中的元素可以分别实现不同的协议。（Any ,继承协议，都需要强转，感觉泛型好像可以，学艺不精，没写出来）
  
# 模块内部结构以及实现
我这里使用MVVM的模式开发。目录结构如下： 见我前面的脚本


# 各个模块实现
## 数据库模块
如果项目需要数据库，这将是一个很基础的模块，要考虑是用 具体参考
## 网络模块
## User模块
user 模块

# fmdb swift版本的封装
# 前言
移动开发经常需要使用 sqlite， FMDB是首选。 一般我们都会对FMDB再进行一个封装使其更适合自己工程的使用。这是我[用代码一步一步实现自己的 ios 架构]()一部分。fmdb 没有swift 版本。但是任然可用。我使用的是 FMDB v2.7.5 具体如何引入工程参考 [GitHub](https://github.com/ccgus/fmdb)。

# 问题
既然要封装FMDB 我就要看看我们要解决哪些问题
* 业务逻辑需求 （选择多数据库）
* 数据效率 （多线程）
* 数据安全  （FMDatabaseQueue）
* 数据一致性 （transaction）
* 调用方便
* 数据库升级

## 选择多数据库模式
对于拥有游客和用户类型的App，数据有两种选择：
|||
|:-:|:-:|
|单个库，多张表| 每张表都有一个UserId字段区分，表比较大，sql 相对麻烦 ，使用简单|
|多库多表|  通过库区分不同用户，表小，效率更高，使用相对复杂 |
以前看过微信的数据库好像是多库的。
我这里选择 多库模式
```
ATTACH DATABASE 'dbPath' as 'dbName'
DETACH DATABASE 'dbName'
```
* 主要用这两个语句创建/分离数据库。注意`dbPath`上的引号不要遗漏。
* 默认是游客数据库id为0，user 登录成功就 attach 到user 数据库
* 因为切换用户要 diattach ，一次程序启动只有 游客和某一个具体的数据库可用。
* 登录用户可以看游客的内容，但游客只能能查看部分登录用户页面。所以不同角色拥有的数据库的表并不相同。
* 我这里并没有联库查询，那样太复杂。相同的角色拥有相同的表。
简单的分析我们可以看出，需要分角色，不同角色看的页面不同，表不同。对应的枚举是
```
enum ResAccessRole: String {
    case Public = "pub"
    case User = "user"
    case All = "all"
}
```   
这里简单点就是登录用户，游客（public），为了代码方便实现有一个All。

## 效率和安全性
关于安全性 FMDB 已经考虑了 ，但是效率问题，需要我们自己管理
FMDatabaseQueue 的内部使用的是 `串行队列` `同步任务` 保证了是线程的安全性，
```
 _queue = dispatch_queue_create([[NSString stringWithFormat:@"fmdb.%@", self] UTF8String], NULL);

    dispatch_sync(_queue, ^() {
//相关代码
}
```
* 数据库的增删改查我这里都使用回调的方式，大部分时候顺序并不重要。
* 数据库的操作不要阻塞主线程，也不能能因为某个操作耗时，阻塞了其他任务。
* 有些操作必须先完成比如创建数据库，数据库升级。
*  综上：只要我们使用 FMDatabaseQueue 就一定是安全的但是这个方法会阻塞当前线程。我们要封装一下。我用一个并行队列+异步任务 + banner 达成我的目的。 这个方法的高效可以看看  [Objective-C、Swift、java、Dart（Flutter）、NodeJs、Js、Python... 我该如何选择？焦虑！](https://www.jianshu.com/p/4ee0c2ea57be)的NOdeJS部分。gcd的使用参考[iOS 多线程：『GCD』详尽总结 『不羁阁』『行走少年郎』](https://www.jianshu.com/p/2d57c72016c6) 
#### 代码实现


TODO：关于数据库操作的顺序可以分得更细。哪些可以并行，哪些必须安顺序进行。但这个工程比较大。我目前的方案效率对我来说够了。

## 数据一致性 transaction 
参考[我对SQLite的强行研究](https://www.jianshu.com/p/06a5324d90be)
这里我主要用这个方法
`- (void)inTransaction:(__attribute__((noescape)) void (^)(FMDatabase *db, BOOL *rollback))block;` 
#### 代码实现

## 数据库升级

## 调用方便
关于 sql 语句的书写我封装了方法 参考[sql 语句Swift封装，链式调用](https://www.jianshu.com/p/3c0c22b36768)
