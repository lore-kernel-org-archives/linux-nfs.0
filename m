From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [PATCH] locks: provide a file lease method	enabling	cluster-coherent leases
Date: Mon, 4 Jun 2007 09:59:20 -0400
Message-ID: <20070604135920.GA2233@fieldses.org>
References: <OF3A5C7199.4DE8BA91-ON882572EE.006302AD-882572EE.0063A704@us.ibm.com> <1180808482.6687.30.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marc Eshel <eshel@almaden.ibm.com>, linux-fsdevel@vger.kernel.org,
	nfs@lists.sourceforge.net, David Teigland <teigland@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1180808482.6687.30.camel@heimdal.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, Jun 02, 2007 at 02:21:22PM -0400, Trond Myklebust wrote:
> Currently, the lease handling is done all in the VFS, and is done prior
> to calling any filesystem operations. Bruce's break_lease() inode
> operation allows the VFS to notify the filesystem that some operation is
> going to be called that requires the lease to be broken.
> 
> My point is that in doing so, you are not atomic with the operation that
> requires the lease to be broken. Some different node may re-establish a
> lease while we're calling back down into the filesystem to perform the
> operation.
> So I agree with you. The break_lease() inode operation isn't going to
> work. The filesystem is going to have to figure out for itself when it
> needs to notify other nodes that the lease needs breaking, and it needs
> to figure out its own methods for ensuring atomicity.

OK, I agree with you both, thanks for the explanations.

It looks to me like there's probably a race in the existing code that
will allow conflicting opens and leases to be granted simultaneously if
the lease request is handled just after may_open() is called.  These
checks at the beginning of __setlease() are an attempt to prevent that
race:

	if ((arg == F_RDLCK) && (atomic_read(&inode->i_writecount) > 0))
		goto out;
	if ((arg == F_WRLCK)
	    && ((atomic_read(&dentry->d_count) > 1)
	        || (atomic_read(&inode->i_count) > 1)))
		goto out;

But, for example, in the case of a simultaneous write open and RDLCK
lease request, I believe the call to setlease could come after the
may_open() but before the call to get_write_access() that bumps
i_writecount.

--b.
