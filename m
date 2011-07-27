Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9744 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753057Ab1G0TxK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 15:53:10 -0400
Subject: Re: [PATCH v3 06/25] pnfs: cleanup_layoutcommit
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Wed, 27 Jul 2011 15:53:09 -0400
In-Reply-To: <1311792048-12551-7-git-send-email-rees@umich.edu>
References: <1311792048-12551-1-git-send-email-rees@umich.edu>
	 <1311792048-12551-7-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1311796389.25645.20.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-07-27 at 14:40 -0400, Jim Rees wrote: 
> From: Andy Adamson <andros@netapp.com>
> 
> This gives layout driver a chance to cleanup structures they put in at
> encode_layoutcommit.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> [fixup layout header pointer for layoutcommit]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> Signed-off-by: Benny Halevy <bhalevy@tonian.com>
> ---
>  fs/nfs/nfs4proc.c       |    1 +
>  fs/nfs/nfs4xdr.c        |    1 +
>  fs/nfs/pnfs.c           |   10 ++++++++++
>  fs/nfs/pnfs.h           |    5 +++++
>  include/linux/nfs_xdr.h |    1 +
>  5 files changed, 18 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index e86de79..6cb84b4 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5963,6 +5963,7 @@ static void nfs4_layoutcommit_release(void *calldata)
>  	struct nfs4_layoutcommit_data *data = calldata;
>  	struct pnfs_layout_segment *lseg, *tmp;
>  
> +	pnfs_cleanup_layoutcommit(data->args.inode, data);
>  	/* Matched by references in pnfs_set_layoutcommit */
>  	list_for_each_entry_safe(lseg, tmp, &data->lseg_list, pls_lc_list) {
>  		list_del_init(&lseg->pls_lc_list);
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index f32dde9..ea2da30 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
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

This really needs to go. We should have

      int (*layoutcommit)()...

instead of 'encode' and 'cleanup' methods...

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

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

