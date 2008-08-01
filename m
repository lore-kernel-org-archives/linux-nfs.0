From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Fri, 1 Aug 2008 12:14:17 +1000
Message-ID: <18578.29049.38904.746701@notabene.brown>
References: <1209670979.25560.587.camel@pmac.infradead.org>
	<20080501204820.GA5951@infradead.org>
	<1209681898.25560.613.camel@pmac.infradead.org>
	<18458.28833.539314.455215@notabene.brown>
	<1217541264.1126.15.camel@shinybook.infradead.org>
	<18578.21997.529551.676627@notabene.brown>
	<1217551230.3719.15.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:47754 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752052AbYHACOZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Jul 2008 22:14:25 -0400
In-Reply-To: message from David Woodhouse on Friday August 1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Friday August 1, dwmw2@infradead.org wrote:
> On Fri, 2008-08-01 at 10:16 +1000, Neil Brown wrote:
> > On Thursday July 31, dwmw2@infradead.org wrote:
> > > On Fri, 2008-05-02 at 11:38 +1000, Neil Brown wrote:
> > > > Why is there a deadlock here?
> > 
> > I was really hoping you would answer this question.
> 
> It's because the nfsd readdirplus code recurses into the file system.
> >From the file system's ->readdir() function we call back into nfsd's
> encode_entry(), which then calls back into the file system's ->lookup()
> function so that it can generate a filehandle.
> 
> For any file system which has its own internal locking -- which includes
> jffs2, btrfs, xfs, jfs, gfs*, ocfs* and probably others -- that
> recursive call back into the file system will deadlock.
> 
> In the specific case of JFFS2, we need that internal locking because of
> lock ordering constraints with the garbage collection -- we need to take
> the allocator lock _before_ the per-inode lock, which means we can't use
> the generic inode->i_mutex for that purpose. That's documented in
> fs/jffs2/README.Locking. I know fewer details about the other affected
> file systems.

It sounds to me like the core problem here is that the locking regime
imposed by the VFS simply isn't suitable for JFFS2 .. and a bunch of
other filesystems.

This seems to suggest that the VFS should be changed.
Superficially, it seems that changing the locking rules so that the
callee takes i_mutex rather than the caller taking it would help and,
in the case of JFFS2, make f->sem redundant.  Does that match your
understanding?

That is obviously a big change and one that should not be made
lightly, but if it was to benefit a number of the newer filesystems, then
it would seem like the appropriate way to go.

Clearly we need a short term solution too as we don't want to wait for
VFS locking rules to be renegotiated.  The idea of a "lock is owned by
me" check is appealing to me as it is a small, localised change that
would easily be removed if/when the locking we "fixed" properly.

In the JFFS2 case I imagine this taking the following form:

 - new field in jffs2_inode_info "struct task_struct *sem_owner",
   initialised to NULL
 - in jffs2_readdir after locking ->sem, set ->sem_owner to current.
 - before unlocking ->sem, set ->sem_owner to NULL
 - in jffs2_lookup, check if "dir_f->sem_owner == current"
   If it does, set a flag reminding us not to drop the lock,
   else mutex_lock(&dir_f->sem);

This should fix the problem with very little cost either in
performance or elegance.  And if/when the locking rules were changed,
the accompanying code review would immediately notice this and remove
it.

NeilBrown
