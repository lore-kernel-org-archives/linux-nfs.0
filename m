Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:64140 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437AbaIIR2u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2014 13:28:50 -0400
Received: by mail-qa0-f53.google.com with SMTP id w8so16153598qac.12
        for <linux-nfs@vger.kernel.org>; Tue, 09 Sep 2014 10:28:49 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 9 Sep 2014 13:28:46 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>, neilb@suse.de
Subject: Re: kernel BUG in fs/dcache.c running nfs
Message-ID: <20140909132846.69376922@tlielax.poochiereds.net>
In-Reply-To: <CAHQdGtSb8vXf0K_kQ08CPFHZ50aSh-+jhCS0x7VVZjg9X8FDsw@mail.gmail.com>
References: <20140908144525.GB19811@infradead.org>
	<20140909105918.59477ee3@tlielax.poochiereds.net>
	<CAHQdGtSb8vXf0K_kQ08CPFHZ50aSh-+jhCS0x7VVZjg9X8FDsw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 9 Sep 2014 09:59:33 -0700
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Tue, Sep 9, 2014 at 7:59 AM, Jeff Layton <jeff.layton@primarydata.com> wrote:
> > On Mon, 8 Sep 2014 07:45:25 -0700
> > Christoph Hellwig <hch@infradead.org> wrote:
> >
> >> I've reproduced a BUG in dcache.c twice now when running xfstests, once
> >> without the "nfs4: queue free_lock_state job submission to nfsiod" and
> >> once with that revert in.
> >>
> >> Both runs are using v4.1 against a Linux server with XFS on the same
> >> host.
> >>
> >> generic/089 199s ...
> >> [ 5497.402293] ------------[ cut here ]------------
> >> [ 5497.403150] kernel BUG at ../fs/dcache.c:1620!
> >> [ 5497.403974] invalid opcode: 0000 [#1] SMP
> >> [ 5497.404826] Modules linked in:
> >> [ 5497.405280] CPU: 1 PID: 14691 Comm: t_mtab Not tainted 3.17.0-rc3+ #264
> >> [ 5497.405585] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
> >> [ 5497.405585] task: ffff88007ac801d0 ti: ffff8800670a4000 task.ti: ffff8800670a4000
> >> [ 5497.405585] RIP: 0010:[<ffffffff811d1345>]  [<ffffffff811d1345>] d_instantiate+0x75/0x80
> >> [ 5497.405585] RSP: 0018:ffff8800670a7a68  EFLAGS: 00010286
> >> [ 5497.405585] RAX: 0000000000000001 RBX: ffff880066c399d8 RCX: ffff88007ac80990
> >> [ 5497.405585] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff880066c399d8
> >> [ 5497.405585] RBP: ffff8800670a7a88 R08: 0000000000000001 R09: 0000000000000000
> >> [ 5497.405585] R10: ffff880072f45000 R11: 000000000003fdf0 R12: ffff880066c399d8
> >> [ 5497.405585] R13: ffff88007a684800 R14: ffff88007acbc280 R15: ffff8800670de000
> >> [ 5497.405585] FS:  00007f6db6aae700(0000) GS:ffff88007fc80000(0000) knlGS:0000000000000000
> >> [ 5497.405585] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> >> [ 5497.405585] CR2: 00007f6db5f56800 CR3: 000000007ac9e000 CR4: 00000000000006e0
> >> [ 5497.405585] Stack:
> >> [ 5497.405585]  ffff8800670a7a88 ffff880066c399d8 ffff88007a684800 ffff88007a684800
> >> [ 5497.405585]  ffff8800670a7b68 ffffffff8135d0c1 ffffffff00000004 ffff8800000000d0
> >> [ 5497.405585]  ffff88007d400180 0000000000000246 ffff8800fffffffe ffff880072f45000
> >> [ 5497.405585] Call Trace:
> >> [ 5497.405585]  [<ffffffff8135d0c1>] nfs4_do_open.constprop.84+0x681/0x960
> >> [ 5497.405585]  [<ffffffff8135d459>] nfs4_atomic_open+0x9/0x20
> >> [ 5497.405585]  [<ffffffff8136cc3d>] nfs4_file_open+0xcd/0x1b0
> >> [ 5497.405585]  [<ffffffff81d9ee56>] ? _raw_spin_unlock+0x26/0x30
> >> [ 5497.405585]  [<ffffffff8176b73d>] ? lockref_get+0x1d/0x30
> >> [ 5497.405585]  [<ffffffff8136cb70>] ? nfs4_file_fsync+0xb0/0xb0
> >> [ 5497.405585]  [<ffffffff811b8092>] do_dentry_open.isra.13+0x1f2/0x320
> >> [ 5497.405585]  [<ffffffff81336f52>] ? nfs_permission+0x62/0x1d0
> >> [ 5497.405585]  [<ffffffff811b82ad>] finish_open+0x1d/0x30
> >> [ 5497.405585]  [<ffffffff811c91be>] do_last.isra.63+0x62e/0xca0
> >> [ 5497.405585]  [<ffffffff811c5703>] ? inode_permission+0x13/0x50
> >> [ 5497.405585]  [<ffffffff811c5bde>] ? link_path_walk+0x23e/0x850
> >> [ 5497.405585]  [<ffffffff811c98e9>] path_openat+0xb9/0x670
> >> [ 5497.405585]  [<ffffffff811b366b>] ? poison_obj+0x2b/0x40
> >> [ 5497.405585]  [<ffffffff811ca26e>] do_filp_open+0x3e/0xa0
> >> [ 5497.405585]  [<ffffffff811d7da1>] ? __alloc_fd+0xd1/0x120
> >> [ 5497.405585]  [<ffffffff811b95cc>] do_sys_open+0x13c/0x230
> >> [ 5497.405585]  [<ffffffff810f5bbd>] ? trace_hardirqs_on_caller+0x10d/0x1d0
> >> [ 5497.405585]  [<ffffffff811b96dd>] SyS_open+0x1d/0x20
> >> [ 5497.405585]  [<ffffffff81d9f5a9>] system_call_fastpath+0x16/0x1b
> >>
> >
> > Odd...
> >
> > It looks like you hit the BUG() in d_instantiate.
> >
> > I don't see any calls to d_instantiate in the current nfs_code (aside
> > from the one in nfs_lookup, and I don't think that's getting called
> > here). d_instantiate is called by d_add though, and that gets called
> > from nfs_atomic_open. Is that what happened here?
> >
> > Maybe you can use gdb to figure out what line of code
> > "nfs4_do_open.constprop.84+0x681" actually is?
> >
> 
> Hi Jeff,
> 
> I took a look at this last night. I suspect that the problem is with
> error handling.
> 
> So the problem is that in the current code, we can end up attaching
> the dentry to the dcache using d_add() in _nfs4_open_and_get_state. I
> suspect that we're hitting an error _after_ that call, that is causing
> the callers of _nfs4_do_open() to loop and retry the open (and thus
> call d_add a second time).
> I haven't had time to investigate where this might be happening, but
> feel free to look...
> 
> Cheers
>   Trond
> 

(readding Neil to cc list)

Ahh ok, makes sense. nfs_atomic_open does this early on:

        BUG_ON(dentry->d_inode);

...so dentry should have been negative when we called into here
originally. That implies that something has already turned it
into a positive dentry here before the d_drop/d_add got called.

Still, turning the d_drop/d_add into a d_delete seems like it might be
the right thing to do there instead. The code is trying to turn this
into a negative dentry and that's what d_delete is supposed to be for.

-- 
Jeff Layton <jlayton@primarydata.com>
