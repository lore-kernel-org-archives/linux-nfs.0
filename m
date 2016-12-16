Return-Path: <jlayton@poochiereds.net>
Message-ID: <1481898915.2639.5.camel@poochiereds.net>
Subject: Re: [PATCH] NFS: nfs_rename() handle -ERESTARTSYS dentry left behind
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trondmy@primarydata.com>,
        Benjamin Coddington
	 <bcodding@redhat.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List
	 <linux-nfs@vger.kernel.org>
Date: Fri, 16 Dec 2016 09:35:15 -0500
In-Reply-To: <EEF3255C-18B5-411E-B9AB-8D065C65CC08@primarydata.com>
References: 
	<11625082826baa811b3ad5b87e1e6e712c6e582d.1481813137.git.bcodding@redhat.com>
	 <CC105B3B-3E0E-4266-9BF2-E61A648BD3AD@primarydata.com>
	 <7D53DC24-3DA9-40BB-BF6E-6DF03A7A0852@redhat.com>
	 <EEF3255C-18B5-411E-B9AB-8D065C65CC08@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-12-16 at 14:23 +0000, Trond Myklebust wrote:
> > 
> > On Dec 16, 2016, at 06:09, Benjamin Coddington <bcodding@redhat.com> wrote:
> > 
> > On 15 Dec 2016, at 17:38, Trond Myklebust wrote:
> > 
> > > 
> > > > 
> > > > On Dec 15, 2016, at 09:48, Benjamin Coddington <bcodding@redhat.com> wrote:
> > > > 
> > > > An interrupted rename will leave the old dentry behind if the rename
> > > > succeeds.  Fix this by forcing a lookup the next time through
> > > > ->d_revalidate.
> > > > 
> > > > Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> > > > ---
> > > > fs/nfs/dir.c | 14 ++++++++++++--
> > > > 1 file changed, 12 insertions(+), 2 deletions(-)
> > > > 
> > > > diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> > > > index 5f1af4cd1a33..5d409616f77e 100644
> > > > --- a/fs/nfs/dir.c
> > > > +++ b/fs/nfs/dir.c
> > > > @@ -2100,14 +2100,24 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
> > > > 		d_rehash(rehash);
> > > > 	trace_nfs_rename_exit(old_dir, old_dentry,
> > > > 			new_dir, new_dentry, error);
> > > > -	if (!error) {
> > > > +
> > > > +	switch (error) {
> > > > +	case 0:
> > > > 		if (new_inode != NULL)
> > > > 			nfs_drop_nlink(new_inode);
> > > > 		d_move(old_dentry, new_dentry);
> > > > 		nfs_set_verifier(new_dentry,
> > > > 					nfs_save_change_attribute(new_dir));
> > > > -	} else if (error == -ENOENT)
> > > > +		break;
> > > > +	case -ENOENT:
> > > > 		nfs_dentry_handle_enoent(old_dentry);
> > > > +		break;
> > > > +	case -ERESTARTSYS:
> > > > +		/* The result of the rename is unknown. Play it safe by
> > > > +		 * forcing a new lookup */
> > > > +		nfs_force_lookup_revalidate(old_dir);
> > > > +		nfs_force_lookup_revalidate(new_dir);
> > > > +	}
> > > 
> > > Doesn’t this error handling belong in nfs_async_rename_done(), or possibly in its “data->complete()” callback? There isn’t much point in forcing a new lookup until we know the RPC call has run its course.
> > 
> > That would be more correct, however if moved there, we'd be forcing a lookup after every rename, not just a rename that was signaled.  Is it worth trying to find a way to inform those functions that the wait was interrupted?
> > 
> 
> There are already precedents for this. Look, for instance, at how the data->cancelled flag interoperates between nfs4_run_open_task() and 
> nfs4_open_release() to trigger state recovery (by issuing a close) if the RPC call was completed, but the user interrupted the operation.
> 
> Cheers
>   Trond

There is the timing to consider here as well. Once you return from this
function the vfs is going to unlock everything without doing the d_move.

Is it better to mark the directories for revalidation at that point, or
when the RENAME reply comes in? I would think that marking it for reval
immediately would be best. Is there an argument for waiting?

-- 
Jeff Layton <jlayton@poochiereds.net>
