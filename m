Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:48490 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752860Ab3HOMkJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Aug 2013 08:40:09 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1V9wqQ-0002Hr-M7
	for linux-nfs@vger.kernel.org; Thu, 15 Aug 2013 14:40:02 +0200
Received: from cpe-72-183-96-20.austin.res.rr.com ([cpe-72-183-96-20.austin.res.rr.com])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 15 Aug 2013 14:40:02 +0200
Received: from malahal by cpe-72-183-96-20.austin.res.rr.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 15 Aug 2013 14:40:02 +0200
To: linux-nfs@vger.kernel.org
From: Malahal Naineni <malahal@us.ibm.com>
Subject: Re: [PATCH/RFC]  Don't try to recover NFS locks when they are lost.
Date: Thu, 15 Aug 2013 12:37:29 +0000 (UTC)
Message-ID: <loom.20130815T141054-61@post.gmane.org>
References: <20130815123604.47755509@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NeilBrown <neilb@...> writes:
> Because this is a fairly big change I introduces a module parameter
> "recover_locks" which defaults to true (the current behaviour) but can be set
> to "false" to tell the client not to try to recover things that were lost.

Current behaviour is broken, why do we want to keep it? I would say, set
it to 'False' by default, and if someone really wants the current broken
behavior, they can set it to 'True'

> -static void nfs4_proc_read_rpc_prepare(struct rpc_task *task, struct
nfs_read_data *data)
> +static int nfs4_proc_read_rpc_prepare(struct rpc_task *task, struct
nfs_read_data *data)
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

Do we want to check for only -EIO return and ignore other errors?

> +	if (unlikely(test_bit(NFS_CONTEXT_BAD, &data->args.context->flags)))
> +		return -EIO;
> +	return 0;
>  }
> 
>  static int nfs4_write_done_cb(struct rpc_task *task, struct
nfs_write_data *data)
>  <at>  <at>  -3990,15 +3994,19  <at>  <at>  static void
nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_messag
>  	nfs41_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
>  }
> 
> -static void nfs4_proc_write_rpc_prepare(struct rpc_task *task, struct
nfs_write_data *data)
> +static int nfs4_proc_write_rpc_prepare(struct rpc_task *task, struct
nfs_write_data *data)
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

Do we want to check for only -EIO return and ignore other errors?

> +	if (unlikely(test_bit(NFS_CONTEXT_BAD, &data->args.context->flags)))
> +		return -EIO;
> +	return 0;
>  }
> 
>  static void nfs4_proc_commit_rpc_prepare(struct rpc_task *task, struct
nfs_commit_data *data)
>  <at>  <at>  -5380,6 +5388,11  <at>  <at>  static int
nfs4_lock_reclaim(struct nfs4_state *state, struct file_lock *request
>  	return err;
>  }
> 
> +bool recover_locks = true;
> +module_param(recover_locks, bool, 0644);
> +MODULE_PARM_DESC(recovery_locks,
> +		 "If the server reports that a lock might be lost, "
> +		 "try to recovery it risking corruption.");
>  static int nfs4_lock_expired(struct nfs4_state *state, struct file_lock
*request)
>  {
>  	struct nfs_server *server = NFS_SERVER(state->inode);
>  <at>  <at>  -5391,6 +5404,10  <at>  <at>  static int
nfs4_lock_expired(struct nfs4_state *state, struct file_lock *request
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
>  <at>  <at>  -998,7 +998,9  <at>  <at>  static int
nfs4_copy_lock_stateid(nfs4_stateid *dst,
>  	fl_pid = lockowner->l_pid;
>  	spin_lock(&state->state_lock);
>  	lsp = __nfs4_find_lock_state(state, fl_owner, fl_pid, NFS4_ANY_LOCK_TYPE);
> -	if (lsp != NULL && test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags) != 0) {
> +	if (lsp && test_bit(NFS_LOCK_LOST, &lsp->ls_flags))
> +		ret = -EIO;
> +	else if (lsp != NULL && test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags)
!= 0) {
>  		nfs4_stateid_copy(dst, &lsp->ls_stateid);
>  		ret = 0;
>  		smp_rmb();

(lsp) and (lsp != NULL): They are same, but it would be good to have the
same check. Also, Trond likes to return EBADF rather than EIO in this
lock loss case. You may need to change EIO to EBADF.

The patch looks good. Thank you.

Regards, Malahal.


