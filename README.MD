# Jiebago-wasm-bind

## 关于本项目

本项目依赖 [结巴分词的Go语言实现](https://github.com/wangbin/jiebago)

源项目是 [结巴分词](https://github.com/fxsjy/jieba)

本项用于将 jiebago 编译为 wasm，并提供简易的 jsapi 绑定，从而方便在浏览器扩展中运行。

本项目中的 ` dict.txt ` 文件来源于上述 Go 语言实现的项目中。

本项目是在做[闪烁阅读](https://github.com/FlickerReader/FlickerReaderZh-firefox-addon)过程中，针对分词需求而做的。不知道有没有人也有类似于离线分词的需求，所以就单独拆出来了。本来那个项目中，该模块作为浏览器扩展，在浏览器初始化的时候加载，所以花费十几秒加载词典显得没有那么怪异。但是如果是 web 场景的话，恐怕要斟酌一下。

## 构建环境

* Go 语言构建环境, 我是用的是 Go1.14，理论上只要是 1.13 之后，支持了编译为 wasm 的版本都行。

* make 命令。大概不是必须的，理论上构建过程和操作系统无关，我只在 ubuntu 环境下执行过。

## 构建命令

* ` make package `

## 使用方法

- 假设上述 ` make package ` 之后，static 目录下的三个文件都可以加载到。（总之下面这个 html 页面能加载到才行），类似于这种结构

```
html\
        index.html
        wasm_exec.js
        main.wasm
        dict.txt
```

```html

    <html>
        <head>
            <meta charset="utf8" />
        </head>
        <!-- 加载 Golang 提供的入口文件 -->
        <script src="wasm_exec.js"></script>
        <script>
            const go = new Go();
            WebAssembly.instantiateStreaming(fetch("main.wasm"), go.importObject)
                .then((result) => go.run(result.instance));
            // 网络请求加载字典文件
            fetch('dict.txt').then((response) => {
                response.text().then((text) => {
                    dict = text;
                })
            });
            /**
             * 确认字典文件加载完成
             * 理论上下面的代码写在回调中是最科学的，应该是这样 
             * WebAssembly 的回调中加载 dict.txt 文件
             * 加载完成字典后，调用下述方法初始化字典，然后开始分词
             **/
            setTimeout(() => {
                // 向分词库中添加字典
                console.log('start_dict')
                jiebaLoadDictionary(dict)   // 莫慌，这步要在 firefox 下要跑 10 几秒，在 chrome 下要跑 5-6 秒
                console.log('end_dict')
                // 开始分词
                console.log(jiebaCut('我住在武汉市长江大桥'));
                console.log(jiebaCut('我住在南京市长江大桥'));
            }, 1000);
            
        </script>
    </html>

```

## 接口说明

**初始化字典**

        jiebaLoadDictionary(string)

初始化分词模块的字典。不加载字典的话，没办法分词的。

**分词**

    jiebaCut(string): string

返回值为 json 字符串。我搞不定把 Go 中的字符串切片直接返回给js，所以干脆转化成字符串返回来了。

## 额外说明

* 有的服务器软件，默认可能不认识 wasm 后缀的文件。导致在 http 请求中返回的 mime 类型不对，导致不能正确加载。nginx 的话需要更新一个叫 mime.type 的配置项，其它服务器软件可能会有类似的情况。

## 待完成的工作

* 不知道 jiebago 的开发者还在不在维护那个项目。已经有一段时间没更新了。可能需要自己实现一个（有可能不需要）

* 完善分词接口啊！命名人家结巴分词提供那么多接口的，只暴露出来两个接口可不太行。

* 不知道有没有办法优化加载词典的速度。在 wasm 中不要考虑 Golang 的多线程。但是有么有其它办法呢？
