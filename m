From: Tim Hasson <tim@aidasystems.com>
Subject: Linux NFS & Heartbeat Failover (RH9.0)
Date: Sat, 16 Aug 2003 06:51:22 -0700
Sender: linux-ha-admin@lists.linux-ha.org
Message-ID: <1061041882.3f3e36da5fa38@mail.aidasystems.com>
Reply-To: linux-ha@lists.linux-ha.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <linux-ha-admin@lists.linux-ha.org>
To: nfs@lists.sourceforge.net, linux-ha@lists.linux-ha.org
Errors-To: linux-ha-admin@lists.linux-ha.org
List-Unsubscribe: <http://lists.linux-ha.org/mailman/listinfo/linux-ha>,
	<mailto:linux-ha-request@lists.linux-ha.org?subject=unsubscribe>
List-Post: <mailto:linux-ha@lists.linux-ha.org>
List-Help: <mailto:linux-ha-request@lists.linux-ha.org?subject=help>
List-Subscribe: <http://lists.linux-ha.org/mailman/listinfo/linux-ha>,
	<mailto:linux-ha-request@lists.linux-ha.org?subject=subscribe>
List-Archive: <http://lists.linux-ha.org/pipermail/linux-ha/>
List-ID: <nfs.lists.sourceforge.net>

Hi,

I am having a problem with NFS server on a multi-homed system. The problem is 
that I want NFS to reply to client requests on eth0:0 and not eth0. The reason 
for that is that eth0:0 alias/virtual ip is managed by heartbeat for failover 
to the backup nfs server (with the /var/lib/nfs on it).

A link of someone who had the same problem (I think):
http://lists.linux-ha.org/pipermail/linux-ha/2003-March/007269.html

Summary:
NFS Client is unable to connect to nfs server started under heartbeat through 
virtual IP.

I have a very similar setup. 2 Redhat 9.0 (2.4.20-19.9smp) boxes running DRBD -
 Network RAID 1 -
 and NFS Server +statd+portmap+fam under heartbeat 1.0.3

I have edited the default /etc/init.d/nfslock script to start rpc.statd with 
the option -n vitualIP so that when NFS server crashes and falls over to the 
secondary, I shouldn't have problems from clients complaining that the statd 
host changed.

However, like him, I got the same error when trying to mount an exported 
directory from the NFS Server via the virtual IP of the 2-node heartbeat 
cluster.
The error is: NFSPROC_NULL: RPC: Timed out

Running tcpdump on the primary node like so:
tcpdump -np -s 1600 udp port 2049
gives some interesting info, especially when I retry mounting by the virtual 
ip from the nfs client. It looks like the server accepts the connection on the 
virtual ip (i.e. eth0:0) but nfsd on port 2049 replies using the primary 
interface ip (i.e. eth0). The client doesn't like the reply from different 
host I guess therefore timing out.

rpcinfo -e nfs.server.virtual.ip (from the client) works as expected.
showmount -e nfs.server.virt.ip  (from the client) works as expected also.

Searching everywhere found few hints. FreeBSD's nfsd has a -h option to 
specify host/ip to tie nfsd to, but Linux doesn't. This blows because AFAIK 
drbd is strictly linux 2.x based.

I tried modifying /etc/ha.d/resources.d/IPaddr so that the ip is assigned in 
add_address() to eth0 statically instead of the eth#:# and also in 
delete_address, and although I was able to mount now from the clients, 
heartbeat stop doesn't seem to stop the services anymore and I see errors 
reported in /var/log/ha-log about IPaddr error 1

Any help would be appreciated.
Please CC me if you reply as I am not subscribed to the list.

Best Regards,
Tim



_______________________________________________
Linux-HA mailing list
Linux-HA@lists.linux-ha.org
http://lists.linux-ha.org/mailman/listinfo/linux-ha
