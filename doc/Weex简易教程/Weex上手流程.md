##Weex上手流程

###介绍
- Weex 是一套简单易用的跨平台开发方案，能以web的开发体验构建高性能、可扩展的 native 应用, 使用 Vue 作为上层框架;
- Vue.js 是一种渐进式 JavaScript 框架。开发者能够通过撰写 *.vue 文件，基于template, style, script 快速构建组件化的 web 应用;

###环境配置
- 1、首先终端安装 Node.js(npm: JS包管理工具也随之安装),可以使用 Homebrew 进行安装, 然后使用 npm命令来安装 weex-toolkit（官方提供的一个脚手架命令行工具，你可以使用它进行 Weex 项目的创建，调试以及打包等功能）;

- 2、初始化工程, 命令: weex init project_name，之后进入项目所在路径，先通过 npm install 安装项目依赖，之后命令运行 "npm run dev" 和 "npm run serve" 开启watch模式和静态服务器;

- 3、已有工程的话，通过导入 Weex SDK framework 到工程即可；

###初始化 Weex 环境
- 1、通过源码编译出 Weex SDK，注意Vaild Architectures配置: armv7,armv7s,arm64等，导入weexSDK.framework；
- 2、在AppDelegate.m 文件中做初始化操作，一般会在 didFinishLaunchingWithOptions 方法中如下添加。


		///////////////////////////////////////////////////
		//Config
		[WXAppConfiguration setAppGroup:@"AliApp"];
		[WXAppConfiguration setAppName:@"WeexDemo"];
		[WXAppConfiguration setAppVersion:@"1.0.0"];
		
		//init sdk enviroment   
		[WXSDKEngine initSDKEnviroment];
		
		//register custom module and component, optional
		[WXSDKEngine registerComponent:@"MyView" withClass:[MyViewComponent class]];
		[WXSDKEngine registerModule:@"event" withClass:[WXEventModule class]];
		
		//register the implementation of protocol, optional
		[WXSDKEngine registerHandler:[WXNavigationDefaultImpl new] withProtocol:@protocol(WXNavigationProtocol)];
		
		//set the log level  
		[WXLog setLogLevel: WXLogLevelAll];
	
- 3、渲染 Weex Instance
	
	Weex 支持整体页面渲染和部分渲染两种模式，用指定的 URL 渲染 Weex 的 view，然后添加到它的父容器上，父容器一般都是 viewController。

		///////////////////////////////////////////////////
		#import <WeexSDK/WXSDKInstance.h>


		 - (void)viewDidLoad 
		 {
				 [super viewDidLoad];
		 		_instance = [[WXSDKInstance alloc] init];
		 		_instance.viewController = self;
		 	 	_instance.frame = self.view.frame; 
		  		__weak typeof(self) weakSelf = self;
		 		_instance.onCreate = ^(UIView *view) {
		  			[weakSelf.weexView removeFromSuperview];
		 			[weakSelf.view addSubview:weakSelf.weexView];
		 		};
		
		 		_instance.onFailed = ^(NSError *error) {
		 			//process failure
				};
		
		  	_instance.renderFinish = ^ (UIView *view) {
		 			//process renderFinish
		 		};
		
		 		 [_instance renderWithURL:self.url options:@{@"bundleUrl":[self.url absoluteString]} data:nil];
		 }

###Weex 页面结构
- 1、组件

	Weex 支持文字、图片、视频等内容型组件，也支持 div、list、scroller 等容器型组件，还包括 slider、input、			textarea、switch 等多种特殊的组件。Weex 的界面就是由这些组件以 DOM 树的方式构建出来的
- 2、布局系统

- 3、功能

- 4、内建模块（animation、WebSocket、picker、clipboard、dom、modal、navigator、storage、stream、webview、globalEvent

- 4、工具：webStorm，SublimeText

###调试
- 1、实时预览：weex-toolkit 支持预览当前开发的weex页面(.we或者.vue)，只需要指定预览的文件路径，浏览器会自动弹出页面：

		weex src/foo.vue
		
- 2、安装 Playground app，然后扫描浏览器右边的二维码，也可以看到在设备上的效果；

- 3、打包weex项目：
 		
 		weex compile src/foo.vue dist_path
 		
- 4、Weex插件添加：

		weex plugin add plugin_name

###参考
- 1、Weex-Toolkit： https://github.com/weexteam/weex-toolkit
- 2、Vue语法：https://cn.vuejs.org
- 3、实时coding看效果:  http://dotwe.org/vue
- 4、Weex集成开发：https://weex.apache.org/cn/guide/set-up-env.html
- 5、基于Weex和Vue开发了一个的完整Demo项目：https://github.com/weexteam/weex-hackernews
- 6、Weex手册：https://weex.apache.org/cn/references/index.html
- 7、目前SVN Weex：https://your_name@192.168.0.102/svn/weex







