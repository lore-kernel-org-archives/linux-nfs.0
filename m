From: Matthew Hodgson <matthew@arasphere.net>
Subject: BUG: at fs/nfs/pagelist.c:339 nfs_scan_dirty() (fwd)
Date: Mon, 12 Feb 2007 16:37:22 +0000 (GMT)
Message-ID: <Pine.LNX.4.64.0702121635490.32298@phoenix.arasphere.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HGeBN-0000Ih-NH
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 08:37:38 -0800
Received: from 87-194-2-4.bethere.co.uk ([87.194.2.4] helo=mail.arasphere.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HGeBM-0007xj-B5
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 08:37:39 -0800
Received: from localhost ([127.0.0.1])
	by mail.arasphere.net with esmtp (Exim 4.54) id 1HGeB8-0008Qt-UO
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 16:37:22 +0000
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi all,

Apologies for the fwd - I suspect this bug report got lost in the noise of 
the LKML.  Hopefully this is a more appropriate place for it...

thanks,

M.

---------- Forwarded message ----------
Date: Mon, 12 Feb 2007 01:37:34 +0000
From: Matthew Hodgson <matthew@arasphere.net>
To: linux-kernel@vger.kernel.org
Subject: BUG: at fs/nfs/pagelist.c:339 nfs_scan_dirty()

Hi,

I just upgraded from 2.6.13.4 to 2.6.20 on a Pentium M, and on booting off an 
NFS root encountered the following bug somewhere after loading the w83627hf 
module and before ohci1394:

BUG: at fs/nfs/pagelist.c:339 nfs_scan_dirty()
   [<c01da1b6>] nfs_scan_dirty+0x168/0x17d
   [<c01dd54a>] nfs_wait_on_requests_locked+0x9c/0xac
   [<c01dda9b>] nfs_sync_mapping_wait+0xad/0x256
   [<c01de35a>] nfs_sync_mapping_range+0x83/0x9e
   [<c01d8037>] nfs_getattr+0x37/0x98
   [<c01d8000>] nfs_getattr+0x0/0x98
   [<c014be19>] vfs_getattr+0x21/0x30
   [<c014c203>] vfs_stat_fd+0x2e/0x40
   [<c0224ec4>] __copy_to_user_ll+0xc9/0xd4
   [<c014c2a2>] sys_stat64+0xf/0x23
   [<c010f5bb>] do_page_fault+0x277/0x528
   [<c0149c61>] vfs_read+0xfa/0x134
   [<c010f344>] do_page_fault+0x0/0x528
   [<c0102c98>] syscall_call+0x7/0xb
   =======================

So far the machine appears stable other than this - but after having had a year 
or so of perfect uptime on the box under 2.6.13.4 with no such kernel errors, I 
thought you might like to know in case this indicates something more serious.

The kernel options given to boot off NFS were...

root=/dev/nfs rw 
nfsroot=192.168.0.x:/home/stb,v3,hard,intr,nolock,retrans=6,rsize=16384,wsize=16384 
ip=dhcp

...and the full dmesg, kernel config, lspci and lsmod output may be found at 
http://www.arasphere.net/linux/nfs-bug.  The NFS server is running the default 
NFS v3 options on 2.6.20 on Core 2 Duo.  No patches have been applied to either 
kernel.

Any advice on whether I should be worried by this, whether it indicates that 
something significant is wrong, and how I might help debug it would be 
appreciated.

thanks.

Matthew.


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
