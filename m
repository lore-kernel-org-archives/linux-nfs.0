Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f171.google.com ([209.85.220.171]:49964 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753653AbaGIUhr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jul 2014 16:37:47 -0400
Received: by mail-vc0-f171.google.com with SMTP id id10so8464178vcb.30
        for <linux-nfs@vger.kernel.org>; Wed, 09 Jul 2014 13:37:46 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Wed, 9 Jul 2014 16:37:44 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 003/114] nfsd: wait to initialize work struct just
 prior to using it
Message-ID: <20140709163744.1aa6126c@tlielax.poochiereds.net>
In-Reply-To: <20140709194114.GC26851@fieldses.org>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
	<1404143423-24381-4-git-send-email-jlayton@primarydata.com>
	<20140708211133.GA26851@fieldses.org>
	<20140709082121.GA30099@infradead.org>
	<20140709194114.GC26851@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 9 Jul 2014 15:41:14 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Jul 09, 2014 at 01:21:21AM -0700, Christoph Hellwig wrote:
> > On Tue, Jul 08, 2014 at 05:11:34PM -0400, J. Bruce Fields wrote:
> > > BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
> > > IP: [<ffffffff810890b1>] process_one_work+0x31/0x500
> > > PGD 0 
> > > Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> > > Modules linked in: nfsd auth_rpcgss oid_registry nfs_acl lockd sunrpc
> > > CPU: 2 PID: 30 Comm: kworker/u8:1 Not tainted 3.16.0-rc2-00023-g30c1d16 #3051
> > > Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> > > task: ffff88003d9cc810 ti: ffff88003d9d0000 task.ti: ffff88003d9d0000
> > > RIP: 0010:[<ffffffff810890b1>]  [<ffffffff810890b1>] process_one_work+0x31/0x500
> > > RSP: 0018:ffff88003d9d3d68  EFLAGS: 00010046
> > > RAX: 0000000000000100 RBX: ffff88003d9caf80 RCX: dead000000200200
> > > RDX: 0000000000000100 RSI: ffff880031429b38 RDI: ffff88003d9caf80
> > > RBP: ffff88003d9d3dd8 R08: ffff88003dcb7800 R09: 0000000001c40000
> > > R10: 0000000000000000 R11: 000000000006b5b0 R12: ffff88003dcb7800
> > > R13: 0000000000000000 R14: ffff880031429b38 R15: ffff88003d9caf80
> > > FS:  0000000000000000(0000) GS:ffff88003fb00000(0000) knlGS:0000000000000000
> > > CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > > CR2: 0000000000000138 CR3: 0000000027744000 CR4: 00000000000006e0
> > > Stack:
> > >  000000003d9d3d88 ffff88003dcb7818 ffff88003d9cafb0 ffff88003dcb7800
> > >  ffff88003dcb7800 ffff88003dcb7800 ffff88003dcb7800 ffff88003d9cafb0
> > >  ffff88003d9d3dd8 ffff88003dcb7800 ffff88003dcb7848 ffff88003d9cafb0
> > > Call Trace:
> > >  [<ffffffff81089b9b>] worker_thread+0x11b/0x4f0
> > >  [<ffffffff81089a80>] ? init_pwq+0x190/0x190
> > >  [<ffffffff81090ac4>] kthread+0xe4/0x100
> > >  [<ffffffff810909e0>] ? __init_kthread_worker+0x70/0x70
> > >  [<ffffffff81a4ca2c>] ret_from_fork+0x7c/0xb0
> > >  [<ffffffff810909e0>] ? __init_kthread_worker+0x70/0x70
> > > Code: 48 89 e5 41 57 41 56 49 89 f6 41 55 45 31 ed 41 54 53 48 89 fb 48 83 ec 48 48 8b 06 4c 8b 67 48 48 89 c2 30 d2 a8 04 4c 0f 45 ea <49> 8b 45 08 48 c7 45 b8 00 00 00 00 48 c7 45 c0 00 00 00 00 8b 
> > > RIP  [<ffffffff810890b1>] process_one_work+0x31/0x500
> > >  RSP <ffff88003d9d3d68>
> > > CR2: 0000000000000008
> > > 
> > > and I'm suspicious of this:
> > > 
> > > > @@ -763,6 +764,8 @@ static void do_probe_callback(struct nfs4_client *clp)
> > > >  
> > > >  	cb->cb_ops = &nfsd4_cb_probe_ops;
> > > >  
> > > > +	INIT_WORK(&cb->cb_work, nfsd4_do_callback_rpc);
> > > > +
> > > >  	run_nfsd4_cb(cb);
> > > >  }
> > > 
> > > This is called all over the place, possibly multiple times on the same
> > > client, so we're calling INIT_WORK on something that may already be in
> > > use--I doubt that's safe.
> > > 
> > > I'm backing out this patch for now.
> > 
> > If that's the case all of do_probe_callback seems very fishy to me, as
> > it scrambles all over the callback structure.  I guess we need to move
> > more of it to an init function then, and have different init functions
> > for the different callbacks.
> 
> Taking a look....  It does look fishy, but those fields are constant, so
> I don't see a bug.
> 
> In delegation recall case (nfsd4_cb_recall()) those fields aren't
> constant, but we guarantee it's only called once.
> 

Yes. I'm inclined to leave well enough alone on this and to leave any
cleanup in this area to Christoph since he said he was overhauling that
code anyway.

I didn't see where you had reverted the patch in your repo, so I went
ahead and did it and then rebased the series on top of the revert.
There were some merge conflicts, but I at least was able to get rid of
the double INIT_WORK calls in the case of a delegation (and do some
related cleanup in this area):

http://git.samba.org/?p=jlayton/linux.git;a=commitdiff;h=60b61375d6a84e74bf1c3c7c230712721e14773d
http://git.samba.org/?p=jlayton/linux.git;a=commitdiff;h=491192c3e6f0966722c34ba36adfde7575640544

Unfortunately there are a few (fairly trivial) merge conflicts later in
the series due to this change. Bruce, do you want me to repost the
whole set, or would you rather just cherry-pick them from my updated
branch?

-- 
Jeff Layton <jlayton@primarydata.com>
