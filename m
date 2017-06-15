Return-Path: <jlayton@poochiereds.net>
Message-ID: <1497553607.4607.13.camel@poochiereds.net>
Subject: Re: [PATCH 2/2] NFS: nfs_rename() - revalidate directories on
 -ERESTARTSYS
From: Jeff Layton <jlayton@poochiereds.net>
To: Benjamin Coddington <bcodding@redhat.com>, Trond Myklebust
 <trond.myklebust@primarydata.com>, Anna Schumaker
 <anna.schumaker@netapp.com>
Cc: mszeredi@redhat.com, bfields@redhat.com, linux-nfs@vger.kernel.org
Date: Thu, 15 Jun 2017 15:06:47 -0400
In-Reply-To: <1497550694.4607.10.camel@redhat.com>
References: <cover.1497541002.git.bcodding@redhat.com>
	 <32ef5d3ded4fe75bb6fc6e1a1aebdd0297257d9e.1497541002.git.bcodding@redhat.com>
	 <1497550694.4607.10.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2017-06-15 at 14:18 -0400, Jeff Layton wrote:
> On Thu, 2017-06-15 at 12:13 -0400, Benjamin Coddington wrote:
> > An interrupted rename will leave the old dentry behind if the rename
> > succeeds.  Fix this by forcing a lookup the next time through
> > ->d_revalidate.
> > 
> > A previous attempt at solving this problem took the approach to complete
> > the work of the rename asynchronously, however that approach was wrong
> > since it would allow the d_move() to occur after the directory's i_mutex
> > had been dropped by the original process.
> > 
> > Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> > ---
> >  fs/nfs/dir.c            | 2 ++
> >  fs/nfs/unlink.c         | 7 +++++++
> >  include/linux/nfs_xdr.h | 1 +
> >  3 files changed, 10 insertions(+)
> > 
> > diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> > index 1faf337b316f..bb697e5c3f6c 100644
> > --- a/fs/nfs/dir.c
> > +++ b/fs/nfs/dir.c
> > @@ -2037,6 +2037,8 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
> >  	error = rpc_wait_for_completion_task(task);
> >  	if (error == 0)
> >  		error = task->tk_status;
> > +	else
> > +		((struct nfs_renamedata *)task->tk_calldata)->cancelled = 1;
> 
> This looks a bit racy. You could end up setting cancelled just after the
> reply comes in and the completion callback checks it. I think that you
> probably either want to do this with an atomic operation or under a lock
> of some sort.
> 
> You could probably do it with an xchg() operation?
> 

As Ben pointed out on IRC, that flag is checked in rpc_release, so as
long as we ensure that it's set while we hold a task reference we should
be fine here without any locking.

That said, do we need a barrier here? We do need to ensure that
cancelled is set before the rpc_put_task occurs.

> >  	rpc_put_task(task);
> >  	nfs_mark_for_revalidate(old_inode);
> >  out:
> > diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
> > index 191aa577dd1f..b47158a34879 100644
> > --- a/fs/nfs/unlink.c
> > +++ b/fs/nfs/unlink.c
> > @@ -288,6 +288,13 @@ static void nfs_async_rename_release(void *calldata)
> >  	if (d_really_is_positive(data->old_dentry))
> >  		nfs_mark_for_revalidate(d_inode(data->old_dentry));
> >  
> > +	/* The result of the rename is unknown. Play it safe by
> > +	 * forcing a new lookup */
> > +	if (data->cancelled) {
> > +		nfs_force_lookup_revalidate(data->old_dir);
> > +		nfs_force_lookup_revalidate(data->new_dir);
> > +	}
> > +
> >  	dput(data->old_dentry);
> >  	dput(data->new_dentry);
> >  	iput(data->old_dir);
> > diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> > index b28c83475ee8..2a8406b4b353 100644
> > --- a/include/linux/nfs_xdr.h
> > +++ b/include/linux/nfs_xdr.h
> > @@ -1533,6 +1533,7 @@ struct nfs_renamedata {
> >  	struct nfs_fattr	new_fattr;
> >  	void (*complete)(struct rpc_task *, struct nfs_renamedata *);
> >  	long timeout;
> > +	int cancelled;
> 
> No need for a whole int for a flag and these do get allocated. Make it a
> bool?
> 
> >  };
> >  
> >  struct nfs_access_entry;
> 
> 

-- 
Jeff Layton <jlayton@poochiereds.net>
