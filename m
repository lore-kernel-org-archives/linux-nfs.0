Return-Path: <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH v7 07/10] pNFS: Retry NFS4ERR_OLD_STATEID errors in
 layoutreturn-on-close
To: Trond Myklebust <trond.myklebust@primarydata.com>, Benjamin Coddington
	<bcodding@redhat.com>
CC: <linux-nfs@vger.kernel.org>
References: <20171106152726.13755-1-trond.myklebust@primarydata.com>
 <20171106152726.13755-2-trond.myklebust@primarydata.com>
 <20171106152726.13755-3-trond.myklebust@primarydata.com>
 <20171106152726.13755-4-trond.myklebust@primarydata.com>
 <20171106152726.13755-5-trond.myklebust@primarydata.com>
 <20171106152726.13755-6-trond.myklebust@primarydata.com>
 <20171106152726.13755-7-trond.myklebust@primarydata.com>
 <20171106152726.13755-8-trond.myklebust@primarydata.com>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <056582c3-b9ef-eadf-b433-db86779b1c56@Netapp.com>
Date: Mon, 6 Nov 2017 14:27:50 -0500
MIME-Version: 1.0
In-Reply-To: <20171106152726.13755-8-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=utf-8
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On 11/06/2017 10:27 AM, Trond Myklebust wrote:
> If our layoutreturn on close operation returns an NFS4ERR_OLD_STATEID,
> then try to update the stateid and retry. We know that there should
> be no further LAYOUTGET requests being launched.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs4proc.c | 18 ++++++++++++++++--
>  fs/nfs/pnfs.c     | 18 ++++++++++++++++++
>  fs/nfs/pnfs.h     |  5 +++++
>  3 files changed, 39 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index fe4a855dc965..1bb0e405aa57 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3165,11 +3165,18 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
>  			calldata->arg.lr_args = NULL;
>  			calldata->res.lr_res = NULL;
>  			break;
> +		case -NFS4ERR_OLD_STATEID:
> +			if (nfs4_refresh_layout_stateid(&calldata->arg.lr_args->stateid,
> +						calldata->inode)) {
> +				calldata->res.lr_ret = 0;
> +				rpc_restart_call_prepare(task);
> +				return;
> +			}
> +			/* Fallthrough */
>  		case -NFS4ERR_ADMIN_REVOKED:
>  		case -NFS4ERR_DELEG_REVOKED:
>  		case -NFS4ERR_EXPIRED:
>  		case -NFS4ERR_BAD_STATEID:
> -		case -NFS4ERR_OLD_STATEID:
>  		case -NFS4ERR_UNKNOWN_LAYOUTTYPE:
>  		case -NFS4ERR_WRONG_CRED:
>  			calldata->arg.lr_args = NULL;
> @@ -5787,11 +5794,18 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
>  			data->args.lr_args = NULL;
>  			data->res.lr_res = NULL;
>  			break;
> +		case -NFS4ERR_OLD_STATEID:
> +			if (nfs4_refresh_layout_stateid(&data->args.lr_args->stateid,
> +						data->inode)) {
> +				data->res.lr_ret = 0;
> +				rpc_restart_call_prepare(task);
> +				return;
> +			}
> +			/* Fallthrough */
>  		case -NFS4ERR_ADMIN_REVOKED:
>  		case -NFS4ERR_DELEG_REVOKED:
>  		case -NFS4ERR_EXPIRED:
>  		case -NFS4ERR_BAD_STATEID:
> -		case -NFS4ERR_OLD_STATEID:
>  		case -NFS4ERR_UNKNOWN_LAYOUTTYPE:
>  		case -NFS4ERR_WRONG_CRED:
>  			data->args.lr_args = NULL;
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 3bcd669a3152..5e4cd6a7af66 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -355,6 +355,24 @@ pnfs_clear_lseg_state(struct pnfs_layout_segment *lseg,
>  }
>  
>  /*
> + * Update the seqid of a layout stateid
> + */
> +bool nfs4_refresh_layout_stateid(nfs4_stateid *dst, struct inode *inode)
> +{
> +	struct pnfs_layout_hdr *lo;
> +	bool ret = false;
> +
> +	spin_lock(&inode->i_lock);
> +	lo = NFS_I(inode)->layout;
> +	if (lo && nfs4_stateid_match_other(dst, &lo->plh_stateid)) {
> +		dst->seqid = lo->plh_stateid.seqid;
> +		ret = true;
> +	}
> +	spin_unlock(&inode->i_lock);
> +	return ret;
> +}
> +
> +/*
>   * Mark a pnfs_layout_hdr and all associated layout segments as invalid
>   *
>   * In order to continue using the pnfs_layout_hdr, a full recovery
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 87f144f14d1e..40159cb572c7 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -251,6 +251,7 @@ int pnfs_destroy_layouts_byfsid(struct nfs_client *clp,
>  		bool is_recall);
>  int pnfs_destroy_layouts_byclid(struct nfs_client *clp,
>  		bool is_recall);
> +bool nfs4_refresh_layout_stateid(nfs4_stateid *dst, struct inode *inode);
>  void pnfs_put_layout_hdr(struct pnfs_layout_hdr *lo);
>  void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
>  			     const nfs4_stateid *new,
> @@ -764,6 +765,10 @@ static inline void nfs4_pnfs_v3_ds_connect_unload(void)
>  {
>  }
>  
> +bool nfs4_refresh_layout_stateid(nfs4_stateid *dst, struct inode *inode)
> +{
> +	return false;
> +}

Shouldn't this be static & inline?  I'm seeing a bunch of "multiple definitions" errors with v4.1 disabled.

Thanks
Anna

>  #endif /* CONFIG_NFS_V4_1 */
>  
>  #if IS_ENABLED(CONFIG_NFS_V4_2)
> 
