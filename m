From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Fri, 01 Aug 2008 09:50:49 +0100
Message-ID: <1217580649.3454.335.camel@pmac.infradead.org>
References: <1209670979.25560.587.camel@pmac.infradead.org>
	 <20080501204820.GA5951@infradead.org>
	 <1209681898.25560.613.camel@pmac.infradead.org>
	 <18458.28833.539314.455215@notabene.brown>
	 <1217541264.1126.15.camel@shinybook.infradead.org>
	 <18578.21997.529551.676627@notabene.brown>
	 <1217551230.3719.15.camel@shinybook.infradead.org>
	 <18578.29049.38904.746701@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:41533 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752078AbYHAIuw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Aug 2008 04:50:52 -0400
In-Reply-To: <18578.29049.38904.746701-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-08-01 at 12:14 +1000, Neil Brown wrote:
> It sounds to me like the core problem here is that the locking regime
> imposed by the VFS simply isn't suitable for JFFS2 .. and a bunch of
> other filesystems.

Well, the VFS isn't the part that's recursing into the file system code
and causing deadlock. It's only nfsd which is doing that.

> This seems to suggest that the VFS should be changed.
> Superficially, it seems that changing the locking rules so that the
> callee takes i_mutex rather than the caller taking it would help and,
> in the case of JFFS2, make f->sem redundant.  Does that match your
> understanding?

Not entirely.

I'm not sure I see how we could make such a change -- the VFS relies on
i_mutex for a number of operations it performs for itself, so it's hard
to see how we could do without using it there.

I'm not entirely sure the approach would be sufficient for JFFS2,
either. Both jffs2_readdir() and jffs2_lookup() are _still_ going to
want to take the lock, whichever lock it is. And recursing back into the
file system while the file system is already holding the lock is _still_
going to be considered harmful.

I have even less faith that it would end up working for the various
other file systems which are affected.

Don't let me discourage you from trying, though :)

> Clearly we need a short term solution too as we don't want to wait for
> VFS locking rules to be renegotiated.  The idea of a "lock is owned by
> me" check is appealing to me as it is a small, localised change that
> would easily be removed if/when the locking we "fixed" properly.
> 
> In the JFFS2 case I imagine this taking the following form:
> 
>  - new field in jffs2_inode_info "struct task_struct *sem_owner",
>    initialised to NULL
>  - in jffs2_readdir after locking ->sem, set ->sem_owner to current.
>  - before unlocking ->sem, set ->sem_owner to NULL
>  - in jffs2_lookup, check if "dir_f->sem_owner == current"
>    If it does, set a flag reminding us not to drop the lock,
>    else mutex_lock(&dir_f->sem);

You're describing the hack I posted at
http://lists.infradead.org/pipermail/linux-mtd/2007-March/017663.html
but couldn't bring myself to commit. And it (or some other workaround)
would be needed in _every_ affected file system.

I'm much happier with putting the workaround in nfsd code, and keeping
it out of the individual file systems.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation



