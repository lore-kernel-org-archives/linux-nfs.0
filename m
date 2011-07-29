Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:34222 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615Ab1G2SyJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2011 14:54:09 -0400
Date: Fri, 29 Jul 2011 14:54:15 -0400
From: Jim Rees <rees@umich.edu>
To: Christoph Hellwig <hch@infradead.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH v4 00/27] add block layout driver to pnfs client
Message-ID: <20110729185415.GA23061@merit.edu>
References: <1311874276-1386-1-git-send-email-rees@umich.edu>
 <20110729155136.GB28306@infradead.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110729155136.GB28306@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Christoph Hellwig wrote:

  How well is the I/O code tested?  It's a full reimplementation of
  code full of nasty traps.  Did you run xfstests over it?  It supports
  nfs, so pointing it to a pnfs share should probably just work.

The current version of the code has been tested with Connectathon and
iozone.  Previous versions have been tested with the above plus various
other test suites and everyday use like kernel builds.

xfstests does require a small patch to work with NFSv4, which I can supply
if anyone is interested.

I can't test the current code with xfstests because NFS 4.1 without pnfs
doesn't pass these tests.  Here is what I get (test with block layout is
similar but without the hung task):

rhcl1# ./check -nfs
FSTYP         -- nfs
PLATFORM      -- Linux/x86_64 rhcl1 3.0.0-blk

001      - output mismatch (see 001.out.bad)
--- 001.out     2011-07-29 12:11:34.057245055 -0400
+++ 001.out.bad 2011-07-29 14:41:36.697152750 -0400
@@ -1,9 +1,4 @@
 QA output created by 001
 cleanup
-setup ....................................
-iter 1 chain ... check ....................................
-iter 2 chain ... check ....................................
-iter 3 chain ... check ....................................
-iter 4 chain ... check ....................................
-iter 5 chain ... check ....................................
+001 not run: this test requires a valid host fs for $SCRATCH_DEV
 cleanup
002      [not run] this test requires a valid host fs for $SCRATCH_DEV
003      [not run] not suitable for this filesystem type: nfs
004      [not run] not suitable for this filesystem type: nfs
005      [not run] this test requires a valid host fs for $SCRATCH_DEV
006      [not run] this test requires a valid host fs for $SCRATCH_DEV
007      [not run] this test requires a valid host fs for $SCRATCH_DEV
008      [not run] not suitable for this filesystem type: nfs
009      [not run] not suitable for this filesystem type: nfs
010      [not run] dbtest was not built for this platform
011      [not run] this test requires a valid host fs for $SCRATCH_DEV
012      [not run] not suitable for this filesystem type: nfs
013      [not run] this test requires a valid host fs for $SCRATCH_DEV
014      [not run] this test requires a valid host fs for $SCRATCH_DEV
015      [not run] not suitable for this filesystem type: nfs
016      [not run] not suitable for this filesystem type: nfs
017      [not run] not suitable for this filesystem type: nfs
018      [not run] not suitable for this filesystem type: nfs
019      [not run] not suitable for this filesystem type: nfs
020      [not run] not suitable for this filesystem type: nfs
021      [not run] not suitable for this filesystem type: nfs
022      [not run] xfsdump not found
023      [not run] xfsdump not found
024      [not run] xfsdump not found
025      [not run] xfsdump not found
026      [not run] xfsdump not found
027      [not run] xfsdump not found
028      [not run] xfsdump not found
029      [not run] not suitable for this filesystem type: nfs
030      [not run] not suitable for this filesystem type: nfs
031      [not run] not suitable for this filesystem type: nfs
032      [not run] not suitable for this filesystem type: nfs
033      [not run] not suitable for this filesystem type: nfs
034      [not run] not suitable for this filesystem type: nfs
035      [not run] xfsdump not found
036      [not run] xfsdump not found
037      [not run] xfsdump not found
038      [not run] xfsdump not found
039      [not run] xfsdump not found
040      [not run] Can't run srcdiff without KWORKAREA set
041      [not run] not suitable for this filesystem type: nfs
042      [not run] not suitable for this filesystem type: nfs
043      [not run] xfsdump not found
044      [not run] not suitable for this filesystem type: nfs
045      [not run] not suitable for this filesystem type: nfs
046      [not run] xfsdump not found
047      [not run] xfsdump not found
048      [not run] not suitable for this filesystem type: nfs
049      [not run] not suitable for this filesystem type: nfs
050      [not run] not suitable for this filesystem type: nfs
051      [not run] not suitable for this filesystem type: nfs
052      [not run] not suitable for this filesystem type: nfs
053      [not run] this test requires a valid $SCRATCH_DEV
054      [not run] not suitable for this filesystem type: nfs
055      [not run] xfsdump not found
056      [not run] xfsdump not found
057      [not run] Place holder for IRIX test 057
058      [not run] Place holder for IRIX test 058
059      [not run] Place holder for IRIX test 059
060      [not run] Place holder for IRIX test 060
061      [not run] xfsdump not found
062      [not run] this test requires a valid $SCRATCH_DEV
063      [not run] xfsdump not found
064      [not run] xfsdump not found
065      [not run] xfsdump not found
066      [not run] xfsdump not found
067      [not run] not suitable for this filesystem type: nfs
068      [not run] not suitable for this filesystem type: nfs
069      [not run] this test requires a valid $SCRATCH_DEV
070      [not run] attrs not supported by this filesystem type: nfs
071      [not run] not suitable for this filesystem type: nfs
072      [not run] not suitable for this filesystem type: nfs
073      [not run] not suitable for this filesystem type: nfs
074      [not run] this test requires a valid host fs for $SCRATCH_DEV
075      [not run] this test requires a valid host fs for $SCRATCH_DEV
076      [not run] this test requires a valid $SCRATCH_DEV
077      [not run] attrs not supported by this filesystem type: nfs
078      [not run] not suitable for this filesystem type: nfs
079      [not run] not suitable for this filesystem type: nfs
080      [not run] not suitable for this filesystem type: nfs
081      [not run] not suitable for this filesystem type: nfs
082      [not run] not suitable for this filesystem type: nfs
083      [not run] not suitable for this filesystem type: nfs
084      [not run] not suitable for this filesystem type: nfs
085      [not run] not suitable for this filesystem type: nfs
086      [not run] not suitable for this filesystem type: nfs
087      [not run] not suitable for this filesystem type: nfs
088      - output mismatch (see 088.out.bad)
--- 088.out     2011-07-29 12:11:34.085247833 -0400
+++ 088.out.bad 2011-07-29 14:41:48.336307595 -0400
@@ -1,9 +1,2 @@
 QA output created by 088
-access(TEST_DIR/t_access, 0) returns 0
-access(TEST_DIR/t_access, R_OK) returns 0
-access(TEST_DIR/t_access, W_OK) returns 0
-access(TEST_DIR/t_access, X_OK) returns -1
-access(TEST_DIR/t_access, R_OK | W_OK) returns 0
-access(TEST_DIR/t_access, R_OK | X_OK) returns -1
-access(TEST_DIR/t_access, W_OK | X_OK) returns -1
-access(TEST_DIR/t_access, R_OK | W_OK | X_OK) returns -1
+fchown: Invalid argument
089
Message from syslogd@rhcl1 at Jul 29 14:42:05 ...
 kernel:------------[ cut here ]------------

Message from syslogd@rhcl1 at Jul 29 14:42:05 ...
 kernel:invalid opcode: 0000 [#1] SMP 

Message from syslogd@rhcl1 at Jul 29 14:42:05 ...
 kernel:Stack:

Message from syslogd@rhcl1 at Jul 29 14:42:05 ...
 kernel:Call Trace:

Message from syslogd@rhcl1 at Jul 29 14:42:05 ...
 kernel:Code: 48 89 e5 53 41 52 48 8b 9f a8 02 00 00 48 8d bb 88 01 00 00 e8 23 39 19 e1 8b 83 5c 02 00 00 ff c0 85 c0 89 83 5c 02 00 00 74 02 <0f> 0b 66 ff 83 88 01 00 00 41 59 5b 5d c3 55 48 89 e5 41 57 41 

INFO: task t_mtab:13810 blocked for more than 10 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
t_mtab          D 0000000000000000     0 13810  13684 0x00000080
 ffff880037b05c38 0000000000000086 ffff88007ae46dc8 ffff880000000000
 ffff88007b02ae00 ffff880037b05fd8 ffff880037b05fd8 0000000000012c40
 ffffffff81a0c020 ffff88007b02ae00 ffff880037b05c38 ffffffffa0281a2f
Call Trace:
 [<ffffffffa0281a2f>] ? __put_nfs_open_context+0x35/0xad [nfs]
 [<ffffffff8143b623>] __mutex_lock_common+0xfd/0x15e
 [<ffffffff8143b799>] __mutex_lock_slowpath+0x16/0x18
 [<ffffffff8143b737>] mutex_lock+0x1e/0x32
 [<ffffffff811082fd>] ? walk_component+0x36d/0x3b1
 [<ffffffff811d738c>] ima_file_check+0x53/0x119
 [<ffffffff81109c2d>] do_last+0x44d/0x57c
 [<ffffffff81108bf6>] ? path_init+0x196/0x29d
 [<ffffffff8110a6e3>] path_openat+0xca/0x30b
 [<ffffffff8109a316>] ? call_rcu_sched+0x10/0x12
 [<ffffffff8110a972>] do_filp_open+0x33/0x81
 [<ffffffff8143af5c>] ? _cond_resched+0x9/0x1d
 [<ffffffff81113920>] ? alloc_fd+0x6d/0x118
 [<ffffffff810fe69b>] do_sys_open+0x69/0xfb
 [<ffffffff810907f2>] ? audit_syscall_entry+0x140/0x16c
 [<ffffffff810fe748>] sys_open+0x1b/0x1d
 [<ffffffff81442592>] system_call_fastpath+0x16/0x1b
INFO: task t_mtab:13812 blocked for more than 10 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
t_mtab          D ffff88007b291c00     0 13812  13684 0x00000080
 ffff880037d97c88 0000000000000082 ffff880037f099d8 ffff88007ae46dc8
 ffff880037b81700 ffff880037d97fd8 ffff880037d97fd8 0000000000012c40
 ffff88007b02ae00 ffff880037b81700 ffff880037d97c58 ffffffffa01ffa64
Call Trace:
 [<ffffffffa01ffa64>] ? generic_lookup_cred+0x10/0x12 [sunrpc]
 [<ffffffff8143b623>] __mutex_lock_common+0xfd/0x15e
 [<ffffffff8143b799>] __mutex_lock_slowpath+0x16/0x18
 [<ffffffff8143b737>] mutex_lock+0x1e/0x32
 [<ffffffff81107a9c>] ? audit_inode+0x15/0x28
 [<ffffffff8110998f>] do_last+0x1af/0x57c
 [<ffffffff81108bf6>] ? path_init+0x196/0x29d
 [<ffffffff8110a6e3>] path_openat+0xca/0x30b
 [<ffffffffa02a545b>] ? __nfs4_close+0xfc/0x108 [nfs]
 [<ffffffff8110a972>] do_filp_open+0x33/0x81
 [<ffffffff8143af5c>] ? _cond_resched+0x9/0x1d
 [<ffffffff81113920>] ? alloc_fd+0x6d/0x118
 [<ffffffff810fe69b>] do_sys_open+0x69/0xfb
 [<ffffffff810907f2>] ? audit_syscall_entry+0x140/0x16c
 [<ffffffff810fe748>] sys_open+0x1b/0x1d
 [<ffffffff81442592>] system_call_fastpath+0x16/0x1b
------------[ cut here ]------------
kernel BUG at /home/rees/linux-pnfs/fs/nfs/callback_xdr.c:775!
invalid opcode: 0000 [#1] SMP 
CPU 0 
Modules linked in: blocklayoutdriver nfs lockd fscache auth_rpcgss nfs_acl sunrpc cpufreq_ondemand powernow_k8 freq_table mperf be2iscsi iscsi_boot_sysfs bnx2i cnic uio cxgb3i libcxgbi cxgb3 mdio ip6t_REJECT ib_iser rdma_cm ib_cm nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter iw_cm ib_sa ib_mad ip6_tables ib_core ib_addr iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi serio_raw amd64_edac_mod pcspkr tg3 i2c_nforce2 i2c_core edac_core edac_mce_amd shpchp k8temp ipv6 autofs4 mptspi ata_generic mptscsih pata_acpi mptbase scsi_transport_spi sata_nv pata_amd [last unloaded: scsi_wait_scan]

Pid: 1503, comm: nfsv4.1-svc Not tainted 3.0.0-blk #35 HP ProLiant DL145 G2/K85NL
RIP: 0010:[<ffffffffa02a89c2>]  [<ffffffffa02a89c2>] nfs4_cb_take_slot+0x2c/0x3a [nfs]
RSP: 0018:ffff880037f89c00  EFLAGS: 00010286
RAX: 00000000ffffffff RBX: ffff88006b7ffc00 RCX: 0000000000000001
RDX: 0000000000000004 RSI: ffff88006b48da40 RDI: ffff88006b7ffd88
RBP: ffff880037f89c10 R08: 0000000000000000 R09: ffff880071a01db8
R10: ffff880071a01ca8 R11: ffff880037f89e40 R12: ffff88006bbb9800
R13: 0000000000000000 R14: ffff88006b716800 R15: ffff88006b7fec00
FS:  00007f78a8d7d720(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000003ff9064c60 CR3: 000000006b341000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process nfsv4.1-svc (pid: 1503, threadinfo ffff880037f88000, task ffff88007b060000)
Stack:
 ffff880071a01ca8 ffff88006b716800 ffff880037f89ca0 ffffffffa02a942f
 ffff88006b716800 ffff880071f33098 ffff880037f89ca0 ffff88006b48da40
 0000000137f89c50 ffff88006b716808 ffff88006b7ffc58 ffff880037f89d60
Call Trace:
 [<ffffffffa02a942f>] nfs4_callback_sequence+0x264/0x32c [nfs]
 [<ffffffffa02a80f9>] nfs4_callback_compound+0x36a/0x4e5 [nfs]
 [<ffffffffa01fff27>] svc_process_common+0x253/0x4d0 [sunrpc]
 [<ffffffffa0200279>] bc_svc_process+0xd5/0xfe [sunrpc]
 [<ffffffffa02a74b3>] nfs41_callback_svc+0xd5/0x126 [nfs]
 [<ffffffff81063928>] ? remove_wait_queue+0x35/0x35
 [<ffffffffa02a73de>] ? param_set_portnr+0x47/0x47 [nfs]
 [<ffffffff8106328a>] kthread+0x7f/0x87
 [<ffffffff81444714>] kernel_thread_helper+0x4/0x10
 [<ffffffff8106320b>] ? kthread_worker_fn+0x143/0x143
 [<ffffffff81444710>] ? gs_change+0x13/0x13
Code: 48 89 e5 53 41 52 48 8b 9f a8 02 00 00 48 8d bb 88 01 00 00 e8 23 39 19 e1 8b 83 5c 02 00 00 ff c0 85 c0 89 83 5c 02 00 00 74 02 <0f> 0b 66 ff 83 88 01 00 00 41 59 5b 5d c3 55 48 89 e5 41 57 41 
RIP  [<ffffffffa02a89c2>] nfs4_cb_take_slot+0x2c/0x3a [nfs]
 RSP <ffff880037f89c00>
---[ end trace 76c6d9f5d46ae22e ]---
Callback slot table overflowed
