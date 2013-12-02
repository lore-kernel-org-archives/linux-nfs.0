Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:11025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752867Ab3LBRWp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Dec 2013 12:22:45 -0500
Date: Mon, 2 Dec 2013 12:22:19 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: 3.12-rc2 nfsd oops in nfsd_cache_lookup
Message-ID: <20131202122219.043174d6@tlielax.poochiereds.net>
In-Reply-To: <20131201102954.GA26976@infradead.org>
References: <20131201102954.GA26976@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 1 Dec 2013 02:29:54 -0800
Christoph Hellwig <hch@infradead.org> wrote:

> 
> Running xfstests against a local server on XFS:
> 
> generic/075 23s ...[  605.063602] nfs: server 127.0.0.1 not responding, still trying
> [  605.064398] general protection fault: 0000 [#1] SMP 
> [  605.064994] Modules linked in:
> [  605.065386] CPU: 2 PID: 3469 Comm: nfsd Not tainted 3.13.0-rc2 #58
> [  605.066051] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
> [  605.066704] task: ffff8800762e6010 ti: ffff8800756d8000 task.ti: ffff8800756d8000
> [  605.066843] RIP: 0010:[<ffffffff81331f1b>]  [<ffffffff81331f1b>] lru_put_end+0x1b/0x60
> [  605.066843] RSP: 0018:ffff8800756d9d28  EFLAGS: 00010246
> [  605.066843] RAX: dead000000200200 RBX: ffff8800754a4e90 RCX: dead000000100100
> [  605.066843] RDX: ffff8800754a4ea0 RSI: ffff8800762e66c0 RDI: ffff8800754a4e90
> [  605.066843] RBP: ffff8800756d9d28 R08: 0000000000000006 R09: 0000000000000001
> [  605.066843] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000001
> [  605.066843] R13: 0000000000000000 R14: 000000000cb5731d R15: ffff88007b4dc000
> [  605.066843] FS:  0000000000000000(0000) GS:ffff88007fd00000(0000) knlGS:0000000000000000
> [  605.066843] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  605.066843] CR2: ffffffffff600400 CR3: 000000006fe87000 CR4: 00000000000006e0
> [  605.066843] Stack:
> [  605.066843]  ffff8800756d9d88 ffffffff81332498 ffff88007cf33600 ffffffff0cb5731d
> [  605.066843]  0000000300000002 4d36e16d00000006 ffff88007b4dc000 ffff88007b4dc000
> [  605.066843]  ffffffff82211230 ffff880076216018 ffffffff822111a0 ffff880076216018
> [  605.066843] Call Trace:
> [  605.066843]  [<ffffffff81332498>] nfsd_cache_lookup+0x3c8/0x730
> [  605.066843]  [<ffffffff8132763e>] nfsd_dispatch+0x5e/0x1b0
> [  605.066843]  [<ffffffff81b6f551>] svc_process+0x4b1/0x760
> [  605.066843]  [<ffffffff81326f9f>] nfsd+0xbf/0x130
> [  605.066843]  [<ffffffff81326ee0>] ? nfsd_destroy+0xc0/0xc0
> [  605.066843]  [<ffffffff810b6b0f>] kthread+0xdf/0x100
> [  605.066843]  [<ffffffff81c4130b>] ? _raw_spin_unlock_irq+0x2b/0x40
> [  605.066843]  [<ffffffff810b6a30>] ? __init_kthread_worker+0x70/0x70
> [  605.066843]  [<ffffffff81c4970c>] ret_from_fork+0x7c/0xb0
> [  605.066843]  [<ffffffff810b6a30>] ? __init_kthread_worker+0x70/0x70


Looks like a similar oops to the one reported here:

    https://bugzilla.redhat.com/show_bug.cgi?id=1025907

Do you have a way to reproduce this reliably?
-- 
Jeff Layton <jlayton@redhat.com>
