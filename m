Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:34826 "EHLO
	mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752927AbcDXUvr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Apr 2016 16:51:47 -0400
Received: by mail-qk0-f182.google.com with SMTP id q76so41453186qke.2
        for <linux-nfs@vger.kernel.org>; Sun, 24 Apr 2016 13:51:46 -0700 (PDT)
Message-ID: <1461531102.3357.25.camel@poochiereds.net>
Subject: Re: parallel lookups on NFS
From: Jeff Layton <jlayton@poochiereds.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 24 Apr 2016 16:51:42 -0400
In-Reply-To: <20160424191835.GL25498@ZenIV.linux.org.uk>
References: <20160424023453.GK25498@ZenIV.linux.org.uk>
	 <1461501975.5219.40.camel@poochiereds.net>
	 <20160424191835.GL25498@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2016-04-24 at 20:18 +0100, Al Viro wrote:
> On Sun, Apr 24, 2016 at 08:46:15AM -0400, Jeff Layton wrote:
> > 
> > > 
> > > 	Suggestions?  Right now my local tree has nfs_lookup() and
> > > nfs_readdir() run with directory locked shared.  And they are still
> > > serialized by the damn ->silly_count ;-/
> > > 
> > Hmm...well, most of that was added in commit 565277f63c61. Looking at
> > the bug referenced in that commit log, I think that the main thing we
> > want to ensure is that rmdir waits until all of the sillydeletes for
> > files in its directory have finished.
> > 
> > But...there's also some code to ensure that if a lookup races in while
> > we're doing the sillydelete that we transfer all of the dentry info to
> > the new alias. That's the messy part.
> It's a bit more - AFAICS, it also wants to prevent lookup coming after we'd
> started with building an unlink request and getting serviced before that
> unlink.
> 
> > 
> > The new infrastructure for parallel lookups might make it simpler
> > actually. When we go to do the sillydelete, could we add the dentry to
> > the "lookup in progress" hash that you're adding as part of the
> > parallel lookup infrastructure? Then the tasks doing lookups could find
> > it and just wait on the sillydelete to complete. After the sillydelete,
> > we'd turn the thing into a negative dentry and then wake up the waiters
> > (if any). That does make the whole dentry teardown a bit more complex
> > though.
> Umm...  A lot more complex, unfortunately - if anything, I would allocate
> a _new_ dentry at sillyrename time and used it pretty much instead of
> your nfs_unlinkdata.  Unhashed, negative and pinned down.  And insert it
> into in-lookup hash only when we get around to actual delayed unlink.
> 
> First of all, dentries in in-lookup hash *must* be negative before they can
> be inserted there.  That wouldn't be so much PITA per se, but we also have
> a problem with the sucker possibly being on a shrink list and only the owner
> of the shrink list can remove it from there.  So this kind of reuse would be
> hard to arrange.
> 
> Do we want to end up with a negative hashed after that unlink, though?
> Sure, we know it's negative, but will anyone really try to look it up
> afterwards?  IOW, is it anything but a hash pollution?  What's more,
> unlike in-lookup hash, there are assumptions about the primary one; namely,
> directory-modifying operation can be certain that nobody else will be adding
> entries to hash behind its back, positive or negative.
> 
You may be right. One problematic scenario is something like this:

A READDIR is issued that ends up racing with a sillydelete. The READDIR response comes in first and we start processing entries. Eventually it hits the dentry that's being sillydeleted and blocks on it. The dentry is deleted on the server so we create a negative dentry and wake up the READDIR. It then reinstantiates the dentry as positive.

Hmm...is that really a problem though? Maybe not since we'll just issue the RMDIR to the server at that point and the directory _would_ be empty there. Alternately we'd probably just end up flushing the dentry when we notice that the dir has changed.

In any case, there probably is little benefit to keeping the dentry around. If d_drop'ing it makes things simpler, then I've no objection.


> I'm not at all sure that NFS doesn't rely upon this.  The in-lookup hash
> has no such warranties (and still very few users, of course), so we can
> afford adding stuff to it without bothering with locking the parent directory.
> _IF_ we don't try to add anything to primary hash, we can bloody well use it
> without ->i_rwsem on the parent.
>
> AFAICS, ->args is redundant if you have the sucker with the right name/parent.
> So's ->dir; the rest is probably still needed, so a shrunk nfs_unlinkdata
> would still be needed, more's the pity...  Well, we can point ->d_fsdata of
> the replacement dentry to set to it.
> 
> And yes, it means allocation in two pieces instead of just one when we hit
> sillyrename.  Seeing that it's doing at least two RPC roundtrips right in
> nfs_sillyrename(), I think that overhead isn't a serious worry.  
> 

Agreed.

> What we get out of that is fully parallel lookup/readdir/sillyunlink - all
> exclusion is on per-name basis (nfs_prime_dcache() vs. nfs_lookup() vs.
> nfs_do_call_unlink()).  It will require a bit of care in atomic_open(),
> though...
> 
> I'll play with that a bit and see what can be done...

-- 
Jeff Layton <jlayton@poochiereds.net>
