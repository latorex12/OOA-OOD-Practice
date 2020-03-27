## 面向对象分析OOA
需求分析是一个递进的过程，我们不能一开始就设计出完善的需求方案。
完善的方案也需要有一个草稿然后一点点推敲，形成最终方案。
### 初稿
使用用户名+密码鉴权
### 初次优化
密码明文传输不安全->考虑加密算法将参数加密->不能避免重放攻击，依然不安全
### 二次优化
需要应对重放攻击->加盐（时间戳
### 三次优化
考虑服务端数据库存储用户名、密码的方案->考虑密码泄露，所以密码不能明文存储
权衡各种因素，安全方案确定->考虑解耦具体存储方式
### 确认需求
- 请求时将相关参数加盐（时间戳）一起拼接成字符串，通过算法生成token，并且将token、AppID、时间戳拼接在 URL 中，一并发送到微服务端
- 微服务端在接收到调用方的接口请求之后，从请求中拆解出 token、AppID、时间戳。
- 微服务端首先检查传递过来的时间戳跟当前时间，是否在 token 失效时间窗口内。如果已经超过失效时间，那就算接口调用鉴权失败，拒绝接口调用请求。
- 如果 token 验证没有过期失效，微服务端再从自己的存储中，取出 AppID 对应的密码，通过同样的 token 生成算法，生成另外一个 token，与调用方传递过来的 token 进行匹配；如果一致，则鉴权成功，允许接口调用，否则就拒绝接口调用。

## 面向对象设计OOD
产出类的设计。

1. 划分职责进而识别出有哪些类根据需求描述，我们把其中涉及的功能点，一个一个罗列出来，然后再去看哪些功能点职责相近，操作同样的属性，可否归为同一个类。
2. 定义类及其属性和方法我们识别出需求描述中的动词，作为候选的方法，再进一步过滤筛选出真正的方法，把功能点中涉及的名词，作为候选属性，然后同样再进行过滤筛选。
3. 定义类与类之间的交互关系UML 统一建模语言中定义了六种类之间的关系。它们分别是：泛化、实现、关联、聚合、组合、依赖。我们从更加贴近编程的角度，对类与类之间的关系做了调整，保留四个关系：泛化、实现、组合、依赖。
4. 将类组装起来并提供执行入口我们要将所有的类组装在一起，提供一个执行入口。这个入口可能是一个 main() 函数，也可能是一组给外部用的 API 接口。通过这个入口，我们能触发整个代码跑起来。

### 划分职责，分类
类是现实世界中事物的一个建模。但是，并不是每个需求都能映射到现实世界，也并不是每个类都与现实世界中的事物一一对应。对于一些抽象的概念，我们是无法通过映射现实世界中的事物的方式来定义类的。
另外一种识别类的方法，那就是把需求描述中的名词罗列出来，作为可能的候选类，然后再进行筛选。对于没有经验的初学者来说，这个方法比较简单、明确，可以直接照着做。
根据需求描述，把其中涉及的功能点，一个一个罗列出来，然后再去看哪些功能点职责相近，操作同样的属性，可否应该归为同一个类。

1. 请求时将相关参数加盐（时间戳）一起拼接成字符串
2. 生成token
3. 将token、AppID、时间戳拼接在 URL 中
4. 请求中拆解出 token、AppID、时间戳
5. 从存储中取出 AppID 和对应的密码
6. 根据时间戳判断 token 是否过期失效
7. 验证两个 token 是否匹配

token有关的操作有：1、2、6、7
URL相关操作有：3、4
操作appid/密码：5

所以可得核心类：
Token：1、2、6、7
Url：3、4
CredentialStroage：5

### 定义类及其属性、方法
#### Token
功能：
把 URL、AppID、密码、时间戳拼接为一个字符串；
对字符串通过加密算法加密生成 token；
根据时间戳判断 token 是否过期失效；
验证两个 token 是否匹配。

属性（名词）：
url、appID、密码、时间戳、字符串、token
方法（动词）：
拼接Token、算法加密、判断过期、验证匹配

设计：
AuthToken
param:
private string token;
private long createTime;
private long expiredTimeInterval;
init:
public AuthToken(string token, long createTime, long expiredTimeInterval);
methods:
public string getToken();
public boolean isExpired();
public boolean match(AuthToken authToken);

最终：
1. 不是所有名词都需要定义为类属性。如url/appid/pwd/timeStamp可以作为方法参数，因为在生成token后，他们就不会再被使用了。
2. 需要挖掘没有出现在功能点描述中的属性，如createTime/expireTimeInterval，可以用来判断token是否过期（考虑是否直接运算出token的过期时间，而非将这两个值存下来？
3. 添加了getToken，属性均为private，不可修改，因为这些参数在初始化之后就已经固定，不再变化
总结：
1. 业务模型上来说，不属于这个类的属性和方法，不应该被放进这个类里，如url/appid信息，并不属于token管理，所以不应放在类中
2. 在设计时，不能单纯的将依赖当下的需求，还要分析这个类从业务模型上来讲，理应具有哪些属性和方法，这样可以一方面保证类定义的完整性，另一方面为未来的扩展留空间。

#### Url
考虑到还有其他的访问方式，不仅是http等，所以取出特异性，统称 ApiRequest

功能：
1. 将token、appID、时间戳拼接到Url中，形成新的Url
2. 解析Url，得到拼接的信息

属性（名词）：
token/appid/时间戳/url
方法（动词）：
拼接、解析

设计：
ApiRequest
params:
private string baseUrl;
private string token;
private string appid;
private long timestamp;
init:
public ApiRequest(string baseUrl, string token, string appid, long timestamp);
methods:
public ApiRequest createFromFullUrl(string url);
public string getBaseUrl();
public string getToken();
public string getAppid();
public long getTimestamp();

#### CredentialStorage
功能：
从存储中取出appid和对应密码。

要求：
需要隐藏具体的存储方式，所以使用接口形式提供。

CredentialStorage
Interface:
string getPasswordByAppid(string appid);

### 定义类间交互关系
UML类间交互关系分为6种：
1. 泛化（b继承a
2. 实现（类b实现接口a
3. 聚合（b包含a，但a生命周期可以不依赖b
4. 组合（b包含a，但a生命周期一定依赖b，不可单独存在
5. 关联（a是b的成员（聚合、组合
6. 依赖（b有使用到a（关联（聚合、组合

简化为：泛化、实现、组合、依赖

### 将类组装起来提供执行入口
由于鉴权应该是一个组件而不是独立运行的系统，所以封装所有实现细节，设计一个顶层的接口类，暴露一组对外调用的API接口，作为组件的入口。

ApiAuth:
Interface:
void auth(string url);
void auth(ApiRequest apiRequest);

ApiAuthImpl:
param:
private CredentialStorage credentialStorage;
init:
public DefaultApiAuth();
public DefaultApiAuth(CredentialStorage credentialStorage);
method:
void auth(string url);
void auth(ApiRequest apiRequest);
