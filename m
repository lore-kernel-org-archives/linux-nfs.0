From: Tim Hasson <tim@aidasystems.com>
Subject: Linux NFS & Heartbeat Failover (RH9.0)
Date: Sat, 16 Aug 2003 08:03:25 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1061046205.3f3e47bd69679@mail.aidasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [208.253.240.78] (helo=mx1.aidasystems.com)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19o2iN-0006ca-00
	for <nfs@lists.sourceforge.net>; Sat, 16 Aug 2003 08:11:35 -0700
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


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

I have a very similar setup. 2 Redhat 9.0 (2.4.20-19.9smp kernel, glibc-2.3.2-
27, nfs-utils-1.0.1-3.9 from rpm) boxes running DRBD -
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



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
