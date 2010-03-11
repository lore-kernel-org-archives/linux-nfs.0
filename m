From: "J. R. Okajima" <hooanon05-/E1597aS9LR3+QwDJ9on6Q@public.gmane.org>
Subject: Re: [PATCH 10/12] NFS: Simplify nfs_wb_page()
Date: Thu, 11 Mar 2010 13:45:56 +0900
Message-ID: <22120.1268282756@jrobl>
References: <20100125221544.16750.70574.stgit@localhost.localdomain> <20100125221545.16750.19154.stgit@localhost.localdomain> <16839.1268247109@jrobl> <1268249482.3096.76.camel@localhost.localdomain> <1268252300.3096.81.camel@localhost.localdomain>
Cc: linux-nfs@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>,
	Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	Jens Axboe <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, linux-fsdevel@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>,
	Al Viro <viro@ZenIV.linux.org.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mtoichi11.ns.itscom.net ([219.110.2.181]:43277 "EHLO
	mtoichi11.ns.itscom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756075Ab0CKErG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Mar 2010 23:47:06 -0500
In-Reply-To: <1268252300.3096.81.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Trond Myklebust:
> OK. Does the following patch fix the deadlock for you?

Thanx for the patch, but it didn't work.

BUG: unable to handle kernel NULL pointer dereference at 0000000000000010
IP: [<ffffffff811cb860>] nfs_clear_page_tag_locked+0x20/0x80
PGD 1e641067 PUD 135a3067 PMD 0 
Oops: 0000 [#1] PREEMPT SMP 
last sysfs file: /sys/fs/aufs/si_fa7907d8bbb32280/br1
CPU 0 
Modules linked in: aufs configs nfsd exportfs nls_iso8859_1 nls_cp437 [last unloaded: aufs]

Pid: 308, comm: nfsiod Not tainted 2.6.33aufsD #730 IPM41/Pegatron
RIP: 0010:[<ffffffff811cb860>]  [<ffffffff811cb860>] nfs_clear_page_tag_locked+0x20/0x80
RSP: 0018:ffff88001f26bd10  EFLAGS: 00010246
RAX: 0000000000000000 RBX: 0000000000000000 RCX: ffffffff86b47850
RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff88001b87e7c0
RBP: ffff88001f26bd30 R08: fdb3fbf8f8168244 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000000 R12: ffff88001b87e7c0
R13: ffff88001f277110 R14: 0000000000000000 R15: ffff88001f2772f8
FS:  0000000000000000(0000) GS:ffff88000bc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000010 CR3: 000000001de5a000 CR4: 00000000000406f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process nfsiod (pid: 308, threadinfo ffff88001f26a000, task ffff88001fe92040)
Stack:
 ffff88001b87e7c0 0000000000000000 ffff88001b87e7c0 ffff88001f277110
<0> ffff88001f26bd70 ffffffff811d1464 ffff88001f2772ec 0000000000000000
<0> ffff88001f277118 ffff88001f277110 ffffffff8162b980 ffffffff81435e20
Call Trace:
 [<ffffffff811d1464>] nfs_commit_release+0x74/0x210
 [<ffffffff81435e20>] ? rpc_async_release+0x0/0x20
 [<ffffffff81435c82>] rpc_release_calldata+0x12/0x20
 [<ffffffff81435cea>] rpc_free_task+0x3a/0xa0
 [<ffffffff81435e30>] rpc_async_release+0x10/0x20
 [<ffffffff8106bd84>] worker_thread+0x2d4/0x420
 [<ffffffff8106bd31>] ? worker_thread+0x281/0x420
 [<ffffffff81070ca0>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8106bab0>] ? worker_thread+0x0/0x420
 [<ffffffff810706d6>] kthread+0x96/0xb0
 [<ffffffff8100b5a4>] kernel_thread_helper+0x4/0x10
 [<ffffffff81464f14>] ? restore_args+0x0/0x30
 [<ffffffff81070640>] ? kthread+0x0/0xb0
 [<ffffffff8100b5a0>] ? kernel_thread_helper+0x0/0x10
Code: 29 00 0f 0b eb fe 0f 1f 44 00 00 55 48 89 e5 48 83 ec 20 4c 89 65 f0 48 89 5d e8 4c 89 6d f8 49 89 fc 48 8b 47 18 48 83 7f 10 00 <48> 8b 40 10 4c 8b 68 40 74 46 49 8d 9d b0 00 00 00 48 89 df e8 
RIP  [<ffffffff811cb860>] nfs_clear_page_tag_locked+0x20/0x80
 RSP <ffff88001f26bd10>
CR2: 0000000000000010
---[ end trace 1265485acdc49b9d ]---


J. R. Okajima
