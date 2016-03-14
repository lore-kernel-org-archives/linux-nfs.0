Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58994 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750912AbcCNVe2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Mar 2016 17:34:28 -0400
Date: Mon, 14 Mar 2016 17:34:26 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@primarydata.com,
        hch@infradead.org
Subject: Re: [PATCH v3 3/3] NFSD: Implement the COPY call
Message-ID: <20160314213426.GC22276@fieldses.org>
References: <1457474158-16050-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1457474158-16050-4-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1457474158-16050-4-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 08, 2016 at 04:55:57PM -0500, Anna Schumaker wrote:
> From: Anna Schumaker <Anna.Schumaker@netapp.com>
> 
> I only implemented the sync version of this call, since it's the
> easiest.  I can simply call vfs_copy_range() and have the vfs do the
> right thing for the filesystem being exported.
> 
> Signed-off-by: Anna Schumaker <bjschuma@netapp.com>
> --
> v3:
> - Check for copying beyond the end of the file
> ---
>  fs/nfsd/nfs4proc.c | 98 ++++++++++++++++++++++++++++++++++++++++++++++++------
>  fs/nfsd/nfs4xdr.c  | 63 +++++++++++++++++++++++++++++++++--
>  fs/nfsd/vfs.c      |  6 ++++
>  fs/nfsd/vfs.h      |  1 +
>  fs/nfsd/xdr4.h     | 23 +++++++++++++
>  5 files changed, 178 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 4cba786..0a1aa2f 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1012,47 +1012,105 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  }
>  
>  static __be32
> -nfsd4_clone(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> -		struct nfsd4_clone *clone)
> +nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> +		  stateid_t *src_stateid, struct file **src,
> +		  stateid_t *dst_stateid, struct file **dst)
>  {
> -	struct file *src, *dst;
>  	__be32 status;
>  
>  	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->save_fh,
> -					    &clone->cl_src_stateid, RD_STATE,
> -					    &src, NULL);
> +					    src_stateid, RD_STATE, src, NULL);
>  	if (status) {
>  		dprintk("NFSD: %s: couldn't process src stateid!\n", __func__);
>  		goto out;
>  	}
>  
>  	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
> -					    &clone->cl_dst_stateid, WR_STATE,
> -					    &dst, NULL);
> +					    dst_stateid, WR_STATE, dst, NULL);
>  	if (status) {
>  		dprintk("NFSD: %s: couldn't process dst stateid!\n", __func__);
>  		goto out_put_src;
>  	}
>  
>  	/* fix up for NFS-specific error code */
> -	if (!S_ISREG(file_inode(src)->i_mode) ||
> -	    !S_ISREG(file_inode(dst)->i_mode)) {
> +	if (!S_ISREG(file_inode(*src)->i_mode) ||
> +	    !S_ISREG(file_inode(*dst)->i_mode)) {
>  		status = nfserr_wrong_type;
>  		goto out_put_dst;
>  	}
>  
> +out:
> +	return status;
> +out_put_dst:
> +	fput(*dst);
> +out_put_src:
> +	fput(*src);
> +	goto out;
> +}
> +
> +static __be32
> +nfsd4_clone(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> +		struct nfsd4_clone *clone)
> +{
> +	struct file *src, *dst;
> +	__be32 status;
> +
> +	status = nfsd4_verify_copy(rqstp, cstate, &clone->cl_src_stateid, &src,
> +				   &clone->cl_dst_stateid, &dst);
> +	if (status)
> +		goto out;
> +
>  	status = nfsd4_clone_file_range(src, clone->cl_src_pos,
>  			dst, clone->cl_dst_pos, clone->cl_count);
>  
> -out_put_dst:
>  	fput(dst);
> -out_put_src:
>  	fput(src);
>  out:
>  	return status;
>  }
>  
>  static __be32
> +nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> +		struct nfsd4_copy *copy)
> +{
> +	struct file *src, *dst;
> +	__be32 status;
> +	ssize_t bytes;
> +	loff_t max;
> +
> +	status = nfsd4_verify_copy(rqstp, cstate, &copy->cp_src_stateid, &src,
> +				   &copy->cp_dst_stateid, &dst);
> +	if (status)
> +		goto out;
> +
> +	max = i_size_read(file_inode(src));
> +	if ((copy->cp_src_pos + copy->cp_count) > max) {
> +		status = nfserr_inval;
> +		goto out_put;
> +	}

If we care about the race between this check and the copy, then we need
some locking.  If we don't, then a comment explaining why not would be
useful here.

(Looks like this check, and the INVAL error, are both mandated by the
spec.  The behavior looks wrong to me--usually EINVAL's reserved for
things the client had to know was a problem, but here the client doesn't
necessarily know the file size.  I would have expected just success and
a short read.)

--b.

> +
> +	bytes = nfsd_copy_range(src, copy->cp_src_pos, dst, copy->cp_dst_pos,
> +				copy->cp_count);
> +
> +	if (bytes < 0)
> +		status = nfserrno(bytes);
> +	else {
> +		copy->cp_res.wr_bytes_written = bytes;
> +		copy->cp_res.wr_stable_how = NFS_UNSTABLE;
> +		copy->cp_consecutive = 1;
> +		copy->cp_synchronous = 1;
> +		gen_boot_verifier(&copy->cp_res.wr_verifier, SVC_NET(rqstp));
> +		status = nfs_ok;
> +	}
> +
> +out_put:
> +	fput(src);
> +	fput(dst);
> +out:
> +	return status;
> +}
> +
> +static __be32
>  nfsd4_fallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		struct nfsd4_fallocate *fallocate, int flags)
>  {
> @@ -1966,6 +2024,18 @@ static inline u32 nfsd4_create_session_rsize(struct svc_rqst *rqstp, struct nfsd
>  		op_encode_channel_attrs_maxsz) * sizeof(__be32);
>  }
>  
> +static inline u32 nfsd4_copy_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
> +{
> +	return (op_encode_hdr_size +
> +		1 /* wr_callback */ +
> +		op_encode_stateid_maxsz /* wr_callback */ +
> +		2 /* wr_count */ +
> +		1 /* wr_committed */ +
> +		op_encode_verifier_maxsz +
> +		1 /* cr_consecutive */ +
> +		1 /* cr_synchronous */) * sizeof(__be32);
> +}
> +
>  #ifdef CONFIG_NFSD_PNFS
>  /*
>   * At this stage we don't really know what layout driver will handle the request,
> @@ -2328,6 +2398,12 @@ static struct nfsd4_operation nfsd4_ops[] = {
>  		.op_name = "OP_CLONE",
>  		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
>  	},
> +	[OP_COPY] = {
> +		.op_func = (nfsd4op_func)nfsd4_copy,
> +		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
> +		.op_name = "OP_COPY",
> +		.op_rsize_bop = (nfsd4op_rsize)nfsd4_copy_rsize,
> +	},
>  	[OP_SEEK] = {
>  		.op_func = (nfsd4op_func)nfsd4_seek,
>  		.op_name = "OP_SEEK",
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index d6ef095..2a73c7e 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1694,6 +1694,30 @@ nfsd4_decode_clone(struct nfsd4_compoundargs *argp, struct nfsd4_clone *clone)
>  }
>  
>  static __be32
> +nfsd4_decode_copy(struct nfsd4_compoundargs *argp, struct nfsd4_copy *copy)
> +{
> +	DECODE_HEAD;
> +	unsigned int tmp;
> +
> +	status = nfsd4_decode_stateid(argp, &copy->cp_src_stateid);
> +	if (status)
> +		return status;
> +	status = nfsd4_decode_stateid(argp, &copy->cp_dst_stateid);
> +	if (status)
> +		return status;
> +
> +	READ_BUF(8 + 8 + 8 + 4 + 4 + 4);
> +	p = xdr_decode_hyper(p, &copy->cp_src_pos);
> +	p = xdr_decode_hyper(p, &copy->cp_dst_pos);
> +	p = xdr_decode_hyper(p, &copy->cp_count);
> +	copy->cp_consecutive = be32_to_cpup(p++);
> +	copy->cp_synchronous = be32_to_cpup(p++);
> +	tmp = be32_to_cpup(p); /* Source server list not supported */
> +
> +	DECODE_TAIL;
> +}
> +
> +static __be32
>  nfsd4_decode_seek(struct nfsd4_compoundargs *argp, struct nfsd4_seek *seek)
>  {
>  	DECODE_HEAD;
> @@ -1793,7 +1817,7 @@ static nfsd4_dec nfsd4_dec_ops[] = {
>  
>  	/* new operations for NFSv4.2 */
>  	[OP_ALLOCATE]		= (nfsd4_dec)nfsd4_decode_fallocate,
> -	[OP_COPY]		= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_COPY]		= (nfsd4_dec)nfsd4_decode_copy,
>  	[OP_COPY_NOTIFY]	= (nfsd4_dec)nfsd4_decode_notsupp,
>  	[OP_DEALLOCATE]		= (nfsd4_dec)nfsd4_decode_fallocate,
>  	[OP_IO_ADVISE]		= (nfsd4_dec)nfsd4_decode_notsupp,
> @@ -4203,6 +4227,41 @@ nfsd4_encode_layoutreturn(struct nfsd4_compoundres *resp, __be32 nfserr,
>  #endif /* CONFIG_NFSD_PNFS */
>  
>  static __be32
> +nfsd42_encode_write_res(struct nfsd4_compoundres *resp, struct nfsd42_write_res *write)
> +{
> +	__be32 *p;
> +
> +	p = xdr_reserve_space(&resp->xdr, 4 + 8 + 4 + NFS4_VERIFIER_SIZE);
> +	if (!p)
> +		return nfserr_resource;
> +
> +	*p++ = cpu_to_be32(0);
> +	p = xdr_encode_hyper(p, write->wr_bytes_written);
> +	*p++ = cpu_to_be32(write->wr_stable_how);
> +	p = xdr_encode_opaque_fixed(p, write->wr_verifier.data,
> +				    NFS4_VERIFIER_SIZE);
> +	return nfs_ok;
> +}
> +
> +static __be32
> +nfsd4_encode_copy(struct nfsd4_compoundres *resp, __be32 nfserr,
> +		  struct nfsd4_copy *copy)
> +{
> +	__be32 *p;
> +
> +	if (!nfserr) {
> +		nfserr = nfsd42_encode_write_res(resp, &copy->cp_res);
> +		if (nfserr)
> +			return nfserr;
> +
> +		p = xdr_reserve_space(&resp->xdr, 4 + 4);
> +		*p++ = cpu_to_be32(copy->cp_consecutive);
> +		*p++ = cpu_to_be32(copy->cp_synchronous);
> +	}
> +	return nfserr;
> +}
> +
> +static __be32
>  nfsd4_encode_seek(struct nfsd4_compoundres *resp, __be32 nfserr,
>  		  struct nfsd4_seek *seek)
>  {
> @@ -4301,7 +4360,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
>  
>  	/* NFSv4.2 operations */
>  	[OP_ALLOCATE]		= (nfsd4_enc)nfsd4_encode_noop,
> -	[OP_COPY]		= (nfsd4_enc)nfsd4_encode_noop,
> +	[OP_COPY]		= (nfsd4_enc)nfsd4_encode_copy,
>  	[OP_COPY_NOTIFY]	= (nfsd4_enc)nfsd4_encode_noop,
>  	[OP_DEALLOCATE]		= (nfsd4_enc)nfsd4_encode_noop,
>  	[OP_IO_ADVISE]		= (nfsd4_enc)nfsd4_encode_noop,
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 5d2a57e..28802a7 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -513,6 +513,12 @@ __be32 nfsd4_clone_file_range(struct file *src, u64 src_pos, struct file *dst,
>  			count));
>  }
>  
> +ssize_t nfsd_copy_range(struct file *src, u64 src_pos, struct file *dst,
> +			u64 dst_pos, u64 count)
> +{
> +	return vfs_copy_file_range(src, src_pos, dst, dst_pos, count, 0);
> +}
> +
>  __be32 nfsd4_vfs_fallocate(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  			   struct file *file, loff_t offset, loff_t len,
>  			   int flags)
> diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
> index c11ba31..e36c497 100644
> --- a/fs/nfsd/vfs.h
> +++ b/fs/nfsd/vfs.h
> @@ -93,6 +93,7 @@ __be32		nfsd_symlink(struct svc_rqst *, struct svc_fh *,
>  				struct svc_fh *res);
>  __be32		nfsd_link(struct svc_rqst *, struct svc_fh *,
>  				char *, int, struct svc_fh *);
> +ssize_t		nfsd_copy_range(struct file *, u64, struct file *, u64, u64);
>  __be32		nfsd_rename(struct svc_rqst *,
>  				struct svc_fh *, char *, int,
>  				struct svc_fh *, char *, int);
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index d955481..2cad349 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -500,6 +500,28 @@ struct nfsd4_clone {
>  	u64		cl_count;
>  };
>  
> +struct nfsd42_write_res {
> +	u64			wr_bytes_written;
> +	u32			wr_stable_how;
> +	nfs4_verifier		wr_verifier;
> +};
> +
> +struct nfsd4_copy {
> +	/* request */
> +	stateid_t	cp_src_stateid;
> +	stateid_t	cp_dst_stateid;
> +	u64		cp_src_pos;
> +	u64		cp_dst_pos;
> +	u64		cp_count;
> +
> +	/* both */
> +	bool		cp_consecutive;
> +	bool		cp_synchronous;
> +
> +	/* response */
> +	struct nfsd42_write_res	cp_res;
> +};
> +
>  struct nfsd4_seek {
>  	/* request */
>  	stateid_t	seek_stateid;
> @@ -565,6 +587,7 @@ struct nfsd4_op {
>  		struct nfsd4_fallocate		allocate;
>  		struct nfsd4_fallocate		deallocate;
>  		struct nfsd4_clone		clone;
> +		struct nfsd4_copy		copy;
>  		struct nfsd4_seek		seek;
>  	} u;
>  	struct nfs4_replay *			replay;
> -- 
> 2.7.2
