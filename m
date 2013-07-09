Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47057 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752634Ab3GIQCy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jul 2013 12:02:54 -0400
Date: Tue, 9 Jul 2013 12:02:43 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        David Howells <dhowells@redhat.com>,
        Tyler Hicks <tyhicks@canonical.com>,
        Dustin Kirkland <dustin.kirkland@gazzang.com>
Subject: Re: [PATCH 08/12] locks: break delegations on unlink
Message-ID: <20130709120243.4c7ca1fc@tlielax.poochiereds.net>
In-Reply-To: <20130709155842.GC8281@fieldses.org>
References: <1372882356-14168-1-git-send-email-bfields@redhat.com>
	<1372882356-14168-9-git-send-email-bfields@redhat.com>
	<20130709090506.71c96841@tlielax.poochiereds.net>
	<20130709155842.GC8281@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 9 Jul 2013 11:58:43 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Jul 09, 2013 at 09:05:06AM -0400, Jeff Layton wrote:
> > On Wed,  3 Jul 2013 16:12:32 -0400
> > "J. Bruce Fields" <bfields@redhat.com> wrote:
> > 
> > > From: "J. Bruce Fields" <bfields@redhat.com>
> > > 
> > > We need to break delegations on any operation that changes the set of
> > > links pointing to an inode.  Start with unlink.
> > > 
> > > Such operations also hold the i_mutex on a parent directory.  Breaking a
> > > delegation may require waiting for a timeout (by default 90 seconds) in
> > > the case of a unresponsive NFS client.  To avoid blocking all directory
> > > operations, we therefore drop locks before waiting for the delegation.
> > > The logic then looks like:
> > > 
> > > 	acquire locks
> > > 	...
> > > 	test for delegation; if found:
> > > 		take reference on inode
> > > 		release locks
> > > 		wait for delegation break
> > > 		drop reference on inode
> > > 		retry
> > > 
> > > It is possible this could never terminate.  (Even if we take precautions
> > > to prevent another delegation being acquired on the same inode, we could
> > > get a different inode on each retry.)  But this seems very unlikely.
> > > 
> > > The initial test for a delegation happens after the lock on the target
> > > inode is acquired, but the directory inode may have been acquired
> > > further up the call stack.  We therefore add a "struct inode **"
> > > argument to any intervening functions, which we use to pass the inode
> > > back up to the caller in the case it needs a delegation synchronously
> > > broken.
> ...
> > > -int vfs_unlink(struct inode *dir, struct dentry *dentry)
> > > +int vfs_unlink(struct inode *dir, struct dentry *dentry, struct inode **delegated_inode)
> > 
> > nit: this might be a good time to add a kerneldoc header on this
> > function. The delegated_inode thing might not be clear to the
> > uninitiated.
> 
> Something like this?
> 
> --b.
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index cba3db1..7c6e244 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -3384,6 +3384,24 @@ SYSCALL_DEFINE1(rmdir, const char __user *, pathname)
>  	return do_rmdir(AT_FDCWD, pathname);
>  }
>  
> +/**
> + * vfs_unlink - unlink a filesystem object
> + * @dir:	parent directory
> + * @dentry:	victim
> + * @delegated_inode: returns victim inode, if the inode is delegated.
> + *
> + * The caller must hold dir->i_mutex.
> + *
> + * If vfs_unlink discovers a delegation, it will return -EWOULDBLOCK and
> + * return a reference to the inode in delegated_inode.  The caller
> + * should then break the delegation on that inode and retry.  Because
> + * breaking a delegation may take a long time, the caller should drop
> + * dir->i_mutex before doing so.
> + *
> + * Alternatively, a caller may pass NULL for delegated_inode.  This may
> + * be appropriate for callers that expect the underlying filesystem not
> + * to be NFS exported.
> + */
>  int vfs_unlink(struct inode *dir, struct dentry *dentry, struct inode **delegated_inode)
>  {
>  	struct inode *target = dentry->d_inode;

ACK -- looks good to me.
-- 
Jeff Layton <jlayton@redhat.com>
