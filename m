Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:13301 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756563Ab1EWSKk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 14:10:40 -0400
Message-ID: <4DDAA30A.8090806@panasas.com>
Date: Mon, 23 May 2011 21:10:18 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v6 19/26] pnfs: support for non-rpc layout drivers
References: <4DDA8C3D.5080706@panasas.com> <1306168687-11649-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <1306168687-11649-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/23/2011 07:38 PM, Benny Halevy wrote:
> Non-rpc layout driver such as for objects and blocks
> implement their own I/O path and error handling logic.
> Therefore bypass NFS-based error handling for these layout drivers.
> 
> [fix lseg ref-count bugs, and null de-refs]
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> [get rid of PNFS_USE_RPC_CODE]
> [get rid of __nfs4_write_done_cb]
> [revert useless change in nfs4_write_done_cb]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/internal.h       |    1 +
>  fs/nfs/nfs4proc.c       |   13 +++++++++--
>  fs/nfs/pnfs.c           |   52 ++++++++++++++++++++++++++++++++++++++++++++++-
>  fs/nfs/pnfs.h           |    2 +
>  include/linux/nfs_xdr.h |    2 +
>  5 files changed, 66 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index ce118ce..bcf0f0f 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -310,6 +310,7 @@ extern int nfs_migrate_page(struct address_space *,
>  #endif
>  
>  /* nfs4proc.c */
> +extern void __nfs4_read_done_cb(struct nfs_read_data *);
>  extern void nfs4_reset_read(struct rpc_task *task, struct nfs_read_data *data);
>  extern int nfs4_init_client(struct nfs_client *clp,
>  			    const struct rpc_timeout *timeparms,
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index cf1b339..92c8bc4 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3175,6 +3175,11 @@ static int nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
>  	return err;
>  }
>  
> +void __nfs4_read_done_cb(struct nfs_read_data *data)
> +{
> +	nfs_invalidate_atime(data->inode);
> +}
> +
>  static int nfs4_read_done_cb(struct rpc_task *task, struct nfs_read_data *data)
>  {
>  	struct nfs_server *server = NFS_SERVER(data->inode);
> @@ -3184,7 +3189,7 @@ static int nfs4_read_done_cb(struct rpc_task *task, struct nfs_read_data *data)
>  		return -EAGAIN;
>  	}
>  
> -	nfs_invalidate_atime(data->inode);
> +	__nfs4_read_done_cb(data);
>  	if (task->tk_status > 0)
>  		renew_lease(server, data->timestamp);
>  	return 0;
> @@ -3198,7 +3203,8 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
>  	if (!nfs4_sequence_done(task, &data->res.seq_res))
>  		return -EAGAIN;
>  
> -	return data->read_done_cb(task, data);
> +	return data->read_done_cb ? data->read_done_cb(task, data) :
> +				    nfs4_read_done_cb(task, data);
>  }
>  
>  static void nfs4_proc_read_setup(struct nfs_read_data *data, struct rpc_message *msg)
> @@ -3243,7 +3249,8 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
>  {
>  	if (!nfs4_sequence_done(task, &data->res.seq_res))
>  		return -EAGAIN;
> -	return data->write_done_cb(task, data);
> +	return data->write_done_cb ? data->write_done_cb(task, data) :
> +		nfs4_write_done_cb(task, data);
>  }
>  
>  /* Reset the the nfs_write_data to send the write to the MDS. */
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index ef535f2..0f59802 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -243,7 +243,7 @@ put_lseg_common(struct pnfs_layout_segment *lseg)
>  {
>  	struct inode *inode = lseg->pls_layout->plh_inode;
>  
> -	BUG_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
> +	WARN_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
>  	list_del_init(&lseg->pls_list);
>  	if (list_empty(&lseg->pls_layout->plh_segs)) {
>  		set_bit(NFS_LAYOUT_DESTROYED, &lseg->pls_layout->plh_flags);
> @@ -1054,6 +1054,31 @@ pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode)
>  	pgio->pg_test = (ld && ld->pg_test) ? pnfs_write_pg_test : NULL;
>  }
>  
> +/*
> + * Called by non rpc-based layout drivers
> + */
> +int
> +pnfs_ld_write_done(struct nfs_write_data *data)
> +{
> +	int status;
> +
> +	if (!data->pnfs_error) {
> +		pnfs_set_layoutcommit(data);
> +		data->mds_ops->rpc_call_done(&data->task, data);
> +		data->mds_ops->rpc_release(data);
> +		return 0;
> +	}
> +
> +	put_lseg(data->lseg);
> +	data->lseg = NULL;

These puts are not good as well. I tested. Do you want a SQUASHME or
a replacement patch?


> +	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
> +		data->pnfs_error);
> +	status = nfs_initiate_write(data, NFS_CLIENT(data->inode),
> +				    data->mds_ops, NFS_FILE_SYNC);
> +	return status ? : -EAGAIN;
> +}
> +EXPORT_SYMBOL_GPL(pnfs_ld_write_done);
> +
>  enum pnfs_try_status
>  pnfs_try_to_write_data(struct nfs_write_data *wdata,
>  			const struct rpc_call_ops *call_ops, int how)
> @@ -1079,6 +1104,31 @@ pnfs_try_to_write_data(struct nfs_write_data *wdata,
>  }
>  
>  /*
> + * Called by non rpc-based layout drivers
> + */
> +int
> +pnfs_ld_read_done(struct nfs_read_data *data)
> +{
> +	int status;
> +
> +	if (!data->pnfs_error) {
> +		__nfs4_read_done_cb(data);
> +		data->mds_ops->rpc_call_done(&data->task, data);
> +		data->mds_ops->rpc_release(data);
> +		return 0;
> +	}
> +
> +	put_lseg(data->lseg);
> +	data->lseg = NULL;

Here to

Boaz
> +	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
> +		data->pnfs_error);
> +	status = nfs_initiate_read(data, NFS_CLIENT(data->inode),
> +				   data->mds_ops);
> +	return status ? : -EAGAIN;
> +}
> +EXPORT_SYMBOL_GPL(pnfs_ld_read_done);
> +
> +/*
>   * Call the appropriate parallel I/O subsystem read function.
>   */
>  enum pnfs_try_status
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index ed167a7..8a6e1f1 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -165,6 +165,8 @@ void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
>  bool pnfs_roc_drain(struct inode *ino, u32 *barrier);
>  void pnfs_set_layoutcommit(struct nfs_write_data *wdata);
>  int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
> +int pnfs_ld_write_done(struct nfs_write_data *);
> +int pnfs_ld_read_done(struct nfs_read_data *);
>  
>  /* pnfs_dev.c */
>  struct nfs4_deviceid_node {
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 7e371f7..7c8ff09 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -1087,6 +1087,7 @@ struct nfs_read_data {
>  	const struct rpc_call_ops *mds_ops;
>  	int (*read_done_cb) (struct rpc_task *task, struct nfs_read_data *data);
>  	__u64			mds_offset;
> +	int			pnfs_error;
>  	struct page		*page_array[NFS_PAGEVEC_SIZE];
>  };
>  
> @@ -1112,6 +1113,7 @@ struct nfs_write_data {
>  	unsigned long		timestamp;	/* For lease renewal */
>  #endif
>  	__u64			mds_offset;	/* Filelayout dense stripe */
> +	int			pnfs_error;
>  	struct page		*page_array[NFS_PAGEVEC_SIZE];
>  };
>  

