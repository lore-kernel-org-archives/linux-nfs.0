Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f42.google.com ([209.85.216.42]:63051 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753443AbaIIQPt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2014 12:15:49 -0400
Received: by mail-qa0-f42.google.com with SMTP id dc16so11943229qab.15
        for <linux-nfs@vger.kernel.org>; Tue, 09 Sep 2014 09:15:48 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 9 Sep 2014 12:15:46 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>, linux-nfs@vger.kernel.org,
        neilb@suse.de
Subject: Re: kernel BUG in fs/dcache.c running nfs
Message-ID: <20140909121546.3981121b@tlielax.poochiereds.net>
In-Reply-To: <20140909121244.610f297d@tlielax.poochiereds.net>
References: <20140908144525.GB19811@infradead.org>
	<20140909105918.59477ee3@tlielax.poochiereds.net>
	<20140909154211.GA6614@infradead.org>
	<20140909121244.610f297d@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 9 Sep 2014 12:12:44 -0400
Jeff Layton <jlayton@primarydata.com> wrote:

> On Tue, 9 Sep 2014 08:42:11 -0700
> Christoph Hellwig <hch@infradead.org> wrote:
> 
> > On Tue, Sep 09, 2014 at 10:59:18AM -0400, Jeff Layton wrote:
> > > > [ 5497.405585]  [<ffffffff8135d0c1>] nfs4_do_open.constprop.84+0x681/0x960
> > > > [ 5497.405585]  [<ffffffff8135d459>] nfs4_atomic_open+0x9/0x20
> > > > [ 5497.405585]  [<ffffffff8136cc3d>] nfs4_file_open+0xcd/0x1b0
> > > > [ 5497.405585]  [<ffffffff811b8092>] do_dentry_open.isra.13+0x1f2/0x320
> > > > [ 5497.405585]  [<ffffffff811b82ad>] finish_open+0x1d/0x30
> > > > [ 5497.405585]  [<ffffffff811c98e9>] path_openat+0xb9/0x670
> > > > [ 5497.405585]  [<ffffffff811ca26e>] do_filp_open+0x3e/0xa0
> > > > [ 5497.405585]  [<ffffffff811b95cc>] do_sys_open+0x13c/0x230
> > > > [ 5497.405585]  [<ffffffff811b96dd>] SyS_open+0x1d/0x20
> > > > [ 5497.405585]  [<ffffffff81d9f5a9>] system_call_fastpath+0x16/0x1b
> > > > 
> > > 
> > > Odd...
> > > 
> > > It looks like you hit the BUG() in d_instantiate.
> > > 
> > > I don't see any calls to d_instantiate in the current nfs_code (aside
> > > from the one in nfs_lookup, and I don't think that's getting called
> > > here). d_instantiate is called by d_add though, and that gets called
> > > from nfs_atomic_open. Is that what happened here?
> > > 
> > > Maybe you can use gdb to figure out what line of code
> > > "nfs4_do_open.constprop.84+0x681" actually is?
> > 
> > My gdb can't cope with these constprop expressions unfortunately.
> > 
> > But when you remove the questionable symbols as I've done above it's
> > pretty clear that this must be the
> > 
> > nfs4_atomic_open
> >  -> nfs4_do_open
> >    -> _nfs4_do_open
> >      -> _nfs4_open_and_get_state
> >        -> d_add
> >          -> d_instantiate
> > 
> > call chain. There is heavy inlining going on inside nfs4file.c, and
> > d_add now is a simple inline around d_instantiate and d_rehash.
> 
> Ok. So I'm guessing that means that the current scheme of doing a
> d_drop/d_add is not valid. d_drop doesn't remove the dentry from the
> i_alias list.
> 
> It looks like the first call there should just be doing a d_delete
> instead, since it's trying to turn the thing into a negative dentry.

(cc'ing Neil B.)

...and I'd hazard a guess that 4fa2c54b5198d might be the culprit. You
might want to try backing that out and see if it's still reproducible.

Neil, any thoughts?

-- 
Jeff Layton <jlayton@primarydata.com>
