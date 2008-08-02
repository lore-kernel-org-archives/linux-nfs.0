From: Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>
Subject: 2.6.26 stable kernel crash with NFS exporting a XFS share
Date: Sat, 02 Aug 2008 12:47:38 +1000
Message-ID: <4893CACA.1060605@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040907010807080908010302"
To: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from tone.orchestra.cse.unsw.EDU.AU ([129.94.242.59]:54952 "EHLO
	tone.orchestra.cse.unsw.EDU.AU" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751609AbYHBDCx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Aug 2008 23:02:53 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040907010807080908010302
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi All

Please see the attached text file which contains
details of a crash I observed recently while
running some tests against Linux nfsd with
XFS as the file system. Details are all there in
the file.


-Shehjar

--------------040907010807080908010302
Content-Type: text/plain;
 name="nfsd_xfs_crash_2.6.26.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfsd_xfs_crash_2.6.26.txt"

Kernel 2.6.26 stable on both client and server
sunrpc.tcp_slot_table_entries=96
NFS wsize=32k
Server file system = XFS over software raid0 w/ 3 10k RPM SAS disks
nfsd threads = 512
Gbit network w/ Jumbo frames
Workload:
Iozone 1-20 writer processes
write() syscall record/buffer size= 50Megs
File size = 500Megs
Server machine is a 2xDual Core Itanium 2 with 8Gigs of RAM, so in theory, maximum memory pressure
will be for (500Megs * 20 Processes)
Client machine is a 4xDual Core Itanium 2 with 16Gigs of RAM.


Remarks:
1. The crash is preceded by hundreds of lines which look like this:
Filesystem "md0": Access to block zero in inode 271 start_block: 0 start_off: 0 blkcnt: 0 extent-   state: 0 lastx: fa

2. Cannot be reproduced on every run of the above workload. Disk corruption?


The stack trace:
================
Unable to handle kernel paging request at virtual address 000000000153e1ff
nfsd[10703]: Oops 11012296146944 [1]

Pid: 10703, CPU 1, comm:                 nfsd
psr : 00001210085a2010 ifs : 800000000000038c ip  : [<a000000100149551>]    Not tainted (2.6.26)
ip is at __kmalloc+0x131/0x220
unat: 0000000000000000 pfs : 000000000000038c rsc : 0000000000000003
rnat: a0000001004c0780 bsps: a0000001001a8060 pr  : 666a96a6a5996665
ldrs: 0000000000000000 ccv : 0000000000000002 fpsr: 0009804c8a70433f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001001494c0 b6  : a0000001004c0780 b7  : a0000001003b4520
f6  : 0fff7810204080f809f84 f7  : 0ffdf9d24f78a00000000
f8  : 10006fe00000000000000 f9  : 10006fe00000000000000
f10 : 0fffefffffffffec33c8a f11 : 1003e0000000000000001
r1  : a0000001011f1c80 r2  : 0000000000508040 r3  : e0000001951b8014
r8  : a000000100f26060 r9  : e000000100015c18 r10 : a000000100f26150
r11 : 000000000000001d r12 : e0000001951bf8b0 r13 : e0000001951b8000
r14 : 00000000000000c0 r15 : a000000100f26068 r16 : 0000000000000001
r17 : 0000000000000001 r18 : e0000001951b8c04 r19 : a000000100ff21f0
r20 : 000000000153e1ff r21 : 0000000000000000 r22 : e000000100015c14
r23 : 0000000000000000 r24 : 00000000000000ff r25 : 000000000000000e
r26 : e000010040919a72 r27 : 0000000000000000 r28 : 0000000000000100
r29 : 0000000000000101 r30 : e0000001551e93ec r31 : 000ffffffffe0000

Call Trace:
 [<a000000100014090>] show_stack+0x50/0xa0
                                sp=e0000001951bf480 bsp=e0000001951b9bc0
 [<a0000001000148e0>] show_regs+0x800/0x840
                                sp=e0000001951bf650 bsp=e0000001951b9b68
 [<a000000100038ca0>] die+0x1a0/0x2c0
                                sp=e0000001951bf650 bsp=e0000001951b9b28
 [<a00000010005a5d0>] ia64_do_page_fault+0x8b0/0x9e0
                                sp=e0000001951bf650 bsp=e0000001951b9ad8
 [<a00000010000b140>] ia64_leave_kernel+0x0/0x270
                                sp=e0000001951bf6e0 bsp=e0000001951b9ad8
 [<a000000100149550>] __kmalloc+0x130/0x220
                                sp=e0000001951bf8b0 bsp=e0000001951b9a78
 [<a0000001004b49a0>] kmem_alloc+0x140/0x2a0
                                sp=e0000001951bf8b0 bsp=e0000001951b9a38
 [<a00000010046f400>] xfs_iext_add_indirect_multi+0xa0/0x440
                                sp=e0000001951bf8b0 bsp=e0000001951b99c0
 [<a000000100471d80>] xfs_iext_add+0x3e0/0x4a0
                                sp=e0000001951bf8b0 bsp=e0000001951b9968
 [<a000000100471e70>] xfs_iext_insert+0x30/0xc0
                                sp=e0000001951bf8c0 bsp=e0000001951b9930
 [<a000000100426560>] xfs_bmap_add_extent_hole_delay+0x6e0/0x7c0
                                sp=e0000001951bf8c0 bsp=e0000001951b98b0
 [<a00000010042af60>] xfs_bmap_add_extent+0x2a0/0x7a0
                                sp=e0000001951bf900 bsp=e0000001951b9820
 [<a000000100432300>] xfs_bmapi+0x1020/0x1c40
                                sp=e0000001951bf950 bsp=e0000001951b95a0
 [<a00000010047db60>] xfs_iomap_write_delay+0x2e0/0x400
                                sp=e0000001951bfa20 bsp=e0000001951b94a8
 [<a00000010047e000>] xfs_iomap+0x380/0x520
                                sp=e0000001951bfaf0 bsp=e0000001951b9448
 [<a0000001004b5ac0>] __xfs_get_blocks+0xc0/0x560
                                sp=e0000001951bfb40 bsp=e0000001951b93e8
 [<a0000001004b6000>] xfs_get_blocks+0x40/0x60
                                sp=e0000001951bfb80 bsp=e0000001951b93b0
 [<a0000001001ab4c0>] __block_prepare_write+0x400/0xa80
                                sp=e0000001951bfb80 bsp=e0000001951b92d0
 [<a0000001001abea0>] block_write_begin+0x100/0x1e0
                                sp=e0000001951bfba0 bsp=e0000001951b9260
 [<a0000001004b8b30>] xfs_vm_write_begin+0x50/0x80
                                sp=e0000001951bfba0 bsp=e0000001951b9210
 [<a0000001000f3df0>] generic_file_buffered_write+0x1d0/0xe00
                                sp=e0000001951bfba0 bsp=e0000001951b9108
 [<a0000001004c8c10>] xfs_write+0x910/0xd80
                                sp=e0000001951bfbd0 bsp=e0000001951b8fc8
 [<a0000001004c0230>] xfs_file_aio_write+0xf0/0x120
                                sp=e0000001951bfc20 bsp=e0000001951b8f90
 [<a000000100150100>] do_sync_readv_writev+0x140/0x1c0
                                sp=e0000001951bfc20 bsp=e0000001951b8f40
 [<a000000100151080>] do_readv_writev+0x160/0x280
                                sp=e0000001951bfd10 bsp=e0000001951b8ef0
 [<a000000100151260>] vfs_writev+0xc0/0x100
                                sp=e0000001951bfda0 bsp=e0000001951b8eb8
 [<a0000001003a3080>] nfsd_vfs_write+0x200/0x660
                                sp=e0000001951bfda0 bsp=e0000001951b8e48
 [<a0000001003a4800>] nfsd_write+0x140/0x1a0
                                sp=e0000001951bfe00 bsp=e0000001951b8de8
 [<a0000001003b46d0>] nfsd3_proc_write+0x1b0/0x200
                                sp=e0000001951bfe10 bsp=e0000001951b8db0
 [<a000000100398aa0>] nfsd_dispatch+0x220/0x4c0
                                sp=e0000001951bfe10 bsp=e0000001951b8d70
 [<a000000100b768f0>] svc_process+0xc30/0x1b40
                                sp=e0000001951bfe10 bsp=e0000001951b8d18
 [<a000000100399850>] nfsd+0x350/0x600
                                sp=e0000001951bfe20 bsp=e0000001951b8c88
 [<a000000100012250>] kernel_thread_helper+0xd0/0x100
                                sp=e0000001951bfe30 bsp=e0000001951b8c60
 [<a0000001000091a0>] start_kernel_thread+0x20/0x40
                                sp=e0000001951bfe30 bsp=e0000001951b8c60


--------------040907010807080908010302--
