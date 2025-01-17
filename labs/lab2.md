Lab 2: Configuring the cluster for the application
---
**Objective:** Configure our five node Riak cluster to run the Multi Backend with LevelDB as the default backend.

Since our sample application uses Secondary Indexes, we need to change the backend from the default of Bitcask.

You have two options to make the configuration changes. You can stop all of the nodes and perform all of the changes at once, or you can perform rolling restarts on the node if you need to make changes with minimal to no impact to your customer.  We will perform a rolling configuration change.  First, we will modify all of the configuration files and then we will perform rolling restarts of the riak process on the cluster nodes.

From the *Operations_Lab* folder:

* Connect to the *app* box with **<span style="font-family:monospace">vagrant ssh app</span>**  
* Start a tmux-ssh session to all of the nodes with **<span style="font-family:monospace">tmux-cssh -u root -cs riak</span>**

#### Edit the configuration

The *riak.conf* file is a last-processed-wins configuration file format with each directive on its own line. This simplifies dynamic creation of the files because there is no complex punctuation rules to be enforced. We can just add overriding directives to the end of the file.

> **<span style="color:red">Warning</span>**: This process will cause any data stored in the Bitcask backed to appear to become inaccessible.  If you need to preserve the data in the backend that you are migrating away from, you will need to use rolling *replace* operations to stimulate transfers which will preserve the backend data.  More information about this process can be found in the Riak KV documentation.

Edit the configuration file by typing **<span style="font-family:monospace">vi /etc/riak/riak.conf</span>**.

* Press **<span style="font-family:monospace">Shift-G</span>** to jump to the end of the file.

* Press **<span style="font-family:monospace">&dollar;</span>** to jump to the end of the line.

* Press **<span style="font-family:monospace">i</span>** enter Insert mode.

* Press the Right Arrow key to move over one space.

* Press Enter to move to the beginning of a new line.

* Add the following lines to the file

**<span style="font-family:monospace">storage\_backend = multi</span>**  
**<span style="font-family:monospace">multi\_backend.default = my\_leveldb</span>**  
**<span style="font-family:monospace">multi\_backend.my\_leveldb.storage\_backend = leveldb</span>**  
**<span style="font-family:monospace">multi\_backend.my\_leveldb.leveldb.data\_root = $(platform\_data\_dir)/leveldb</span>**  
**<span style="font-family:monospace">multi\_backend.my\_leveldb.leveldb.maximum\_memory.percent = 50</span>**  
**<span style="font-family:monospace">multi\_backend.my\_bitcask.storage\_backend = bitcask</span>**  
**<span style="font-family:monospace">multi\_backend.my\_bitcask.bitcask.data\_root = $(platform\_data\_dir)/bitcask</span>**

* Press Escape to exit Insert mode,
* Type **<span style="font-family:monospace">:wq</span>** and press Enter to save our changes to the file and to exit vi.

* Press **<span style="font-family:monospace">Ctrl-D</span>** once to exit our tmux session and then **<span style="font-family:monospace">Ctrl-D</span>** once more to exit the ssh session to *app* and return to the *Operations_Lab* folder.

#### Rolling Restart

Perform a rolling restart of the cluster nodes by connecting to each node in turn and restarting Riak using the following procedure.  From the *Operations_Lab* folder:

* Connect to a node with **<span style="font-family:monospace">vagrant ssh</span>** *<span style="font-family:monospace">«vagrant_nodename»</span>*

* Start a root shell with **<span style="font-family:monospace">sudo su - </span>**

* Stop the Riak service with **<span style="font-family:monospace">riak stop</span>**

* Start the Riak service with **<span style="font-family:monospace">riak start</span>**

* Wait for Riak KV to start up with **<span style="font-family:monospace">riak-admin wait-for-service riak_kv</span>**

* (Optional, Recommended) Wait for transfers to complete by watching  **<span style="font-family:monospace">riak-admin transfers</span>**

* Press **<span style="font-family:monospace">Ctrl-D</span>** two times to exit all of the running shells and return to the *Operations_Lab* folder.
* Repeat the process on the next node.


We now have our five node cluster using LevelDB as the default backend and a Bitcask backend available for use as well.
