Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:32999 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753538Ab1C2PGh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Mar 2011 11:06:37 -0400
Subject: Re: NFS v4 client blocks when using UDP protocol
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4D91ED79.4020302@bull.net>
Date: Tue, 29 Mar 2011 11:06:30 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <4A05F533-1BE6-4DFC-BC53-9392DA8BED76@oracle.com>
References: <EB0F26AF-C0DB-4861-ABB5-72E39CB38090@bull.net> <4D91ED79.4020302@bull.net>
To: Menyhart Zoltan <Zoltan.Menyhart@bull.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Zoltan-

As far as I know, NFSv4 is not supported on UDP transports.  Some of it may work, but no warrantee, either expressed or implied, is given.  :-)

On Mar 29, 2011, at 10:32 AM, Menyhart Zoltan wrote:

> Hi,
> 
> NFS v4 client blocks under heavy load, when using UDP protocol.
> No progress can be seen, the test program "iozone" cannot be killed.
> 
> "nfsiostat 10 -p" reports 2 "nfs_writepages()" calls on every 10 seconds:
> 
> server:/ mounted on /mnt/test:
>   op/s		rpc bklog
>   0.00 	   0.00
> read:             ops/s		   kB/s		  kB/op		retrans		avg RTT (ms)	avg exe (ms)
> 		  0.000 	  0.000 	  0.000        0 (0.0%) 	  0.000 	  0.000
> write:            ops/s		   kB/s		  kB/op		retrans		avg RTT (ms)	avg exe (ms)
> 		  0.000 	  0.000 	  0.000        0 (0.0%) 	  0.000 	  0.000
> 0 nfs_readpage() calls read 0 pages
> 0 nfs_readpages() calls read 0 pages
> 0 nfs_updatepage() calls
> 0 nfs_writepage() calls wrote 0 pages
> 2 nfs_writepages() calls wrote 0 pages (0.0 pages per call)
> 
> Checking the test program with the "crash" reports:
> 
> PID: 6185   TASK: ffff8804047020c0  CPU: 0   COMMAND: "iozone"
> #0 [ffff88036ce638b8] schedule at ffffffff814d9459
> #1 [ffff88036ce63980] schedule_timeout at ffffffff814da152
> #2 [ffff88036ce63a30] io_schedule_timeout at ffffffff814d8f2f
> #3 [ffff88036ce63a60] balance_dirty_pages at ffffffff811213d1
> #4 [ffff88036ce63b80] balance_dirty_pages_ratelimited_nr at ffffffff811217e4
> #5 [ffff88036ce63b90] generic_file_buffered_write at ffffffff8110d993
> #6 [ffff88036ce63c60] __generic_file_aio_write at ffffffff8110f230
> #7 [ffff88036ce63d20] generic_file_aio_write at ffffffff8110f4cf
> #8 [ffff88036ce63d70] nfs_file_write at ffffffffa05e4c2e
> #9 [ffff88036ce63dc0] do_sync_write at ffffffff81170bda
> #10 [ffff88036ce63ef0] vfs_write at ffffffff81170ed8
> #11 [ffff88036ce63f30] sys_write at ffffffff81171911
> #12 [ffff88036ce63f80] system_call_fastpath at ffffffff8100b172
>    RIP: 0000003709a0e490  RSP: 00007fffba8eac78  RFLAGS: 00000246
>    RAX: 0000000000000001  RBX: ffffffff8100b172  RCX: 0000003709a0ec10
>    RDX: 0000000000400000  RSI: 00007fe469600000  RDI: 0000000000000003
>    RBP: 0000000000000298   R8: 0000000000000000   R9: 0000000000000000
>    R10: 0000000000000000  R11: 0000000000000246  R12: 00007fe469600000
>    R13: 0000000000eb4c20  R14: 0000000000400000  R15: 0000000000eb4c20
>    ORIG_RAX: 0000000000000001  CS: 0033  SS: 002b
> 
> No activity can be seen with wireshark on the network.
> Rebooting the client and restarting the test can show another failing point:
> 
> PID: 4723   TASK: ffff8803fc235580  CPU: 2   COMMAND: "iozone"
> #0 [ffff880417e2dc08] schedule at ffffffff814d9459
> #1 [ffff880417e2dcd0] io_schedule at ffffffff814d9c43
> #2 [ffff880417e2dcf0] sync_page at ffffffff8110d01d
> #3 [ffff880417e2dd00] __wait_on_bit at ffffffff814da4af
> #4 [ffff880417e2dd50] wait_on_page_bit at ffffffff8110d1d3
> #5 [ffff880417e2ddb0] wait_on_page_writeback_range at ffffffff8110d5eb
> #6 [ffff880417e2deb0] filemap_write_and_wait_range at ffffffff8110d7b8
> #7 [ffff880417e2dee0] vfs_fsync_range at ffffffff8119f11e
> #8 [ffff880417e2df30] vfs_fsync at ffffffff8119f1ed
> #9 [ffff880417e2df40] do_fsync at ffffffff8119f22e
> #10 [ffff880417e2df70] sys_fsync at ffffffff8119f280
> #11 [ffff880417e2df80] system_call_fastpath at ffffffff8100b172
>    RIP: 0000003709a0ebb0  RSP: 00007fff5517dc28  RFLAGS: 00000212
>    RAX: 000000000000004a  RBX: ffffffff8100b172  RCX: 00000000000000ef
>    RDX: 0000000000000000  RSI: 0000000000000000  RDI: 0000000000000003
>    RBP: 0000000000008000   R8: 00000000ffffffff   R9: 0000000000000000
>    R10: 0000000000000000  R11: 0000000000000246  R12: ffffffff8119f280
>    R13: ffff880417e2df78  R14: 00000000011d7c30  R15: 0000000000000000
>    ORIG_RAX: 000000000000004a  CS: 0033  SS: 002b
> 
> Sometimes console messages appear, like:
> 
> INFO: task iozone:4723 blocked for more than 120 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> iozone        D 0000000000000002     0  4723   4683 0x00000080
> ffff880417e2dcc8 0000000000000086 ffff880417e2dc48 ffffffffa042fc99
> ffff88036e53d440 ffff8803e386aac0 ffff880402cf4610 ffff88036e53d448
> ffff8803fc235b38 ffff880417e2dfd8 000000000000f558 ffff8803fc235b38
> Call Trace:
> [<ffffffffa042fc99>] ? rpc_run_task+0xd9/0x130 [sunrpc]
> [<ffffffff81098aa9>] ? ktime_get_ts+0xa9/0xe0
> [<ffffffff8110cfe0>] ? sync_page+0x0/0x50
> [<ffffffff814d9c43>] io_schedule+0x73/0xc0
> [<ffffffff8110d01d>] sync_page+0x3d/0x50
> [<ffffffff814da4af>] __wait_on_bit+0x5f/0x90
> [<ffffffff8110d1d3>] wait_on_page_bit+0x73/0x80
> [<ffffffff8108df40>] ? wake_bit_function+0x0/0x50
> [<ffffffff81122f25>] ? pagevec_lookup_tag+0x25/0x40
> [<ffffffff8110d5eb>] wait_on_page_writeback_range+0xfb/0x190
> [<ffffffff8110d7b8>] filemap_write_and_wait_range+0x78/0x90
> [<ffffffff8119f11e>] vfs_fsync_range+0x7e/0xe0
> [<ffffffff8119f1ed>] vfs_fsync+0x1d/0x20
> [<ffffffff8119f22e>] do_fsync+0x3e/0x60
> [<ffffffff8119f280>] sys_fsync+0x10/0x20
> [<ffffffff8100b172>] system_call_fastpath+0x16/0x1b
> 
> This problem can be systematically reproduced with the following test:
> 
> iozone -a -c -e -E -L 64 -m -S 4096 -f /mnt/test/file -g 20G -n 1M -y 4K
> 
> It can be reproduced with both type of networks we have, see below.
> 
> Switching on RPC debugging with "sysctl -w sunrpc.rpc_debug=65535" gives:
> 
> -pid- flgs status -client- --rqstp- -timeout ---ops--
> 28139 0001    -11 ffff88040f403400   (null)        0 ffffffffa06157e0 nfsv4 WRITE a:call_reserveresult q:xprt_backlog
> 29167 0001    -11 ffff88040f403400 ffff8803ff405130        0 ffffffffa06157e0 nfsv4 WRITE a:call_status q:xprt_resend
> 29172 0001    -11 ffff88040f403400   (null)        0 ffffffffa06157e0 nfsv4 WRITE a:call_reserveresult q:xprt_backlog
> ...
> 51364 0001    -11 ffff88040f403400   (null)        0 ffffffffa06157e0 nfsv4 WRITE a:call_reserveresult q:xprt_backlog
> 55355 0001    -11 ffff88040f403400 ffff8803ff405450        0 ffffffffa06157e0 nfsv4 WRITE a:call_status q:xprt_resend
> 55356 0001    -11 ffff88040f403400 ffff8803ff404000        0 ffffffffa06157e0 nfsv4 WRITE a:call_status q:xprt_resend
> 55357 0001    -11 ffff88040f403400 ffff8803ff404c80        0 ffffffffa06157e0 nfsv4 WRITE a:call_status q:xprt_resend
> 55369 0001    -11 ffff88040f403400 ffff8803ff4055e0        0 ffffffffa06157e0 nfsv4 WRITE a:call_status q:xprt_resend
> ...
> 55370 0001    -11 ffff88040f403400   (null)        0 ffffffffa06157e0 nfsv4 WRITE a:call_reserveresult q:xprt_backlog
> 55371 0001    -11 ffff88040f403400   (null)        0 ffffffffa06157e0 nfsv4 WRITE a:call_reserveresult q:xprt_backlog
> ...
> 
> No error messages in "dmesg" neither in "/var/log/messages" at the server side.
> 
> 
> Our test HW:
> 2 * Supermicro R460, 2 dual core Xeons 5150 2.66GHz in each machine
> InfiniBand Mellanox Technologies MT26418 in DDR mode, IP over IB
> Intel Corporation 80003ES2LAN Gigabit Ethernet Controller, point to point direct connection
> 
> SW:
> Kernels up to 2.6.38-rc8
> 
> 
> Server side:
> 
> A SW RAID "/dev/md0" mounted on "/md0" is exported:
> 
> /dev/md0:
>         Version : 0.90
>   Creation Time : Wed Feb 18 17:18:34 2009
>      Raid Level : raid0
>      Array Size : 357423360 (340.87 GiB 366.00 GB)
>    Raid Devices : 5
>   Total Devices : 5
> Preferred Minor : 0
>     Persistence : Superblock is persistent
>     Update Time : Wed Feb 18 17:18:34 2009
>           State : clean
>  Active Devices : 5
> Working Devices : 5
>  Failed Devices : 0
>   Spare Devices : 0
>      Chunk Size : 256K
>            UUID : 05fae940:c7540b1e:d0f324d8:8f753e72
>          Events : 0.1
> 
>     Number   Major   Minor   RaidDevice State
>        0       8       16        0      active sync   /dev/sdb
>        1       8       32        1      active sync   /dev/sdc
>        2       8       48        2      active sync   /dev/sdd
>        3       8       64        3      active sync   /dev/sde
>        4       8       80        4      active sync   /dev/sdf
> 
> /etc/exports:
> /md0 *(rw,insecure,no_subtree_check,sync,fsid=0)
> 
> The client machine mounts it as follows:
> 
> mount -o async,udp 192.168.1.79:/ /mnt/test	# Ethernet
> or
> mount -o async,udp 192.168.42.79:/ /mnt/test	# IP over IB
> 
> 
> Have you already seen this problem?
> Thank you in advance,
> 
> Zoltan Menyhart
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




