From: "Robert Williamson" <robbiew@us.ibm.com>
Subject: NFS causing kernel BUG at lines 1701 and 1702 in slab.c
Date: Wed, 13 Aug 2003 14:05:55 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF9C9BC083.38DCD957-ON85256D81.0068B5F6-86256D81.0068F48A@pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e1.ny.us.ibm.com ([32.97.182.101])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19n0we-0000R3-00
	for <nfs@lists.sourceforge.net>; Wed, 13 Aug 2003 12:06:05 -0700
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

Distribution: SuSE 8.0 with 2.6.0-test3

Hardware Environment: Described in testplan located at
http://ltp.sf.net/nfs

Software Environment: glibc 2.2.5 and nfs-utils 1.0.5 on server.

Problem Description: One NFS client hit the 1701 bug, while the other hit
the
1702.  Both hit after a few hours of performing a loop of random file I/O
system calls over NFS.  Afterwards, even though the test was still running,
all
NFS activity had stopped on both clients.  Also, a cat /proc/slabinfo
produced
a Segmentation Fault.  Here's an example of both bugs:
===========================
kernel BUG at mm/slab.c:1701!
invalid operand: 0000 [#1]
CPU:    0
EIP:    0060:[cache_alloc_refill+258/720]    Not tainted
EFLAGS: 00010002
EIP is at cache_alloc_refill+0x102/0x2d0
eax: 00000000   ebx: 00000006   ecx: c74a7000   edx: c74a7018
esi: 00000007   edi: 00000004   ebp: c43dfcd8   esp: c43dfca4
ds: 007b   es: 007b   ss: 0068
Process fsstress (pid: 26441, threadinfo=c43de000 task=cf139940)
Stack: 00000000 cfdaee98 00000286 cfda6958 00000006 c74a7000 00000006
cfdaeea4
       cfdaeea4 cfdaeeac 00001000 c74a7018 cfda6948 c43dfcfc c0130ea4
cfdaee98
       000000d0 00000000 cefd8b80 cfe82fec c0426b98 c43dfd1c c43dfd0c
c019719b
Call Trace:
 [kmem_cache_alloc+76/280] kmem_cache_alloc+0x4c/0x118
 [nfs_alloc_inode+19/64] nfs_alloc_inode+0x13/0x40
 [alloc_inode+22/332] alloc_inode+0x16/0x14c
 [get_new_inode+18/196] get_new_inode+0x12/0xc4
 [iget5_locked+125/136] iget5_locked+0x7d/0x88
 [nfs_find_actor+0/176] nfs_find_actor+0x0/0xb0
 [nfs_init_locked+0/60] nfs_init_locked+0x0/0x3c
 [__nfs_fhget+95/808] __nfs_fhget+0x5f/0x328
 [nfs_find_actor+0/176] nfs_find_actor+0x0/0xb0
 [nfs_init_locked+0/60] nfs_init_locked+0x0/0x3c
 [nfs_fhget+67/76] nfs_fhget+0x43/0x4c
 [nfs_instantiate+87/172] nfs_instantiate+0x57/0xac
 [nfs_symlink+325/432] nfs_symlink+0x145/0x1b0
 [call_timeout+32/264] call_timeout+0x20/0x108
 [nfs_permission+284/392] nfs_permission+0x11c/0x188
 [permission+38/60] permission+0x26/0x3c
 [vfs_symlink+95/136] vfs_symlink+0x5f/0x88
 [sys_symlink+121/204] sys_symlink+0x79/0xcc
 [syscall_call+7/11] syscall_call+0x7/0xb

Code: 0f 0b a5 06 87 8a 38 c0 89 f6 85 c0 7c 04 39 d8 72 08 0f 0b
===========================
kernel BUG at mm/slab.c:1702!
invalid operand: 0000 [#1]
CPU:    0
EIP:    0060:[cache_alloc_refill+276/720]    Not tainted
EFLAGS: 00010086
EIP is at cache_alloc_refill+0x114/0x2d0
eax: cfdb875c   ebx: 00000006   ecx: cfdb1eac   edx: cfdb1ec4
esi: 00000002   edi: 00000007   ebp: c345fcd8   esp: c345fca4
ds: 007b   es: 007b   ss: 0068
Process fsstress (pid: 15862, threadinfo=c345e000 task=c7ce59c0)
Stack: 00000000 cfdb1e98 00000286 cfdb0958 00000006 cfdb1eac 00000006
cfdb1ea4
       cfdb1ea4 cfdb1eac 00000000 cfdb1ec4 cfdb0948 c345fcfc c0130ea4
cfdb1e98
       000000d0 00000000 cf034b80 cfe8c080 c0426bb0 c345fd1c c345fd0c
c019719b
Call Trace:
 [kmem_cache_alloc+76/280] kmem_cache_alloc+0x4c/0x118
 [nfs_alloc_inode+19/64] nfs_alloc_inode+0x13/0x40
 [alloc_inode+22/332] alloc_inode+0x16/0x14c
 [get_new_inode+18/196] get_new_inode+0x12/0xc4
 [iget5_locked+125/136] iget5_locked+0x7d/0x88
 [nfs_find_actor+0/176] nfs_find_actor+0x0/0xb0
 [nfs_init_locked+0/60] nfs_init_locked+0x0/0x3c
 [__nfs_fhget+95/808] __nfs_fhget+0x5f/0x328
 [nfs_find_actor+0/176] nfs_find_actor+0x0/0xb0
 [nfs_init_locked+0/60] nfs_init_locked+0x0/0x3c
 [nfs_fhget+67/76] nfs_fhget+0x43/0x4c
 [nfs_instantiate+87/172] nfs_instantiate+0x57/0xac
 [nfs_mknod+172/232] nfs_mknod+0xac/0xe8
 [parse_rock_ridge_inode_internal+696/1504]
parse_rock_ridge_inode_internal+0x2b8/0x5e0
 [nfs_permission+354/392] nfs_permission+0x162/0x188
 [permission+38/60] permission+0x26/0x3c
 [vfs_mknod+166/208] vfs_mknod+0xa6/0xd0
 [sys_mknod+283/372] sys_mknod+0x11b/0x174
 [syscall_call+7/11] syscall_call+0x7/0xb

Code: 0f 0b a6 06 87 8a 38 c0 8b 55 f8 8b 04 82 83 f8 ff 75 d5 8b
===========================


Steps to reproduce: See the http://ltp.sf.net/nfs for the test plan and
location of the test, fsstress, that produces the random file i/o related
system calls.  I'm thinking this may be an NFS issue, rather than slab, so
I
decided to start here first.

-Robbie

Robert V. Williamson <robbiew@us.ibm.com>
Linux Test Project
IBM Linux Technology Center
Web: http://ltp.sourceforge.net
IRC: #ltp on freenode.irc.net
====================
"Only two things are infinite, the universe and human stupidity, and I'm
not sure about the former." -Albert Einstein




-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
