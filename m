Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:36781 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757555Ab2HIND4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Aug 2012 09:03:56 -0400
Received: by pbbrr13 with SMTP id rr13so885582pbb.19
        for <linux-nfs@vger.kernel.org>; Thu, 09 Aug 2012 06:03:56 -0700 (PDT)
MIME-Version: 1.0
From: Idan Kedar <idank@tonian.com>
Date: Thu, 9 Aug 2012 16:03:15 +0300
Message-ID: <CABpMAyL-B9Kqg8O4xxxtj0X8PF7fP4TM+NnLA_Ynhm-_3C6MUg@mail.gmail.com>
Subject: return layout on error, BUG/deadlock
To: Boaz Harrosh <bharrosh@panasas.com>, NFS list <linux-nfs@vger.kernel.org>
Cc: Benny Halevy <bhalevy@tonian.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

As a result of some experiments, I wanted to see what happens when I
inject an error (hard coded) to the object layout driver. the patch is
at the bottom of this mail. the reason I did this is because when I
inject errors in my modified version of the object layout driver, I
get the same BUG Tigran reported about yesterday:
nfs4proc.c:6252 :   BUG_ON(!list_empty(&lo->plh_segs));

In my modified version (based on kernel 3.3), the bug seems to be that
pnfs_ld_write_done calls pnfs_return_layout in the error path, even if
there is in-flight I/O.
I wanted to see if this is a result of my modifications, so I injected
errors to the ORE (on kernel 3.5) and ran Connectathon's basic tests,
and got a deadlock AND that BUG:

[  112.659066] =================================
[  112.659066] [ INFO: inconsistent lock state ]
[  112.659066] 3.5.0-nfsobj+ #35 Not tainted
[  112.659066] ---------------------------------
[  112.659066] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
[  112.659066] kworker/0:2/456 [HC0[0]:SC0[0]:HE1:SE1] takes:
[  112.659066]  (&(&objlay->lock)->rlock){+.?...}, at:
[<ffffffffa02558fc>] objlayout_encode_layoutreturn+0x6c/0x420
[objlayoutdriver]
[  112.659066] {IN-SOFTIRQ-W} state was registered at:
[  112.659066]   [<ffffffff810b2bd8>] __lock_acquire+0x5e8/0x1bb0
[  112.659066]   [<ffffffff810b47c2>] lock_acquire+0x92/0x120
[  112.659066]   [<ffffffff81713e16>] _raw_spin_lock+0x36/0x70
[  112.659066]   [<ffffffffa025622d>]
objlayout_iodone.part.1+0x25/0x56 [objlayoutdriver]
[  112.659066]   [<ffffffffa025573b>] objlayout_write_done+0xcb/0xd0
[objlayoutdriver]
[  112.659066]   [<ffffffffa02541c3>] _write_done+0x43/0x60 [objlayoutdriver]
[  112.659066]   [<ffffffffa023a013>] _last_io+0x13/0x20 [libore]
[  112.659066]   [<ffffffffa023a868>] _done_io+0x28/0x30 [libore]
[  112.659066]   [<ffffffffa0229f94>] osd_request_async_done+0xd4/0xf0 [libosd]
[  112.659066]   [<ffffffff812a4a38>] blk_finish_request+0xa8/0x2c0
[  112.659066]   [<ffffffff812a4c9f>] blk_end_bidi_request+0x4f/0x80
[  112.659066]   [<ffffffff812a4d10>] blk_end_request+0x10/0x20
[  112.659066]   [<ffffffff8138c36f>] scsi_io_completion+0xaf/0x670
[  112.659066]   [<ffffffff81382861>] scsi_finish_command+0xd1/0x130
[  112.659066]   [<ffffffff8138c1bf>] scsi_softirq_done+0x13f/0x160
[  112.659066]   [<ffffffff812abb3c>] blk_done_softirq+0x8c/0xa0
[  112.659066]   [<ffffffff81068be8>] __do_softirq+0xc8/0x250
[  112.659066]   [<ffffffff8171696c>] call_softirq+0x1c/0x30
[  112.659066]   [<ffffffff81015785>] do_softirq+0xa5/0xe0
[  112.659066]   [<ffffffff8106893b>] local_bh_enable_ip+0xeb/0x100
[  112.659066]   [<ffffffff81714244>] _raw_spin_unlock_bh+0x34/0x40
[  112.659066]   [<ffffffff815c8abc>] release_sock+0x14c/0x190
[  112.659066]   [<ffffffff81613005>] tcp_sendpage+0xc5/0x6e0
[  112.659066]   [<ffffffff81638703>] inet_sendpage+0xd3/0x120
[  112.659066]   [<ffffffffa0221586>]
iscsi_sw_tcp_pdu_xmit+0x116/0x290 [iscsi_tcp]
[  112.659066]   [<ffffffff814ba930>] iscsi_tcp_task_xmit+0xb0/0x2d0
[  112.659066]   [<ffffffff814354ae>] iscsi_xmit_task+0x5e/0xb0
[  112.659066]   [<ffffffff81437457>] iscsi_xmitworker+0x1f7/0x330
[  112.659066]   [<ffffffff8107d8af>] process_one_work+0x19f/0x530
[  112.659066]   [<ffffffff8107f5d9>] worker_thread+0x159/0x340
[  112.659066]   [<ffffffff810847a7>] kthread+0xb7/0xc0
[  112.659066]   [<ffffffff81716874>] kernel_thread_helper+0x4/0x10
[  112.659066] irq event stamp: 56183
[  112.659066] hardirqs last  enabled at (56183): [<ffffffff810688e7>]
local_bh_enable_ip+0x97/0x100
[  112.659066] hardirqs last disabled at (56181): [<ffffffff81068894>]
local_bh_enable_ip+0x44/0x100
[  112.659066] softirqs last  enabled at (56182): [<ffffffffa00344d0>]
xprt_prepare_transmit+0x70/0x90 [sunrpc]
[  112.659066] softirqs last disabled at (56180): [<ffffffff81713ee8>]
_raw_spin_lock_bh+0x18/0x70
[  112.659066]
[  112.659066] other info that might help us debug this:
[  112.659066]  Possible unsafe locking scenario:
[  112.659066]
[  112.659066]        CPU0
[  112.659066]        ----
[  112.659066]   lock(&(&objlay->lock)->rlock);
[  112.659066]   <Interrupt>
[  112.659066]     lock(&(&objlay->lock)->rlock);
[  112.659066]
[  112.659066]  *** DEADLOCK ***
[  112.659066]
[  112.659066] 2 locks held by kworker/0:2/456:
[  112.659066]  #0:  (events){.+.+.+}, at: [<ffffffff8107d84c>]
process_one_work+0x13c/0x530
[  112.659066]  #1:  ((&wdata->task.u.tk_work)){+.+.+.}, at:
[<ffffffff8107d84c>] process_one_work+0x13c/0x530
[  112.659066]
[  112.659066] stack backtrace:
[  112.659066] Pid: 456, comm: kworker/0:2 Not tainted 3.5.0-nfsobj+ #35
[  112.659066] Call Trace:
[  112.659066]  [<ffffffff81703f08>] print_usage_bug+0x1f5/0x206
[  112.659066]  [<ffffffff8102242f>] ? save_stack_trace+0x2f/0x50
[  112.659066]  [<ffffffff810b2595>] mark_lock+0x295/0x2f0
[  112.659066]  [<ffffffff810b1af0>] ? check_usage_forwards+0x140/0x140
[  112.659066]  [<ffffffff810b2c3a>] __lock_acquire+0x64a/0x1bb0
[  112.659066]  [<ffffffff810aef9d>] ? trace_hardirqs_off+0xd/0x10
[  112.659066]  [<ffffffff8109852f>] ? local_clock+0x6f/0x80
[  112.659066]  [<ffffffff8101baf3>] ? native_sched_clock+0x13/0x80
[  112.659066]  [<ffffffff8101bb69>] ? sched_clock+0x9/0x10
[  112.659066]  [<ffffffff810982c5>] ? sched_clock_local+0x25/0x90
[  112.659066]  [<ffffffff81098458>] ? sched_clock_cpu+0xa8/0x110
[  112.659066]  [<ffffffffa02558fc>] ?
objlayout_encode_layoutreturn+0x6c/0x420 [objlayoutdriver]
[  112.659066]  [<ffffffff810b47c2>] lock_acquire+0x92/0x120
[  112.659066]  [<ffffffffa02558fc>] ?
objlayout_encode_layoutreturn+0x6c/0x420 [objlayoutdriver]
[  112.659066]  [<ffffffff8101bb69>] ? sched_clock+0x9/0x10
[  112.659066]  [<ffffffffa02551a0>] ?
__copy_nfsS_and_zero_terminate+0x90/0x90 [objlayoutdriver]
[  112.659066]  [<ffffffff81713e16>] _raw_spin_lock+0x36/0x70
[  112.659066]  [<ffffffffa02558fc>] ?
objlayout_encode_layoutreturn+0x6c/0x420 [objlayoutdriver]
[  112.659066]  [<ffffffff8101bb69>] ? sched_clock+0x9/0x10
[  112.659066]  [<ffffffffa02558fc>]
objlayout_encode_layoutreturn+0x6c/0x420 [objlayoutdriver]
[  112.659066]  [<ffffffff81098458>] ? sched_clock_cpu+0xa8/0x110
[  112.659066]  [<ffffffff810aef9d>] ? trace_hardirqs_off+0xd/0x10
[  112.659066]  [<ffffffff8109852f>] ? local_clock+0x6f/0x80
[  112.659066]  [<ffffffffa016541a>] ?
nfs4_xdr_enc_layoutreturn+0x11a/0x170 [nfs]
[  112.659066]  [<ffffffffa0045797>] ?
xdr_encode_opaque_fixed+0x47/0x80 [sunrpc]
[  112.659066]  [<ffffffffa02551a0>] ?
__copy_nfsS_and_zero_terminate+0x90/0x90 [objlayoutdriver]
[  112.659066]  [<ffffffffa0165449>] nfs4_xdr_enc_layoutreturn+0x149/0x170 [nfs]
[  112.659066]  [<ffffffff810688e7>] ? local_bh_enable_ip+0x97/0x100
[  112.659066]  [<ffffffffa00344d0>] ? xprt_prepare_transmit+0x70/0x90 [sunrpc]
[  112.659066]  [<ffffffffa0165300>] ? nfs4_xdr_enc_commit+0xe0/0xe0 [nfs]
[  112.659066]  [<ffffffffa003bc05>] rpcauth_wrap_req+0x65/0x70 [sunrpc]
[  112.659066]  [<ffffffffa0030dae>] call_transmit+0x18e/0x260 [sunrpc]
[  112.659066]  [<ffffffffa003a360>] __rpc_execute+0x70/0x280 [sunrpc]
[  112.659066]  [<ffffffffa0030c20>] ? call_connect+0x40/0x40 [sunrpc]
[  112.659066]  [<ffffffffa0030c20>] ? call_connect+0x40/0x40 [sunrpc]
[  112.659066]  [<ffffffff81084e9e>] ? wake_up_bit+0x2e/0x40
[  112.659066]  [<ffffffffa02551a0>] ?
__copy_nfsS_and_zero_terminate+0x90/0x90 [objlayoutdriver]
[  112.659066]  [<ffffffffa003ab4f>] rpc_execute+0x4f/0xb0 [sunrpc]
[  112.659066]  [<ffffffffa02551a0>] ?
__copy_nfsS_and_zero_terminate+0x90/0x90 [objlayoutdriver]
[  112.659066]  [<ffffffffa00327b5>] rpc_run_task+0x75/0x90 [sunrpc]
[  112.659066]  [<ffffffffa0161c96>] nfs4_proc_layoutreturn+0x86/0xb0 [nfs]
[  112.659066]  [<ffffffffa0174594>] _pnfs_return_layout+0x114/0x180 [nfs]
[  112.659066]  [<ffffffffa0174737>] pnfs_ld_write_done+0x67/0xe0 [nfs]
[  112.659066]  [<ffffffffa02551b5>] _rpc_write_complete+0x15/0x20
[objlayoutdriver]
[  112.659066]  [<ffffffff8107d8af>] process_one_work+0x19f/0x530
[  112.659066]  [<ffffffff8107d84c>] ? process_one_work+0x13c/0x530
[  112.659066]  [<ffffffff8107f5d9>] worker_thread+0x159/0x340
[  112.659066]  [<ffffffff8107f480>] ? manage_workers+0x230/0x230
[  112.659066]  [<ffffffff810847a7>] kthread+0xb7/0xc0
[  112.659066]  [<ffffffff810b5295>] ? trace_hardirqs_on_caller+0x105/0x190
[  112.659066]  [<ffffffff81716874>] kernel_thread_helper+0x4/0x10
[  112.659066]  [<ffffffff81714bb0>] ? retint_restore_args+0x13/0x13
[  112.659066]  [<ffffffff810846f0>] ? __init_kthread_worker+0x70/0x70
[  112.659066]  [<ffffffff81716870>] ? gs_change+0x13/0x13
[  112.787051] ------------[ cut here ]------------
[  112.787799] kernel BUG at fs/nfs/nfs4proc.c:6252!
[  112.787799] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[  112.787799] CPU 0
[  112.787799] Modules linked in:[  112.787799]
nfs_layout_nfsv41_files objlayoutdriver exofs libore osd libosd
iscsi_tcp netconsole nfs nfsd fscache lockd auth_rpcgss nfs_acl sunrpc
e1000 rtc_cmos serio_raw [last unloaded: scsi_wait_scan]

[  112.787799] Pid: 456, comm: kworker/0:2 Not tainted 3.5.0-nfsobj+
#35 innotek GmbH VirtualBox
[  112.787799] RIP: 0010:[<ffffffffa015a245>]  [<ffffffffa015a245>]
nfs4_layoutreturn_done+0xd5/0xe0 [nfs]
[  112.787799] RSP: 0018:ffff88003c7bdb50  EFLAGS: 00010206
[  112.787799] RAX: ffff880034480b90 RBX: ffff88003cbb5860 RCX: ffff88003add4ca8
[  112.787799] RDX: 0000000000000000 RSI: ffff8800354b1288 RDI: 0000000000000246
[  112.787799] RBP: ffff88003c7bdb70 R08: 0000000000000002 R09: 0000000000000000
[  112.787799] R10: 0000000000000000 R11: 0000000000000000 R12: ffff88003a782240
[  112.787799] R13: ffff880034480b68 R14: ffff88003a787138 R15: ffffffffa02551a0
[  112.787799] FS:  0000000000000000(0000) GS:ffff88003e200000(0000)
knlGS:0000000000000000
[  112.787799] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  112.787799] CR2: 0000003f33c9b640 CR3: 0000000034070000 CR4: 00000000000006f0
[  112.787799] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  112.787799] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  112.787799] Process kworker/0:2 (pid: 456, threadinfo
ffff88003c7bc000, task ffff88003add4620)
[  112.787799] Stack:
[  112.787799]  ffff88003a787138 ffff88003a782240 ffff8800347c4858
ffff88003c7bdcf8
[  112.787799]  ffff88003c7bdb90 ffffffffa00391fc ffff88003a787138
ffff88003a782240
[  112.787799]  ffff88003c7bdc00 ffffffffa003a360 000000003c7bdbc0
ffff88003a7822b0
[  112.787799] Call Trace:
[  112.787799]  [<ffffffffa00391fc>] rpc_exit_task+0x2c/0x90 [sunrpc]
[  112.787799]  [<ffffffffa003a360>] __rpc_execute+0x70/0x280 [sunrpc]
[  112.787799]  [<ffffffffa00391d0>] ? rpc_async_release+0x20/0x20 [sunrpc]
[  112.787799]  [<ffffffffa00391d0>] ? rpc_async_release+0x20/0x20 [sunrpc]
[  112.787799]  [<ffffffff81084e9e>] ? wake_up_bit+0x2e/0x40
[  112.787799]  [<ffffffffa02551a0>] ?
__copy_nfsS_and_zero_terminate+0x90/0x90 [objlayoutdriver]
[  112.787799]  [<ffffffffa003ab4f>] rpc_execute+0x4f/0xb0 [sunrpc]
[  112.787799]  [<ffffffffa02551a0>] ?
__copy_nfsS_and_zero_terminate+0x90/0x90 [objlayoutdriver]
[  112.787799]  [<ffffffffa00327b5>] rpc_run_task+0x75/0x90 [sunrpc]
[  112.787799]  [<ffffffffa0161c96>] nfs4_proc_layoutreturn+0x86/0xb0 [nfs]
[  112.787799]  [<ffffffffa0174594>] _pnfs_return_layout+0x114/0x180 [nfs]
[  112.787799]  [<ffffffffa0174737>] pnfs_ld_write_done+0x67/0xe0 [nfs]
[  112.787799]  [<ffffffffa02551b5>] _rpc_write_complete+0x15/0x20
[objlayoutdriver]
[  112.787799]  [<ffffffff8107d8af>] process_one_work+0x19f/0x530
[  112.787799]  [<ffffffff8107d84c>] ? process_one_work+0x13c/0x530
[  112.787799]  [<ffffffff8107f5d9>] worker_thread+0x159/0x340
[  112.787799]  [<ffffffff8107f480>] ? manage_workers+0x230/0x230
[  112.787799]  [<ffffffff810847a7>] kthread+0xb7/0xc0
[  112.787799]  [<ffffffff810b5295>] ? trace_hardirqs_on_caller+0x105/0x190
[  112.787799]  [<ffffffff81716874>] kernel_thread_helper+0x4/0x10
[  112.787799]  [<ffffffff81714bb0>] ? retint_restore_args+0x13/0x13
[  112.787799]  [<ffffffff810846f0>] ? __init_kthread_worker+0x70/0x70
[  112.787799]  [<ffffffff81716870>] ? gs_change+0x13/0x13
[  112.787799] Code: c3 0f 1f 44 00 00 48 8d 73 64 ba 01 00 00 00 4c
89 ef e8 ff ab 01 00 eb c8 0f 1f 44 00 00 4c 89 e7 e8 e0 66 ed ff e9
5a ff ff ff <0f> 0b 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 53 48 83 ec
08 66
[  112.787799] RIP  [<ffffffffa015a245>] nfs4_layoutreturn_done+0xd5/0xe0 [nfs]
[  112.787799]  RSP <ffff88003c7bdb50>
[  112.872492] ---[ end trace 114822acc0612b2a ]---


My setup:

Data server is osd-osc emulator
MDS is nfsd-exofs on kernel 3.3 (Benny's kernel)

Is there any fix for this? Or is it not an issue and my injection is
just wrong and stupid?
I've seen some discussions on this in the mailing list, and I saw the
patch that removes the BUG, but I'm not sure if this is the right
thing to do for object layout.

---
 fs/exofs/ore.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index 24a49d4..e9d7b45 100644
--- a/fs/exofs/ore.c
+++ b/fs/exofs/ore.c
@@ -426,9 +426,14 @@ int ore_check_io(struct ore_io_state *ios,
ore_on_dev_error on_dev_error)
 		if (unlikely(!or))
 			continue;

-		ret = osd_req_decode_sense(or, &osi);
-		if (likely(!ret))
-			continue;
+		if (jiffies % 6 == 0) {
+			osi.osd_err_pri = OSD_ERR_PRI_EIO;
+			ret = -EIO;
+		} else {
+			ret = osd_req_decode_sense(or, &osi);
+			if (likely(!ret))
+				continue;
+		}

 		if (OSD_ERR_PRI_CLEAR_PAGES == osi.osd_err_pri) {
 			/* start read offset passed endof file */
-- 
1.7.6.5


-- 
idank
