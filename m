From: "David B. Ritch" <dritch@hpti.com>
Subject: NFS mount/umount problem
Date: 16 Jan 2003 14:17:36 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1042744656.3312.43.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Craig Tierney <ctierney@hpti.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sl-highp1-1-0.sprintlink.net ([144.228.5.138] helo=localhost.localdomain)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18ZFeV-0006b7-00
	for <nfs@lists.sourceforge.net>; Thu, 16 Jan 2003 11:26:11 -0800
To: NFS mailing list <nfs@lists.sourceforge.net>
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

A colleague of mine who is having email difficulties asked me to forward
this to the list.

I am having a problem with nfs mounts under linux-2.4.20.

Server:
Redhat-8.0, kernel upgraded to linux-2.4.20 + Trond's NFS Patches.
Dual PIII 933 Mhz, 2 GB ram, tg3 gigabit ethernet driver.

Client
Redhat-7.1, kernel upgraded to linux-2.4.18 + Trond's NFS patches.
Dual Xeon 2.2 Ghz, 1 GB ram, e100 ethernet driver.

After I upgraded the server from 2.4.14 to 2.4.20, I am having a problem
mounting and unmounting the NFS partitions using autofs. I have all
of the clients touch the nfs filesystems (ls /misc/scratchx) to cause
them to mount.  Many of the mounts fail (~ 50%) with the error.  If I
slow
down the rate at which the ls is executed, I have a better chance at
mounting all of the filesystems.  When I operate on chucks of the nodes
128 at a time, I can usually get them to mount ok.

In the messages file I get:

Jan 16 16:58:51 g0427 automount[537]: attempting to mount entry
/misc/scratchx
Jan 16 16:59:12 g0427 automount[13130]: >> mount: RPC: Timed out
Jan 16 16:59:12 g0427 automount[13130]: mount(nfs): nfs: mount failure
x00:/export/scratch1 on /misc/scratchx

I tried increasing timeo to 30 and 60, and this appeared to help it
did not fix the problem.  I never change timeo before.

When the mounts do fail, I try and clean them up with umount.  Often
when doing this I will get error messages on some of the nodes:

  Bad UMNT RPC: RPC: Timed out

This problem can be reduced when I do not have the umount execute on
all of the nodes at the same time.

This happens with when the filesystem is ext3 or xfs.

I do not have these problems under the 2.4.14 kernel.

Are there some timing values in RPC that have changed or that I can
change
to increase timeouts?  Does anyone have any other ideas?

Thanks,
Craig

-- 
David B. Ritch
High Performance Technologies, Inc.


-------------------------------------------------------
This SF.NET email is sponsored by: Thawte.com
Understand how to protect your customers personal information by implementing
SSL on your Apache Web Server. Click here to get our FREE Thawte Apache 
Guide: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0029en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
