Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35025 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753298AbcISRWl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Sep 2016 13:22:41 -0400
Received: by mail-qk0-f196.google.com with SMTP id w204so10194859qka.2
        for <linux-nfs@vger.kernel.org>; Mon, 19 Sep 2016 10:22:40 -0700 (PDT)
Message-ID: <1474305756.5754.3.camel@poochiereds.net>
Subject: Re: [PATCH v4 9/9] nfs: allow blocking locks to be awoken by lock
 callbacks
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org
Date: Mon, 19 Sep 2016 13:22:36 -0400
In-Reply-To: <1474150659-23894-10-git-send-email-jlayton@redhat.com>
References: <1474150659-23894-1-git-send-email-jlayton@redhat.com>
         <1474150659-23894-10-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2016-09-17 at 18:17 -0400, Jeff Layton wrote:
> Add a waitqueue head to the client structure. Have clients set a wait
> on that queue prior to requesting a lock from the server. If the lock
> is blocked, then we can use that to wait for wakeups.
> 
> Note that we do need to do this "manually" since we need to set the
> wait on the waitqueue prior to requesting the lock, but requesting a
> lock can involve activities that can block.
> 
> However, only do that for NFSv4.1 locks, either by compiling out
> all of the waitqueue handling when CONFIG_NFS_V4_1 is disabled, or
> skipping all of it at runtime if we're dealing with v4.0, or v4.1
> servers that don't send lock callbacks.
> 
> Note too that even when we expect to get a lock callback, RFC5661
> section 20.11.4 is pretty clear that we still need to poll for them,
> so we do still sleep on a timeout. We do however always poll at the
> longest interval in that case.
> 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfs/callback_proc.c    |  4 ++
>  fs/nfs/nfs4client.c       |  3 ++
>  fs/nfs/nfs4proc.c         | 94 ++++++++++++++++++++++++++++++++++++++++++++++-
>  include/linux/nfs_fs_sb.h |  3 ++
>  4 files changed, 103 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index 974881824414..e9aa235e9d10 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -638,6 +638,10 @@ __be32 nfs4_callback_notify_lock(struct cb_notify_lock_args *args, void *dummy,
> >  	dprintk_rcu("NFS: CB_NOTIFY_LOCK request from %s\n",
> >  		rpc_peeraddr2str(cps->clp->cl_rpcclient, RPC_DISPLAY_ADDR));
>  
> > +	/* Don't wake anybody if the string looked bogus */
> > +	if (args->cbnl_valid)
> > +		__wake_up(&cps->clp->cl_lock_waitq, TASK_NORMAL, 0, args);
> +
> >  	return htonl(NFS4_OK);
>  }
>  #endif /* CONFIG_NFS_V4_1 */
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index cd3b7cfdde16..9f62df5feb7d 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -199,6 +199,9 @@ struct nfs_client *nfs4_alloc_client(const struct nfs_client_initdata *cl_init)
> >  	clp->cl_minorversion = cl_init->minorversion;
> >  	clp->cl_mvops = nfs_v4_minor_ops[cl_init->minorversion];
> >  	clp->cl_mig_gen = 1;
> +#if IS_ENABLED(CONFIG_NFS_V4_1)
> > +	init_waitqueue_head(&clp->cl_lock_waitq);
> +#endif
> >  	return clp;
>  
>  error:
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index e6a098976612..60daeaa92983 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -6166,7 +6166,8 @@ static int nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *
>  #define NFS4_LOCK_MAXTIMEOUT (30 * HZ)
>  
>  static int
> -nfs4_retry_setlk(struct nfs4_state *state, int cmd, struct file_lock *request)
> +nfs4_retry_setlk_simple(struct nfs4_state *state, int cmd,
> > +			struct file_lock *request)
>  {
> > >  	int		status = -ERESTARTSYS;
> > >  	unsigned long	timeout = NFS4_LOCK_MINTIMEOUT;
> @@ -6183,6 +6184,97 @@ nfs4_retry_setlk(struct nfs4_state *state, int cmd, struct file_lock *request)
> >  	return status;
>  }
>  
> +#ifdef CONFIG_NFS_V4_1
> +struct nfs4_lock_waiter {
> > > +	struct task_struct	*task;
> > > +	struct inode		*inode;
> > > +	struct nfs_lowner	*owner;
> > > +	bool			notified;
> +};
> +
> +static int
> +nfs4_wake_lock_waiter(wait_queue_t *wait, unsigned int mode, int flags, void *key)
> +{
> > +	int ret;
> > +	struct cb_notify_lock_args *cbnl = key;
> > > > +	struct nfs4_lock_waiter	*waiter	= wait->private;
> > > +	struct nfs_lowner	*lowner = &cbnl->cbnl_owner,
> > +				*wowner = waiter->owner;
> +
> > +	/* Only wake if the callback was for the same owner */
> > +	if (lowner->clientid != wowner->clientid ||
> > > +	    lowner->id != wowner->id		 ||
> > +	    lowner->s_dev != wowner->s_dev)
> > +		return 0;
> +
> > +	/* Make sure it's for the right inode */
> > +	if (nfs_compare_fh(NFS_FH(waiter->inode), &cbnl->cbnl_fh))
> > +		return 0;
> +
> > +	waiter->notified = true;
> +
> > +	/* override "private" so we can use default_wake_function */
> > +	wait->private = waiter->task;
> > +	ret = autoremove_wake_function(wait, mode, flags, key);
> > +	wait->private = waiter;
> > +	return ret;
> +}
> +
> +static int
> +nfs4_retry_setlk(struct nfs4_state *state, int cmd, struct file_lock *request)
> +{
> +	int status;

Whoops! We can end up returning an uninitialized value if signalled()
is true when we hit the while loop below. Need to initialize that to
-ERESTARTSYS here.

Now why didn't the compiler catch that?  Hmmm...

> +	unsigned long flags;
> > +	struct nfs4_lock_state *lsp = request->fl_u.nfs4_fl.owner;
> > +	struct nfs_server *server = NFS_SERVER(state->inode);
> > +	struct nfs_client *clp = server->nfs_client;
> > +	wait_queue_head_t *q = &clp->cl_lock_waitq;
> > +	struct nfs_lowner owner = { .clientid = clp->cl_clientid,
> > +				    .id = lsp->ls_seqid.owner_id,
> > +				    .s_dev = server->s_dev };
> > +	struct nfs4_lock_waiter waiter = { .task  = current,
> > +					   .inode = state->inode,
> > +					   .owner = &owner,
> > +					   .notified = false };
> > +	wait_queue_t wait;
> +
> > +	/* Don't bother with waitqueue if we don't expect a callback */
> > +	if (!test_bit(NFS_STATE_MAY_NOTIFY_LOCK, &state->flags))
> > +		return nfs4_retry_setlk_simple(state, cmd, request);
> +
> > +	init_wait(&wait);
> > +	wait.private = &waiter;
> > +	wait.func = nfs4_wake_lock_waiter;
> > +	add_wait_queue(q, &wait);
> +
> > +	while(!signalled()) {
> > +		status = nfs4_proc_setlk(state, cmd, request);
> > +		if ((status != -EAGAIN) || IS_SETLK(cmd))
> > +			break;
> +
> > +		status = -ERESTARTSYS;
> > +		spin_lock_irqsave(&q->lock, flags);
> > +		if (waiter.notified) {
> > +			spin_unlock_irqrestore(&q->lock, flags);
> > +			continue;
> > +		}
> > +		set_current_state(TASK_INTERRUPTIBLE);
> > +		spin_unlock_irqrestore(&q->lock, flags);
> +
> > +		freezable_schedule_timeout_interruptible(NFS4_LOCK_MAXTIMEOUT);
> > +	}
> +
> > +	finish_wait(q, &wait);
> > +	return status;
> +}
> +#else /* !CONFIG_NFS_V4_1 */
> +static inline int
> +nfs4_retry_setlk(struct nfs4_state *state, int cmd, struct file_lock *request)
> +{
> > +	return nfs4_retry_setlk_simple(state, cmd, request);
> +}
> +#endif
> +
>  static int
>  nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
>  {
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 14a762d2734d..b34097c67848 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -103,6 +103,9 @@ struct nfs_client {
> >  #define NFS_SP4_MACH_CRED_WRITE    5	/* WRITE */
> >  #define NFS_SP4_MACH_CRED_COMMIT   6	/* COMMIT */
>  #define NFS_SP4_MACH_CRED_PNFS_CLEANUP  7 /* LAYOUTRETURN */
> +#if IS_ENABLED(CONFIG_NFS_V4_1)
> > > +	wait_queue_head_t	cl_lock_waitq;
> +#endif /* CONFIG_NFS_V4_1 */
>  #endif /* CONFIG_NFS_V4 */
>  
> >  	/* Our own IP address, as a null-terminated string.
-- 
Jeff Layton <jlayton@poochiereds.net>
