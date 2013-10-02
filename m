Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cobra.newdream.net ([66.33.216.30]:58467 "EHLO
	cobra.newdream.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754017Ab3JBTEt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Oct 2013 15:04:49 -0400
Date: Wed, 2 Oct 2013 12:04:49 -0700 (PDT)
From: Sage Weil <sage@inktank.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
cc: Christoph Hellwig <hch@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        sandeen@redhat.com
Subject: Re: why is i_ino unsigned long, anyway?
In-Reply-To: <20131002190034.GH14808@fieldses.org>
Message-ID: <alpine.DEB.2.00.1310021204190.12714@cobra.newdream.net>
References: <20130912160324.GE1462@fieldses.org> <20130912193328.GP13318@ZenIV.linux.org.uk> <20130929115454.GA3953@infradead.org> <20131002142527.GD14808@fieldses.org> <20131002160527.GB23875@infradead.org> <20131002175328.GF14808@fieldses.org>
 <alpine.DEB.2.00.1310021130280.7765@cobra.newdream.net> <20131002190034.GH14808@fieldses.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2 Oct 2013, J. Bruce Fields wrote:
> On Wed, Oct 02, 2013 at 11:47:22AM -0700, Sage Weil wrote:
> > On Wed, 2 Oct 2013, J. Bruce Fields wrote:
> > > On Wed, Oct 02, 2013 at 09:05:27AM -0700, Christoph Hellwig wrote:
> > > > On Wed, Oct 02, 2013 at 10:25:27AM -0400, J. Bruce Fields wrote:
> > > > > If so then it's no huge code duplication to it by hand:
> > > > > 
> > > > > 	if (inode->i_op->getattr)
> > > > > 		inode->i_op->getattr(path->mnt, path->dentry, &stat);
> > > > > 	else
> > > > > 		generic_fillattr(inode, &stat);
> > > > 
> > > > Maybe make that a vfs_getattr_nosec and let vfs_getattr call it?
> > > > 
> > > > Including a proper kerneldoc comment explaining when to use it, please.
> > > 
> > > Something like this?
> > 
> > I'm late to this thread, but: getattr() is a comparatively expensive 
> > operation for just getting an (immutable) ino value on a distributed or 
> > clustered fs.  It would be nice if there were a separate call that didn't 
> > try to populate all the other kstat fields with valid data.  Something 
> > like this was part of the xstat series from forever ago (a bit mask passed 
> > to getattr indicating which fields were needed), so the approach below 
> > might be okay if we think we'll get there sometime soon, but my preference 
> > would be for another fix...
> 
> Understood, and perhaps this code should eventually take advantage of
> xstat, but:
> 
> 	- this code isn't handling the common case, so we're not too
> 	  worried about the performance, and
> 	- you also have the option of defining your own
> 	  export_operations->get_name.  Especially consider that if you
> 	  have some better way to answer the question "what is the name
> 	  of inode X in directory Y" that's better than reading Y
> 	  looking for a matching inode number.

Ah, I see.  Sounds good then!

Thanks-
sage

> 
> --b.
> 
> > (Ceph also uses 64-bit inos.)
> > 
> > Thanks!
> > sage
> > 
> > 
> > > 
> > > --b.
> > > 
> > > commit 8418a41b7192cf2f372ae091207adb29a088f9a0
> > > Author: J. Bruce Fields <bfields@redhat.com>
> > > Date:   Tue Sep 10 11:41:12 2013 -0400
> > > 
> > >     exportfs: fix 32-bit nfsd handling of 64-bit inode numbers
> > >     
> > >     Symptoms were spurious -ENOENTs on stat of an NFS filesystem from a
> > >     32-bit NFS server exporting a very large XFS filesystem, when the
> > >     server's cache is cold (so the inodes in question are not in cache).
> > >     
> > >     Reported-by: Trevor Cordes <trevor@tecnopolis.ca>
> > >     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > > 
> > > diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
> > > index 293bc2e..811831a 100644
> > > --- a/fs/exportfs/expfs.c
> > > +++ b/fs/exportfs/expfs.c
> > > @@ -215,7 +215,7 @@ struct getdents_callback {
> > >  	struct dir_context ctx;
> > >  	char *name;		/* name that was found. It already points to a
> > >  				   buffer NAME_MAX+1 is size */
> > > -	unsigned long ino;	/* the inum we are looking for */
> > > +	u64 ino;		/* the inum we are looking for */
> > >  	int found;		/* inode matched? */
> > >  	int sequence;		/* sequence counter */
> > >  };
> > > @@ -255,10 +255,10 @@ static int get_name(const struct path *path, char *name, struct dentry *child)
> > >  	struct inode *dir = path->dentry->d_inode;
> > >  	int error;
> > >  	struct file *file;
> > > +	struct kstat stat;
> > >  	struct getdents_callback buffer = {
> > >  		.ctx.actor = filldir_one,
> > >  		.name = name,
> > > -		.ino = child->d_inode->i_ino
> > >  	};
> > >  
> > >  	error = -ENOTDIR;
> > > @@ -268,6 +268,16 @@ static int get_name(const struct path *path, char *name, struct dentry *child)
> > >  	if (!dir->i_fop)
> > >  		goto out;
> > >  	/*
> > > +	 * inode->i_ino is unsigned long, kstat->ino is u64, so the
> > > +	 * former would be insufficient on 32-bit hosts when the
> > > +	 * filesystem supports 64-bit inode numbers.  So we need to
> > > +	 * actually call ->getattr, not just read i_ino:
> > > +	 */
> > > +	error = vfs_getattr_nosec(path, &stat);
> > > +	if (error)
> > > +		return error;
> > > +	buffer.ino = stat.ino;
> > > +	/*
> > >  	 * Open the directory ...
> > >  	 */
> > >  	file = dentry_open(path, O_RDONLY, cred);
> > > diff --git a/fs/stat.c b/fs/stat.c
> > > index 04ce1ac..71a39e8 100644
> > > --- a/fs/stat.c
> > > +++ b/fs/stat.c
> > > @@ -37,14 +37,21 @@ void generic_fillattr(struct inode *inode, struct kstat *stat)
> > >  
> > >  EXPORT_SYMBOL(generic_fillattr);
> > >  
> > > -int vfs_getattr(struct path *path, struct kstat *stat)
> > > +/**
> > > + * vfs_getattr_nosec - getattr without security checks
> > > + * @path: file to get attributes from
> > > + * @stat: structure to return attributes in
> > > + *
> > > + * Get attributes without calling security_inode_getattr.
> > > + *
> > > + * Currently the only caller other than vfs_getattr is internal to the
> > > + * filehandle lookup code, which uses only the inode number and returns
> > > + * no attributes to any user.  Any other code probably wants
> > > + * vfs_getattr.
> > > + */
> > > +int vfs_getattr_nosec(struct path *path, struct kstat *stat)
> > >  {
> > >  	struct inode *inode = path->dentry->d_inode;
> > > -	int retval;
> > > -
> > > -	retval = security_inode_getattr(path->mnt, path->dentry);
> > > -	if (retval)
> > > -		return retval;
> > >  
> > >  	if (inode->i_op->getattr)
> > >  		return inode->i_op->getattr(path->mnt, path->dentry, stat);
> > > @@ -53,6 +60,18 @@ int vfs_getattr(struct path *path, struct kstat *stat)
> > >  	return 0;
> > >  }
> > >  
> > > +EXPORT_SYMBOL_GPL(vfs_getattr_nosec);
> > > +
> > > +int vfs_getattr(struct path *path, struct kstat *stat)
> > > +{
> > > +	int retval;
> > > +
> > > +	retval = security_inode_getattr(path->mnt, path->dentry);
> > > +	if (retval)
> > > +		return retval;
> > > +	return vfs_getattr_nosec(path, stat);
> > > +}
> > > +
> > >  EXPORT_SYMBOL(vfs_getattr);
> > >  
> > >  int vfs_fstat(unsigned int fd, struct kstat *stat)
> > > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > > index 9818747..5a51faa 100644
> > > --- a/include/linux/fs.h
> > > +++ b/include/linux/fs.h
> > > @@ -2500,6 +2500,7 @@ extern int page_symlink(struct inode *inode, const char *symname, int len);
> > >  extern const struct inode_operations page_symlink_inode_operations;
> > >  extern int generic_readlink(struct dentry *, char __user *, int);
> > >  extern void generic_fillattr(struct inode *, struct kstat *);
> > > +int vfs_getattr_nosec(struct path *path, struct kstat *stat);
> > >  extern int vfs_getattr(struct path *, struct kstat *);
> > >  void __inode_add_bytes(struct inode *inode, loff_t bytes);
> > >  void inode_add_bytes(struct inode *inode, loff_t bytes);
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > 
> > > 
> 
> 
