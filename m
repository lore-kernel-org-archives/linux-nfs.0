Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33075 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751501AbdF1Ozo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jun 2017 10:55:44 -0400
Received: by mail-io0-f195.google.com with SMTP id j200so5456685ioe.0
        for <linux-nfs@vger.kernel.org>; Wed, 28 Jun 2017 07:55:43 -0700 (PDT)
Subject: Re: [PATCH 3/4] nfs4: add NFSv4 LOOKUPP handlers
To: Christoph Hellwig <hch@lst.de>, trond.myklebust@primarydata.com,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: jlayton@poochiereds.net, linux-nfs@vger.kernel.org
References: <20170627154403.20944-1-hch@lst.de>
 <20170627154403.20944-4-hch@lst.de>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <99a3d554-399f-3d02-2033-3962fc00afea@gmail.com>
Date: Wed, 28 Jun 2017 10:55:35 -0400
MIME-Version: 1.0
In-Reply-To: <20170627154403.20944-4-hch@lst.de>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Christoph,

On 06/27/2017 11:44 AM, Christoph Hellwig wrote:
> From: Jeff Layton <jeff.layton@primarydata.com>
> 
> This will be needed in order to implement the get_parent export op
> for nfsd.

I think this patch conflicts with your constify and function pointer cleanups from a few weeks ago, and it may need to be updated.

Just double checking:  Bruce, are you taking the constify series for 4.13?

Thanks,
Anna

> 
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
>  fs/nfs/nfs4proc.c       | 49 +++++++++++++++++++++++++++++++++
>  fs/nfs/nfs4trace.h      | 29 ++++++++++++++++++++
>  fs/nfs/nfs4xdr.c        | 73 +++++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/nfs4.h    |  1 +
>  include/linux/nfs_xdr.h | 17 +++++++++++-
>  5 files changed, 168 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index c08c46a3b8cd..6fd9eee8e4ee 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3802,6 +3802,54 @@ nfs4_proc_lookup_mountpoint(struct inode *dir, const struct qstr *name,
>  	return (client == NFS_CLIENT(dir)) ? rpc_clone_client(client) : client;
>  }
>  
> +static int _nfs4_proc_lookupp(struct inode *inode,
> +		struct nfs_fh *fhandle, struct nfs_fattr *fattr,
> +		struct nfs4_label *label)
> +{
> +	struct rpc_clnt *clnt = NFS_CLIENT(inode);
> +	struct nfs_server *server = NFS_SERVER(inode);
> +	int		       status;
> +	struct nfs4_lookupp_arg args = {
> +		.bitmask = server->attr_bitmask,
> +		.fh = NFS_FH(inode),
> +	};
> +	struct nfs4_lookupp_res res = {
> +		.server = server,
> +		.fattr = fattr,
> +		.label = label,
> +		.fh = fhandle,
> +	};
> +	struct rpc_message msg = {
> +		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LOOKUPP],
> +		.rpc_argp = &args,
> +		.rpc_resp = &res,
> +	};
> +
> +	args.bitmask = nfs4_bitmask(server, label);
> +
> +	nfs_fattr_init(fattr);
> +
> +	dprintk("NFS call  lookupp ino=0x%lx\n", inode->i_ino);
> +	status = nfs4_call_sync(clnt, server, &msg, &args.seq_args,
> +				&res.seq_res, 0);
> +	dprintk("NFS reply lookupp: %d\n", status);
> +	return status;
> +}
> +
> +static int nfs4_proc_lookupp(struct inode *inode, struct nfs_fh *fhandle,
> +			     struct nfs_fattr *fattr, struct nfs4_label *label)
> +{
> +	struct nfs4_exception exception = { };
> +	int err;
> +	do {
> +		err = _nfs4_proc_lookupp(inode, fhandle, fattr, label);
> +		trace_nfs4_lookupp(inode, err);
> +		err = nfs4_handle_exception(NFS_SERVER(inode), err,
> +				&exception);
> +	} while (exception.retry);
> +	return err;
> +}
> +
>  static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry)
>  {
>  	struct nfs_server *server = NFS_SERVER(inode);
> @@ -9312,6 +9360,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
>  	.getattr	= nfs4_proc_getattr,
>  	.setattr	= nfs4_proc_setattr,
>  	.lookup		= nfs4_proc_lookup,
> +	.lookupp	= nfs4_proc_lookupp,
>  	.access		= nfs4_proc_access,
>  	.readlink	= nfs4_proc_readlink,
>  	.create		= nfs4_proc_create,
> diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
> index 845d0eadefc9..be1da19c65d6 100644
> --- a/fs/nfs/nfs4trace.h
> +++ b/fs/nfs/nfs4trace.h
> @@ -891,6 +891,35 @@ DEFINE_NFS4_LOOKUP_EVENT(nfs4_remove);
>  DEFINE_NFS4_LOOKUP_EVENT(nfs4_get_fs_locations);
>  DEFINE_NFS4_LOOKUP_EVENT(nfs4_secinfo);
>  
> +TRACE_EVENT(nfs4_lookupp,
> +		TP_PROTO(
> +			const struct inode *inode,
> +			int error
> +		),
> +
> +		TP_ARGS(inode, error),
> +
> +		TP_STRUCT__entry(
> +			__field(dev_t, dev)
> +			__field(u64, ino)
> +			__field(int, error)
> +		),
> +
> +		TP_fast_assign(
> +			__entry->dev = inode->i_sb->s_dev;
> +			__entry->ino = NFS_FILEID(inode);
> +			__entry->error = error;
> +		),
> +
> +		TP_printk(
> +			"error=%d (%s) inode=%02x:%02x:%llu",
> +			__entry->error,
> +			show_nfsv4_errors(__entry->error),
> +			MAJOR(__entry->dev), MINOR(__entry->dev),
> +			(unsigned long long)__entry->ino
> +		)
> +);
> +
>  TRACE_EVENT(nfs4_rename,
>  		TP_PROTO(
>  			const struct inode *olddir,
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 3aebfdc82b30..b55017987dcd 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -159,6 +159,8 @@ static int nfs4_stat_to_errno(int);
>  				(op_decode_hdr_maxsz)
>  #define encode_lookup_maxsz	(op_encode_hdr_maxsz + nfs4_name_maxsz)
>  #define decode_lookup_maxsz	(op_decode_hdr_maxsz)
> +#define encode_lookupp_maxsz	(op_encode_hdr_maxsz)
> +#define decode_lookupp_maxsz	(op_decode_hdr_maxsz)
>  #define encode_share_access_maxsz \
>  				(2)
>  #define encode_createmode_maxsz	(1 + encode_attrs_maxsz + encode_verifier_maxsz)
> @@ -618,6 +620,18 @@ static int nfs4_stat_to_errno(int);
>  				decode_lookup_maxsz + \
>  				decode_getattr_maxsz + \
>  				decode_getfh_maxsz)
> +#define NFS4_enc_lookupp_sz	(compound_encode_hdr_maxsz + \
> +				encode_sequence_maxsz + \
> +				encode_putfh_maxsz + \
> +				encode_lookupp_maxsz + \
> +				encode_getattr_maxsz + \
> +				encode_getfh_maxsz)
> +#define NFS4_dec_lookupp_sz	(compound_decode_hdr_maxsz + \
> +				decode_sequence_maxsz + \
> +				decode_putfh_maxsz + \
> +				decode_lookupp_maxsz + \
> +				decode_getattr_maxsz + \
> +				decode_getfh_maxsz)
>  #define NFS4_enc_lookup_root_sz (compound_encode_hdr_maxsz + \
>  				encode_sequence_maxsz + \
>  				encode_putrootfh_maxsz + \
> @@ -1368,6 +1382,11 @@ static void encode_lookup(struct xdr_stream *xdr, const struct qstr *name, struc
>  	encode_string(xdr, name->len, name->name);
>  }
>  
> +static void encode_lookupp(struct xdr_stream *xdr, struct compound_hdr *hdr)
> +{
> +	encode_op_hdr(xdr, OP_LOOKUPP, decode_lookupp_maxsz, hdr);
> +}
> +
>  static void encode_share_access(struct xdr_stream *xdr, u32 share_access)
>  {
>  	__be32 *p;
> @@ -2120,6 +2139,25 @@ static void nfs4_xdr_enc_lookup(struct rpc_rqst *req, struct xdr_stream *xdr,
>  }
>  
>  /*
> + * Encode LOOKUPP request
> + */
> +static void nfs4_xdr_enc_lookupp(struct rpc_rqst *req, struct xdr_stream *xdr,
> +				const struct nfs4_lookupp_arg *args)
> +{
> +	struct compound_hdr hdr = {
> +		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
> +	};
> +
> +	encode_compound_hdr(xdr, req, &hdr);
> +	encode_sequence(xdr, &args->seq_args, &hdr);
> +	encode_putfh(xdr, args->fh, &hdr);
> +	encode_lookupp(xdr, &hdr);
> +	encode_getfh(xdr, &hdr);
> +	encode_getfattr(xdr, args->bitmask, &hdr);
> +	encode_nops(&hdr);
> +}
> +
> +/*
>   * Encode LOOKUP_ROOT request
>   */
>  static void nfs4_xdr_enc_lookup_root(struct rpc_rqst *req,
> @@ -5005,6 +5043,11 @@ static int decode_lookup(struct xdr_stream *xdr)
>  	return decode_op_hdr(xdr, OP_LOOKUP);
>  }
>  
> +static int decode_lookupp(struct xdr_stream *xdr)
> +{
> +	return decode_op_hdr(xdr, OP_LOOKUPP);
> +}
> +
>  /* This is too sick! */
>  static int decode_space_limit(struct xdr_stream *xdr,
>  		unsigned long *pagemod_limit)
> @@ -6182,6 +6225,35 @@ static int nfs4_xdr_dec_lookup(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
>  }
>  
>  /*
> + * Decode LOOKUPP response
> + */
> +static int nfs4_xdr_dec_lookupp(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
> +				struct nfs4_lookupp_res *res)
> +{
> +	struct compound_hdr hdr;
> +	int status;
> +
> +	status = decode_compound_hdr(xdr, &hdr);
> +	if (status)
> +		goto out;
> +	status = decode_sequence(xdr, &res->seq_res, rqstp);
> +	if (status)
> +		goto out;
> +	status = decode_putfh(xdr);
> +	if (status)
> +		goto out;
> +	status = decode_lookupp(xdr);
> +	if (status)
> +		goto out;
> +	status = decode_getfh(xdr, res->fh);
> +	if (status)
> +		goto out;
> +	status = decode_getfattr_label(xdr, res->fattr, res->label, res->server);
> +out:
> +	return status;
> +}
> +
> +/*
>   * Decode LOOKUP_ROOT response
>   */
>  static int nfs4_xdr_dec_lookup_root(struct rpc_rqst *rqstp,
> @@ -7517,6 +7589,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
>  	PROC(ACCESS,		enc_access,		dec_access),
>  	PROC(GETATTR,		enc_getattr,		dec_getattr),
>  	PROC(LOOKUP,		enc_lookup,		dec_lookup),
> +	PROC(LOOKUPP,		enc_lookupp,		dec_lookupp),
>  	PROC(LOOKUP_ROOT,	enc_lookup_root,	dec_lookup_root),
>  	PROC(REMOVE,		enc_remove,		dec_remove),
>  	PROC(RENAME,		enc_rename,		dec_rename),
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index 1b1ca04820a3..47239c336688 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -479,6 +479,7 @@ enum {
>  	NFSPROC4_CLNT_ACCESS,
>  	NFSPROC4_CLNT_GETATTR,
>  	NFSPROC4_CLNT_LOOKUP,
> +	NFSPROC4_CLNT_LOOKUPP,
>  	NFSPROC4_CLNT_LOOKUP_ROOT,
>  	NFSPROC4_CLNT_REMOVE,
>  	NFSPROC4_CLNT_RENAME,
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index b28c83475ee8..7a664a5fcc25 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -1012,7 +1012,6 @@ struct nfs4_link_res {
>  	struct nfs_fattr *		dir_attr;
>  };
>  
> -
>  struct nfs4_lookup_arg {
>  	struct nfs4_sequence_args	seq_args;
>  	const struct nfs_fh *		dir_fh;
> @@ -1028,6 +1027,20 @@ struct nfs4_lookup_res {
>  	struct nfs4_label		*label;
>  };
>  
> +struct nfs4_lookupp_arg {
> +	struct nfs4_sequence_args	seq_args;
> +	const struct nfs_fh		*fh;
> +	const u32			*bitmask;
> +};
> +
> +struct nfs4_lookupp_res {
> +	struct nfs4_sequence_res	seq_res;
> +	const struct nfs_server		*server;
> +	struct nfs_fattr		*fattr;
> +	struct nfs_fh			*fh;
> +	struct nfs4_label		*label;
> +};
> +
>  struct nfs4_lookup_root_arg {
>  	struct nfs4_sequence_args	seq_args;
>  	const u32 *			bitmask;
> @@ -1567,6 +1580,8 @@ struct nfs_rpc_ops {
>  	int	(*lookup)  (struct inode *, const struct qstr *,
>  			    struct nfs_fh *, struct nfs_fattr *,
>  			    struct nfs4_label *);
> +	int	(*lookupp) (struct inode *, struct nfs_fh *,
> +			    struct nfs_fattr *, struct nfs4_label *);
>  	int	(*access)  (struct inode *, struct nfs_access_entry *);
>  	int	(*readlink)(struct inode *, struct page *, unsigned int,
>  			    unsigned int);
> 
