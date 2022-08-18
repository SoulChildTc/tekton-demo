### 目录说明

- auth-config: 包含gitlab、镜像仓库的认证以及提供给Task的ServiceAccount

- fluentd: 包含简单的日志收集配置以及fluentd部署

- qyweixin-webhook: 企业微信回调服务

- reports-nginx: 用于展示测试报告的nginx服务

- tekton: tekton相关配置
  - tasks: 包含所有的task配置
  - pipelines: 包含所有流水线配置
  - triggers: 包含触发器相关配置
    - eventListener: 事件监听器配置
    - triggerBindings: 参数提取器配置
    - triggerTemplate: 用于实例化Pipeline的配置



# DevOps作品演示


### 团队成员
同尘(运维工程师), 得胜(前端工程师), 水水(测试工程师), 小江(后端工程师)


### 1.1、项目说明

这次演示服务部分采用Node和Python两个语言栈进行开发，
其中Node服务会发起HTTP请求调用Python服务进行微服务的调用链路演示


### 1.2、流水线说明

流水线主要包含两个Pipeline，分别是CI和CD，其中CI部分是用mergequest来触发，CD部分的触发为企业微信审批通过触发。

CI部分演示的流程如下：

- 代码拉取
- 质量门禁，检测三方依赖是否有安全隐患，中央服务器可以维护一个黑名单库
- 代码规范检查并产出明确的报告
- 单元测试，使用用Allure进行报告的生成
- 覆盖度检测
- sonarqube代码静态扫描
- 构建上传容器镜像
- 生成测试环境yaml部署文件
- 通过argocd发布到测试环境
- 接口测试
- 集成测试
- 生成线上环境yaml部署文件
- 收集测试报告收集上传到nginx服务器
- 企业微信通知流水线执行完成


CD部分演示的流程如下：

- 合并线上环境yaml部署文件到主分支
- 企业微信通知开始灰度发布
- 开始灰度发布
- 合并master分支并打tag进行归档

## 1.3、工具链

- 基础设施：
    - 运行环境：Kubernetes
    - 代码管理：Gitlab
    - 项目管理：TAPD
    - 内部镜像库：harbor
- 代码
    - 技术框架：Python, Node
- 持续集成
    - 执行引擎：Tekton
    - 静态代码检查 pylint
    - 单元测试：pytest, Allure
    - 覆盖度：Coverage
    - 代码质控：Sonar
    - 镜像制作：Kaniko
- 自动化测试
    - 接口测试：Yapi
- 持续部署
    - 执行引擎：Argo CD
    - 部署工具：ArgoCD
    - 灰度发布：ArgoRollout
- 可观测性
    - 可视化度量：Prometheus+Grafana
    - 日志: EFK
    - 全链路：Elastic APM


## 2、需求管理

### 2.1、需求说明

本次演示项目采用一个简单的微服务作为流水线的演示，需求相对比较简单。python提供一个返回简单字符串的接口给到node调用


### 2.2、需求管理

需求管理采用工具为TAPD，具体拆分为【需求】-【子需求】-【任务】，具体的任务对应到相关研发人员，并评估工作时间。

![image](https://i.niupic.com/images/2022/03/20/9WOY.png)

![image](https://i.niupic.com/images/2022/03/20/9WPq.png)

### 2.3、工作量评估

工作量在计划会议上全员进行参与，所有工作量必须透明公开，承诺在计划能完成。在TAPD上输入【预计开始】和【预计结束】时间

![image](https://i.niupic.com/images/2022/03/22/9WWp.png)

### 2.4、代码库关联

我们在TAPD上将需求和Gitlab代码库进行关联，在小组成员提交代码时需要明确关联的需求。

![image](https://i.niupic.com/images/2022/03/20/9WPs.png))

同时可以看到该项目中代码提交的统计数据

![image](https://i.niupic.com/images/2022/03/20/9WPz.jpg)

## 3、代码管理

### 3.1、代码管理工具

代码管理库采用Gitlab进行版本管理

### 3.2、分支管理

本次演示项目分支策略比较简单，采用【master】作为主干分支策略，简单说明如下：

- feature分支
    - 功能分支
- release分支
    - 部署分支
    - 编译、测试、单测覆盖度、代码质量、测试环境部署等均在该分支上进行
- master分支
    - 线上分支
    - 完成测试流程后，合并到该分支进行上线部署
    - 打tag留档

![image](https://i.niupic.com/images/2022/03/21/9WUA.png)

### 3.3、代码审查

提交测试时需要将代码合并入release分支，此时需要人工进行代码审核，确认无误后合并会进行ci流程,部署到测试环境，此步骤也是本次演示中唯二需要人工介入中的第一个步骤

![image](https://i.niupic.com/images/2022/03/22/9WWu.png)

## 4、制品管理

### 4.1、统一制品库

- 项目依赖制品库：harbor

  ![image](https://i.niupic.com/images/2022/03/20/9WPx.png)

## 5、构建方式

### 5.1、通过gitlab mergerequest触发tekton eventlisteners

### 5.2、由多个Task组成一条Pipeline，Task可以在多条Pipeline中复用

### 5.3、构建过程中依赖以及其他输出通过pvc在整条pipeline中进行数据共享

### 5.4、构建资源弹性

采用Tekton原生弹性能力进行构建，即用即销毁，不会长期的占用集群资源



## 6、持续集成

### 6.1、触发机制

项目团队成员提交代码变更后，需要发起mergeRequest请求，经过code review后会自动进行集成


### 6.2、集成结果推送

流水线执行结果企业微信到达项目成员，如果构建失败，通过详情信息直接关联到对应的构建任务，查看失败原因。以下是企业微信的相关截图

- 构建成功

  ![image](https://i.niupic.com/images/2022/03/22/9WWz.png)

- 构建失败

  ![image](https://i.niupic.com/images/2022/03/22/9WWx.png)


## 7、自动化测试


### 7.1、单元测试和覆盖度


单测报告
![image](https://i.niupic.com/images/2022/03/22/9WWA.png)

覆盖度报告
![image](https://i.niupic.com/images/2022/03/22/9WWD.png)

代码规范报告
![image](https://i.niupic.com/images/2022/03/22/9WWD.png)


### 7.2、接口测试

![image](https://i.niupic.com/images/2022/03/23/9X1W.png)
使用YPAI平台进行接口协议管理及自动化用例执行


## 8、代码质量管控

### 8.1、质控工具

本次项目代码质量管控采用Sonar

![image](https://i.niupic.com/images/2022/03/22/9WWC.png)

同时引入pylint作为python代码规范

![image](https://i.niupic.com/images/2022/03/22/9WWB.png)


### 8.2、sonar可视化

登录sonar即可查看代码质量报告

![image](https://i.niupic.com/images/2022/03/22/9WWE.png)

## 9、部署流水线

### 9.1、自动化

代码提交变更后自动触发流水线，流水线的整个生命周期中只有上线合并代码的确认环节需要人为干预，其他均为自动化处理

![image](https://i.niupic.com/images/2022/03/22/9WWF.png)

### 9.2、多环境

本次演示包括四个环境：

- 开发环境
- 测试环境
- 预发布环境
- 产线环境

具体说明见【第10部分】

### 9.3、应用和配置分离

项目部署在k8s中，配置可以通过ConfigMap来进行读取，做到应用和配置分离的效果

### 9.4、灰度发布

利用ArgoRollout进行灰度发布，灰度发布示意图

![企业微信截图_63aac2d6-c729-4df3-bf44-1806b776264d](https://i.niupic.com/images/2022/03/24/9X3t.jpg)


## 10、环境管理

### 10.1、环境确定

本次演示项目准备了四个环境，以下是环境说明和访问地址

|       环境        |                说明                |          访问地址           |
| :---------------: | :--------------------------------: | :-------------------------: |
| 测试环境（test）  | 包括功能测试和压力测试等           | node-test.devops.soulchild.cn 、 python-test.devops.soulchild.cn |
| 产线环境（prod）  |            最终产线环境            | node.devops.soulchild.cn 、 python.devops.soulchild.cn |

### 10.2、环境交付

由于机器数量的限制，环境交付采用k8s的namespace做逻辑隔离

![企业微信截图_63aac2d6-c729-4df3-bf44-1806b776264d](http://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c3f3b6d897f946868135a5cf1065011c~tplv-k3u1fbpfcp-zoom-1.image)

## 11、度量可视化

本次项目最终线上监控采用【Metrics】+ 【Log】+ 【Tracing】

### 11.1、日志

通过Fluntd采集日志文件，并输出到ES集群中，研发人员通过kibana可以查询对应服务的日志

![image](https://i.niupic.com/images/2022/03/22/9WWI.png)


### 11.3、Tracing

链路追踪依赖APM组件，在Kibana中进行展示

![image](https://i.niupic.com/images/2022/03/20/9WPK.png)

![image](https://i.niupic.com/images/2022/03/20/9WPJ.png)


### 12、流程亮点

- 适合中小型团队快速落地的完整CI/CD流水线
- CI过程中更加注重报告的输出，同时增加安全检测
- CD过程中落地GitOps，同时增加灰度发布能力
- 度量可视化部分实践OpenTelemetry协议，采用Elastic APM进行落地
- 完成了一个从需求到审批流程,上线,报告输出,到链路日志追踪的完整项目
