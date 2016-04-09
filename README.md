# WebViewJavascriptBridgeDemo
这是个基于webView的图文混排demo，使用了WebViewJavascriptBridge第三方框架
该demo除了能够实现图文混排，还实现了webView和原生的交互。（总之实现了java和oc的深度交互）

##工程原理解释
###网页下载 
 

1. 网页在加载的时候调用onload方法，通过修改网页要的img标签，让网页不加载图片。
2. 是通过WebViewJavascriptBridge调用oc端的downloadImages将要下载的图片数组传到oc端，oc通过sdwebimage框架下载图片，每下载完一张图片讲图片保存到本地之后。
3. 每下载完一张图片，调用js的imagesDownloadComplete方法，将原来到url和本地地址和传到web端。
4. 网页通过原来的老的url找到标签，讲新的本地url替换掉标签掉src，刷新图片。

###图片放大 
 

1. 在onload方法里给img加一个onclick的事件。
2. 在实现onclick方法，在图片被点击的时候，js端将图片所在web的坐标，以及当前是第几张图片调用oc端的imageDidClicked方法。
3. oc端在拿到信息后进行图片的放大缩小

###效果演示

![](https://github.com/ChenZhangQuan/WebViewJavascriptBridgeDemo/example.gif) 
