Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:43209 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752548Ab1BUSx3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Feb 2011 13:53:29 -0500
Message-ID: <4D62B4A8.5030500@panasas.com>
Date: Mon, 21 Feb 2011 10:53:28 -0800
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 5/7] NFSv4.1: implement generic pnfs layer write switch
References: <1298310576-13523-1-git-send-email-iisaman@netapp.com> <1298310576-13523-6-git-send-email-iisaman@netapp.com>
In-Reply-To: <1298310576-13523-6-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-02-21 09:49, Fred Isaman wrote:
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 1d4e631..3766afea 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -79,6 +79,8 @@ struct pnfs_layoutdriver_type {
>  	 * I/O, else return PNFS_NOT_ATTEMPTED to fall back to normal NFS
>  	 */
>  	enum pnfs_try_status (*read_pagelist) (struct nfs_read_data *nfs_data);
> +	enum pnfs_try_status
> +	(*write_pagelist) (struct nfs_write_data *nfs_data, int how);

nit: line break

>  };
>  
>  struct pnfs_layout_hdr {
> @@ -120,6 +122,8 @@ pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
>  		   enum pnfs_iomode access_type);
>  void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
>  void unset_pnfs_layoutdriver(struct nfs_server *);
> +enum pnfs_try_status pnfs_try_to_write_data(struct nfs_write_data *,
> +					     const struct rpc_call_ops *, int);
>  enum pnfs_try_status pnfs_try_to_read_data(struct nfs_read_data *,
>  					    const struct rpc_call_ops *);
>  void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *);
> @@ -200,6 +204,13 @@ pnfs_try_to_read_data(struct nfs_read_data *data,
>  	return PNFS_NOT_ATTEMPTED;
>  }
>  
> +static inline enum pnfs_try_status
> +pnfs_try_to_write_data(struct nfs_write_data *data,
> +		       const struct rpc_call_ops *call_ops, int how)
> +{
> +	return PNFS_NOT_ATTEMPTED;
> +}
> +
>  static inline bool
>  pnfs_roc(struct inode *ino)
>  {
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 6cf5de6..b6b683d 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -873,6 +873,10 @@ static int nfs_write_rpcsetup(struct nfs_page *req,
>  	data->res.verf    = &data->verf;
>  	nfs_fattr_init(&data->fattr);
>  
> +	if (data->lseg &&
> +	    (pnfs_try_to_write_data(data, call_ops, how) == PNFS_ATTEMPTED))
> +		return 0;
> +
>  	return nfs_initiate_write(data, NFS_CLIENT(inode), call_ops, how);
>  }
>  
> diff --git a/include/linux/nfs_iostat.h b/include/linux/nfs_iostat.h
> index 37a1437..8866bb3 100644
> --- a/include/linux/nfs_iostat.h
> +++ b/include/linux/nfs_iostat.h
> @@ -114,6 +114,7 @@ enum nfs_stat_eventcounters {
>  	NFSIOS_SHORTWRITE,
>  	NFSIOS_DELAY,
>  	NFSIOS_PNFS_READ,
> +	NFSIOS_PNFS_WRITE,
>  	__NFSIOS_COUNTSMAX,
>  };
>  
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 09d9681..c82ad33 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -1039,6 +1039,7 @@ struct nfs_write_data {
>  	struct nfs_writeargs	args;		/* argument struct */
>  	struct nfs_writeres	res;		/* result struct */
>  	struct pnfs_layout_segment *lseg;
> +	const struct rpc_call_ops *mds_ops;

nit: mds_ops is not really used in the patch, just initialized.
better introduce it along with its usage in patch 7/7.

Benny

>  	int (*write_done_cb) (struct rpc_task *task, struct nfs_write_data *data);
>  #ifdef CONFIG_NFS_V4
>  	unsigned long		timestamp;	/* For lease renewal */
