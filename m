Return-Path: <jeff.layton@primarydata.com>
Date: Tue, 29 Dec 2015 09:55:43 -0500
From: Jeff Layton <jeff.layton@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker
 <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 05/10] lockd: Plumb nfs_open_context into nlm client
 unlock
Message-ID: <20151229095543.1f298ae1@tlielax.poochiereds.net>
In-Reply-To: <alpine.OSX.2.19.9992.1512290847360.87866@planck.local>
References: <cover.1451319354.git.bcodding@redhat.com>
	<df93190f75c88f920f7503ca912be404b592a165.1451319354.git.bcodding@redhat.com>
	<20151229084304.6b30c24f@tlielax.poochiereds.net>
	<alpine.OSX.2.19.9992.1512290847360.87866@planck.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 29 Dec 2015 09:08:00 -0500 (EST)
Benjamin Coddington <bcodding@redhat.com> wrote:

> > On Mon, 28 Dec 2015 11:28:01 -0500
> > Benjamin Coddington <bcodding@redhat.com> wrote:
> >
> > > We cannot depend on a file_lock->fl_file still being around while
> > > performing unlocks for NFSv2 and NFSv3.  Pass along the nfs_open_context to
> > > provide the necessary inode and credential to complete the unlock.
> > >
> > > Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> > > ---
> > >  fs/lockd/clntproc.c        |   16 ++++++++++------
> > >  fs/nfs/nfs3proc.c          |    4 +---
> > >  fs/nfs/proc.c              |    4 +---
> > >  include/linux/lockd/bind.h |    3 ++-
> > >  4 files changed, 14 insertions(+), 13 deletions(-)
> > >
> > > diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
> > > index 1129520..72b65c4 100644
> > > --- a/fs/lockd/clntproc.c
> > > +++ b/fs/lockd/clntproc.c
> > > @@ -25,7 +25,8 @@
> > >
> > >  static int	nlmclnt_test(struct nlm_rqst *, struct file_lock *);
> > >  static int	nlmclnt_lock(struct nlm_rqst *, struct file_lock *);
> > > -static int	nlmclnt_unlock(struct nlm_rqst *, struct file_lock *);
> > > +static int	nlmclnt_unlock(struct nfs_open_context *nfs,
> > > +		struct nlm_rqst *, struct file_lock *);
> >
> > This smells a bit like a layering violation. The NLM APIs really
> > shouldn't require stuff that's NFS specific.
> 
> I had second thoughts about this too, but it didn't make sense to keep the
> separation if we're just going to use nfs_file_cred() in NLM anyway..
> 
> Do you think we should find a way to clean that out too?
> 

Ok, good point...

I do think it would be cleaner to try to excise the two, but I'm not
religious about it. FWIW, it looks like this patch added the
nfs_file_cred calls to lockd:

commit d11d10cc05c94a32632d6928d15a1034200dd9a5
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Apr 2 14:44:05 2008 -0400

    NLM/lockd: Ensure client locking calls use correct credentials
    
    Now that we've added the 'generic' credentials (that are independent of the
    rpc_client) to the nfs_open_context, we can use those in the NLM client to
    ensure that the lock/unlock requests are authenticated to whoever
    originally opened the file.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


I'll let Trond make the call on whether we should try to keep them separate...

> > >  static int	nlm_stat_to_errno(__be32 stat);
> > >  static void	nlmclnt_locks_init_private(struct file_lock *fl, struct nlm_host *host);
> > >  static int	nlmclnt_cancel(struct nlm_host *, int , struct file_lock *);
> > > @@ -147,13 +148,15 @@ static void nlmclnt_release_lockargs(struct nlm_rqst *req)
> > >
> > >  /**
> > >   * nlmclnt_proc - Perform a single client-side lock request
> > > - * @host: address of a valid nlm_host context representing the NLM server
> > > + * @ctx: address of the nfs_open_context for lock to operate upon
> > >   * @cmd: fcntl-style file lock operation to perform
> > >   * @fl: address of arguments for the lock operation
> > >   *
> > >   */
> > > -int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl)
> > > +int nlmclnt_proc(struct nfs_open_context *ctx, int cmd, struct file_lock *fl)
> > >  {
> > > +	struct inode		*inode = d_inode(ctx->dentry);
> > > +	struct nlm_host		*host = NFS_SERVER(inode)->nlm_host;
> > >  	struct nlm_rqst		*call;
> > >  	int			status;
> > >
> > > @@ -175,7 +178,7 @@ int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl)
> > >  			call->a_args.block = IS_SETLKW(cmd) ? 1 : 0;
> > >  			status = nlmclnt_lock(call, fl);
> > >  		} else
> > > -			status = nlmclnt_unlock(call, fl);
> > > +			status = nlmclnt_unlock(ctx, call, fl);
> > >  	} else if (IS_GETLK(cmd))
> > >  		status = nlmclnt_test(call, fl);
> > >  	else
> > > @@ -646,7 +649,8 @@ nlmclnt_reclaim(struct nlm_host *host, struct file_lock *fl,
> > >   * UNLOCK: remove an existing lock
> > >   */
> > >  static int
> > > -nlmclnt_unlock(struct nlm_rqst *req, struct file_lock *fl)
> > > +nlmclnt_unlock(struct nfs_open_context *ctx,
> > > +		struct nlm_rqst *req, struct file_lock *fl)
> > >  {
> > >  	struct nlm_host	*host = req->a_host;
> > >  	struct nlm_res	*resp = &req->a_res;
> > > @@ -669,7 +673,7 @@ nlmclnt_unlock(struct nlm_rqst *req, struct file_lock *fl)
> > >  	}
> > >
> > >  	atomic_inc(&req->a_count);
> > > -	status = nlmclnt_async_call(nfs_file_cred(fl->fl_file), req,
> > > +	status = nlmclnt_async_call(ctx->cred, req,
> > >  			NLMPROC_UNLOCK, &nlmclnt_unlock_ops);
> >
> > Since this is the only place you're going to fetch anything out of the
> > ctx, maybe it'd be best to just pass down a rpc_cred pointer instead?
> 
> Patch 7 changes do_vfs_lock() to take the inode instead of the file, so the
> ctx is useful again to obtain the inode.
> 
> Ben
> 

Hmm ok. It's still possible to pass the inode separately as well, but
again I'll leave that decision up to Trond.

> > >  	if (status < 0)
> > >  		goto out;
> > > diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
> > > index a10e147..2941ab7 100644
> > > --- a/fs/nfs/nfs3proc.c
> > > +++ b/fs/nfs/nfs3proc.c
> > > @@ -868,9 +868,7 @@ static void nfs3_proc_commit_setup(struct
> > > nfs_commit_data *data, struct rpc_mess static int
> > >  nfs3_proc_lock(struct nfs_open_context *ctx, int cmd, struct
> > > file_lock *fl) {
> > > -	struct inode *inode = d_inode(ctx->dentry);
> > > -
> > > -	return nlmclnt_proc(NFS_SERVER(inode)->nlm_host, cmd, fl);
> > > +	return nlmclnt_proc(ctx, cmd, fl);
> > >  }
> > >
> > >  static int nfs3_have_delegation(struct inode *inode, fmode_t flags)
> > > diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
> > > index 185deb9..17d892e 100644
> > > --- a/fs/nfs/proc.c
> > > +++ b/fs/nfs/proc.c
> > > @@ -636,9 +636,7 @@ nfs_proc_commit_setup(struct nfs_commit_data
> > > *data, struct rpc_message *msg) static int
> > >  nfs_proc_lock(struct nfs_open_context *ctx, int cmd, struct
> > > file_lock *fl) {
> > > -	struct inode *inode = d_inode(ctx->dentry);
> > > -
> > > -	return nlmclnt_proc(NFS_SERVER(inode)->nlm_host, cmd, fl);
> > > +	return nlmclnt_proc(ctx, cmd, fl);
> > >  }
> > >
> > >  /* Helper functions for NFS lock bounds checking */
> > > diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
> > > index 4d24d64..1d62e85 100644
> > > --- a/include/linux/lockd/bind.h
> > > +++ b/include/linux/lockd/bind.h
> > > @@ -18,6 +18,7 @@
> > >
> > >  /* Dummy declarations */
> > >  struct svc_rqst;
> > > +struct nfs_open_context;
> > >
> > >  /*
> > >   * This is the set of functions for lockd->nfsd communication
> > > @@ -52,7 +53,7 @@ struct nlmclnt_initdata {
> > >  extern struct nlm_host *nlmclnt_init(const struct nlmclnt_initdata
> > > *nlm_init); extern void	nlmclnt_done(struct nlm_host *host);
> > >
> > > -extern int	nlmclnt_proc(struct nlm_host *host, int cmd,
> > > +extern int	nlmclnt_proc(struct nfs_open_context *ctx, int cmd,
> > >  					struct file_lock *fl);
> > >  extern int	lockd_up(struct net *net);
> > >  extern void	lockd_down(struct net *net);
> >
> >
> > --
> > Jeff Layton <jeff.layton@primarydata.com>
> >


-- 
Jeff Layton <jeff.layton@primarydata.com>
