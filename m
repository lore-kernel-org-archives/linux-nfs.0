Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:32037 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756040Ab3HOMqS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Aug 2013 08:46:18 -0400
Date: Thu, 15 Aug 2013 08:47:06 -0400
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: NFS <linux-nfs@vger.kernel.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: Re: [PATCH/RFC]  Don't try to recover NFS locks when they are lost.
Message-ID: <20130815084706.4811d74e@corrin.poochiereds.net>
In-Reply-To: <20130815123604.47755509@notabene.brown>
References: <20130815123604.47755509@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 15 Aug 2013 12:36:04 +1000
NeilBrown <neilb@suse.de> wrote:

> 
> 
> When an NFS (V4 specifically) client loses contact with the server it can
> lose any locks that it holds.
> Currently when it reconnects to the server it simply tries to reclaim
> those locks.  This might succeed even though some other client has held and
> released a lock in the mean time.  So the first client might think the file
> is unchanged, but it isn't.  This isn't good.
> 
> If, when recovery happens, the locks cannot be claimed because some other
> client still holds the lock, then  we get a message in the kernel logs, but
> the client can still write.  So two clients can both think they have a lock
> and can both write at the same time.  This is equally not good.
> 
> There was a patch a while ago
>   http://comments.gmane.org/gmane.linux.nfs/41917
> 
> which tried to address some of this, but it didn't seem to go anywhere.
> That patch would also send a signal to the process.  That might be useful
> but I'm really just interested in failing the writes.
> For NFSv4 (unlike v2/v3) there is a strong link between the lock and the
> write request so we can fairly easily fail an IO of the lock is gone.
> 
> The patch below attempts to do this.  Does it make sense?
> Because this is a fairly big change I introduces a module parameter
> "recover_locks" which defaults to true (the current behaviour) but can be set
> to "false" to tell the client not to try to recover things that were lost.
> 
> Comments?
> 
> Thanks,
> NeilBrown
> 
> 

Failing a read or write when we can't recover a lock over the range
seems reasonable to me. IIUC though, you're also saying that we
shouldn't try to recover locks when the lease has expired? If so, then
that seems wrong...

Isn't it the responsibility of the server to not allow a lock to be
reclaimed when there has been a conflicting lock in the interim? It's
quite possible (and even advantageous) for a server to hold onto a lock
for a client that has missed renewing its lease when no other client has
made a conflicting lock request.

> 
> diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
> index f5c84c3..de0229b 100644
> --- a/fs/nfs/nfs3proc.c
> +++ b/fs/nfs/nfs3proc.c
> @@ -826,9 +826,10 @@ static void nfs3_proc_read_setup(struct nfs_read_data *data, struct rpc_message
>  	msg->rpc_proc = &nfs3_procedures[NFS3PROC_READ];
>  }
>  
> -static void nfs3_proc_read_rpc_prepare(struct rpc_task *task, struct nfs_read_data *data)
> +static int nfs3_proc_read_rpc_prepare(struct rpc_task *task, struct nfs_read_data *data)
>  {
>  	rpc_call_start(task);
> +	return 0;
>  }
>  
>  static int nfs3_write_done(struct rpc_task *task, struct nfs_write_data *data)
> @@ -847,9 +848,10 @@ static void nfs3_proc_write_setup(struct nfs_write_data *data, struct rpc_messag
>  	msg->rpc_proc = &nfs3_procedures[NFS3PROC_WRITE];
>  }
>  
> -static void nfs3_proc_write_rpc_prepare(struct rpc_task *task, struct nfs_write_data *data)
> +static int nfs3_proc_write_rpc_prepare(struct rpc_task *task, struct nfs_write_data *data)
>  {
>  	rpc_call_start(task);
> +	return 0;
>  }
>  
>  static void nfs3_proc_commit_rpc_prepare(struct rpc_task *task, struct nfs_commit_data *data)
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index ee81e35..a468b345 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -135,6 +135,7 @@ struct nfs4_lock_state {
>  	struct list_head	ls_locks;	/* Other lock stateids */
>  	struct nfs4_state *	ls_state;	/* Pointer to open state */
>  #define NFS_LOCK_INITIALIZED 0
> +#define NFS_LOCK_LOST        1
>  	unsigned long		ls_flags;
>  	struct nfs_seqid_counter	ls_seqid;
>  	nfs4_stateid		ls_stateid;
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index cf11799..bcbcd07 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3907,15 +3907,19 @@ static void nfs4_proc_read_setup(struct nfs_read_data *data, struct rpc_message
>  	nfs41_init_sequence(&data->args.seq_args, &data->res.seq_res, 0);
>  }
>  
> -static void nfs4_proc_read_rpc_prepare(struct rpc_task *task, struct nfs_read_data *data)
> +static int nfs4_proc_read_rpc_prepare(struct rpc_task *task, struct nfs_read_data *data)
>  {
>  	if (nfs4_setup_sequence(NFS_SERVER(data->header->inode),
>  			&data->args.seq_args,
>  			&data->res.seq_res,
>  			task))
> -		return;
> -	nfs4_set_rw_stateid(&data->args.stateid, data->args.context,
> -			data->args.lock_context, FMODE_READ);
> +		return 0;
> +	if (nfs4_set_rw_stateid(&data->args.stateid, data->args.context,
> +				data->args.lock_context, FMODE_READ) == -EIO)
> +		return -EIO;
> +	if (unlikely(test_bit(NFS_CONTEXT_BAD, &data->args.context->flags)))
> +		return -EIO;
> +	return 0;
>  }
>  
>  static int nfs4_write_done_cb(struct rpc_task *task, struct nfs_write_data *data)
> @@ -3990,15 +3994,19 @@ static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_messag
>  	nfs41_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
>  }
>  
> -static void nfs4_proc_write_rpc_prepare(struct rpc_task *task, struct nfs_write_data *data)
> +static int nfs4_proc_write_rpc_prepare(struct rpc_task *task, struct nfs_write_data *data)
>  {
>  	if (nfs4_setup_sequence(NFS_SERVER(data->header->inode),
>  			&data->args.seq_args,
>  			&data->res.seq_res,
>  			task))
> -		return;
> -	nfs4_set_rw_stateid(&data->args.stateid, data->args.context,
> -			data->args.lock_context, FMODE_WRITE);
> +		return 0;
> +	if (nfs4_set_rw_stateid(&data->args.stateid, data->args.context,
> +				data->args.lock_context, FMODE_WRITE) == -EIO)
> +		return -EIO;
> +	if (unlikely(test_bit(NFS_CONTEXT_BAD, &data->args.context->flags)))
> +		return -EIO;
> +	return 0;
>  }
>  
>  static void nfs4_proc_commit_rpc_prepare(struct rpc_task *task, struct nfs_commit_data *data)
> @@ -5380,6 +5388,11 @@ static int nfs4_lock_reclaim(struct nfs4_state *state, struct file_lock *request
>  	return err;
>  }
>  
> +bool recover_locks = true;
> +module_param(recover_locks, bool, 0644);
> +MODULE_PARM_DESC(recovery_locks,
> +		 "If the server reports that a lock might be lost, "
> +		 "try to recovery it risking corruption.");
>  static int nfs4_lock_expired(struct nfs4_state *state, struct file_lock *request)
>  {
>  	struct nfs_server *server = NFS_SERVER(state->inode);
> @@ -5391,6 +5404,10 @@ static int nfs4_lock_expired(struct nfs4_state *state, struct file_lock *request
>  	err = nfs4_set_lock_state(state, request);
>  	if (err != 0)
>  		return err;
> +	if (!recover_locks) {
> +		set_bit(NFS_LOCK_LOST, &request->fl_u.nfs4_fl.owner->ls_flags);
> +		return 0;
> +	}
>  	do {
>  		if (test_bit(NFS_DELEGATED_STATE, &state->flags) != 0)
>  			return 0;
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index e22862f..4d103ff 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -998,7 +998,9 @@ static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
>  	fl_pid = lockowner->l_pid;
>  	spin_lock(&state->state_lock);
>  	lsp = __nfs4_find_lock_state(state, fl_owner, fl_pid, NFS4_ANY_LOCK_TYPE);
> -	if (lsp != NULL && test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags) != 0) {
> +	if (lsp && test_bit(NFS_LOCK_LOST, &lsp->ls_flags))
> +		ret = -EIO;
> +	else if (lsp != NULL && test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags) != 0) {
>  		nfs4_stateid_copy(dst, &lsp->ls_stateid);
>  		ret = 0;
>  		smp_rmb();
> diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
> index c041c41..a8f57c7 100644
> --- a/fs/nfs/proc.c
> +++ b/fs/nfs/proc.c
> @@ -623,9 +623,10 @@ static void nfs_proc_read_setup(struct nfs_read_data *data, struct rpc_message *
>  	msg->rpc_proc = &nfs_procedures[NFSPROC_READ];
>  }
>  
> -static void nfs_proc_read_rpc_prepare(struct rpc_task *task, struct nfs_read_data *data)
> +static int nfs_proc_read_rpc_prepare(struct rpc_task *task, struct nfs_read_data *data)
>  {
>  	rpc_call_start(task);
> +	return 0;
>  }
>  
>  static int nfs_write_done(struct rpc_task *task, struct nfs_write_data *data)
> @@ -644,9 +645,10 @@ static void nfs_proc_write_setup(struct nfs_write_data *data, struct rpc_message
>  	msg->rpc_proc = &nfs_procedures[NFSPROC_WRITE];
>  }
>  
> -static void nfs_proc_write_rpc_prepare(struct rpc_task *task, struct nfs_write_data *data)
> +static int nfs_proc_write_rpc_prepare(struct rpc_task *task, struct nfs_write_data *data)
>  {
>  	rpc_call_start(task);
> +	return 0;
>  }
>  
>  static void nfs_proc_commit_rpc_prepare(struct rpc_task *task, struct nfs_commit_data *data)
> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
> index 70a26c6..31db5c3 100644
> --- a/fs/nfs/read.c
> +++ b/fs/nfs/read.c
> @@ -513,9 +513,10 @@ static void nfs_readpage_release_common(void *calldata)
>  void nfs_read_prepare(struct rpc_task *task, void *calldata)
>  {
>  	struct nfs_read_data *data = calldata;
> -	NFS_PROTO(data->header->inode)->read_rpc_prepare(task, data);
> -	if (unlikely(test_bit(NFS_CONTEXT_BAD, &data->args.context->flags)))
> -		rpc_exit(task, -EIO);
> +	int err;
> +	err = NFS_PROTO(data->header->inode)->read_rpc_prepare(task, data);
> +	if (err)
> +		rpc_exit(task, err);
>  }
>  
>  static const struct rpc_call_ops nfs_read_common_ops = {
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index f1bdb72..7816801 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1265,9 +1265,10 @@ EXPORT_SYMBOL_GPL(nfs_pageio_reset_write_mds);
>  void nfs_write_prepare(struct rpc_task *task, void *calldata)
>  {
>  	struct nfs_write_data *data = calldata;
> -	NFS_PROTO(data->header->inode)->write_rpc_prepare(task, data);
> -	if (unlikely(test_bit(NFS_CONTEXT_BAD, &data->args.context->flags)))
> -		rpc_exit(task, -EIO);
> +	int err;
> +	err = NFS_PROTO(data->header->inode)->write_rpc_prepare(task, data);
> +	if (err)
> +		rpc_exit(task, err);
>  }
>  
>  void nfs_commit_prepare(struct rpc_task *task, void *calldata)
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 8651574..c71e12b 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -1419,12 +1419,12 @@ struct nfs_rpc_ops {
>  	void	(*read_setup)   (struct nfs_read_data *, struct rpc_message *);
>  	void	(*read_pageio_init)(struct nfs_pageio_descriptor *, struct inode *,
>  				    const struct nfs_pgio_completion_ops *);
> -	void	(*read_rpc_prepare)(struct rpc_task *, struct nfs_read_data *);
> +	int	(*read_rpc_prepare)(struct rpc_task *, struct nfs_read_data *);
>  	int	(*read_done)  (struct rpc_task *, struct nfs_read_data *);
>  	void	(*write_setup)  (struct nfs_write_data *, struct rpc_message *);
>  	void	(*write_pageio_init)(struct nfs_pageio_descriptor *, struct inode *, int,
>  				     const struct nfs_pgio_completion_ops *);
> -	void	(*write_rpc_prepare)(struct rpc_task *, struct nfs_write_data *);
> +	int	(*write_rpc_prepare)(struct rpc_task *, struct nfs_write_data *);
>  	int	(*write_done)  (struct rpc_task *, struct nfs_write_data *);
>  	void	(*commit_setup) (struct nfs_commit_data *, struct rpc_message *);
>  	void	(*commit_rpc_prepare)(struct rpc_task *, struct nfs_commit_data *);


-- 
Jeff Layton <jlayton@redhat.com>
