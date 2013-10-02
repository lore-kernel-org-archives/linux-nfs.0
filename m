Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38197 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752927Ab3JBO0A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Oct 2013 10:26:00 -0400
Date: Wed, 2 Oct 2013 10:25:27 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, sandeen@redhat.com
Subject: Re: why is i_ino unsigned long, anyway?
Message-ID: <20131002142527.GD14808@fieldses.org>
References: <20130912160324.GE1462@fieldses.org>
 <20130912193328.GP13318@ZenIV.linux.org.uk>
 <20130929115454.GA3953@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130929115454.GA3953@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Sep 29, 2013 at 04:54:54AM -0700, Christoph Hellwig wrote:
> On Thu, Sep 12, 2013 at 08:33:28PM +0100, Al Viro wrote:
> > i_ino use is entirely up to filesystem; it may be used by library helpers,
> > provided that the choice of using or not using those is, again, up to
> > filesystem in question.
> 
> With more and more filesystems using large inode numbers I'm starting to
> wonder if this still makes sense.  But given that it's been this way for
> a long time we should have more documentation of it for sure.
> 
> > NFSD has no damn business looking at it; library
> > helpers in fs/exportfs might, but that makes them not suitable for use
> > by filesystems without inode numbers or with 64bit ones.
> > 
> > The reason why it's there at all is that it serves as convenient icache
> > search key for many filesystems.  IOW, it's used by iget_locked() and
> > avoiding the overhead of 64bit comparisons on 32bit hosts is the main
> > reason to avoid making it u64.
> > 
> > Again, no fs-independent code has any business looking at it, 64bit or
> > not.  From the VFS point of view there is no such thing as inode number.
> > And get_name() is just a library helper.  For many fs types it works
> > as suitable ->s_export_op->get_name() instance, but decision to use it
> > or not belongs to filesystem in question and frankly, it's probably better
> > to provide an instance of your own anyway.
> 
> Given that these days most exportable filesystems use 64-bit inode
> numbers I think we should put the patch from Bruce in.  Nevermind that
> it's in a slow path, so the overhead of vfs_getattr really doesn't hurt.

Calling vfs_getattr adds a security_inode_getattr() call that wasn't
there before.  Any chance of that being a problem?

If so then it's no huge code duplication to it by hand:

	if (inode->i_op->getattr)
		inode->i_op->getattr(path->mnt, path->dentry, &stat);
	else
		generic_fillattr(inode, &stat);

--b.
