From: Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Sun, 17 Aug 2008 11:22:06 -0700
Message-ID: <20080817182206.GA4199@webber.adilger.int>
References: <76bd70e30807311831p771d0f1eia3e303bd84919422@mail.gmail.com>
 <1217597759.3454.356.camel@pmac.infradead.org>
 <1217598976.3454.359.camel@pmac.infradead.org>
 <76bd70e30808010905j3010a6bfy534c068a662d348d@mail.gmail.com>
 <1217607571.3454.417.camel@pmac.infradead.org>
 <76bd70e30808011047u3cd0a56cg3b2d62e01afed014@mail.gmail.com>
 <20080802182644.GE30454@fieldses.org>
 <18581.40178.976747.769343@notabene.brown>
 <76bd70e30808031015l36db41bexf319e85ba7acc4e9@mail.gmail.com>
 <18582.21855.2092.903688@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chucklever@gmail.com, "J. Bruce Fields" <bfields@fieldses.org>,
	David Woodhouse <dwmw2@infradead.org>, viro@zeniv.linux.org.uk,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:61631 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751758AbYHQSWX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 17 Aug 2008 14:22:23 -0400
In-reply-to: <18582.21855.2092.903688-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 04, 2008  11:03 +1000, Neil Brown wrote:
> So, given that background, it is possible to see some more possible
> solutions (other than the ones already mentioned).
> 
>  - drop the internal lock across filldir.
>    It could be seen a impolite to hold any locks across a callback
>    that are not documented as being held.
>    This would put an extra burden on the filesystem, but it shouldn't
>    be a particularly big burden.
>    A filesystem needs to be able to find the 'next' entry from a
>    sequential 'seek' pointer so that is the most state that needs to
>    be preserved.  It might be convenient to be able to keep more state
>    (pointers into data structures etc).  All this can be achieved with
>    fairly standard practice:
>      a/ have a 'version' number per inode which is updated when any
>         internal restructure happens.
>      b/ when calling filldir, record the version number, drop the lock
>         call filldir, reclaim the lock, check the version number
>      c/ if the version number matches (as it mostly will) just keep
>         going.  If it doesn't jump back to the top of readdir where
>         we decode the current seek address.
> 
>    Some filesystems have problems implementing seekdir/telldir so they
>    might not be totally happy here.  I have little sympathy for such
>    filesystems and feel the burden should be on them to make it work.
> 
>  - use i_mutex to protect internal changes too, and drop i_mutex while
>    doing internal restructuring.   This would need some VFS changes so
>    that dropping i_mutex would be safe.  It would require some way to
>    lock an individual dentry.  Probably you would lock it under
>    i_mutex by setting a flag bit, wait for the flag on some inode-wide
>    waitqueue, and drop the lock by clearing the flag and waking the
>    waitqueue. And you are never allowed to look at ->d_inode if the
>    lock flag is set.

When we were working on scaling the performance of concurrent operations
in a single directory we added hashed dentry locks instead of using
i_mutex (well, i_sem in those days) to lock the whole directory.  To make
the change manageable we replaced direct i_sem locking on the directory
inode with ->lock_dir() and ->unlock_dir() methods, defaulting to just
down() and up() on i_sem, but replacing this with a per-entry lock on
the child dentry hash.

This allowed Lustre servers to create/lookup/rename/remove many entries
in a single directory concurrently, and I think this same approach could
be useful in this case also.  This allows filesystems that need it to
bypass i_mutex if they need their own brand of locking, while leaving
the majority of filesystems untouched.

It also has the benefit that filesystems that need improved multi-threaded
performance in a single directory (e.g. JFFS2, XFS, or HPC or MTA
workloads) have the ability to do it.  There is definitely some work
needed internal to the filesystem to take advantage of this increased
parallelism, and we did implement such changes for ext3+htree directories,
adding internal locking on each leaf block that scaled the concurrency
with the size of the directory.


Alas, we don't have any up-to-date kernel patches for this, though the VFS
patch was posted to LKML back in Feb 2005 as "RFC: pdirops: vfs patch"
http://www.mail-archive.com/linux-fsdevel@vger.kernel.org/msg01617.html
We have better dynamic locking code today (one of Jan's objections about
that patch), but the VFS part of the patch is no longer maintained.  The
ext3+htree patch was also posted "[RFC] parallel directory operations"
http://www.ussg.iu.edu/hypermail/linux/kernel/0307.1/att-0041/03-ext3-pdirops.patch


Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.

