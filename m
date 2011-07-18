From: Bryan Schumaker <bjschuma@netapp.com>
Subject: Re: [PATCH v2 2/2] NFS: Send SIGIO on lost locks
Date: Mon, 18 Jul 2011 13:58:46 -0400
Message-ID: <4E247456.4040207@netapp.com>
References: <1311011616-11503-1-git-send-email-bjschuma@netapp.com> <1311011616-11503-2-git-send-email-bjschuma@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	David Howels <dhowells@redhat.com>,
	Steve French <sfrench@samba.org>,
	Miklos Szeredi <miklos@szeredi.hu>,
	linux-fsdevel@vger.kernel.org
To: bjschuma@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49900 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751149Ab1GRR6s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Jul 2011 13:58:48 -0400
In-Reply-To: <1311011616-11503-2-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I fixed Ingo's email address in the patch, it should be "@redhat.com" and not "@redahat".  Sorry about that.

- Bryan

On 07/18/2011 01:53 PM, bjschuma@netapp.com wrote:
> From: Bryan Schumaker <bjschuma@netapp.com>
> 
> If we discover that the server has lost a client's lock, we send SIGIO to the
> client application and let the application decide the best method of handling
> the error.
> 
> This could also be done by sending the SIGLOST signal to the userland
> application.  Most architectures have a definition of SIGIO commented out in
> their signal.h.  In most cases, SIGLOST would be defined to the same value as
> SIGIO.  A new signal could be created, but there are no available slots before
> SIGRTMIN.
> 
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> CC: Trond Myklebust <Trond.Myklebust@netapp.com>
> CC: Thomas Gleixner <tglx@linutronix.de>
> CC: Ingo Molnar <mingo@redhat.com>
> CC: David Howels <dhowells@redhat.com>
> CC: Steve French <sfrench@samba.org>
> CC: Miklos Szeredi <miklos@szeredi.hu>
> CC: linux-fsdevel@vger.kernel.org
> ---
>  Documentation/kernel-parameters.txt |    7 +++++++
>  fs/nfs/nfs4_fs.h                    |    2 ++
>  fs/nfs/nfs4proc.c                   |   21 +++++++++++++++++++++
>  fs/nfs/nfs4state.c                  |   14 ++++++++++++++
>  fs/nfs/read.c                       |    9 +++++++++
>  fs/nfs/write.c                      |    7 +++++++
>  6 files changed, 60 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> index fd248a31..988ebdc 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -1593,6 +1593,13 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>  			of returning the full 64-bit number.
>  			The default is to return 64-bit inode numbers.
>  
> +	nfs.enable_sigio=
> +			[NFSv4.1] enable sending SIGIO to applications.
> +			If true, the NFS client will send SIGIO to applications
> +			when a lost file lock is detected.  If false, the client
> +			will attempt to recover the lock.
> +			The default is to send SIGIO.
> +
>  	nfs.nfs4_disable_idmapping=
>  			[NFSv4] When set, this option disables the NFSv4
>  			idmapper on the client, but only if the mount
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index c30aed2..8fa02af 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -163,6 +163,7 @@ struct nfs4_lock_state {
>  	struct list_head	ls_locks;	/* Other lock stateids */
>  	struct nfs4_state *	ls_state;	/* Pointer to open state */
>  #define NFS_LOCK_INITIALIZED 1
> +#define NFS_LOCK_INVALID     2
>  	int			ls_flags;
>  	struct nfs_seqid_counter	ls_seqid;
>  	struct rpc_sequence	ls_sequence;
> @@ -346,6 +347,7 @@ extern struct nfs4_state * nfs4_get_open_state(struct inode *, struct nfs4_state
>  extern void nfs4_put_open_state(struct nfs4_state *);
>  extern void nfs4_close_state(struct path *, struct nfs4_state *, fmode_t);
>  extern void nfs4_close_sync(struct path *, struct nfs4_state *, fmode_t);
> +extern int nfs4_validate_lock_stateid(struct nfs4_state *, struct nfs_lock_context *);
>  extern void nfs4_state_set_mode_locked(struct nfs4_state *, fmode_t);
>  extern void nfs4_schedule_lease_recovery(struct nfs_client *);
>  extern void nfs4_schedule_state_manager(struct nfs_client *);
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index f37218b..bb29384 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -4462,6 +4462,8 @@ out:
>  }
>  
>  #if defined(CONFIG_NFS_V4_1)
> +bool enable_sigio = true;
> +
>  static int nfs41_lock_expired(struct nfs4_state *state, struct file_lock *request)
>  {
>  	int status;
> @@ -4472,10 +4474,29 @@ static int nfs41_lock_expired(struct nfs4_state *state, struct file_lock *reques
>  	status = nfs41_test_stateid(server, stateid);
>  	if (status == NFS_OK)
>  		return 0;
> +
>  	nfs41_free_stateid(server, stateid);
>  	lock_state->ls_seqid.flags &= !NFS_SEQID_CONFIRMED;
> +
> +	if (enable_sigio) {
> +		u32 secid;
> +		struct siginfo info = {
> +			.si_signo = SIGIO,
> +			.si_code  = __SI_SIGLOST,
> +			.si_errno = -ENOLCK,
> +		};
> +		lock_state->ls_flags |= NFS_LOCK_INVALID;
> +		security_task_getsecid(current, &secid);
> +		kill_pid_info_as_uid(SIGIO, &info, request->fl_nspid,
> +			current_cred()->uid, current_cred()->euid, secid);
> +		return 0;
> +	}
>  	return nfs4_lock_expired(state, request);
>  }
> +
> +module_param(enable_sigio, bool, 0644);
> +MODULE_PARM_DESC(enable_sigio, "Send SIGIO to an application when a lost lock"
> +			"is detected instead of attempting recovery");
>  #endif
>  
>  static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *request)
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 5d744a5..101d9b4 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -725,6 +725,20 @@ __nfs4_find_lock_state(struct nfs4_state *state, fl_owner_t fl_owner, pid_t fl_p
>  	return NULL;
>  }
>  
> +int nfs4_validate_lock_stateid(struct nfs4_state *state, struct nfs_lock_context *lock_ctx)
> +{
> +	int valid = 1;
> +	struct nfs4_lock_state *lock_state;
> +
> +	spin_lock(&state->state_lock);
> +	lock_state = __nfs4_find_lock_state(state, lock_ctx->lockowner, lock_ctx->pid, NFS4_ANY_LOCK_TYPE);
> +	if (lock_state != NULL)
> +		valid = (lock_state->ls_flags & NFS_LOCK_INVALID) == 0;
> +	spin_unlock(&state->state_lock);
> +	nfs4_put_lock_state(lock_state);
> +	return valid;
> +}
> +
>  /*
>   * Return a compatible lock_state. If no initialized lock_state structure
>   * exists, return an uninitialized one.
> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
> index c394662..c597f9e 100644
> --- a/fs/nfs/read.c
> +++ b/fs/nfs/read.c
> @@ -468,6 +468,15 @@ static void nfs_readpage_release_partial(void *calldata)
>  void nfs_read_prepare(struct rpc_task *task, void *calldata)
>  {
>  	struct nfs_read_data *data = calldata;
> +	struct nfs4_state *state = data->args.context->state;
> +	struct nfs_lock_context *lock_context = data->args.lock_context;
> +
> +	if (!nfs4_validate_lock_stateid(state, lock_context)) {
> +		task->tk_status = -EIO;
> +		task->tk_action = NULL;
> +		return;
> +	}
> +
>  
>  	if (nfs4_setup_sequence(NFS_SERVER(data->inode),
>  				&data->args.seq_args, &data->res.seq_res,
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 7f8732e..49ca975 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1114,7 +1114,14 @@ out:
>  void nfs_write_prepare(struct rpc_task *task, void *calldata)
>  {
>  	struct nfs_write_data *data = calldata;
> +	struct nfs4_state *state = data->args.context->state;
> +	struct nfs_lock_context *lock_context = data->args.lock_context;
>  
> +	if (!nfs4_validate_lock_stateid(state, lock_context)) {
> +		task->tk_status = -EIO;
> +		task->tk_action = NULL;
> +		return;
> +	}
>  	if (nfs4_setup_sequence(NFS_SERVER(data->inode),
>  				&data->args.seq_args,
>  				&data->res.seq_res, 1, task))

