From: José Vicente Núñez Zuleta <josevnz@newbreak.com>
Subject: NFS problems: help needed with extremely poor NFS performance
Date: Tue, 23 Apr 2002 19:29:59 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020423192959.2670a7ce.josevnz@newbreak.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from unknown.level3.net ([63.211.90.124] helo=mail.newbreak.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1709ja-0001Cq-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Apr 2002 16:30:06 -0700
Received: from linux0037 (hicks150-45.optonline.net [167.206.150.45] (may be forged))
	by mail.newbreak.com (8.11.0/8.11.0) with SMTP id g3NNTxx10341
	for <nfs@lists.sourceforge.net>; Tue, 23 Apr 2002 19:29:59 -0400
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

Greetings,

I'm having serious problems with my NFS environment; The server is a Dual Pentium III 1Ghz running Redhat 7.2 (Kernel 2.4.7-10smp) and the clients are Dual Pentium 1Ghz Redhat 6.2 (Kernel 2.2.14-5.0smp).

We have a process that opens a lot of files on all the cluster and after some seconds, all the clients start showing the following messages:

Apr 23 19:12:05 linux0102 kernel: nfs: server lnxdev0003 OK 
Apr 23 19:12:17 linux0102 kernel: nfs: task 1059 can't get a request slot 
Apr 23 19:12:33 linux0102 kernel: nfs: server lnxdev0003 OK 
Apr 23 19:12:44 linux0102 kernel: nfs: server lnxdev0003 not responding, still trying 
Apr 23 19:12:44 linux0102 kernel: nfs: server lnxdev0003 OK 
Apr 23 19:12:54 linux0102 kernel: nfs: server lnxdev0003 not responding, still trying 
Apr 23 19:14:45 linux0102 automount[895]: expired /nb_apps/espiel
Apr 23 19:14:45 linux0102 automount[895]: expired /nb_apps/expat
Apr 23 19:14:45 linux0102 automount[895]: expired /nb_apps/crypto
Apr 23 19:14:45 linux0102 automount[895]: expired /nb_apps/rogue
Apr 23 19:14:45 linux0102 automount[895]: expired /nb_apps/ACE
Apr 23 19:14:45 linux0102 automount[895]: expired /nb_apps/xerces
Apr 23 19:15:49 linux0102 automount[906]: expired /home/suresh
Apr 23 19:16:06 linux0102 kernel: nfs: server lnxdev0003 OK 
Apr 23 19:16:06 linux0102 kernel: nfs: server lnxdev0003 OK 
Apr 23 19:16:38 linux0102 kernel: nfs: server lnxdev0003 not responding, still trying 

I followed the tutorial that appears at "http://nfs.sourceforge.net/nfs-howto/performance.html" and applied the following optimizations (with no result):

- Deactivated auto-negotiation on the HUB (we have a Cisco FastHub 400) and forced the NIC to use "Full Duplex" using FastEthernet. This should reduce the number of collissions.
- Increased the number of nfsd servers and the socket queue (here is a fragment of my script, /etc/init.d/nfs, currently i use 16 nfsd servers):
  
   RPCNFSDCOUNT=16
   ....
   # NFSv3 only if kernel >= 2.2.18
   OS_RELEASE=`uname --release`
   ....
        echo -n "Starting NFS mountd: "
        daemon rpc.mountd $RPCMOUNTDOPTS
        echo
        echo -n "Starting NFS daemon: "
        echo 262144 > /proc/sys/net/core/rmem_default
        echo 262144 > /proc/sys/net/core/rmem_max
        daemon rpc.nfsd $RPCNFSDCOUNT
        echo 65536 > /proc/sys/net/core/rmem_default
        echo 65536 > /proc/sys/net/core/rmem_max
        echo
- I increased the rsize and wsize on my clients to 4096 (im using automount and NIS, /etc/auto.master):
   /home   auto.home -rw,intr,retry=10,rsize=4096,wsize=4096
   /nb_apps   auto.nb_apps -rw,intr,retry=10,rsize=4096,wsize=4096
   /data   auto.data -rw,intr,retry=10,rsize=4096,wsize=4096


What i should try next?. We have a network with very few machines, apparently no collissions (the stats at the hub doesn't show that many but i will have to confirm).

Should i try to update the nfs-tools on all the boxes ( i can't do the same to the kernel because we have a Cordba lib that could broke, at least on the clients)?

The server doesn't have a high load (i'm monitoring the box using top and UCD-SNMP) and other network apps work fine so far :(

Thanks in advance.


   




_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
