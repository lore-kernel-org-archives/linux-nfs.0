Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:56871 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848AbbCOM4P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Mar 2015 08:56:15 -0400
Received: from hch by bombadil.infradead.org with local (Exim 4.80.1 #2 (Red Hat Linux))
	id 1YX85W-00023h-Dg
	for linux-nfs@vger.kernel.org; Sun, 15 Mar 2015 12:56:14 +0000
Date: Sun, 15 Mar 2015 05:56:14 -0700
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org
Subject: nfsd use after free in 4.0-rc
Message-ID: <20150315125614.GA766@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

generic/011 1s ...[  154.375068] general protection fault: 0000 [#1] SMP 
[  154.376050] Modules linked in:
[  154.376785] CPU: 2 PID: 3818 Comm: nfsd Not tainted 4.0.0-rc3+ #150
[  154.377891] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  154.377891] task: ffff88007b294410 ti: ffff88007a910000 task.ti: ffff88007a910000
[  154.377891] RIP: 0010:[<ffffffff81102050>]  [<ffffffff81102050>] __lock_acquire+0x140/0x1e20
[  154.377891] RSP: 0018:ffff88007a9139e8  EFLAGS: 00010002
[  154.377891] RAX: 0000000000000046 RBX: 6b6b6b6b6b6b6f03 RCX: 0000000000000000
[  154.377891] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 6b6b6b6b6b6b6f1b
[  154.377891] RBP: ffff88007a913ac8 R08: 0000000000000001 R09: 0000000000000000
[  154.377891] R10: 0000000000000000 R11: 0000000000000001 R12: ffff88007b294410
[  154.377891] R13: 6b6b6b6b6b6b6f1b R14: 0000000000000000 R15: 0000000000000000
[  154.377891] FS:  0000000000000000(0000) GS:ffff88007fd00000(0000) knlGS:0000000000000000
[  154.377891] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  154.377891] CR2: 00007ffff85d1fec CR3: 0000000076ebb000 CR4: 00000000000007e0
[  154.377891] Stack:
[  154.377891]  ffff88007b294410 ffffffff824c0a20 ffff88007b294c08 0000000000000002
[  154.377891]  ffff88007a913af8 ffffffff0000032c ffff880000000000 0000000000000000
[  154.377891]  ffff88007a913b18 0000000000000046 ffff88007b294c00 ffffffff0000001a
[  154.377891] Call Trace:
[  154.377891]  [<ffffffff811042ff>] lock_acquire+0x9f/0x120
[  154.377891]  [<ffffffff813c603e>] ? nfsd4_process_open2+0x1de/0x1010
[  154.377891]  [<ffffffff810fff5c>] ? lockdep_init_map+0xbc/0x520
[  154.397191]  [<ffffffff81e3fcec>] _raw_spin_lock+0x2c/0x40
[  154.397191]  [<ffffffff813c603e>] ? nfsd4_process_open2+0x1de/0x1010
[  154.397191]  [<ffffffff81e40446>] ? _raw_spin_unlock+0x26/0x30
[  154.397191]  [<ffffffff813c603e>] nfsd4_process_open2+0x1de/0x1010
[  154.397191]  [<ffffffff813c5e60>] ? nfsd4_process_open1+0x3d0/0x3d0
[  154.397191]  [<ffffffff811d79f3>] ? inode_permission+0x13/0x50
[  154.397191]  [<ffffffff813aa462>] ? nfsd_permission+0x72/0x130
[  154.397191]  [<ffffffff813a744a>] ? fh_verify+0x14a/0x540
[  154.397191]  [<ffffffff813b6fa0>] nfsd4_open+0x370/0x780
[  154.397191]  [<ffffffff813b6c30>] ? nfsd4_link+0xf0/0xf0
[  154.397191]  [<ffffffff813b782c>] nfsd4_proc_compound+0x47c/0x680
[  154.397191]  [<ffffffff813a4711>] nfsd_dispatch+0xa1/0x1b0
[  154.397191]  [<ffffffff81d5864a>] svc_process_common+0x2da/0x570
[  154.397191]  [<ffffffff81d58ca6>] svc_process+0x176/0x1e0
[  154.397191]  [<ffffffff813a3fe7>] nfsd+0x157/0x1d0
[  154.397191]  [<ffffffff813a3e90>] ? nfsd_destroy+0xc0/0xc0
[  154.397191]  [<ffffffff813a3e90>] ? nfsd_destroy+0xc0/0xc0
[  154.397191]  [<ffffffff810dda0f>] kthread+0xdf/0x100
[  154.397191]  [<ffffffff810dd930>] ? __init_kthread_worker+0x70/0x70
[  154.397191]  [<ffffffff81e40918>] ret_from_fork+0x58/0x90
[  154.397191]  [<ffffffff810dd930>] ? __init_kthread_worker+0x70/0x70
[  154.397191] Code: 85 db 75 53 0f 1f 80 00 00 00 00 31 c0 48 8b 5d d8 4c 8b 65 e0 4c 8b 6d e8 4c 8b 75 f0 4c 8b 7d f8 c9 c3 0f 1f 84 00 00 00 00 00 <49> 81 7d 00 c0 58 75 82 b8 00 00 00 00 44 0f 44 c0 41 83 fe 01 
[  154.397191] RIP  [<ffffffff81102050>] __lock_acquire+0x140/0x1e20
[  154.397191]  RSP <ffff88007a9139e8>
[  154.397191] ---[ end trace ce8f0fa2103c18f2 ]---
[  165.320204] Slab corruption (Tainted: G      D        ): nfsd4_openowners start=ffff88007b3fa8b0, len=528
[  165.321157] Redzone: 0x9f911029d74e35b/0x9f911029d74e35b.
[  165.321660] Last user: [<ffffffff813c0a43>](nfs4_free_openowner+0x13/0x20)
[  165.322281] 030: 6c 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b lkkkkkkkkkkkkkkk
[  165.323172] Prev obj: start=ffff88007b3fa688, len=528
[  165.323743] Redzone: 0x9f911029d74e35b/0x9f911029d74e35b.
[  165.324365] Last user: [<ffffffff813c0a43>](nfs4_free_openowner+0x13/0x20)
[  165.325035] 000: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  165.325925] 010: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  165.326809] Next obj: start=ffff88007b3faad8, len=528
[  165.327366] Redzone: 0x9f911029d74e35b/0x9f911029d74e35b.
[  165.327916] Last user:
[<ffffffff813c0a43>](nfs4_free_openowner+0x13/0x20)
[  165.328572] 000: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[  165.329439] 010: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
