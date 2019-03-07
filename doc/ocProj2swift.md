### 2018-8-8修改

https://blog.csdn.net/zhao18933/article/details/46640657
Swift项目的main函数为何消失了？如何把它找出来？


## 方案一：直接在原工程上 添加 swift 发生了这个错误,无法解决    
https://stackoverflow.com/questions/50600236/introducing-swift-in-oc-project-causes-compilation-error

search lib path  这只是填写了依赖，一定要把lib添加进来
other link 
other flag

## 方案二：新建LoochaCampusSwift工程文件夹，将原工程迁移过来   

1. 在script文件夹下新建serverObjects.rb和ProtoHelper.rb
主要功能：具体的查看源码     
	* git clone proto
	* 编译出对应的oc文件
	* 配置工程
	* 生成自动化脚本
	* 首次使用：cd 到 scripts 目录下 运行：`runby ./serverObjects.rb`  以后都是自动完成。

2. 修改原有配置文件
	* LoochaCampusMain.xcconfig 添加 Primary_System_Framework  Primary_System_LIB

3. 计划一步一步修改为swift版本
	* Network







