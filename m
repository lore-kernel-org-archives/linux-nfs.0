Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:59824 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751281AbbAFS7X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jan 2015 13:59:23 -0500
Message-ID: <54AC3088.9060904@Netapp.com>
Date: Tue, 6 Jan 2015 13:59:20 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Tom Haynes <thomas.haynes@primarydata.com>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 43/49] nfs41: allow async version layoutreturn
References: <1419405208-25975-1-git-send-email-loghyr@primarydata.com> <1419405208-25975-44-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1419405208-25975-44-git-send-email-loghyr@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Tao and Tom,

On 12/24/2014 02:13 AM, Tom Haynes wrote:
> From: Peng Tao <tao.peng@primarydata.com>
> 
> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
> Signed-off-by: Tom Haynes <loghyr@primarydata.com>
> ---
>  fs/nfs/nfs4proc.c | 11 +++++++++--
>  fs/nfs/pnfs.c     | 12 +++++++-----
>  fs/nfs/pnfs.h     |  2 +-
>  3 files changed, 17 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index bf5ef58..53df457 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -7800,7 +7800,7 @@ static const struct rpc_call_ops nfs4_layoutreturn_call_ops = {
>  	.rpc_release = nfs4_layoutreturn_release,
>  };
>  
> -int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp)
> +int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool sync)
>  {
>  	struct rpc_task *task;
>  	struct rpc_message msg = {
> @@ -7814,16 +7814,23 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp)
>  		.rpc_message = &msg,
>  		.callback_ops = &nfs4_layoutreturn_call_ops,
>  		.callback_data = lrp,
> +		.flags = RPC_TASK_ASYNC,
>  	};
> -	int status;
> +	int status = 0;
>  
>  	dprintk("--> %s\n", __func__);
>  	nfs4_init_sequence(&lrp->args.seq_args, &lrp->res.seq_res, 1);
>  	task = rpc_run_task(&task_setup_data);
>  	if (IS_ERR(task))
>  		return PTR_ERR(task);
> +	if (sync == false)
> +		goto out;
> +	status = nfs4_wait_for_completion_rpc_task(task);
> +	if (status != 0)
> +		goto out;

Is there any way to share this code with nfs4_proc_layoutcommit?

Thanks,
Anna

>  	status = task->tk_status;
>  	trace_nfs4_layoutreturn(lrp->args.inode, status);
> +out:
>  	dprintk("<-- %s status=%d\n", __func__, status);
>  	rpc_put_task(task);
>  	return status;
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 63beace..e889b97 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -52,7 +52,8 @@ static LIST_HEAD(pnfs_modules_tbl);
>  
>  static int
>  pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
> -		       enum pnfs_iomode iomode, u64 offset, u64 length);
> +		       enum pnfs_iomode iomode, u64 offset, u64 length,
> +		       bool sync);
>  
>  /* Return the registered pnfs layout driver module matching given id */
>  static struct pnfs_layoutdriver_type *
> @@ -393,7 +394,7 @@ pnfs_put_lseg(struct pnfs_layout_segment *lseg)
>  		pnfs_free_lseg(lseg);
>  		if (need_return)
>  			pnfs_send_layoutreturn(lo, stateid, iomode, 0,
> -					       NFS4_MAX_UINT64);
> +					       NFS4_MAX_UINT64, true);
>  		else
>  			pnfs_put_layout_hdr(lo);
>  	}
> @@ -898,7 +899,8 @@ static void pnfs_clear_layoutcommit(struct inode *inode,
>  
>  static int
>  pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
> -		       enum pnfs_iomode iomode, u64 offset, u64 length)
> +		       enum pnfs_iomode iomode, u64 offset, u64 length,
> +		       bool sync)
>  {
>  	struct inode *ino = lo->plh_inode;
>  	struct nfs4_layoutreturn *lrp;
> @@ -924,7 +926,7 @@ pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
>  	lrp->clp = NFS_SERVER(ino)->nfs_client;
>  	lrp->cred = lo->plh_lc_cred;
>  
> -	status = nfs4_proc_layoutreturn(lrp);
> +	status = nfs4_proc_layoutreturn(lrp, sync);
>  out:
>  	if (status) {
>  		spin_lock(&ino->i_lock);
> @@ -991,7 +993,7 @@ _pnfs_return_layout(struct inode *ino)
>  	pnfs_free_lseg_list(&tmp_list);
>  
>  	status = pnfs_send_layoutreturn(lo, stateid, IOMODE_ANY, 0,
> -					NFS4_MAX_UINT64);
> +					NFS4_MAX_UINT64, true);
>  out:
>  	dprintk("<-- %s status: %d\n", __func__, status);
>  	return status;
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 26e7cd8..7a33c50 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -219,7 +219,7 @@ extern int nfs4_proc_getdeviceinfo(struct nfs_server *server,
>  				   struct pnfs_device *dev,
>  				   struct rpc_cred *cred);
>  extern struct pnfs_layout_segment* nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags);
> -extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp);
> +extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool sync);
>  
>  /* pnfs.c */
>  void pnfs_get_layout_hdr(struct pnfs_layout_hdr *lo);
> 

