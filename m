Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:58104 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754102AbbHHOUm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 8 Aug 2015 10:20:42 -0400
Date: Sat, 8 Aug 2015 16:20:40 +0200
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: xfstests crash with trond/testing
Message-ID: <20150808142040.GA9456@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Running against a local pnfs block layout server.  4.2-rc5 is fine.


generic/208 files ...
[ 4230.992608] BUG: unable to handle kernel NULL pointer dereference at           (null)
[ 4230.992923] IP: [<ffffffff81370509>] nfs_request_add_commit_list+0x59/0x140
[ 4230.992923] PGD 6eaa7067 PUD 7a30f067 PMD 0 
[ 4230.992923] Oops: 0000 [#1] SMP 
[ 4230.992923] Modules linked in:
[ 4230.992923] CPU: 3 PID: 22263 Comm: kworker/3:3 Not tainted 4.2.0-rc5+ #1718
[ 4230.992923] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[ 4230.992923] Workqueue: nfsiod rpc_async_release
[ 4230.992923] task: ffff88006dd64d40 ti: ffff88006efc8000 task.ti: ffff88006efc8000
[ 4230.992923] RIP: 0010:[<ffffffff81370509>]  [<ffffffff81370509>] nfs_request_add_commit_list+0x59/0x140
[ 4230.992923] RSP: 0018:ffff88006efcbc68  EFLAGS: 00010282
[ 4230.992923] RAX: 0000000000000000 RBX: ffff88006efcbcb0 RCX: 0000000000000001
[ 4230.992923] RDX: 0000000000000003 RSI: ffff88003ffa3aa0 RDI: ffff88003ffa3a88
[ 4230.992923] RBP: ffff88006efcbc88 R08: 0000000000000001 R09: 0000000000000000
[ 4230.992923] R10: 0000000000000000 R11: 0000000000000000 R12: ffff88007dc807e0
[ 4230.992923] R13: ffff88001c99ad78 R14: ffff88006de28490 R15: 0000000000000001
[ 4230.992923] FS:  0000000000000000(0000) GS:ffff88007fd80000(0000) knlGS:0000000000000000
[ 4230.992923] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 4230.992923] CR2: 0000000000000000 CR3: 000000007af3e000 CR4: 00000000000006e0
[ 4230.992923] Stack:
[ 4230.992923]  ffff88006de28490 ffff88007a2584c0 ffff88006de28480 ffff88001c99ac08
[ 4230.992923]  ffff88006efcbc98 ffffffff81371154 ffff88006efcbd08 ffffffff8136aced
[ 4230.992923]  ffff88006efcbcc8 ffff88003ffa3a88 ffff88001c99ad68 ffff88001c99ad88
[ 4230.992923] Call Trace:
[ 4230.992923]  [<ffffffff81371154>] nfs_mark_request_commit+0x44/0x50
[ 4230.992923]  [<ffffffff8136aced>] nfs_direct_write_completion+0xdd/0x230
[ 4230.992923]  [<ffffffff8136baab>] nfs_pgio_release+0x1b/0x30
[ 4230.992923]  [<ffffffff81d3143e>] rpc_free_task+0x2e/0x70
[ 4230.992923]  [<ffffffff81d318f0>] rpc_async_release+0x10/0x20
[ 4230.992923]  [<ffffffff810e06f9>] process_one_work+0x1a9/0x460
[ 4230.992923]  [<ffffffff810e0683>] ? process_one_work+0x133/0x460
[ 4230.992923]  [<ffffffff810e0b07>] worker_thread+0x117/0x420
[ 4230.992923]  [<ffffffff810e09f0>] ? process_scheduled_works+0x40/0x40
[ 4230.992923]  [<ffffffff810e6b1f>] kthread+0xdf/0x100
[ 4230.992923]  [<ffffffff810e6a40>] ? __init_kthread_worker+0x70/0x70
[ 4230.992923]  [<ffffffff81d8129f>] ret_from_fork+0x3f/0x70
[ 4230.992923]  [<ffffffff810e6a40>] ? __init_kthread_worker+0x70/0x70
[ 4230.992923] Code: e8 1d f0 ff ff 48 8b 3b e8 f5 04 a1 00 4d 8b 64 24 10 49 8b 04 24 a9 00 00 01 00 0f 85 e1 00 00 00 49 8b 44 24 08 48 83 7b 18 00 <4c> 8b 28 74 0e 48 8b 5d e8 4c 8b 65 f0 4c 8b 6d f8 c9 c3 4c 89 
