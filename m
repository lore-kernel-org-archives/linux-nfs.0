From: José Vicente Núñez Zuleta <josevnz@newbreak.com>
Subject: NFS weird problem: help needed (pmap_getmaps rpc)
Date: Fri, 29 Mar 2002 17:13:20 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020329171320.58995b41.josevnz@newbreak.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Received: from unknown.level3.net ([63.211.90.124] helo=lenbkx0001.newbreak.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16r4ck-0004KT-00
	for <nfs@lists.sourceforge.net>; Fri, 29 Mar 2002 14:13:30 -0800
Received: from linux0037 (hicks150-45.optonline.net [167.206.150.45] (may be forged))
	by lenbkx0001.newbreak.com (8.11.6/8.11.6) with SMTP id g2TMDLr28309
	for <nfs@lists.sourceforge.net>; Fri, 29 Mar 2002 17:13:21 -0500 (EST)
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

After running a batch job (that runs on many clients at the same time and open files shared using NFS) the following
message appears on Syslog:

Mar 21 15:49:26 10.1.40.44 automount[13439]: >> pmap_getmaps rpc problem: RPC:
Timed out
Mar 21 15:49:26 10.1.40.44 automount[13439]: >> mount: RPC: Unable to receive;
errno = Connection refused
Mar 21 15:49:26 10.1.40.44 automount[13439]: mount(nfs): nfs: mount failure
lnxsrv0001:/export/home/suhrud on /home/suhrud

The workaround is to restart the batch job and the problem disapears.

I checked the following documentation in order to see what parameters i can tune:


http://nfs.sourceforge.net/nfs-howto/performance.html
http://nfs.sourceforge.net/nfs-howto/ (just to make a reference here. Very usefull).
http://nfs.sourceforge.net/ (Sort of a FAQ. We are not experiencing any of the problems that appear on this FAQ).

I plan to apply the following change on production, but i not sure if they fill help me at all:

1) To /etc/init.d/nfs file:

# Number of servers to be started by default
RPCNFSDCOUNT=32

And:
echo
echo -n "Starting NFS daemon: "
echo 262144 > /proc/sys/net/core/rmem_default
echo 262144 > /proc/sys/net/core/rmem_max
daemon rpc.nfsd $RPCNFSDCOUNT
echo 65536 > /proc/sys/net/core/rmem_default
echo 65536 > /proc/sys/net/core/rmem_max

Has anyone has seen this error so far? My server runs Redhat 7.0 and the clients are 6.2 machines. All the client have Fast Ethernet and the server have a Gibabit Ethernet on fiber.

The server also has a Ultra ATA disk.

Thanks in advance.


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
