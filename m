From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Tue, 5 Aug 2008 08:37:01 +1000
Message-ID: <18583.33933.818892.71415@notabene.brown>
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
	<20080804184115.GG25940@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chucklever@gmail.com, David Woodhouse <dwmw2@infradead.org>,
	viro@zeniv.linux.org.uk, Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: message from J. Bruce Fields on Monday August 4
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday August 4, bfields@fieldses.org wrote:
> On Mon, Aug 04, 2008 at 11:03:27AM +1000, Neil Brown wrote:
> >  - use i_mutex to protect internal changes too, and drop i_mutex while
> >    doing internal restructuring.   This would need some VFS changes so
> >    that dropping i_mutex would be safe.  It would require some way to
> >    lock an individual dentry.  Probably you would lock it under
> >    i_mutex by setting a flag bit, wait for the flag on some inode-wide
> >    waitqueue, and drop the lock by clearing the flag and waking the
> >    waitqueue. And you are never allowed to look at ->d_inode if the
> >    lock flag is set.
> 
> Isn't there a lot of kernel code that assumes that following ->d_inode
> is safe?  Or are you only worried about looking at certain
> filesystem-internal fields of d_inode?

I overstated that restriction a bit.
The way ->d_inode works is that it is set once and then never changed.
A rename doesn't change ->d_inode, it changes the name in the dentry,
and possibly the ->d_parent pointer.  An unlink also leaves ->d_inode
alone and just unhashes the dentry.  ->d_inode is never cleared until
the dentry is freed.
So ->d_inode starts as NULL, is (possibly) set to a value, and stays
that way.
Currently if the name exists, then ->d_inode will be set non-NULL
under i_mutex and so a NULL value will never be visible outside of
i_mutex.  If the name doesn't exist, a NULL value *will* be visible
outside of i_mutex and it could subsequently get (under i_mutex) set
when name is created.

If i_mutex is allowed to be dropped early, then a premature NULL could
be visible in ->d_inode for a name that does exist.  This is the case
the needs to be guarded against.
So when I said "you are never allowed to look at ->d_inode ...." I 
could have said "you are never allowed to see a NULL in ->d_inode ..."
While lots of places dereference ->d_inode, relative few do it in a
context where ->d_inode could be NULL, and these are probably all in
fs/namei.c or related code.  Most of them would be fairly easy to get
to work with dentry locking.

The problem case is rename (as it always is).  With rename, d_move
needs to be called after the filesystem has committed to the rename,
but before i_mutex is dropped.  That would be awkward for filesystems
that needed to collect garbage or whatever before completing the
rename.
I would probably address this by allowing ->rename to return -EAGAIN
with the meaning that i_mutex was dropped but nothing was committed
to, and that vfs_rename_* should try again from the top.  Presumably
->rename will have done some garbage collection or whatever is needed
and the next call to ->rename has a much better chance of going
through without needing to drop the lock.  I don't know if livelocks
could be a problem with this approach.


> 
> The locking required to keep the filesystem namespace consistent is
> difficult and important, so I think changing it would require an
> extremely careful description of the new design and a commitment from
> some filesystem developers to actually take advantage of it....

An "extremely careful description of the new design" is something we
could happily see more of in the kernel world, isn't it :-)
Agreed.


NeilBrown
