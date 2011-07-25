Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:54175 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752119Ab1GYO1A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jul 2011 10:27:00 -0400
Received: by pzk37 with SMTP id 37so8592804pzk.1
        for <linux-nfs@vger.kernel.org>; Mon, 25 Jul 2011 07:27:00 -0700 (PDT)
Message-ID: <4E2D7D2E.50204@tonian.com>
Date: Mon, 25 Jul 2011 10:26:54 -0400
From: Benny Halevy <bhalevy@tonian.com>
To: Jim Rees <rees@umich.edu>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH v2 06/25] pnfs: cleanup_layoutcommit
References: <1311276865-29484-1-git-send-email-rees@umich.edu> <1311276865-29484-7-git-send-email-rees@umich.edu>
In-Reply-To: <1311276865-29484-7-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-07-21 15:34, Jim Rees wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> This gives layout driver a chance to cleanup structures they put in at
> encode_layoutcommit.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> [fixup layout header pointer for layoutcommit]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> Signed-off-by: Benny Halevy <benny@tonian.com>
> ---
>  fs/nfs/nfs4proc.c       |    1 +
>  fs/nfs/nfs4xdr.c        |    3 ++-
>  fs/nfs/pnfs.c           |   10 ++++++++++
>  fs/nfs/pnfs.h           |    5 +++++
>  include/linux/nfs_xdr.h |    1 +
>  5 files changed, 19 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index e02f545..795033c5 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5965,6 +5965,7 @@ static void nfs4_layoutcommit_release(void *calldata)
>  	struct nfs4_layoutcommit_data *data = calldata;
>  	struct pnfs_layout_segment *lseg, *tmp;
>  
> +	pnfs_cleanup_layoutcommit(data->args.inode, data);
>  	/* Matched by references in pnfs_set_layoutcommit */
>  	list_for_each_entry_safe(lseg, tmp, &data->lseg_list, pls_lc_list) {
>  		list_del_init(&lseg->pls_lc_list);
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 5ce3c64..07c41b2 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -1991,7 +1991,7 @@ encode_layoutcommit(struct xdr_stream *xdr,
>  	*p++ = cpu_to_be32(OP_LAYOUTCOMMIT);
>  	/* Only whole file layouts */
>  	p = xdr_encode_hyper(p, 0); /* offset */
> -	p = xdr_encode_hyper(p, NFS4_MAX_UINT64); /* length */
> +	p = xdr_encode_hyper(p, args->lastbytewritten+1); /* length */

This particular change seems to be related to [PATCH 03/25]
"NFS41: Let layoutcommit handle multiple segments"

Benny

>  	*p++ = cpu_to_be32(0); /* reclaim */
>  	p = xdr_encode_opaque_fixed(p, args->stateid.data, NFS4_STATEID_SIZE);
>  	*p++ = cpu_to_be32(1); /* newoffset = TRUE */
> @@ -5596,6 +5596,7 @@ static int decode_layoutcommit(struct xdr_stream *xdr,
>  	int status;
>  
>  	status = decode_op_hdr(xdr, OP_LAYOUTCOMMIT);
> +	res->status = status;
>  	if (status)
>  		return status;
>  
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index fbebd2a..3b20753 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1411,6 +1411,16 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
>  }
>  EXPORT_SYMBOL_GPL(pnfs_set_layoutcommit);
>  
> +void pnfs_cleanup_layoutcommit(struct inode *inode,
> +			       struct nfs4_layoutcommit_data *data)
> +{
> +	struct nfs_server *nfss = NFS_SERVER(inode);
> +
> +	if (nfss->pnfs_curr_ld->cleanup_layoutcommit)
> +		nfss->pnfs_curr_ld->cleanup_layoutcommit(NFS_I(inode)->layout,
> +							 data);
> +}
> +
>  /*
>   * For the LAYOUT4_NFSV4_1_FILES layout type, NFS_DATA_SYNC WRITEs and
>   * NFS_UNSTABLE WRITEs with a COMMIT to data servers must store enough
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index bddd8b9..f271425 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -113,6 +113,9 @@ struct pnfs_layoutdriver_type {
>  				     struct xdr_stream *xdr,
>  				     const struct nfs4_layoutreturn_args *args);
>  
> +	void (*cleanup_layoutcommit) (struct pnfs_layout_hdr *layoutid,
> +				      struct nfs4_layoutcommit_data *data);
> +
>  	void (*encode_layoutcommit) (struct pnfs_layout_hdr *layoutid,
>  				     struct xdr_stream *xdr,
>  				     const struct nfs4_layoutcommit_args *args);
> @@ -196,6 +199,8 @@ void pnfs_roc_release(struct inode *ino);
>  void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
>  bool pnfs_roc_drain(struct inode *ino, u32 *barrier);
>  void pnfs_set_layoutcommit(struct nfs_write_data *wdata);
> +void pnfs_cleanup_layoutcommit(struct inode *inode,
> +			       struct nfs4_layoutcommit_data *data);
>  int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
>  int _pnfs_return_layout(struct inode *);
>  int pnfs_ld_write_done(struct nfs_write_data *);
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 94f27e5..569ea5b 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -269,6 +269,7 @@ struct nfs4_layoutcommit_res {
>  	struct nfs_fattr *fattr;
>  	const struct nfs_server *server;
>  	struct nfs4_sequence_res seq_res;
> +	int status;
>  };
>  
>  struct nfs4_layoutcommit_data {
