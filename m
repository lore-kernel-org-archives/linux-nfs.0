Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36826 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751307Ab1DTUeQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 16:34:16 -0400
Subject: Re: [RFC 09/27] pnfs: support for non-rpc layout drivers
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1303320444-21295-1-git-send-email-bhalevy@panasas.com>
References: <4DAF0DE1.6020609@panasas.com>
	 <1303320444-21295-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Apr 2011 16:34:15 -0400
Message-ID: <1303331655.23206.46.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-04-20 at 20:27 +0300, Benny Halevy wrote:
> Non-rpc layout driver such as for objects and blocks
> implement their own I/O path and error handling logic.
> Therefore bypass NFS-based error handling for these layout drivers.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/internal.h       |    2 +
>  fs/nfs/nfs4filelayout.c |    1 +
>  fs/nfs/nfs4proc.c       |   14 +++++++++++-
>  fs/nfs/pnfs.c           |   48 +++++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfs/pnfs.h           |    7 +++++-
>  include/linux/nfs_xdr.h |    2 +
>  6 files changed, 71 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index ce118ce..1914d2f 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -310,6 +310,8 @@ extern int nfs_migrate_page(struct address_space *,
>  #endif
>  
>  /* nfs4proc.c */
> +extern void __nfs4_read_done_cb(struct nfs_read_data *);
> +extern void __nfs4_write_done_cb(struct nfs_write_data *);
>  extern void nfs4_reset_read(struct rpc_task *task, struct nfs_read_data *data);
>  extern int nfs4_init_client(struct nfs_client *clp,
>  			    const struct rpc_timeout *timeparms,
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 2feab7f..e67a0d4 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -859,6 +859,7 @@ static struct pnfs_layoutdriver_type filelayout_type = {
>  	.id			= LAYOUT_NFSV4_1_FILES,
>  	.name			= "LAYOUT_NFSV4_1_FILES",
>  	.owner			= THIS_MODULE,
> +	.flags			= PNFS_USE_RPC_CODE,

This isn't being used anywhere, so why do I need it in this patch?

>  	.alloc_lseg		= filelayout_alloc_lseg,
>  	.free_lseg		= filelayout_free_lseg,
>  	.pg_test		= filelayout_pg_test,
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index d0eb50b..cc2cdcd 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3149,6 +3149,11 @@ static int nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
>  	return err;
>  }
>  
> +void __nfs4_read_done_cb(struct nfs_read_data *data)
^^^^^^^^^^^^^^^^^^^^^^^^^^^ why the wrapper?
> +{
> +	nfs_invalidate_atime(data->inode);
> +}
> +
>  static int nfs4_read_done_cb(struct rpc_task *task, struct nfs_read_data *data)
>  {
>  	struct nfs_server *server = NFS_SERVER(data->inode);
> @@ -3158,7 +3163,7 @@ static int nfs4_read_done_cb(struct rpc_task *task, struct nfs_read_data *data)
>  		return -EAGAIN;
>  	}
>  
> -	nfs_invalidate_atime(data->inode);
> +	__nfs4_read_done_cb(data);
>  	if (task->tk_status > 0)
>  		renew_lease(server, data->timestamp);
>  	return 0;
> @@ -3198,6 +3203,11 @@ void nfs4_reset_read(struct rpc_task *task, struct nfs_read_data *data)
>  }
>  EXPORT_SYMBOL_GPL(nfs4_reset_read);
>  
> +void __nfs4_write_done_cb(struct nfs_write_data *data)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Again, why the wrapper?

> +{
> +	nfs_post_op_update_inode_force_wcc(data->inode, data->res.fattr);
> +}
> +
>  static int nfs4_write_done_cb(struct rpc_task *task, struct nfs_write_data *data)
>  {
>  	struct inode *inode = data->inode;
> @@ -3208,7 +3218,7 @@ static int nfs4_write_done_cb(struct rpc_task *task, struct nfs_write_data *data
>  	}
>  	if (task->tk_status >= 0) {
>  		renew_lease(NFS_SERVER(inode), data->timestamp);
> -		nfs_post_op_update_inode_force_wcc(inode, data->res.fattr);
> +		__nfs4_write_done_cb(data);
>  	}
>  	return 0;
>  }
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index a5050d2..18ae397 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1130,6 +1130,30 @@ pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode)
>  	pgio->pg_test = (ld && ld->pg_test) ? pnfs_write_pg_test : NULL;
>  }
>  
> +/*
> + * Called by non rpc-based layout drivers
> + */
> +int
> +pnfs_write_done(struct nfs_write_data *data)
^^^^^^^^^^^^^^^^^^ If this is not generic to all pnfs layout drivers,
then why the apparently generic name?

Why isn't this being introduced together with a driver that actually
uses the functionality? There is no way to review it outside of that
context.

> +{
> +	int status;
> +
> +	put_lseg(data->lseg);
> +	data->lseg = NULL;
> +	if (!data->pnfs_error) {
> +		__nfs4_write_done_cb(data);
> +		data->mds_ops->rpc_call_done(NULL, data);
> +		data->mds_ops->rpc_release(data);
> +		return 0;
> +	}
> +
> +	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
> +		data->pnfs_error);
> +	status = nfs_initiate_write(data, NFS_CLIENT(data->inode), data->mds_ops, NFS_FILE_SYNC);
> +	return status ? : -EAGAIN;
> +}
> +EXPORT_SYMBOL_GPL(pnfs_write_done);
> +
>  enum pnfs_try_status
>  pnfs_try_to_write_data(struct nfs_write_data *wdata,
>  			const struct rpc_call_ops *call_ops, int how)
> @@ -1155,6 +1179,30 @@ pnfs_try_to_write_data(struct nfs_write_data *wdata,
>  }
>  
>  /*
> + * Called by non rpc-based layout drivers
> + */
> +int
> +pnfs_read_done(struct nfs_read_data *data)
> +{
> +	int status;
> +
> +	put_lseg(data->lseg);
> +	data->lseg = NULL;
> +	if (!data->pnfs_error) {
> +		__nfs4_read_done_cb(data);
> +		data->mds_ops->rpc_call_done(NULL, data);
> +		data->mds_ops->rpc_release(data);
> +		return 0;
> +	}
> +
> +	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
> +		data->pnfs_error);
> +	status = nfs_initiate_read(data, NFS_CLIENT(data->inode), data->mds_ops);
> +	return status ? : -EAGAIN;
> +}
> +EXPORT_SYMBOL_GPL(pnfs_read_done);
> +
> +/*
>   * Call the appropriate parallel I/O subsystem read function.
>   */
>  enum pnfs_try_status
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 9f8e970..18b84ce 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -65,8 +65,11 @@ enum {
>  };
>  
>  enum layoutdriver_policy_flags {
> +	/* Should the full nfs rpc cleanup code be used after io */
> +	PNFS_USE_RPC_CODE		= 1 << 0,
> +
>  	/* Should the pNFS client commit and return the layout upon a setattr */
> -	PNFS_LAYOUTRET_ON_SETATTR	= 1 << 0,
> +	PNFS_LAYOUTRET_ON_SETATTR	= 1 << 1,
>  };
>  
>  /* Per-layout driver specific registration structure */
> @@ -182,6 +185,8 @@ bool pnfs_roc_drain(struct inode *ino, u32 *barrier);
>  void pnfs_set_layoutcommit(struct nfs_write_data *wdata);
>  int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
>  int _pnfs_return_layout(struct inode *, struct pnfs_layout_range *, bool wait);
> +int pnfs_write_done(struct nfs_write_data *);
> +int pnfs_read_done(struct nfs_read_data *);
>  
>  static inline int lo_fail_bit(u32 iomode)
>  {
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 01eb1ae..41f896a 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -1108,6 +1108,7 @@ struct nfs_read_data {
>  	const struct rpc_call_ops *mds_ops;
>  	int (*read_done_cb) (struct rpc_task *task, struct nfs_read_data *data);
>  	__u64			mds_offset;
> +	int			pnfs_error;
>  	struct page		*page_array[NFS_PAGEVEC_SIZE];
>  };
>  
> @@ -1133,6 +1134,7 @@ struct nfs_write_data {
>  	unsigned long		timestamp;	/* For lease renewal */
>  #endif
>  	__u64			mds_offset;	/* Filelayout dense stripe */
> +	int			pnfs_error;
>  	struct page		*page_array[NFS_PAGEVEC_SIZE];
>  };
>  

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

