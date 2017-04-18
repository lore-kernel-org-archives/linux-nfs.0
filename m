Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:15378 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932443AbdDRPEC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Apr 2017 11:04:02 -0400
Subject: Re: [PATCH 1/1] NFS append COMMIT after synchronous COPY
To: Olga Kornievskaia <kolga@netapp.com>,
        <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
References: <20170417211537.93047-1-kolga@netapp.com>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <5ebc2df1-f209-fb9d-ee71-b2e64d0139e9@Netapp.com>
Date: Tue, 18 Apr 2017 11:03:56 -0400
MIME-Version: 1.0
In-Reply-To: <20170417211537.93047-1-kolga@netapp.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga,

On 04/17/2017 05:15 PM, Olga Kornievskaia wrote:
> Instead of messing with the commit path which has been causing issues,
> add a COMMIT op after the COPY and ask for stable copies in the first
> space.
> 
> It saves a round trip, since after the COPY, the client sends a COMMIT
> anyway.
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/internal.h  |  1 -
>  fs/nfs/nfs42proc.c |  6 ------
>  fs/nfs/nfs42xdr.c  | 15 +++++++++++++++
>  fs/nfs/write.c     | 30 ------------------------------
>  4 files changed, 15 insertions(+), 37 deletions(-)
> 
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 7b38fed..2989418 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -495,7 +495,6 @@ void nfs_mark_request_commit(struct nfs_page *req,
>  			     u32 ds_commit_idx);
>  int nfs_write_need_commit(struct nfs_pgio_header *);
>  void nfs_writeback_update_inode(struct nfs_pgio_header *hdr);
> -int nfs_commit_file(struct file *file, struct nfs_write_verifier *verf);
>  int nfs_generic_commit_list(struct inode *inode, struct list_head *head,
>  			    int how, struct nfs_commit_info *cinfo);
>  void nfs_retry_commit(struct list_head *page_list,
> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
> index 1e486c7..9fee48d 100644
> --- a/fs/nfs/nfs42proc.c
> +++ b/fs/nfs/nfs42proc.c
> @@ -174,12 +174,6 @@ static ssize_t _nfs42_proc_copy(struct file *src,
>  	if (status)
>  		return status;
>  
> -	if (res->write_res.verifier.committed != NFS_FILE_SYNC) {
> -		status = nfs_commit_file(dst, &res->write_res.verifier.verifier);
> -		if (status)
> -			return status;
> -	}
> -
>  	truncate_pagecache_range(dst_inode, pos_dst,
>  				 pos_dst + res->write_res.count);
>  
> diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
> index 6c72964..03f3c9e 100644
> --- a/fs/nfs/nfs42xdr.c
> +++ b/fs/nfs/nfs42xdr.c
> @@ -25,6 +25,8 @@
>  					 NFS42_WRITE_RES_SIZE + \
>  					 1 /* cr_consecutive */ + \
>  					 1 /* cr_synchronous */)
> +#define decode_commit_maxsz		(op_decode_hdr_maxsz + \
> +					 decode_verifier_maxsz)e

nfs4xdr.c includes this file (it's a weird setup, I know), so this and the corresponding encode size should already be declared and available to us.  Can you add them to the NFS4_enc_copy_sz and NFS4_dec_copy_size values?

Thanks,
Anna

>  #define encode_deallocate_maxsz		(op_encode_hdr_maxsz + \
>  					 encode_fallocate_maxsz)
>  #define decode_deallocate_maxsz		(op_decode_hdr_maxsz)
> @@ -222,6 +224,18 @@ static void nfs4_xdr_enc_allocate(struct rpc_rqst *req,
>  	encode_nops(&hdr);
>  }
>  
> +static void encode_copy_commit(struct xdr_stream *xdr,
> +			  struct nfs42_copy_args *args,
> +			  struct compound_hdr *hdr)
> +{
> +	__be32 *p;
> +
> +	encode_op_hdr(xdr, OP_COMMIT, decode_commit_maxsz, hdr);
> +	p = reserve_space(xdr, 12);
> +	p = xdr_encode_hyper(p, args->dst_pos);
> +	*p = cpu_to_be32(args->count);
> +}
> +
>  /*
>   * Encode COPY request
>   */
> @@ -239,6 +253,7 @@ static void nfs4_xdr_enc_copy(struct rpc_rqst *req,
>  	encode_savefh(xdr, &hdr);
>  	encode_putfh(xdr, args->dst_fh, &hdr);
>  	encode_copy(xdr, args, &hdr);
> +	encode_copy_commit(xdr, args, &hdr);
>  	encode_nops(&hdr);
>  }
>  
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index abb2c8a..8d65d88 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1720,36 +1720,6 @@ void nfs_retry_commit(struct list_head *page_list,
>  	return -ENOMEM;
>  }
>  
> -int nfs_commit_file(struct file *file, struct nfs_write_verifier *verf)
> -{
> -	struct inode *inode = file_inode(file);
> -	struct nfs_open_context *open;
> -	struct nfs_commit_info cinfo;
> -	struct nfs_page *req;
> -	int ret;
> -
> -	open = get_nfs_open_context(nfs_file_open_context(file));
> -	req  = nfs_create_request(open, NULL, NULL, 0, i_size_read(inode));
> -	if (IS_ERR(req)) {
> -		ret = PTR_ERR(req);
> -		goto out_put;
> -	}
> -
> -	nfs_init_cinfo_from_inode(&cinfo, inode);
> -
> -	memcpy(&req->wb_verf, verf, sizeof(struct nfs_write_verifier));
> -	nfs_request_add_commit_list(req, &cinfo);
> -	ret = nfs_commit_inode(inode, FLUSH_SYNC);
> -	if (ret > 0)
> -		ret = 0;
> -
> -	nfs_free_request(req);
> -out_put:
> -	put_nfs_open_context(open);
> -	return ret;
> -}
> -EXPORT_SYMBOL_GPL(nfs_commit_file);
> -
>  /*
>   * COMMIT call returned
>   */
> 
