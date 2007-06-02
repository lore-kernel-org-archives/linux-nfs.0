From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: [NFS] [PATCH] locks: provide a file lease method	enabling	cluster-coherent
 leases
Date: Sat, 2 Jun 2007 11:09:24 -0700
Message-ID: <OF3A5C7199.4DE8BA91-ON882572EE.006302AD-882572EE.0063A704@us.ibm.com>
References: <1180805950.6687.17.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	David Teigland <teigland@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1180805950.6687.17.camel@heimdal.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

nfs-bounces@lists.sourceforge.net wrote on 06/02/2007 10:39:10 AM:

> On Fri, 2007-06-01 at 12:53 -0400, J. Bruce Fields wrote:
> > > It also means that you're calling twice down
> > > into the filesystem for every call to may_open() (once for
> > > vfs_permission() and once for break_lease()) and 3 times in
> > > do_sys_truncate().
> > > 
> > > Would it perhaps make sense to package up the call to 
vfs_permission()
> > > and break_lease() as a single 'may_open()' inode operation that 
could be
> > > called by may_open(), do_sys_truncate() and nfsd?
> > 
> > Could be, but this may no longer make sense when we try to do
> > lease-breaking on rename and unlink.
> 
> Hmm... Clustered lease breaking on rename and unlink really needs to be
> done _atomically_ with the actual operation. It really needs to be done
> inside the ->rename() and ->unlink() operation because only the
> filesystem can guarantee atomicity.

A cluster filesystem don't need the inode operation breake_lease. The fs 
must be able to detect the conflict and break the lease using 
__break_lease() call on all the nodes that hold a conflicting leases.
Marc. 

> Thinking about it, perhaps the may_open() thing is wrong too: again, you
> have atomicity requirements inside the open() call. A break_lease()
> inode operation won't help either...
> 
> Trond
> 
> 
> 
-------------------------------------------------------------------------
> This SF.net email is sponsored by DB2 Express
> Download DB2 Express C - the FREE version of DB2 express and take
> control of your XML. No limits. Just data. Click to get it now.
> http://sourceforge.net/powerbar/db2/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

