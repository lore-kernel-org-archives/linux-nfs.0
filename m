Return-Path: <jeff.layton@primarydata.com>
Date: Tue, 29 Dec 2015 08:34:33 -0500
From: Jeff Layton <jeff.layton@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker
 <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 03/10] NFS: Pass nfs_open_context instead of file to
 the lock procs
Message-ID: <20151229083433.61a8b3f0@tlielax.poochiereds.net>
In-Reply-To: <alpine.OSX.2.19.9992.1512290810470.87866@planck.local>
References: <cover.1451319354.git.bcodding@redhat.com>
	<bb069293c68a1685193ea85d0140356bf8234193.1451319354.git.bcodding@redhat.com>
	<20151228144449.6f4b1b77@tlielax.poochiereds.net>
	<alpine.OSX.2.19.9992.1512290810470.87866@planck.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 29 Dec 2015 08:24:56 -0500 (EST)
Benjamin Coddington <bcodding@redhat.com> wrote:

> On Mon, 28 Dec 2015, Jeff Layton wrote:
> 
> > On Mon, 28 Dec 2015 11:27:59 -0500
> > Benjamin Coddington <bcodding@redhat.com> wrote:
> >
> > > We only use the file struct pointer to obtain the nfs_open_context (or the
> > > inode for v2/v3), so just pass that instead.  This allows us to use the
> > > lock procedure without a reference to a struct file which may not be
> > > available while releasing locks after a file close.
> > >
> > > Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> >
> >
> > Hmm...
> >
> > So what pins the nfs_open_context in place after the filp is gone?
> >
> > AFAICT, that gets zapped when the struct file goes away. Is there any
> > chance that the ctx pointers you're passing around here might outlive
> > the structure to which they point?
> 
> Patch 9 sets up the only time we'll want to perform an unlock without a
> filp, and that is when that unlock has been deferred due to outstanding IO.
> When the IO completes, nfs_iocounter_dec() is called while holding a
> reference to a nfs_lock_context containing a reference to the
> nfs_open_context, and that final unlock is done while holding that
> reference.
> 
> Ben
> 

Ahh ok, I think I get it then...the nfs_open_context's refcount lives
in the lock_context. Complicated refcounting, but that predates this
patch. You can add:

Reviewed-by: Jeff Layton <jeff.layton@primarydata.com>

> > > ---
> > >  fs/nfs/file.c           |    9 ++++++---
> > >  fs/nfs/nfs3proc.c       |    4 ++--
> > >  fs/nfs/nfs4proc.c       |    4 +---
> > >  fs/nfs/proc.c           |    4 ++--
> > >  include/linux/nfs_xdr.h |    2 +-
> > >  5 files changed, 12 insertions(+), 11 deletions(-)
> > >
> > > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> > > index 1e4804b..5dec0fb 100644
> > > --- a/fs/nfs/file.c
> > > +++ b/fs/nfs/file.c
> > > @@ -711,6 +711,7 @@ static int
> > >  do_getlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
> > >  {
> > >  	struct inode *inode = filp->f_mapping->host;
> > > +	struct nfs_open_context *ctx = nfs_file_open_context(filp);
> > >  	int status = 0;
> > >  	unsigned int saved_type = fl->fl_type;
> > >
> > > @@ -728,7 +729,7 @@ do_getlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
> > >  	if (is_local)
> > >  		goto out_noconflict;
> > >
> > > -	status = NFS_PROTO(inode)->lock(filp, cmd, fl);
> > > +	status = NFS_PROTO(inode)->lock(ctx, cmd, fl);
> > >  out:
> > >  	return status;
> > >  out_noconflict:
> > > @@ -745,6 +746,7 @@ static int
> > >  do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
> > >  {
> > >  	struct inode *inode = filp->f_mapping->host;
> > > +	struct nfs_open_context *ctx = nfs_file_open_context(filp);
> > >  	struct nfs_lock_context *l_ctx;
> > >  	int status;
> > >
> > > @@ -771,7 +773,7 @@ do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
> > >  	 * "-olocal_lock="
> > >  	 */
> > >  	if (!is_local)
> > > -		status = NFS_PROTO(inode)->lock(filp, cmd, fl);
> > > +		status = NFS_PROTO(inode)->lock(ctx, cmd, fl);
> > >  	else
> > >  		status = do_vfs_lock(filp, fl);
> > >  	return status;
> > > @@ -786,6 +788,7 @@ static int
> > >  do_setlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
> > >  {
> > >  	struct inode *inode = filp->f_mapping->host;
> > > +	struct nfs_open_context *ctx = nfs_file_open_context(filp);
> > >  	int status;
> > >
> > >  	/*
> > > @@ -801,7 +804,7 @@ do_setlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
> > >  	 * "-olocal_lock="
> > >  	 */
> > >  	if (!is_local)
> > > -		status = NFS_PROTO(inode)->lock(filp, cmd, fl);
> > > +		status = NFS_PROTO(inode)->lock(ctx, cmd, fl);
> > >  	else
> > >  		status = do_vfs_lock(filp, fl);
> > >  	if (status < 0)
> > > diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
> > > index cb28cce..a10e147 100644
> > > --- a/fs/nfs/nfs3proc.c
> > > +++ b/fs/nfs/nfs3proc.c
> > > @@ -866,9 +866,9 @@ static void nfs3_proc_commit_setup(struct nfs_commit_data *data, struct rpc_mess
> > >  }
> > >
> > >  static int
> > > -nfs3_proc_lock(struct file *filp, int cmd, struct file_lock *fl)
> > > +nfs3_proc_lock(struct nfs_open_context *ctx, int cmd, struct file_lock *fl)
> > >  {
> > > -	struct inode *inode = file_inode(filp);
> > > +	struct inode *inode = d_inode(ctx->dentry);
> > >
> > >  	return nlmclnt_proc(NFS_SERVER(inode)->nlm_host, cmd, fl);
> > >  }
> > > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > > index 05ea1e1..784ba4e 100644
> > > --- a/fs/nfs/nfs4proc.c
> > > +++ b/fs/nfs/nfs4proc.c
> > > @@ -6097,15 +6097,13 @@ static int nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *
> > >  }
> > >
> > >  static int
> > > -nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
> > > +nfs4_proc_lock(struct nfs_open_context *ctx, int cmd, struct file_lock *request)
> > >  {
> > > -	struct nfs_open_context *ctx;
> > >  	struct nfs4_state *state;
> > >  	unsigned long timeout = NFS4_LOCK_MINTIMEOUT;
> > >  	int status;
> > >
> > >  	/* verify open state */
> > > -	ctx = nfs_file_open_context(filp);
> > >  	state = ctx->state;
> > >
> > >  	if (IS_GETLK(cmd)) {
> > > diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
> > > index b417bbc..185deb9 100644
> > > --- a/fs/nfs/proc.c
> > > +++ b/fs/nfs/proc.c
> > > @@ -634,9 +634,9 @@ nfs_proc_commit_setup(struct nfs_commit_data *data, struct rpc_message *msg)
> > >  }
> > >
> > >  static int
> > > -nfs_proc_lock(struct file *filp, int cmd, struct file_lock *fl)
> > > +nfs_proc_lock(struct nfs_open_context *ctx, int cmd, struct file_lock *fl)
> > >  {
> > > -	struct inode *inode = file_inode(filp);
> > > +	struct inode *inode = d_inode(ctx->dentry);
> > >
> > >  	return nlmclnt_proc(NFS_SERVER(inode)->nlm_host, cmd, fl);
> > >  }
> > > diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> > > index 11bbae4..58c4682 100644
> > > --- a/include/linux/nfs_xdr.h
> > > +++ b/include/linux/nfs_xdr.h
> > > @@ -1555,7 +1555,7 @@ struct nfs_rpc_ops {
> > >  	void	(*commit_setup) (struct nfs_commit_data *, struct rpc_message *);
> > >  	void	(*commit_rpc_prepare)(struct rpc_task *, struct nfs_commit_data *);
> > >  	int	(*commit_done) (struct rpc_task *, struct nfs_commit_data *);
> > > -	int	(*lock)(struct file *, int, struct file_lock *);
> > > +	int	(*lock)(struct nfs_open_context *, int, struct file_lock *);
> > >  	int	(*lock_check_bounds)(const struct file_lock *);
> > >  	void	(*clear_acl_cache)(struct inode *);
> > >  	void	(*close_context)(struct nfs_open_context *ctx, int);
> >
> >
> > --
> > Jeff Layton <jeff.layton@primarydata.com>
> >


-- 
Jeff Layton <jeff.layton@primarydata.com>
