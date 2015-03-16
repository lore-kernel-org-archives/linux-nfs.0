Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yh0-f41.google.com ([209.85.213.41]:34800 "EHLO
	mail-yh0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757107AbbCPRhn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Mar 2015 13:37:43 -0400
Received: by yhch68 with SMTP id h68so19968172yhc.1
        for <linux-nfs@vger.kernel.org>; Mon, 16 Mar 2015 10:37:42 -0700 (PDT)
Date: Mon, 16 Mar 2015 13:37:39 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: nfsd use after free in 4.0-rc
Message-ID: <20150316133739.66459170@tlielax.poochiereds.net>
In-Reply-To: <20150316171005.GE12231@fieldses.org>
References: <20150315125614.GA766@infradead.org>
	<20150315180811.02847842@tlielax.poochiereds.net>
	<20150316114648.GA7432@infradead.org>
	<20150316082004.348e39af@tlielax.poochiereds.net>
	<20150316122731.GA32163@infradead.org>
	<20150316161955.GD12231@fieldses.org>
	<20150316125314.6501449b@tlielax.poochiereds.net>
	<20150316171005.GE12231@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 16 Mar 2015 13:10:05 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Mar 16, 2015 at 12:53:14PM -0400, Jeff Layton wrote:
> > On Mon, 16 Mar 2015 12:19:55 -0400
> > bfields@fieldses.org (J. Bruce Fields) wrote:
> > 
> > > On Mon, Mar 16, 2015 at 05:27:31AM -0700, Christoph Hellwig wrote:
> > > > On Mon, Mar 16, 2015 at 08:20:04AM -0400, Jeff Layton wrote:
> > > > > I just tried a v3.19 kernel on the server and could reproduce this
> > > > > there with generic/011 as well, so this looks like a preexisting bug of
> > > > > some sort. Perhaps the recent client changes to allow parallel opens
> > > > > are helping to expose it?
> > > > 
> > > > That sounds like a good explanation, as I've never seen this before
> > > > those changes were merged.
> > > 
> > > Possibly unrelated, but I'm suspicious of the release_open_stateid() on
> > > nfs4_get_vfs_file() failure: I believe a) we're not holding any locks
> > > over those two calls, and b) the stateid is globally visible ever since
> > > init_open_stateid.  So by the time we call release_open_stateid(),
> > > another open could have found that stateid and be trying to work with
> > > it, right?  Maybe I'm missing something.
> > > 
> > > nfs4_get_vfs_file() is where an actual vfs open can happen, so it's
> > > doing a lot of work, and can sleep--so it seems a particularly likely
> > > point for someone else to race with us.
> > > 
> > 
> > In theory it's possible for that stateid to be found and used that way.
> > It really shouldn't happen though because it's a brand new stateid and
> > the client should have no idea what it actually is.
> 
> nfsd4_find_existing_open() looks like it will still find such a stateid.
> I haven't tried to trace through what happens if it finds a stateid that
> then immediately has release_open_stateid called on it.
> 
> --b.
> 

Oh, good point. I guess what matters is whether you bump the refcount
before the it has already dropped to 0 or not. If you get it before,
then it should be pretty harmless (though the client will probably end
up in stateid recovery). If after, then it's likely to get torn down
out from under you.

Probably we ought to make that atomic_inc an atomic_inc_not_zero, and
simply return NULL if that returns false. Either that or make sure we
take the cl_lock before bumping the refcount.

Still, the problem seems to be in the openowner slab, not in the
stateid slab so far. It's possible that that is the bug, but I think
we'll need to figure out how that is happening if so.

> > 
> > If that does happen though, it should be safe. release_open_stateid
> > does actually respect the refcount. It basically takes the lock,
> > unhashes it and then does a put on the stateid. If the refcount
> > goes to 0, then it puts it onto the reaplist to be freed later.
> > 
> > So if that were to happen we might end up with a stale stateid, but
> > it really shouldn't, and it certainly ought not cause any real
> > refcounting problems.
> > -- 
> > Jeff Layton <jeff.layton@primarydata.com>


-- 
Jeff Layton <jeff.layton@primarydata.com>
