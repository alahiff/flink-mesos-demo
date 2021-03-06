# flink-mesos-demo

Demonstrates how to experiment with Flink-on-Mesos (WIP).

A Flink cluster consists of a JobManager (often called the AppMaster process) plus some number of TaskManagers (TM).
The snapshot build of Flink contains a new Mesos-specific AppMaster capable of registering as a Mesos framework and
launching TMs as Mesos tasks.    The AppMaster is designed to run in Mesos too, as a task of a not-yet-available component 
called the dispatcher.

To demonstrate the available functionality, this repository builds a simple Docker image capable of launching the AppMaster.
Feel free to launch a Docker container manually, or as a Marathon/Aurora application.

## Quick-Start

### Build the docker image
```
$ cd <repo>
$ docker build -t alahiff/flink-on-mesos:0.4.5 .
```
 
### Start the AppMaster
Instead of producing an image with baked-in Mesos configuration we pass them as arguments to the mesos-appmaster.sh script run in the container:
```
docker run -itd --net=host -v /path/to/flink/conf:/opt/flink/conf alahiff/flink-on-mesos:0.4.5 \
    /opt/flink/bin/mesos-appmaster.sh \
    -Dmesos.failover-timeout=60 \
    -Dmesos.master= \
    -Dmesos.resourcemanager.framework.role= \
    -Dmesos.resourcemanager.framework.principal= \
    -Dmesos.resourcemanager.framework.secret= \
    -Dmesos.resourcemanager.tasks.container.type=docker \
    -Dmesos.resourcemanager.tasks.container.image.name=alahiff/flink-on-mesos:0.4.5 \
    -Dmesos.resourcemanager.tasks.cpus=1 \
    -Dmesos.initial-tasks=1 \
    -Djobmanager.rpc.address=
```

In addition to the standard settings, the following 
Mesos-specific settings may be configured:

| Key            | Description |
|----------------|-------------|
| `mesos.master`   | The connection string for Mesos, as an ip:port pair, or as `zk://server:2181/mesos`. |
| `mesos.failover-timeout` | The number of seconds that Mesos will allow for failover of the AppMaster. | 
| `mesos.resourcemanager.framework.role` | The Mesos framework role. |
| `mesos.resourcemanager.framework.principal` | The Mesos framework principal. |
| `mesos.resourcemanager.framework.secret` | The Mesos framework secret. |

I found that I needed to change `jobmanager.rpc.address` to the hostname of the machine on which I run the AppMaster, otherwise the TaskManagers would try to connect to localhost rather than the correct hostname on which the AppMaster is running.

### Open the Web UI
Browse to `http://<appmaster host>:8081/`

## Notes

### Customization

The Dockerfile defines certain environent variables which may be customized.  Note that in the final user experience,
such information is provided as CLI parameters to such commands as `mesos-session.sh` and `flink run`.

| Variable | Description |
|----------|------------|
| `_CLIENT_TM_COUNT` | Sets the number of TaskManagers to allocate.  |
| `_CLIENT_TM_MEMORY` | Sets the amount of memory to allocate for each TM. |
| `_SLOTS` | Sets the number of Flink task slots to advertize. |
| `_CLIENT_USERNAME` | The username for Mesos task and for Hadoop purposes. |

### High Availability
The AppMaster uses ZooKeeper (if configured) to support high-availability.    Upon an AppMaster crash,
the replacement AppMaster (as provided by Marathon/Aurora here, and later the dispatcher) reconnects to
any still-running TaskManagers.

Be sure to set the `high-availability.zookeeper.path.namespace` setting to a
unique value for each Flink cluster.
