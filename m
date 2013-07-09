Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45539 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751945Ab3GIUvR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jul 2013 16:51:17 -0400
Date: Tue, 9 Jul 2013 16:51:01 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org,
        Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>,
        David Howells <dhowells@redhat.com>,
        Tyler Hicks <tyhicks@canonical.com>,
        Dustin Kirkland <dustin.kirkland@gazzang.com>
Subject: Re: [PATCH 12/12] locks: break delegations on any attribute
 modification
Message-ID: <20130709205101.GK32574@pad.fieldses.org>
References: <1372882356-14168-1-git-send-email-bfields@redhat.com>
 <1372882356-14168-13-git-send-email-bfields@redhat.com>
 <20130709093047.0096f061@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130709093047.0096f061@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 09, 2013 at 09:30:47AM -0400, Jeff Layton wrote:
> On Wed,  3 Jul 2013 16:12:36 -0400
> "J. Bruce Fields" <bfields@redhat.com> wrote:
> 
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > NFSv4 uses leases to guarantee that clients can cache metadata as well
> > as data.
> > 
> > Cc: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
> > Cc: David Howells <dhowells@redhat.com>
> > Cc: Tyler Hicks <tyhicks@canonical.com>
> > Cc: Dustin Kirkland <dustin.kirkland@gazzang.com>
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  drivers/base/devtmpfs.c   |    4 ++--
> >  fs/attr.c                 |    5 ++++-
> >  fs/cachefiles/interface.c |    4 ++--
> >  fs/ecryptfs/inode.c       |    2 +-
> >  fs/hpfs/namei.c           |    2 +-
> >  fs/inode.c                |    6 +++++-
> >  fs/nfsd/vfs.c             |    8 ++++++--
> >  fs/open.c                 |   21 +++++++++++++++++----
> >  fs/utimes.c               |    9 ++++++++-
> >  include/linux/fs.h        |    2 +-
> >  10 files changed, 47 insertions(+), 16 deletions(-)
> > 
> > diff --git a/drivers/base/devtmpfs.c b/drivers/base/devtmpfs.c
> > index 1b8490e..0f38201 100644
> > --- a/drivers/base/devtmpfs.c
> > +++ b/drivers/base/devtmpfs.c
> > @@ -216,7 +216,7 @@ static int handle_create(const char *nodename, umode_t mode, kuid_t uid,
> >  		newattrs.ia_gid = gid;
> >  		newattrs.ia_valid = ATTR_MODE|ATTR_UID|ATTR_GID;
> >  		mutex_lock(&dentry->d_inode->i_mutex);
> > -		notify_change(dentry, &newattrs);
> > +		notify_change(dentry, &newattrs, NULL);
> >  		mutex_unlock(&dentry->d_inode->i_mutex);
> >  
> >  		/* mark as kernel-created inode */
> > @@ -322,7 +322,7 @@ static int handle_remove(const char *nodename, struct device *dev)
> >  			newattrs.ia_valid =
> >  				ATTR_UID|ATTR_GID|ATTR_MODE;
> >  			mutex_lock(&dentry->d_inode->i_mutex);
> > -			notify_change(dentry, &newattrs);
> > +			notify_change(dentry, &newattrs, NULL);
> >  			mutex_unlock(&dentry->d_inode->i_mutex);
> >  			err = vfs_unlink(parent.dentry->d_inode, dentry, NULL);
> >  			if (!err || err == -ENOENT)
> > diff --git a/fs/attr.c b/fs/attr.c
> > index 1449adb..261f5c9 100644
> > --- a/fs/attr.c
> > +++ b/fs/attr.c
> > @@ -167,7 +167,7 @@ void setattr_copy(struct inode *inode, const struct iattr *attr)
> >  }
> >  EXPORT_SYMBOL(setattr_copy);
> >  
> > -int notify_change(struct dentry * dentry, struct iattr * attr)
> > +int notify_change(struct dentry * dentry, struct iattr * attr, struct inode **delegated_inode)
> >  {
> >  	struct inode *inode = dentry->d_inode;
> >  	umode_t mode = inode->i_mode;
> > @@ -243,6 +243,9 @@ int notify_change(struct dentry * dentry, struct iattr * attr)
> >  	error = security_inode_setattr(dentry, attr);
> >  	if (error)
> >  		return error;
> > +	error = try_break_deleg(inode, delegated_inode);
> > +	if (error)
> > +		return error;
> >  
> >  	if (inode->i_op->setattr)
> >  		error = inode->i_op->setattr(dentry, attr);
> > diff --git a/fs/cachefiles/interface.c b/fs/cachefiles/interface.c
> > index 746ce53..40f5917 100644
> > --- a/fs/cachefiles/interface.c
> > +++ b/fs/cachefiles/interface.c
> > @@ -417,14 +417,14 @@ static int cachefiles_attr_changed(struct fscache_object *_object)
> >  		_debug("discard tail %llx", oi_size);
> >  		newattrs.ia_valid = ATTR_SIZE;
> >  		newattrs.ia_size = oi_size & PAGE_MASK;
> > -		ret = notify_change(object->backer, &newattrs);
> > +		ret = notify_change(object->backer, &newattrs, NULL);
> >  		if (ret < 0)
> >  			goto truncate_failed;
> >  	}
> >  
> >  	newattrs.ia_valid = ATTR_SIZE;
> >  	newattrs.ia_size = ni_size;
> > -	ret = notify_change(object->backer, &newattrs);
> > +	ret = notify_change(object->backer, &newattrs, NULL);
> >  
> >  truncate_failed:
> >  	mutex_unlock(&object->backer->d_inode->i_mutex);
> > diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
> > index 19e4435..bd54575 100644
> > --- a/fs/ecryptfs/inode.c
> > +++ b/fs/ecryptfs/inode.c
> > @@ -992,7 +992,7 @@ static int ecryptfs_setattr(struct dentry *dentry, struct iattr *ia)
> >  		lower_ia.ia_valid &= ~ATTR_MODE;
> >  
> >  	mutex_lock(&lower_dentry->d_inode->i_mutex);
> > -	rc = notify_change(lower_dentry, &lower_ia);
> > +	rc = notify_change(lower_dentry, &lower_ia, NULL);
> >  	mutex_unlock(&lower_dentry->d_inode->i_mutex);
> >  out:
> >  	fsstack_copy_attr_all(inode, lower_inode);
> > diff --git a/fs/hpfs/namei.c b/fs/hpfs/namei.c
> > index 345713d..1b39afd 100644
> > --- a/fs/hpfs/namei.c
> > +++ b/fs/hpfs/namei.c
> > @@ -407,7 +407,7 @@ again:
> >  			/*printk("HPFS: truncating file before delete.\n");*/
> >  			newattrs.ia_size = 0;
> >  			newattrs.ia_valid = ATTR_SIZE | ATTR_CTIME;
> > -			err = notify_change(dentry, &newattrs);
> > +			err = notify_change(dentry, &newattrs, NULL);
> >  			put_write_access(inode);
> >  			if (!err)
> >  				goto again;
> > diff --git a/fs/inode.c b/fs/inode.c
> > index 304db4c..664d631 100644
> > --- a/fs/inode.c
> > +++ b/fs/inode.c
> > @@ -1633,7 +1633,11 @@ static int __remove_suid(struct dentry *dentry, int kill)
> >  	struct iattr newattrs;
> >  
> >  	newattrs.ia_valid = ATTR_FORCE | kill;
> > -	return notify_change(dentry, &newattrs);
> > +	/*
> > +	 * Note we call this on write, so notify_change will not
> > +	 * encounter any conflicting delegations:
> > +	 */
> > +	return notify_change(dentry, &newattrs, NULL);
> >  }
> >  
> >  int file_remove_suid(struct file *file)
> > diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> > index b9740cb..e781901 100644
> > --- a/fs/nfsd/vfs.c
> > +++ b/fs/nfsd/vfs.c
> > @@ -426,7 +426,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
> >  			goto out_nfserr;
> >  		fh_lock(fhp);
> >  
> > -		host_err = notify_change(dentry, iap);
> > +		host_err = notify_change(dentry, iap, NULL);
> >  		err = nfserrno(host_err);
> >  		fh_unlock(fhp);
> >  	}
> > @@ -959,7 +959,11 @@ static void kill_suid(struct dentry *dentry)
> >  	ia.ia_valid = ATTR_KILL_SUID | ATTR_KILL_SGID | ATTR_KILL_PRIV;
> >  
> >  	mutex_lock(&dentry->d_inode->i_mutex);
> > -	notify_change(dentry, &ia);
> > +	/*
> > +	 * Note we call this on write, so notify_change will not
> > +	 * encounter any conflicting delegations:
> > +	 */
> > +	notify_change(dentry, &ia, NULL);
> >  	mutex_unlock(&dentry->d_inode->i_mutex);
> >  }
> >  
> > diff --git a/fs/open.c b/fs/open.c
> > index 8c74100..1a39d29 100644
> > --- a/fs/open.c
> > +++ b/fs/open.c
> > @@ -57,7 +57,7 @@ int do_truncate(struct dentry *dentry, loff_t length, unsigned int time_attrs,
> >  		newattrs.ia_valid |= ret | ATTR_FORCE;
> >  
> >  	mutex_lock(&dentry->d_inode->i_mutex);
> > -	ret = notify_change(dentry, &newattrs);
> > +	ret = notify_change(dentry, &newattrs, NULL);
> >  	mutex_unlock(&dentry->d_inode->i_mutex);
> >  	return ret;
> >  }
> 
> Isn't it possible we'll need to break a delegation on truncate()?

In the truncate case, the caller called break_lease, and in the
ftruncate case it's called with a write open, and the open already broke
any leases or delegations.

Might need a comment--could I get away with just this?:

 	mutex_lock(&dentry->d_inode->i_mutex);
+	/* NULL is safe: any delegations have already been broken: */
 	ret = notify_change(dentry, &newattrs, NULL);
 	mutex_unlock(&dentry->d_inode->i_mutex);
 	return ret;

I also added something to the notify_change kerneldoc: "passing NULL is
fine for callers holding the file open for write, as there can be no
conflicting delegation in that case."

--b.
