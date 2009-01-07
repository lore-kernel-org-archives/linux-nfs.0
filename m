From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsd stuckage
Date: Tue, 6 Jan 2009 19:28:16 -0500
Message-ID: <20090107002816.GL13785@fieldses.org>
References: <20090106145612.d4d9948d.akpm@linux-foundation.org> <20090106230244.GB13785@fieldses.org> <20090106230356.GA31520@lst.de> <20090106230551.GC13785@fieldses.org> <20090107001501.GH13785@fieldses.org> <20090106162328.1b4511a6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hch@lst.de, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, neilb@suse.de, snakebyte@gmx.de
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:32850 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755609AbZAGA2T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jan 2009 19:28:19 -0500
In-Reply-To: <20090106162328.1b4511a6.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 06, 2009 at 04:23:28PM -0800, Andrew Morton wrote:
> On Tue, 6 Jan 2009 19:15:01 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> >     nfsd: fix double-locks of directory mutex
> 
> grumble.

This is literally just a revert of part of 4c728ef583b3d822; if you'd
like me to clean up this stuff while I'm there, I'm happy to.

--b.

> > +/*
> > + * Sync a file
> > + * As this calls fsync (not fdatasync) there is no need for a write_inode
> > + * after it.
> > + */
> > +static inline int nfsd_dosync(struct file *filp, struct dentry *dp,
> > +			      const struct file_operations *fop)
> > +{
> > +	struct inode *inode = dp->d_inode;
> > +	int (*fsync) (struct file *, struct dentry *, int);
> > +	int err;
> > +
> > +	err = filemap_fdatawrite(inode->i_mapping);
> > +	if (err == 0 && fop && (fsync = fop->fsync))
> > +		err = fsync(filp, dp, 0);
> > +	if (err == 0)
> > +		err = filemap_fdatawait(inode->i_mapping);
> > +
> > +	return err;
> > +}
> 
> This function is HUGE!  And hardly a fastpath.
> 
> >  static int
> >  nfsd_sync(struct file *filp)
> >  {
> > -	return vfs_fsync(filp, filp->f_path.dentry, 0);
> > +        int err;
> > +	struct inode *inode = filp->f_path.dentry->d_inode;
> > +	dprintk("nfsd: sync file %s\n", filp->f_path.dentry->d_name.name);
> > +	mutex_lock(&inode->i_mutex);
> > +	err=nfsd_dosync(filp, filp->f_path.dentry, filp->f_op);
> 
> (checkpatch?)
> 
> > +	mutex_unlock(&inode->i_mutex);
> > +
> > +	return err;
> >  }
> >  
> >  int
> > -nfsd_sync_dir(struct dentry *dentry)
> > +nfsd_sync_dir(struct dentry *dp)
> >  {
> > -	return vfs_fsync(NULL, dentry, 0);
> > +	return nfsd_dosync(NULL, dp, dp->d_inode->i_fop);
> >  }
> 
> And we expand it twice.  
