## java helloworld小程序，用于学习测试tekton pipeline

### 示例中使用的是kaniko构建镜像

使用方法:
```bash
# 创建namespace
k create ns java-demo

# 定义task
k apply -f mvn.task.yaml -f kaniko-build-push.task.yaml

# 定义pipeline
k apply -f java-demo-pipeline.yaml

# 定义git资源
k apply -f git-plr.yaml

# 配置凭证
k create secret -n java-demo docker-registry aliyun-cr --docker-server=xxxxx --docker-username=xxx --docker-password=xxx

# 创建mvn配置文件
k create cm -n java-demo mvn-settings --from-file=settings.xml

# 配置pvc
k create -f pvc.yaml

# 定义pipelinerun
k apply -f java-demo-piperun.yaml
```
