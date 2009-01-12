From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH,RFC] more graceful sunrpc cache updates for HA
Date: Mon, 12 Jan 2009 10:51:46 -0500
Message-ID: <20090112155146.GA24322@fieldses.org>
References: <496B1A7E.80807@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, NFS list <linux-nfs@vger.kernel.org>
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:39681 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752382AbZALPvw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Jan 2009 10:51:52 -0500
In-Reply-To: <496B1A7E.80807-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 12, 2009 at 09:25:02PM +1100, Greg Banks wrote:
> The kernel keeps an effectively global generation number (genid). 
> Interfaces are provided to userspace to allow querying the genid, and to
> allow atomically incrementing and querying the genid.  After exportfs
> makes a change to etab it asks the kernel to increment the genid.  When
> mountd wants to know if the etab has changed, it checks the genid and
> re-reads etab if the genid has changed since the last read.  The export
> updates that mountd writes into the kernel are tagged with the genid
> that mountd thinks they belong to, and this is stored in the cache
> entry.  Missing is a hunk to make cache_fresh() compare the genids of
> the entry and the cache_detail and if they differ start an upcall (but
> *not* consider the entry invalid, i.e. behave like the age >
> refresh_age/2 case).

So the result is just to give userspace a way to tell the kernel that it
should start making upcalls without yet dropping the existing cache
entries?

I'd like to guarantee that nfsd behavior reflects the updated exports
by the time exportfs returns.  From your description, it doesn't sound
like you're trying to meet such a guarantee?  Or is there some way for
exportfs to wait till it sees the updates made?

It also might be possible to teach exportfs and/or mountd how to write
the "diff" between the current kernel exports and the new exports into
the export cache.

> a) allow large NFS calls to be deferred, up to the maximum wsize rather
> than just a page, or
> 
> b) change call deferral to always block the calling thread instead of
> using a deferral record and returning -EAGAIN

Any deferral method sufficient to handle reads and writes already
requires saving a fair amount of state, so I wonder whether the extra
overhead just to keep another thread around is worth the trouble of
avoiding....

--b.

> Both approaches have interesting and potentially frightening side
> effects, but could be made to work.  I've discussed option b) with
> Bruce, and I understand the NFSv4.1 guys have their own reasons for
> wanting to do something like that.  Maybe the above will help explain
> why the current call deferral behaviour gives me the irrits :-)
