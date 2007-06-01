From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [PATCH] locks: provide a file lease method enabling cluster-coherent leases
Date: Fri, 1 Jun 2007 12:53:17 -0400
Message-ID: <20070601165317.GE10492@fieldses.org>
References: <1180647624483-git-send-email-bfields@fieldses.org> <11806476252240-git-send-email-bfields@fieldses.org> <11806476252913-git-send-email-bfields@fieldses.org> <1180650849.7084.19.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org,
	David Teigland <teigland@redhat.com>,
	nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1180650849.7084.19.camel@heimdal.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, May 31, 2007 at 06:34:09PM -0400, Trond Myklebust wrote:
> On Thu, 2007-05-31 at 17:40 -0400, J. Bruce Fields wrote:
> > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > index 7cf0c54..09aefb4 100644
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -1112,6 +1112,7 @@ struct file_operations {
> >  	int (*flock) (struct file *, int, struct file_lock *);
> >  	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
> >  	ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
> > +	int (*set_lease)(struct file *, long, struct file_lock **);
> >  };
> >  
> >  struct inode_operations {
> > @@ -1137,6 +1138,7 @@ struct inode_operations {
> >  	ssize_t (*listxattr) (struct dentry *, char *, size_t);
> >  	int (*removexattr) (struct dentry *, const char *);
> >  	void (*truncate_range)(struct inode *, loff_t, loff_t);
> > +	int (*break_lease)(struct inode *, unsigned int);
> 
> Splitting the lease into a file_operation part and an inode_operation
> part looks really ugly.

Well, we could stick them both in the file_operations, of course, but I
think it really would be a bug for the behavior of the break_lease
operation to ever vary based on the file passed in.  (And we eventually
want to break leases in places like rename where we don't even have a
file.)

> It also means that you're calling twice down
> into the filesystem for every call to may_open() (once for
> vfs_permission() and once for break_lease()) and 3 times in
> do_sys_truncate().
> 
> Would it perhaps make sense to package up the call to vfs_permission()
> and break_lease() as a single 'may_open()' inode operation that could be
> called by may_open(), do_sys_truncate() and nfsd?

Could be, but this may no longer make sense when we try to do
lease-breaking on rename and unlink.

For the purposes of the current limited GFS2 implementation, we don't
even need a break operation yet.  So maybe that should just be split out
into a separate patch for now, and postpone dealing with this part until
we figure out how to do a full GFS2 lease implementation.

--b.
