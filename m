Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52125 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752408Ab1DTUWR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 16:22:17 -0400
Subject: Re: [RFC 08/27] pnfs: {setup,cleanup}_layoutcommit
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1303320436-21258-1-git-send-email-bhalevy@panasas.com>
References: <4DAF0DE1.6020609@panasas.com>
	 <1303320436-21258-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Apr 2011 16:22:15 -0400
Message-ID: <1303330935.23206.42.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-04-20 at 20:27 +0300, Benny Halevy wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/nfs4proc.c       |    2 ++
>  fs/nfs/nfs4xdr.c        |    1 +
>  fs/nfs/pnfs.c           |   21 +++++++++++++++++++++
>  fs/nfs/pnfs.h           |    8 ++++++++
>  include/linux/nfs_xdr.h |    1 +
>  5 files changed, 33 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index b4df7a6..d0eb50b 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5807,6 +5807,7 @@ static void nfs4_layoutcommit_prepare(struct rpc_task *task, void *calldata)
>  	if (nfs4_setup_sequence(server, &data->args.seq_args,
>  				&data->res.seq_res, 1, task))
>  		return;
> +	data->res.status = -1;
>  	rpc_call_start(task);
>  }
>  
> @@ -5841,6 +5842,7 @@ static void nfs4_layoutcommit_release(void *calldata)
>  {
>  	struct nfs4_layoutcommit_data *data = calldata;
>  
> +	pnfs_cleanup_layoutcommit(data->args.inode, data);
>  	/* Matched by references in pnfs_set_layoutcommit */
>  	put_lseg(data->lseg);
>  	put_rpccred(data->cred);
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 4f7bef9..23e608f 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -5307,6 +5307,7 @@ static int decode_layoutcommit(struct xdr_stream *xdr,
>  	int status;
>  
>  	status = decode_op_hdr(xdr, OP_LAYOUTCOMMIT);
> +	res->status = status;
>  	if (status)
>  		return status;
>  
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 0b4ad1f..a5050d2 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1181,6 +1181,19 @@ pnfs_try_to_read_data(struct nfs_read_data *rdata,
>  	return trypnfs;
>  }
>  
> +void pnfs_cleanup_layoutcommit(struct inode *inode,
> +			       struct nfs4_layoutcommit_data *data)
> +{
> +	struct nfs_server *nfss = NFS_SERVER(inode);
> +
> +	/* TODO: Maybe we should avoid this by allowing the layout driver
> +	* to directly xdr its layout on the wire.
> +	*/
> +	if (nfss->pnfs_curr_ld->cleanup_layoutcommit)
> +		nfss->pnfs_curr_ld->cleanup_layoutcommit(
> +					NFS_I(inode)->layout, data);
> +}
> +
>  /*
>   * Currently there is only one (whole file) write lseg.
>   */
> @@ -1277,6 +1290,14 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
>  	data->args.lastbytewritten = end_pos - 1;
>  	data->res.server = NFS_SERVER(inode);
>  
> +	/* Call layout driver to set the arguments */
> +	if (NFS_SERVER(inode)->pnfs_curr_ld->setup_layoutcommit) {
> +		status = NFS_SERVER(inode)->pnfs_curr_ld->setup_layoutcommit(
> +				NFS_I(inode)->layout, &data->args);
> +		if (status)
> +			goto out;
> +	}
> +
>  	status = nfs4_proc_layoutcommit(data, sync);
>  out:
>  	dprintk("<-- %s status %d\n", __func__, status);
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 011885e..9f8e970 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -99,10 +99,16 @@ struct pnfs_layoutdriver_type {
>  	/* device notification methods */
>  	void (*delete_deviceid)(struct nfs4_deviceid *);
>  
> +	int (*setup_layoutcommit) (struct pnfs_layout_hdr *layoutid,
> +				   struct nfs4_layoutcommit_args *args);
> +
>  	void (*encode_layoutcommit) (struct pnfs_layout_hdr *layoutid,
>  				     struct xdr_stream *xdr,
>  				     const struct nfs4_layoutcommit_args *args);
>  
> +	void (*cleanup_layoutcommit) (struct pnfs_layout_hdr *layoutid,
> +				      struct nfs4_layoutcommit_data *data);
> +

This is yet more callback ugliness. Please replace this +  the
encode_layoutcommit+.... with a single

int (*layoutcommit) (struct pnfs_layout_hdr)

that does everything from pre- and post-processing to the actual RPC
call for layoutcommit.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

