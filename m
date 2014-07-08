Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f177.google.com ([209.85.220.177]:43224 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909AbaGHXcW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 19:32:22 -0400
Received: by mail-vc0-f177.google.com with SMTP id ij19so6090512vcb.22
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 16:32:21 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 8 Jul 2014 19:32:19 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 003/114] nfsd: wait to initialize work struct just
 prior to using it
Message-ID: <20140708193219.50e194cb@tlielax.poochiereds.net>
In-Reply-To: <20140708211133.GA26851@fieldses.org>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
	<1404143423-24381-4-git-send-email-jlayton@primarydata.com>
	<20140708211133.GA26851@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 8 Jul 2014 17:11:34 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Jun 30, 2014 at 11:48:32AM -0400, Jeff Layton wrote:
> > There's a fair chance we won't ever need this work struct, so we might
> > as well delay initializing it until just before we're going to use it.
> > In a later patch, we'll need to intialize the work with a different
> > function for delegation callbacks. By delaying this, we avoid having
> > to do it twice.
> 
> When I run
> 
> 	./nfs4.1/testserver.py f19:/exports/xfs/FUBAR --maketree --rundeps COMP1
> 
> I get crashes like:
> 
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
> IP: [<ffffffff810890b1>] process_one_work+0x31/0x500
> PGD 0 
> Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> Modules linked in: nfsd auth_rpcgss oid_registry nfs_acl lockd sunrpc
> CPU: 2 PID: 30 Comm: kworker/u8:1 Not tainted 3.16.0-rc2-00023-g30c1d16 #3051
> Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> task: ffff88003d9cc810 ti: ffff88003d9d0000 task.ti: ffff88003d9d0000
> RIP: 0010:[<ffffffff810890b1>]  [<ffffffff810890b1>] process_one_work+0x31/0x500
> RSP: 0018:ffff88003d9d3d68  EFLAGS: 00010046
> RAX: 0000000000000100 RBX: ffff88003d9caf80 RCX: dead000000200200
> RDX: 0000000000000100 RSI: ffff880031429b38 RDI: ffff88003d9caf80
> RBP: ffff88003d9d3dd8 R08: ffff88003dcb7800 R09: 0000000001c40000
> R10: 0000000000000000 R11: 000000000006b5b0 R12: ffff88003dcb7800
> R13: 0000000000000000 R14: ffff880031429b38 R15: ffff88003d9caf80
> FS:  0000000000000000(0000) GS:ffff88003fb00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000000000138 CR3: 0000000027744000 CR4: 00000000000006e0
> Stack:
>  000000003d9d3d88 ffff88003dcb7818 ffff88003d9cafb0 ffff88003dcb7800
>  ffff88003dcb7800 ffff88003dcb7800 ffff88003dcb7800 ffff88003d9cafb0
>  ffff88003d9d3dd8 ffff88003dcb7800 ffff88003dcb7848 ffff88003d9cafb0
> Call Trace:
>  [<ffffffff81089b9b>] worker_thread+0x11b/0x4f0
>  [<ffffffff81089a80>] ? init_pwq+0x190/0x190
>  [<ffffffff81090ac4>] kthread+0xe4/0x100
>  [<ffffffff810909e0>] ? __init_kthread_worker+0x70/0x70
>  [<ffffffff81a4ca2c>] ret_from_fork+0x7c/0xb0
>  [<ffffffff810909e0>] ? __init_kthread_worker+0x70/0x70
> Code: 48 89 e5 41 57 41 56 49 89 f6 41 55 45 31 ed 41 54 53 48 89 fb 48 83 ec 48 48 8b 06 4c 8b 67 48 48 89 c2 30 d2 a8 04 4c 0f 45 ea <49> 8b 45 08 48 c7 45 b8 00 00 00 00 48 c7 45 c0 00 00 00 00 8b 
> RIP  [<ffffffff810890b1>] process_one_work+0x31/0x500
>  RSP <ffff88003d9d3d68>
> CR2: 0000000000000008
> 
> and I'm suspicious of this:
> 
> > @@ -763,6 +764,8 @@ static void do_probe_callback(struct nfs4_client *clp)
> >  
> >  	cb->cb_ops = &nfsd4_cb_probe_ops;
> >  
> > +	INIT_WORK(&cb->cb_work, nfsd4_do_callback_rpc);
> > +
> >  	run_nfsd4_cb(cb);
> >  }
> 
> This is called all over the place, possibly multiple times on the same
> client, so we're calling INIT_WORK on something that may already be in
> use--I doubt that's safe.
> 

Doh! That makes total sense, and yes it would almost certainly wreak
havoc to reinitialize a workqueue job that has already been queued.

> I'm backing out this patch for now.
> 

Yes, please do. Christoph, I think we'll just have to live with the
double initialization here.

Cheers,
-- 
Jeff Layton <jlayton@primarydata.com>
