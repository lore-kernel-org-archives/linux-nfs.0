From: OMestre <omestre@freeshell.org>
Subject: celerra
Date: 11 Jun 2002 12:27:33 -0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1023809253.1602.32.camel@ws-tor-0004.procergs>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from chicago.procergs.com.br ([200.198.128.92])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17HnYa-0007si-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Jun 2002 08:27:40 -0700
Received: from localhost.localdomain (unknown [172.28.6.9])
	by chicago.procergs.com.br (Postfix) with ESMTP id 7C9C3563D0
	for <nfs@lists.sourceforge.net>; Tue, 11 Jun 2002 12:27:33 -0300 (BRT)
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


  Hello,
  This mailing lists is my final chance... :)
  The problem is: 
  I have one NAS solution in my company: 
    Symmetryx + Connectrix + celerra file server.
  The celerra (file server) exports filesystem over nfs to my *nix
clients: Solaris, FreeBSD, Linux. 
  I can mount the filesystems from any machine, and i have some FreeBSD
boxes running diskless, just fine! But the linux ones do not works very
well. When i mount one filesystem and start my work, it just hangs! for
any cp, rm or sometimes "ls" commands. 
   But as i can mount the filesystems, i did tryed configure the linux
as  diskless machines, that was my original job. But the kernel can't
mount the rootfs with error messages about "RPC timeout while looking
for port 100003 and 100005". I issue the command rpcinfo -p <my_server>
from my servers and did see all services available! NFS all versions
(1,2 and 3), all protocols (tcp and udp). Then i did tryed make a
diskless machine mounts the rootfs served by another linux machine (Su
SE 7.3), and works fine! I did contacted the emc support, but the
argument is obvious: The other OS works, and the linux too, when i do
not try make it diskless. I did tryed the 2.2.19 kernel... but do not
work too.
  Anybody use this solution (celerra), and have diskless machines
(linux), in this environment?
  There are patches to kernel for my problems? Why the linux reports rpc
unavaliable on boot, but in execution time (machine up from local
disks), the mount NFS works (unstable, with hangs)?
  resume: Two problems
          1- Diskless linux over celerra do not work
          2- Mount NFS fs over celerra (from linux machines), is very
unstable.

  Thanks for everyone!
-- 
------------------------------------------------------------------------
FreeShell's master                           http://omestre.freeshel.org
------------------------------------------------------------------------


_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas - http://devcon.sprintpcs.com/adp/index.cfm?source=osdntextlink

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
