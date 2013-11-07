Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:54529 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752009Ab3KGVgo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Nov 2013 16:36:44 -0500
Date: Thu, 7 Nov 2013 13:36:39 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, bfields@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd: remove_stid can be incorporated into
 nfs4_put_delegation
Message-ID: <20131107213639.GA31244@infradead.org>
References: <525CE711.1040107@primarydata.com>
 <1381820280-14120-1-git-send-email-bhalevy@primarydata.com>
 <20131104224758.GB8828@fieldses.org>
 <52786E74.8030505@primarydata.com>
 <20131107170204.GA10530@infradead.org>
 <527BF1B5.4070508@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <527BF1B5.4070508@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

FYI, here is the actual oops:

generic/013 9s ...[  252.796884] ------------[ cut here ]------------
[  252.797661] kernel BUG at fs/nfsd/nfs4state.c:141!
[  252.798391] invalid opcode: 0000 [#1] SMP 
[  252.799191] Modules linked in:
[  252.799780] CPU: 1 PID: 466 Comm: kworker/1:1 Not tainted 3.12.0-rc3+ #97
[  252.799996] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  252.799996] Workqueue: rpciod rpc_async_schedule
[  252.799996] task: ffff88007d79e640 ti: ffff88007cc5a000 task.ti: ffff88007cc5a000
[  252.799996] RIP: 0010:[<ffffffff8134c6b1>]  [<ffffffff8134c6b1>] nfs4_assert_state_locked+0x11/0x20
[  252.799996] RSP: 0018:ffff88007cc5bce8  EFLAGS: 00010246
[  252.799996] RAX: 0000000000000001 RBX: ffff880078f8ed48 RCX: 0000000000000000
[  252.799996] RDX: dead000000200200 RSI: 0000000000000000 RDI: ffff880078f8ed48
[  252.799996] RBP: ffff88007cc5bce8 R08: 0000000000000000 R09: ffff88007bb24350
[  252.799996] R10: ffff88007fbfbfd0 R11: 0000000000000000 R12: ffff88007bb24800
[  252.799996] R13: ffffffff81afd0f0 R14: 0000000000000000 R15: 0000000000000000
[  252.799996] FS:  0000000000000000(0000) GS:ffff88007fc80000(0000) knlGS:0000000000000000
[  252.799996] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b [  252.799996] CR2: ffffffffff600400 CR3: 0000000075204000 CR4: 00000000000006e0
[  252.799996] Stack:
[  252.799996]  ffff88007cc5bd08 ffffffff8134ccdc ffff880078f8ed48 ffff88007bb24800
[  252.799996]  ffff88007cc5bd28 ffffffff8134ce11 ffff88007cc5bd38 ffff880078f8ee40
[  252.799996]  ffff88007cc5bd48 ffffffff81355b6a ffff88007cdce480 0000000000000e81
[  252.799996] Call Trace:
[  252.799996]  [<ffffffff8134ccdc>] nfsd4_remove_stid+0x1c/0x40
[  252.799996]  [<ffffffff8134ce11>] nfs4_put_delegation+0x11/0x40
[  252.799996]  [<ffffffff81355b6a>] nfsd4_cb_recall_release+0x6a/0x80
[  252.799996]  [<ffffffff81afd67e>] rpc_free_task+0x2e/0x50
[  252.799996]  [<ffffffff81afd6f5>] rpc_final_put_task+0x55/0x60
[  252.799996]  [<ffffffff81afd87c>] __rpc_execute+0x17c/0x280
[  252.799996]  [<ffffffff81afd9a5>] rpc_async_schedule+0x25/0x40
[  252.799996]  [<ffffffff810ab58c>] process_one_work+0x16c/0x3e0
[  252.799996]  [<ffffffff810abc39>] worker_thread+0x119/0x370
[  252.799996]  [<ffffffff810abb20>] ? rescuer_thread+0x2e0/0x2e0
[  252.799996]  [<ffffffff810b1c6b>] kthread+0xbb/0xc0
[  252.799996]  [<ffffffff81040000>] ? vmx_handle_exit+0x450/0x8d0
[  252.799996]  [<ffffffff810b1bb0>] ? kthread_freezable_should_stop+0x60/0x60
[  252.799996]  [<ffffffff81bc78cc>] ret_from_fork+0x7c/0xb0
[  252.799996]  [<ffffffff810b1bb0>] ? kthread_freezable_should_stop+0x60/0x60
[  252.799996] Code: 16 82 48 89 e5 e8 c0 06 87 00 5d c3 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 8b 05 ba 27 e2 00 55 48 89 e5 83 f8 01 74 02 5d c3 <0f> 0b 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 41 57 

