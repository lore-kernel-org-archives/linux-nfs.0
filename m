From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Sat, 2 Aug 2008 09:11:49 +1000
Message-ID: <18579.38965.178789.21355@notabene.brown>
References: <1209670979.25560.587.camel@pmac.infradead.org>
	<20080501204820.GA5951@infradead.org>
	<1209681898.25560.613.camel@pmac.infradead.org>
	<18458.28833.539314.455215@notabene.brown>
	<1217541264.1126.15.camel@shinybook.infradead.org>
	<18578.21997.529551.676627@notabene.brown>
	<1217551230.3719.15.camel@shinybook.infradead.org>
	<18578.29049.38904.746701@notabene.brown>
	<20080801100359.GM28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Woodhouse <dwmw2@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:46540 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751732AbYHAXL6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Aug 2008 19:11:58 -0400
In-Reply-To: message from Al Viro on Friday August 1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Friday August 1, viro@ZenIV.linux.org.uk wrote:
> On Fri, Aug 01, 2008 at 12:14:17PM +1000, Neil Brown wrote:
> 
> > It sounds to me like the core problem here is that the locking regime
> > imposed by the VFS simply isn't suitable for JFFS2 .. and a bunch of
> > other filesystems.
> > 
> > This seems to suggest that the VFS should be changed.
> > Superficially, it seems that changing the locking rules so that the
> > callee takes i_mutex rather than the caller taking it would help and,
> > in the case of JFFS2, make f->sem redundant.  Does that match your
> > understanding?
> 
> Huh?  How could that possibly help?  You are not changing the sequence
> of operations on locks, you only slightly modify the timing; how could
> that possibly eliminate a deadlock?  Moreover, how the _hell_ could
> making exclusion area smaller make f->sem redundant?

By moving the locking of i_mutex inside the filesystem methods, I
reasoned that the filesystem would have more control and be able to do
things in the order that it wanted.

I gathered from the JFFS locking document - admitted a very brief
reading - that it the VFS took i_mutex at awkward times for JFFS2,
and the for this reason, JFFS2 introduced f->sem, described as:

  "This is the JFFS2-internal equivalent of the inode mutex i->i_sem."

If i_mutex became internal, maybe JFFS2 wouldn't need an internal
equivalent.

But I did miss an important point.
The reason that the current code works with many filesystems is that 
lookup_one_len *doesn't* take i_mutex before calling ->lookup.  It 
assumes that it is already held.  So pushing the locking down into
->lookup would actually break other filesystems without fixing this
one.  My Bad.


So it seems like recursion into the filesystem is a Bad Thing and we
need a different approach.
I really don't like NFSD having to cache all the names that it gets
from readdir and then hand them back to lookup one at a time, though
it might end up being the answer..

What about this (I know you're going to hate it)??

A new open flags: O_READDIRPLUS.
If ->readdir finds that it is set on filp->f_flags, then it does a
lookup on each name it finds and makes sure they are all in the
dcache.
Then when NFSD calls lookup_one_len inside the filldir callback, it
will find the answer in the cache and not need to recurse into the
filesystem.

We would need some way to be sure that the new dentry didn't get
flushed from the dcache before NFSD called lookup_one_len.  I guess
if ->readdir held a reference on it while filldir was called that
would be an adequate guarantee.

This would then make O_READDIRPLUS available to userspace too. 
"ls -l" could use it and thus give the filesystem an opportunity to
optimise things.
->readdir could:
    load a block of the directory
    schedule reads for all the inodes in parallel
    attach them to the dcache in series, using whatever locking
        was needed and no more.


I'm actually starting to like the idea.  Which means it is probably
doomed.

NeilBrown
