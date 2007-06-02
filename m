From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] [PATCH] locks: provide a file lease
	method	enabling	cluster-coherent leases
Date: Sat, 02 Jun 2007 14:21:22 -0400
Message-ID: <1180808482.6687.30.camel@heimdal.trondhjem.org>
References: <OF3A5C7199.4DE8BA91-ON882572EE.006302AD-882572EE.0063A704@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	David Teigland <teigland@redhat.com>
To: Marc Eshel <eshel@almaden.ibm.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <OF3A5C7199.4DE8BA91-ON882572EE.006302AD-882572EE.0063A704@us.ibm.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, 2007-06-02 at 11:09 -0700, Marc Eshel wrote:

> A cluster filesystem don't need the inode operation breake_lease. The fs 
> must be able to detect the conflict and break the lease using 
> __break_lease() call on all the nodes that hold a conflicting leases.
> Marc. 

Currently, the lease handling is done all in the VFS, and is done prior
to calling any filesystem operations. Bruce's break_lease() inode
operation allows the VFS to notify the filesystem that some operation is
going to be called that requires the lease to be broken.

My point is that in doing so, you are not atomic with the operation that
requires the lease to be broken. Some different node may re-establish a
lease while we're calling back down into the filesystem to perform the
operation.
So I agree with you. The break_lease() inode operation isn't going to
work. The filesystem is going to have to figure out for itself when it
needs to notify other nodes that the lease needs breaking, and it needs
to figure out its own methods for ensuring atomicity.

Cheers
  Trond

