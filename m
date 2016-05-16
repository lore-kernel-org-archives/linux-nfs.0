Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52576 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754149AbcEPTCw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 May 2016 15:02:52 -0400
Message-ID: <1463425370.5011.26.camel@redhat.com>
Subject: Re: blocked on the spin lock
From: Dave Wysochanski <dwysocha@redhat.com>
Reply-To: dwysocha@redhat.com
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Cc: Weston Andros Adamson <dros@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>,
        Andy Adamson <william.adamson@netapp.com>
Date: Mon, 16 May 2016 15:02:50 -0400
In-Reply-To: <148899538.11512158.1462174191227.JavaMail.zimbra@desy.de>
References: <148899538.11512158.1462174191227.JavaMail.zimbra@desy.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2016-05-02 at 09:29 +0200, Mkrtchyan, Tigran wrote:
> 
> Hi Dros et. al.
> 
> We have seen the following stack trace on one of out systems:
> 
> 
> Apr 28 22:09:51 bird510 kernel: BUG: soft lockup - CPU#7 stuck for 67s! [tee:13755]
> Apr 28 22:09:51 bird510 kernel: Modules linked in: ipmi_devintf dell_rbu nfs_layout_nfsv41_files fuse nfs lockd fscache auth_rpcgss nfs_acl vfat fat usb_storage mpt3sas mpt2sas raid_class mptctl openafs(P)(U) autofs4 sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf sg joy
> dev power_meter acpi_ipmi ipmi_si ipmi_msghandler iTCO_wdt iTCO_vendor_support bnx2 microcode dcdbas lpc_ich mfd_core i7core_edac edac_core shpchp ext4 jbd2 mbcache sd_mod crc_t10dif mptsas mptscsih mptbase scsi_transport_sas mlx4_ib ib_sa ib_mad ib_core ib_addr ipv6 mlx4_en p
> tp pps_core mlx4_core dm_mirror dm_region_hash dm_log dm_mod [last unloaded: ipmi_devintf]
> Apr 28 22:09:51 bird510 kernel: CPU 7
> Apr 28 22:09:51 bird510 kernel: Modules linked in: ipmi_devintf dell_rbu nfs_layout_nfsv41_files fuse nfs lockd fscache auth_rpcgss nfs_acl vfat fat usb_storage mpt3sas mpt2sas raid_class mptctl openafs(P)(U) autofs4 sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf sg joy
> dev power_meter acpi_ipmi ipmi_si ipmi_msghandler iTCO_wdt iTCO_vendor_support bnx2 microcode dcdbas lpc_ich mfd_core i7core_edac edac_core shpchp ext4 jbd2 mbcache sd_mod crc_t10dif mptsas mptscsih mptbase scsi_transport_sas mlx4_ib ib_sa ib_mad ib_core ib_addr ipv6 mlx4_en p
> tp pps_core mlx4_core dm_mirror dm_region_hash dm_log dm_mod [last unloaded: ipmi_devintf]
> Apr 28 22:09:51 bird510 kernel:
> Apr 28 22:09:51 bird510 kernel: Pid: 13755, comm: tee Tainted: P           -- ------------    2.6.32-573.12.1.el6.x86_64 #1 Dell Inc. PowerEdge M610/0N582M
> Apr 28 22:09:51 bird510 kernel: RIP: 0010:[<ffffffff8153bde1>]  [<ffffffff8153bde1>] _spin_lock+0x21/0x30
> Apr 28 22:09:51 bird510 kernel: RSP: 0018:ffff8803528179c8  EFLAGS: 00000297
> Apr 28 22:09:51 bird510 kernel: RAX: 00000000000003b1 RBX: ffff8803528179c8 RCX: 0000000000000000
> Apr 28 22:09:51 bird510 kernel: RDX: 00000000000003b0 RSI: ffff880159aeb820 RDI: ffff880159aeb8d0
> Apr 28 22:09:51 bird510 kernel: RBP: ffffffff8100bc0e R08: ffff880352817af0 R09: 0000000000000002
> Apr 28 22:09:51 bird510 kernel: R10: ffffea0008efc428 R11: 0000000000000003 R12: 0000000000000001
> Apr 28 22:09:51 bird510 kernel: R13: 001310facb5806bd R14: 0000000000000000 R15: 0000000000000000
> Apr 28 22:09:51 bird510 kernel: FS:  00007f3e78118700(0000) GS:ffff880028260000(0000) knlGS:0000000000000000
> Apr 28 22:09:51 bird510 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> Apr 28 22:09:51 bird510 kernel: CR2: 00007fefa21ff000 CR3: 0000000352959000 CR4: 00000000000007e0
> Apr 28 22:09:51 bird510 kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> Apr 28 22:09:51 bird510 kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Apr 28 22:09:51 bird510 kernel: Process tee (pid: 13755, threadinfo ffff880352814000, task ffff880636064ab0)
> Apr 28 22:09:51 bird510 kernel: Stack:
> Apr 28 22:09:51 bird510 kernel: ffff880352817a18 ffffffffa0490dc1 ffff880159aeb8d0 ffff880159aeb770
> Apr 28 22:09:51 bird510 kernel: <d> 0000000000000000 0000000000000000 ffffffffa04bd040 ffffffffa048f39a
> Apr 28 22:09:51 bird510 kernel: <d> ffff8803378761c0 ffffea000a13dcc0 ffff880352817a48 ffffffffa0490ec8
> Apr 28 22:09:51 bird510 kernel: Call Trace:
> Apr 28 22:09:51 bird510 kernel: [<ffffffffa0490dc1>] ? nfs_clear_request_commit+0xa1/0xf0 [nfs]
> Apr 28 22:09:51 bird510 kernel: [<ffffffffa048f39a>] ? nfs_page_find_request_locked+0x2a/0x40 [nfs]
> Apr 28 22:09:51 bird510 kernel: [<ffffffffa0490ec8>] ? nfs_wb_page_cancel+0xb8/0xf0 [nfs]
> Apr 28 22:09:51 bird510 kernel: [<ffffffffa047e4f7>] ? nfs_invalidate_page+0x47/0x80 [nfs]
> Apr 28 22:09:51 bird510 kernel: [<ffffffff8113edb5>] ? do_invalidatepage+0x25/0x30
> Apr 28 22:09:51 bird510 kernel: [<ffffffff8113f0d2>] ? truncate_inode_page+0xa2/0xc0
> Apr 28 22:09:51 bird510 kernel: [<ffffffff8113f47f>] ? truncate_inode_pages_range+0x16f/0x500
> Apr 28 22:09:51 bird510 kernel: [<ffffffff81129cd7>] ? mempool_free_slab+0x17/0x20
> Apr 28 22:09:51 bird510 kernel: [<ffffffff8113f8a5>] ? truncate_inode_pages+0x15/0x20
> Apr 28 22:09:51 bird510 kernel: [<ffffffff8113f8ff>] ? truncate_pagecache+0x4f/0x70
> Apr 28 22:09:51 bird510 kernel: [<ffffffffa0480eb9>] ? nfs_setattr_update_inode+0xb9/0x150 [nfs]
> Apr 28 22:09:51 bird510 kernel: [<ffffffffa0493a6b>] ? nfs3_proc_setattr+0xdb/0x120 [nfs]
> Apr 28 22:09:51 bird510 kernel: [<ffffffffa048f6b3>] ? nfs_wb_all+0x43/0x50 [nfs]
> Apr 28 22:09:51 bird510 kernel: [<ffffffffa0482610>] ? nfs_setattr+0xf0/0x170 [nfs]
> Apr 28 22:09:51 bird510 kernel: [<ffffffff811b1118>] ? notify_change+0x168/0x340
> Apr 28 22:09:51 bird510 kernel: [<ffffffffa0480de8>] ? nfs_open+0x78/0x90 [nfs]
> Apr 28 22:09:51 bird510 kernel: [<ffffffff8118fcb4>] ? do_truncate+0x64/0xa0
> Apr 28 22:09:51 bird510 kernel: [<ffffffff81232b9f>] ? security_inode_permission+0x1f/0x30
> Apr 28 22:09:51 bird510 kernel: [<ffffffff811a4fc1>] ? do_filp_open+0x861/0xd20
> Apr 28 22:09:51 bird510 kernel: [<ffffffff8129df8a>] ? strncpy_from_user+0x4a/0x90
> Apr 28 22:09:51 bird510 kernel: [<ffffffff811b1ff2>] ? alloc_fd+0x92/0x160
> Apr 28 22:09:51 bird510 kernel: [<ffffffff8118e967>] ? do_sys_open+0x67/0x130
> Apr 28 22:09:51 bird510 kernel: [<ffffffff8118ea70>] ? sys_open+0x20/0x30
> Apr 28 22:09:51 bird510 kernel: [<ffffffff8100b0d2>] ? system_call_fastpath+0x16/0x1b
> Apr 28 22:09:51 bird510 kernel: Code: 01 74 05 e8 52 1c d6 ff c9 c3 55 48 89 e5 0f 1f 44 00 00 b8 00 00 01 00 f0 0f c1 07 0f b7 d0 c1 e8 10 39 c2 74 0e f3 90 0f b7 17 <eb> f5 83 3f 00 75 f4 eb df c9 c3 0f 1f 40 00 55 48 89 e5 0f 1f
> Apr 28 22:09:51 bird510 kernel: Call Trace:
> Apr 28 22:09:51 bird510 kernel: [<ffffffffa0490dc1>] ? nfs_clear_request_commit+0xa1/0xf0 [nfs]
> Apr 28 22:09:51 bird510 kernel: [<ffffffffa048f39a>] ? nfs_page_find_request_locked+0x2a/0x40 [nfs]
> Apr 28 22:09:51 bird510 kernel: [<ffffffffa0490ec8>] ? nfs_wb_page_cancel+0xb8/0xf0 [nfs]
> Apr 28 22:09:51 bird510 kernel: [<ffffffffa047e4f7>] ? nfs_invalidate_page+0x47/0x80 [nfs]
> Apr 28 22:09:51 bird510 kernel: [<ffffffff8113edb5>] ? do_invalidatepage+0x25/0x30
> Apr 28 22:09:51 bird510 kernel: [<ffffffff8113f0d2>] ? truncate_inode_page+0xa2/0xc0
> Apr 28 22:09:51 bird510 kernel: [<ffffffff8113f47f>] ? truncate_inode_pages_range+0x16f/0x500
> Apr 28 22:09:51 bird510 kernel: [<ffffffff81129cd7>] ? mempool_free_slab+0x17/0x20
> Apr 28 22:09:51 bird510 kernel: [<ffffffff8113f8a5>] ? truncate_inode_pages+0x15/0x20
> Apr 28 22:09:51 bird510 kernel: [<ffffffff8113f8ff>] ? truncate_pagecache+0x4f/0x70
> Apr 28 22:09:51 bird510 kernel: [<ffffffffa0480eb9>] ? nfs_setattr_update_inode+0xb9/0x150 [nfs]
> Apr 28 22:09:51 bird510 kernel: [<ffffffffa0493a6b>] ? nfs3_proc_setattr+0xdb/0x120 [nfs]
> Apr 28 22:09:51 bird510 kernel: [<ffffffffa048f6b3>] ? nfs_wb_all+0x43/0x50 [nfs]
> Apr 28 22:09:51 bird510 kernel: [<ffffffffa0482610>] ? nfs_setattr+0xf0/0x170 [nfs]
> Apr 28 22:09:51 bird510 kernel: [<ffffffff811b1118>] ? notify_change+0x168/0x340
> Apr 28 22:09:51 bird510 kernel: [<ffffffffa0480de8>] ? nfs_open+0x78/0x90 [nfs]
> Apr 28 22:09:51 bird510 kernel: [<ffffffff8118fcb4>] ? do_truncate+0x64/0xa0
> Apr 28 22:09:51 bird510 kernel: [<ffffffff81232b9f>] ? security_inode_permission+0x1f/0x30
> Apr 28 22:09:51 bird510 kernel: [<ffffffff811a4fc1>] ? do_filp_open+0x861/0xd20
> Apr 28 22:09:51 bird510 kernel: [<ffffffff8129df8a>] ? strncpy_from_user+0x4a/0x90
> Apr 28 22:09:51 bird510 kernel: [<ffffffff811b1ff2>] ? alloc_fd+0x92/0x160
> Apr 28 22:09:51 bird510 kernel: [<ffffffff8118e967>] ? do_sys_open+0x67/0x130
> Apr 28 22:09:51 bird510 kernel: [<ffffffff8118ea70>] ? sys_open+0x20/0x30
> Apr 28 22:09:51 bird510 kernel: [<ffffffff8100b0d2>] ? system_call_fastpath+0x16/0x1b
> 
> 
> 
> 
> The questionable spin lock was remove by commit 411a99adf. Is there was a problem?
> Do we need a packport in RHEL kernel?
> 


This is a known bug 1322823.  It should be fixed in RHEL6.7
kernel-2.6.32-573.27.1.el6 or above as well as RHEL6.8
kernel-2.6.32-642.el6 or higher.  It only affects kernels
2.6.32-573.10.2.el6 until kernel-2.6.32-573.27.1.el6.  The bug is
private but see the description below.  

This bug was an unfortunate side-effect of a fix for another nasty bug
Bug 1135601 - System panics with "kernel BUG at fs/nfs/inode.c:113!
But 1135601 was fixed by a RHEL6 equivalent of the following upstream
patch: 3e21704 nfs: handle multiple reqs in nfs_wb_page_cancel

Saving &inode->i_lock in an NFS specific structure seems problematic
which maybe why it was missed in the backport, and partially removed in
commit 411a99adf.  I posted a related cleanup patch in this area
https://www.spinics.net/lists/linux-nfs/msg57194.html



Bug 1322823 - RHEL6.7.z: nfs client kernel deadlock due to inode->i_lock
== nfs_commit_info.lock in code path nfs_wb_page_cancel ->
nfs_clear_request_commit due to patch to fix bug 1135601

Dave Wysochanski 2016-03-31 07:50:18 EDT

Description of problem:
Repeated kernel deadlock hit multiple times by a customer, and caused by the current fix to bug 1135601.  Basically the NFS client / RPC deadlocks due to a spinlock being taken twice.  We have vmcores.

I think in the fix for 1135601 the following "finer point" of the NFS
client was missed:  So inode->i_lock == nfs_commit_info.lock?  If that's
true it may be ok but it's not obvious and it's unclear why the code
isn't just using inode->i_lock but apparently copying the address into
nfs_commit_info.lock ?  Indeed looking at the code we have:
~~~
static void nfs_init_cinfo_from_inode(struct nfs_commit_info *cinfo,
                                      struct inode *inode)
{
        cinfo->lock = &inode->i_lock;
        cinfo->mds = &NFS_I(inode)->commit_info;
        cinfo->ds = pnfs_get_ds_info(inode);
        cinfo->dreq = NULL;
        cinfo->completion_ops = &nfs_commit_completion_ops;
}
"fs/nfs/write.c" 1927L, 50230C
~~~


== Technical explanation of deadlock seen in vmcore ==

Ok with the understanding that inode->i_lock == nfs_commit_info.lock, take a look at the pid 11305
~~~
crash> bt
PID: 11305  TASK: ffff881c7715aab0  CPU: 8   COMMAND: "sas"
 #0 [ffff881078806e90] crash_nmi_callback at ffffffff81033cf6
 #1 [ffff881078806ea0] notifier_call_chain at ffffffff8153f545
 #2 [ffff881078806ee0] atomic_notifier_call_chain at ffffffff8153f5aa
 #3 [ffff881078806ef0] notify_die at ffffffff810a783e
 #4 [ffff881078806f20] do_nmi at ffffffff8153d203
 #5 [ffff881078806f50] nmi at ffffffff8153cac0
    [exception RIP: _spin_lock+0x1c]
    RIP: ffffffff8153c32c  RSP: ffff88104032fb58  RFLAGS: 00000297
    RAX: 00000000000009c1  RBX: ffff880a82b84bc0  RCX: 0000000000000000
    RDX: 00000000000009c0  RSI: ffff8809ff681820  RDI: ffff8809ff6818d0
    RBP: ffff88104032fb58   R8: ffff88104032fc80   R9: 0000000000000002
    R10: ffffea0022eec790  R11: 0000000000000003  R12: ffff88104032fb68
    R13: 0000000000000000  R14: ffff8809ff6818d0  R15: 0000000000000020
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
--- <NMI exception stack> ---
 #6 [ffff88104032fb58] _spin_lock at ffffffff8153c32c
 #7 [ffff88104032fb60] nfs_clear_request_commit at ffffffffa03e9dc1 [nfs]
 #8 [ffff88104032fbb0] nfs_wb_page_cancel at ffffffffa03e9ec8 [nfs]
 #9 [ffff88104032fbe0] nfs_invalidate_page at ffffffffa03d74f7 [nfs]
#10 [ffff88104032fc00] do_invalidatepage at ffffffff8113edb5
#11 [ffff88104032fc10] truncate_inode_page at ffffffff8113f0d2
#12 [ffff88104032fc30] truncate_inode_pages_range at ffffffff8113f47f
#13 [ffff88104032fd20] truncate_inode_pages at ffffffff8113f8a5
#14 [ffff88104032fd30] truncate_pagecache at ffffffff8113f8ff
#15 [ffff88104032fd60] nfs_setattr_update_inode at ffffffffa03d9eb9 [nfs]
#16 [ffff88104032fd90] nfs3_proc_setattr at ffffffffa03eca6b [nfs]
#17 [ffff88104032fe20] nfs_setattr at ffffffffa03db610 [nfs]
#18 [ffff88104032fe60] notify_change at ffffffff811b1338
#19 [ffff88104032fed0] do_truncate at ffffffff8118fee4
#20 [ffff88104032ff40] sys_ftruncate at ffffffff81190290
#21 [ffff88104032ff80] system_call_fastpath at ffffffff8100b0d2
    RIP: 00002b53f548a4d7  RSP: 00002b543fb36b50  RFLAGS: 00010246
    RAX: 000000000000004d  RBX: ffffffff8100b0d2  RCX: 00002b5426a29c48
    RDX: 00002b543f11a880  RSI: 0000000000020000  RDI: 0000000000000028
    RBP: 00002b543f11a880   R8: 0000000000010000   R9: 00002b544e8a63b0
    R10: 000000000000002a  R11: 0000000000000206  R12: 00002b543f11ad88
    R13: 00002b53f9ae7fe0  R14: 00002b53fa43af20  R15: 00002b543f11a880
    ORIG_RAX: 000000000000004d  CS: 0033  SS: 002b
crash> dis -lr ffffffffa03e9ec8 | tail
0xffffffffa03e9eb6 <nfs_wb_page_cancel+0xa6>:   pop    %r13
0xffffffffa03e9eb8 <nfs_wb_page_cancel+0xa8>:   pop    %r14
0xffffffffa03e9eba <nfs_wb_page_cancel+0xaa>:   leaveq 
0xffffffffa03e9ebb <nfs_wb_page_cancel+0xab>:   retq   
0xffffffffa03e9ebc <nfs_wb_page_cancel+0xac>:   nopl   0x0(%rax)
/usr/src/debug/kernel-2.6.32-573.18.1.el6/linux-2.6.32-573.18.1.el6.x86_64/fs/nfs/write.c: 1787
0xffffffffa03e9ec0 <nfs_wb_page_cancel+0xb0>:   mov    %rbx,%rdi
0xffffffffa03e9ec3 <nfs_wb_page_cancel+0xb3>:   callq  0xffffffffa03e9d20 <nfs_clear_request_commit>
/usr/src/debug/kernel-2.6.32-573.18.1.el6/linux-2.6.32-573.18.1.el6.x86_64/arch/x86/include/asm/spinlock.h: 174
0xffffffffa03e9ec8 <nfs_wb_page_cancel+0xb8>:   mov    %r14,%rax
crash> dis -lr ffffffffa03e9dc1 | tail
0xffffffffa03e9dab <nfs_clear_request_commit+0x8b>:     mov    -0x10(%rbp),%rbx
0xffffffffa03e9daf <nfs_clear_request_commit+0x8f>:     mov    -0x8(%rbp),%r12
0xffffffffa03e9db3 <nfs_clear_request_commit+0x93>:     leaveq 
0xffffffffa03e9db4 <nfs_clear_request_commit+0x94>:     retq   
0xffffffffa03e9db5 <nfs_clear_request_commit+0x95>:     nopl   (%rax)
/usr/src/debug/kernel-2.6.32-573.18.1.el6/linux-2.6.32-573.18.1.el6.x86_64/fs/nfs/write.c: 558
0xffffffffa03e9db8 <nfs_clear_request_commit+0x98>:     mov    -0x40(%rbp),%rdi
0xffffffffa03e9dbc <nfs_clear_request_commit+0x9c>:     callq  0xffffffff8153c310 <_spin_lock>
/usr/src/debug/kernel-2.6.32-573.18.1.el6/linux-2.6.32-573.18.1.el6.x86_64/arch/x86/include/asm/bitops.h: 252
0xffffffffa03e9dc1 <nfs_clear_request_commit+0xa1>:     lock btrl $0x2,0x40(%rbx)
~~~


Now look at the code, specifically nfs_wb_page_cancel and nfs_clear_request_commit.  On line 1780 we take inode->i_lock.
~~~
fs/nfs/write.c
1771 
1772 int nfs_wb_page_cancel(struct inode *inode, struct page *page)
1773 {
1774 	struct nfs_page *req;
1775 	int ret = 0;
1776 
1777 	BUG_ON(!PageLocked(page));
1778 	for (;;) {
1779 		wait_on_page_writeback(page);
1780    	spin_lock(&inode->i_lock);  <----------- Takes spinlock the first time
1781 		req = nfs_page_find_request_locked(page);
1782 		if (req == NULL) {
1783 			spin_unlock(&inode->i_lock);
1784 			break;
1785 		}
1786 		if (nfs_lock_request(req)) {
1787 			nfs_clear_request_commit(req);    <---------- executing inside here
1788 			spin_unlock(&inode->i_lock);


549 static void
550 nfs_clear_request_commit(struct nfs_page *req)
551 {
552 	if (test_bit(PG_CLEAN, &req->wb_flags)) {
553 		struct inode *inode = req->wb_context->dentry->d_inode;
554 		struct nfs_commit_info cinfo;
555 
556 		nfs_init_cinfo_from_inode(&cinfo, inode);
557 		if (!pnfs_clear_request_commit(req, &cinfo)) {
558-->			spin_lock(cinfo.lock);      <-------------- Tries to take spinlock a second time
559 			nfs_request_remove_commit_list(req, &cinfo);
560 			spin_unlock(cinfo.lock);
561 		}
562 		nfs_clear_page_commit(req->wb_page);
563 	}
564 }
~~~

Version-Release number of selected component (if applicable):
2.6.32-573.18.1.el6

How reproducible:
multiple times by one customer so far

Steps to Reproduce:
TBD

Actual results:
NFS client system deadlocks


