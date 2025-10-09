# YAML Troubleshooting
This course relies heavily on the use of YAML files to define object configurations. As YAML is a significant whitespace-based syntax, you will invariably run into indentation and formatting issues at points throughout. You will get a lot more out of the course and have a better learning experience if you can troubleshoot common issues yourself.

## An Example
Consider the following YAML manifest:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: brokenPod
  labels:
    run: brokenPod
spec:
  volumes:
  - name: foobar
    emptyDir: {}
    terminationGracePeriodSeconds: 0
  containers:
  - image: nginx
    name: nginx-server
    resources:
    requests:
      cpu: 10m
      memory: 10Mi
    limits:
      cpu: 10m 
      memory: 10Mi
    ports:
      containerPort: 80
```
There are several issues with this file related to YAML syntax, which exemplify common errors and their resolutions.

## Cannot unmarshal object into Go struct field
If you attempt to create a pod from the manifest above, the first issue you will hit will be:
```
Error from server (BadRequest): error when creating "brokenPod.yaml": Pod in version "v1" cannot be handled as a Pod: json: cannot unmarshal object into Go struct field Container.spec.containers.ports of type []v1.ContainerPort
```
To understand the issue here, note the field reference telling us where the issue is - _spec.containers.ports_. This is referencing the ports block at the end of the manifest. Also note the target type that we are trying to unmarshall into - []v1.ContainerPort - is an array (as indicated by the []). The solution is that _ports_ should be a list, so we need to make the containerPort a list item, which in YAML can be done by preceding it with a '-', like so:
```yaml
...
    ports:
    - containerPort: 80
```

## Unknown fields
If you attempt to create the pod again, after fixing the container port, you will hit another error:
```
Error from server (BadRequest): error when creating "brokenPod.yaml": Pod in version "v1" cannot be handled as a Pod: strict decoding error: unknown field "spec.containers[0].limits", unknown field "spec.containers[0].requests", unknown field "spec.volumes[0].terminationGracePeriodSeconds"
```
This is a sure-fire indicator of incorrect indentation. Looking at the refs for the unknown fields we again get a sense of where the problems are:
###  _spec.containers[0].limits_ and _spec.containers[0].requests_ - the resources section of the spec
```yaml
...
    resources:
    requests:
      cpu: 10m
      memory: 10Mi
    limits:
      cpu: 10m
      memory: 10Mi
```
These need to be indented further, so that the requests and limits mappings belong to the resources block, not the container block:
```yaml
...
    resources:
      requests:
        cpu: 10m
        memory: 10Mi
      limits:
        cpu: 10m
        memory: 10Mi
```
###  _spec.volumes[0].terminationGracePeriodSeconds_ - the volumes section of the spec
```yaml
...
spec:
  volumes:
  - name: foobar
    emptyDir: {}
    terminationGracePeriodSeconds: 0
```
Here the issue is the opposite - terminationGracePeriodSeconds is indented too far, and should belong to the top-level spec object:
```yaml
...
spec:
  volumes:
  - name: foobar
    emptyDir: {}
  terminationGracePeriodSeconds: 0
```

## Fully corrected configuration
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: brokenPod
  labels:
    run: brokenPod
spec:
  volumes:
  - name: foobar
    emptyDir: {}
  terminationGracePeriodSeconds: 0
  containers:
  - image: nginx
    name: nginx-server
    resources:
      requests:
        cpu: 10m
        memory: 10Mi
      limits:
        cpu: 10m 
        memory: 10Mi
    ports:
    - containerPort: 80
```
Paying careful attention to kubectl error messages will enable you to have a good shot at fixing most of the YAML issues you encounter throughout the remainder of the course.