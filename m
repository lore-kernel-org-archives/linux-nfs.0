Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57649 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753782Ab3GINHE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jul 2013 09:07:04 -0400
Date: Tue, 9 Jul 2013 09:07:00 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        David Howells <dhowells@redhat.com>,
        Tyler Hicks <tyhicks@canonical.com>,
        Dustin Kirkland <dustin.kirkland@gazzang.com>
Subject: Re: [PATCH 08/12] locks: break delegations on unlink
Message-ID: <20130709090700.4995a648@tlielax.poochiereds.net>
In-Reply-To: <20130709090506.71c96841@tlielax.poochiereds.net>
References: <1372882356-14168-1-git-send-email-bfields@redhat.com>
	<1372882356-14168-9-git-send-email-bfields@redhat.com>
	<20130709090506.71c96841@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 9 Jul 2013 09:05:06 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> On Wed,  3 Jul 2013 16:12:32 -0400
> "J. Bruce Fields" <bfields@redhat.com> wrote:
> 
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > We need to break delegations on any operation that changes the set of
> > links pointing to an inode.  Start with unlink.
> > 
> > Such operations also hold the i_mutex on a parent directory.  Breaking a
> > delegation may require waiting for a timeout (by default 90 seconds) in
> > the case of a unresponsive NFS client.  To avoid blocking all directory
> > operations, we therefore drop locks before waiting for the delegation.
> > The logic then looks like:
> > 
> > 	acquire locks
> > 	...
> > 	test for delegation; if found:
> > 		take reference on inode
> > 		release locks
> > 		wait for delegation break
> > 		drop reference on inode
> > 		retry
> > 
> > It is possible this could never terminate.  (Even if we take precautions
> > to prevent another delegation being acquired on the same inode, we could
> > get a different inode on each retry.)  But this seems very unlikely.
> > 
> > The initial test for a delegation happens after the lock on the target
> > inode is acquired, but the directory inode may have been acquired
> > further up the call stack.  We therefore add a "struct inode **"
> > argument to any intervening functions, which we use to pass the inode
> > back up to the caller in the case it needs a delegation synchronously
> > broken.
> > 
> > Cc: David Howells <dhowells@redhat.com>
> > Cc: Tyler Hicks <tyhicks@canonical.com>
> > Cc: Dustin Kirkland <dustin.kirkland@gazzang.com>
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  drivers/base/devtmpfs.c |    2 +-
> >  fs/cachefiles/namei.c   |    2 +-
> >  fs/ecryptfs/inode.c     |    2 +-
> >  fs/namei.c              |   24 +++++++++++++++++++++---
> >  fs/nfsd/vfs.c           |    2 +-
> >  include/linux/fs.h      |    2 +-
> >  ipc/mqueue.c            |    2 +-
> >  7 files changed, 27 insertions(+), 9 deletions(-)
> > 
> > diff --git a/drivers/base/devtmpfs.c b/drivers/base/devtmpfs.c
> > index 7413d06..1b8490e 100644
> > --- a/drivers/base/devtmpfs.c
> > +++ b/drivers/base/devtmpfs.c
> > @@ -324,7 +324,7 @@ static int handle_remove(const char *nodename, struct device *dev)
> >  			mutex_lock(&dentry->d_inode->i_mutex);
> >  			notify_change(dentry, &newattrs);
> >  			mutex_unlock(&dentry->d_inode->i_mutex);
> > -			err = vfs_unlink(parent.dentry->d_inode, dentry);
> > +			err = vfs_unlink(parent.dentry->d_inode, dentry, NULL);
> >  			if (!err || err == -ENOENT)
> >  				deleted = 1;
> >  		}
> > diff --git a/fs/cachefiles/namei.c b/fs/cachefiles/namei.c
> > index 8c01c5fc..d61d884 100644
> > --- a/fs/cachefiles/namei.c
> > +++ b/fs/cachefiles/namei.c
> > @@ -294,7 +294,7 @@ static int cachefiles_bury_object(struct cachefiles_cache *cache,
> >  		if (ret < 0) {
> >  			cachefiles_io_error(cache, "Unlink security error");
> >  		} else {
> > -			ret = vfs_unlink(dir->d_inode, rep);
> > +			ret = vfs_unlink(dir->d_inode, rep, NULL);
> >  
> >  			if (preemptive)
> >  				cachefiles_mark_object_buried(cache, rep);
> > diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
> > index 5eab400..af42d88 100644
> > --- a/fs/ecryptfs/inode.c
> > +++ b/fs/ecryptfs/inode.c
> > @@ -153,7 +153,7 @@ static int ecryptfs_do_unlink(struct inode *dir, struct dentry *dentry,
> >  
> >  	dget(lower_dentry);
> >  	lower_dir_dentry = lock_parent(lower_dentry);
> > -	rc = vfs_unlink(lower_dir_inode, lower_dentry);
> > +	rc = vfs_unlink(lower_dir_inode, lower_dentry, NULL);
> >  	if (rc) {
> >  		printk(KERN_ERR "Error in vfs_unlink; rc = [%d]\n", rc);
> >  		goto out_unlock;
> > diff --git a/fs/namei.c b/fs/namei.c
> > index 7e76fe1..cba3db1 100644
> > --- a/fs/namei.c
> > +++ b/fs/namei.c
> > @@ -3384,7 +3384,7 @@ SYSCALL_DEFINE1(rmdir, const char __user *, pathname)
> >  	return do_rmdir(AT_FDCWD, pathname);
> >  }
> >  
> > -int vfs_unlink(struct inode *dir, struct dentry *dentry)
> > +int vfs_unlink(struct inode *dir, struct dentry *dentry, struct inode **delegated_inode)
> 
> nit: this might be a good time to add a kerneldoc header on this
> function. The delegated_inode thing might not be clear to the
> uninitiated.
> 
> >  {
> >  	struct inode *target = dentry->d_inode;
> >  	int error = may_delete(dir, dentry, 0);
> > @@ -3401,11 +3401,20 @@ int vfs_unlink(struct inode *dir, struct dentry *dentry)
> >  	else {
> >  		error = security_inode_unlink(dir, dentry);
> >  		if (!error) {
> > +			error = break_deleg(target, O_WRONLY|O_NONBLOCK);
> > +			if (error) {
> > +				if (error == -EWOULDBLOCK && delegated_inode) {
> > +					*delegated_inode = target;
> > +					ihold(target);
> > +				}
> > +				goto out;
> > +			}
> >  			error = dir->i_op->unlink(dir, dentry);
> >  			if (!error)
> >  				dont_mount(dentry);
> >  		}
> >  	}
> > +out:
> >  	mutex_unlock(&target->i_mutex);
> >  
> >  	/* We don't d_delete() NFS sillyrenamed files--they still exist. */
> > @@ -3430,6 +3439,7 @@ static long do_unlinkat(int dfd, const char __user *pathname)
> >  	struct dentry *dentry;
> >  	struct nameidata nd;
> >  	struct inode *inode = NULL;
> > +	struct inode *delegated_inode = NULL;
> >  	unsigned int lookup_flags = 0;
> >  retry:
> >  	name = user_path_parent(dfd, pathname, &nd, lookup_flags);
> > @@ -3444,7 +3454,7 @@ retry:
> >  	error = mnt_want_write(nd.path.mnt);
> >  	if (error)
> >  		goto exit1;
> > -
> > +retry_deleg:
> >  	mutex_lock_nested(&nd.path.dentry->d_inode->i_mutex, I_MUTEX_PARENT);
> >  	dentry = lookup_hash(&nd);
> >  	error = PTR_ERR(dentry);
> > @@ -3459,13 +3469,21 @@ retry:
> >  		error = security_path_unlink(&nd.path, dentry);
> >  		if (error)
> >  			goto exit2;
> > -		error = vfs_unlink(nd.path.dentry->d_inode, dentry);
> > +		error = vfs_unlink(nd.path.dentry->d_inode, dentry, &delegated_inode);
> >  exit2:
> >  		dput(dentry);
> >  	}
> >  	mutex_unlock(&nd.path.dentry->d_inode->i_mutex);
> >  	if (inode)
> >  		iput(inode);	/* truncate the inode here */
> > +	inode = NULL;
> > +	if (delegated_inode) {
> > +		error = break_deleg(delegated_inode, O_WRONLY);
> > +		iput(delegated_inode);
> > +		delegated_inode = NULL;
> > +		if (!error)
> > +			goto retry_deleg;
> > +	}
> >  	mnt_drop_write(nd.path.mnt);
> >  exit1:
> >  	path_put(&nd.path);
> > diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> > index 84ce601..6ccaca2 100644
> > --- a/fs/nfsd/vfs.c
> > +++ b/fs/nfsd/vfs.c
> > @@ -1882,7 +1882,7 @@ nfsd_unlink(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
> >  	if (host_err)
> >  		goto out_put;
> >  	if (type != S_IFDIR)
> > -		host_err = vfs_unlink(dirp, rdentry);
> > +		host_err = vfs_unlink(dirp, rdentry, NULL);
> >  	else
> >  		host_err = vfs_rmdir(dirp, rdentry);
> >  	if (!host_err)
> > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > index c6cc686..f951588 100644
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -1463,7 +1463,7 @@ extern int vfs_mknod(struct inode *, struct dentry *, umode_t, dev_t);
> >  extern int vfs_symlink(struct inode *, struct dentry *, const char *);
> >  extern int vfs_link(struct dentry *, struct inode *, struct dentry *);
> >  extern int vfs_rmdir(struct inode *, struct dentry *);
> > -extern int vfs_unlink(struct inode *, struct dentry *);
> > +extern int vfs_unlink(struct inode *, struct dentry *, struct inode **);
> >  extern int vfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *);
> >  
> >  /*
> > diff --git a/ipc/mqueue.c b/ipc/mqueue.c
> > index e4e47f6..384eb35 100644
> > --- a/ipc/mqueue.c
> > +++ b/ipc/mqueue.c
> > @@ -884,7 +884,7 @@ SYSCALL_DEFINE1(mq_unlink, const char __user *, u_name)
> >  		err = -ENOENT;
> >  	} else {
> >  		ihold(inode);
> > -		err = vfs_unlink(dentry->d_parent->d_inode, dentry);
> > +		err = vfs_unlink(dentry->d_parent->d_inode, dentry, NULL);
> >  	}
> >  	dput(dentry);
> >  
> 
> We probably also ought to eyeball some of these other cases where you
> passing in NULL as the deleg_inode too. It's probably reasonable in
> most cases -- exporting a filesystem that you also mount using ecryptfs
> seems silly, but you never know...
> Looks reasonable otherwise, if a little convoluted.
> 

My apologies -- one of my gripes with claws-mail is that "ctrl+return"
is "Send", and I occasionally fat-finger it. Anyway...

Acked-by: Jeff Layton <jlayton@redhat.com>
