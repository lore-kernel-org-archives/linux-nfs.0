From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/2] commit_metadata export operation replacing
	nfsd_sync_dir
Date: Fri, 12 Feb 2010 12:31:06 -0500
Message-ID: <20100212173106.GA22633@infradead.org>
References: <20100211220454.26466.37578.stgit@case> <20100211220500.26466.24169.stgit@case> <1265984620.3201.73.camel@doink1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Myers <bpm@sgi.com>, bfields@fieldses.org,
	linux-nfs@vger.kernel.org, xfs@oss.sgi.com
To: Alex Elder <aelder@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:43960 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752711Ab0BLRbJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Feb 2010 12:31:09 -0500
In-Reply-To: <1265984620.3201.73.camel@doink1>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> In the cases you pass the child dentry, you will now be syncing
> things to disk in a slightly different way/order from before.
> I think this way is actually much better, but I thought I'd ask
> anyway:  are you sure that it's OK to sync them at the same time,
> rather than directory first, then child (or the other way around,
> depending on the case)?

The order is defined by when we commit the transactions, if we do
the log force on the later one first we already write out the first
transaction.  Note that in any transaction filesystems the changes
that create/mkdir/link/unlink do to parent and child will be in
the same transaction anyway, which is kinda the point of adding
the transactions to start with.  Only for the case where we do
a setattr in addition to the primary transaction we'll actually
have another transaction to deal with and the above applies.

> >  nfsd4_sync_rec_dir(void)
> >  {
> > -	mutex_lock(&rec_dir.dentry->d_inode->i_mutex);
> > -	nfsd_sync_dir(rec_dir.dentry);
> > -	mutex_unlock(&rec_dir.dentry->d_inode->i_mutex);
> > +	vfs_fsync(NULL, rec_dir.dentry, 0);
> 
> Why do you no longer need to acquire the mutex here?
> I see it gets acquired during the ->fsync() call
> inside vfs_fsync_range(), but is there a reason
> that it needed to be held during the filemap_write_and_wait()
> (as is done in the nfsd_sync_dir() code) also?

We don't need i_mutex for filemap_write_and_wait, it's just held
because someone used the nfsd_sync_dir helper where it doesn't
fit very well.

> > @@ -415,9 +449,8 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
> >  	}
> >  	if (size_change)
> >  		put_write_access(inode);
> > -	if (!err)
> > -		if (EX_ISSYNC(fhp->fh_export))
> > -			write_inode_now(inode, 1);
> > +	if (!err && !delay_commit)
> > +		err = nfserrno(commit_metadata(fhp, NULL));
> 
> Is this sufficient even if the size has changed?

Yes.

