From: Burton Windle <bwindle@fint.org>
Subject: 2.6.3: oops reading /proc/net/rpc/auth.unix.ip/content
Date: Tue, 24 Feb 2004 09:17:54 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0402240909310.889@morpheus>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvdOR-0000yM-Hv
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 06:18:39 -0800
Received: from mta01.alltel.net ([166.102.165.143] helo=mta01-srv.alltel.net)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AvdNl-0007BE-0u
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 06:17:57 -0800
Received: from morpheus ([151.213.160.133]) by mta01-srv.alltel.net
          with ESMTP
          id <20040224141755.SKGH4486.mta01-srv.alltel.net@morpheus>
          for <nfs@lists.sourceforge.net>; Tue, 24 Feb 2004 08:17:55 -0600
Received: from bwindle (helo=localhost)
	by morpheus with local-esmtp (Exim 3.36 #1 (Debian))
	id 1AvdNi-0000FD-00
	for <nfs@lists.sourceforge.net>; Tue, 24 Feb 2004 09:17:54 -0500
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello.  I just upgraded a workstation from 2.6.2 to 2.6.3, and am now
seeing an oops on boot when my init scripts run the nfs-kernel-server
script. The oops actually happens whenever trying to read
/proc/net/rpc/auth.unix.ip/content

Is this a known-issue?

Linux version 2.6.3 (root@jekyll) (gcc version 3.3.2 (Debian)) #11 Mon Feb 23 22:23:26 EST 2004

Unable to handle kernel NULL pointer dereference at virtual address 00000044
 printing eip:
c0396beb
*pde = 00000000
Oops: 0002 [#1]
CPU:    0
EIP:    0060:[<c0396beb>]    Not tainted
EFLAGS: 00010246
EIP is at content_open+0x5b/0x80
eax: 00000000   ebx: cfb49628   ecx: 00000000   edx: cf92d738
esi: 00000000   edi: cfb29df4   ebp: cfc45f3c   esp: cfc45f28
ds: 007b   es: 007b   ss: 0068
Process grep (pid: 225, threadinfo=cfc44000 task=cfe01440)
Stack: cfb29df4 c0435e98 cfb29df4 cf9b2c24 ffffffe9 cfc45f58 c015b824 cf9b2c24
       cfb29df4 00000000 cffee000 00008000 cfc45f9c c015b76b cf9dfae0 cfff56ec
       00008000 00000003 00008000 cffee000 cf9dfae0 cfff56ec cffee000 00008000
Call Trace:
 [<c015b824>] dentry_open+0xac/0x14c
 [<c015b76b>] filp_open+0x4f/0x5c
 [<c015bdb3>] sys_open+0x37/0x80
 [<c0109c1b>] syscall_call+0x7/0xb

Code: 89 58 44 89 f0 8b 5d f4 8b 75 f8 8b 7d fc 89 ec 5d c3 8d 76



CONFIG_NET=y
CONFIG_PACKET=y
CONFIG_UNIX=y
CONFIG_NET_KEY=y
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_XFRM=y
CONFIG_IPV6_SCTP__=y
CONFIG_NETDEVICES=y
CONFIG_DUMMY=y
CONFIG_NET_ETHERNET=y
CONFIG_MII=y
CONFIG_NET_VENDOR_3COM=y
CONFIG_VORTEX=y
CONFIG_NET_TULIP=y
CONFIG_TULIP=y
CONFIG_DE4X5=y
CONFIG_WINBOND_840=y
CONFIG_DM9102=y
CONFIG_NET_PCI=y
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
CONFIG_NFSD=y
CONFIG_NFSD_V3=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_EXPORTFS=y
CONFIG_SUNRPC=y
CONFIG_SMB_FS=y
CONFIG_MSDOS_PARTITION=y
CONFIG_NLS=y
CONFIG_DEBUG_KERNEL=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_SLAB=y
CONFIG_DEBUG_IOVIRT=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_SPINLOCK_SLEEP=y
CONFIG_FRAME_POINTER=y


--
Burton Windle                           bwindle@fint.org



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
