Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:48054 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932688AbaJVTuS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Oct 2014 15:50:18 -0400
Message-ID: <54480A77.4000804@Netapp.com>
Date: Wed, 22 Oct 2014 15:50:15 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3] NFS: Implement SEEK
References: <1411754328-18589-1-git-send-email-Anna.Schumaker@Netapp.com> <1411754328-18589-2-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1411754328-18589-2-git-send-email-Anna.Schumaker@Netapp.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/26/14 13:58, Anna Schumaker wrote:
> From: Anna Schumaker <Anna.Schumaker@netapp.com>
>
> The SEEK operation is used when an application makes an lseek call with
> either the SEEK_HOLE or SEEK_DATA flags set.  I fall back on
> nfs_file_llseek() if the server does not have SEEK support.
>
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> ---
>  fs/nfs/Makefile           |  1 +
>  fs/nfs/inode.c            |  2 +
>  fs/nfs/nfs42.h            | 14 +++++++
>  fs/nfs/nfs42proc.c        | 69 +++++++++++++++++++++++++++++++++
>  fs/nfs/nfs42xdr.c         | 98 +++++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfs/nfs4_fs.h          |  3 ++
>  fs/nfs/nfs4file.c         | 25 ++++++++++++
>  fs/nfs/nfs4proc.c         |  4 +-
>  fs/nfs/nfs4xdr.c          |  7 ++++
>  include/linux/nfs4.h      |  3 ++
>  include/linux/nfs_fs_sb.h |  1 +
>  include/linux/nfs_xdr.h   | 19 +++++++++
>  12 files changed, 244 insertions(+), 2 deletions(-)
>  create mode 100644 fs/nfs/nfs42.h
>  create mode 100644 fs/nfs/nfs42proc.c
>  create mode 100644 fs/nfs/nfs42xdr.c
>
> diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
> index 4782e08..04cb830 100644
> --- a/fs/nfs/Makefile
> +++ b/fs/nfs/Makefile
> @@ -28,6 +28,7 @@ nfsv4-y := nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o nfs4super.o nfs4file.o
>  nfsv4-$(CONFIG_NFS_USE_LEGACY_DNS) += cache_lib.o
>  nfsv4-$(CONFIG_SYSCTL)	+= nfs4sysctl.o
>  nfsv4-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
> +nfsv4-$(CONFIG_NFS_V4_2)	+= nfs42proc.o
>  
>  obj-$(CONFIG_PNFS_FILE_LAYOUT) += filelayout/
>  obj-$(CONFIG_PNFS_OBJLAYOUT) += objlayout/
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 141c9f4..6388a59 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -718,6 +718,7 @@ struct nfs_lock_context *nfs_get_lock_context(struct nfs_open_context *ctx)
>  	kfree(new);
>  	return res;
>  }
> +EXPORT_SYMBOL_GPL(nfs_get_lock_context);
>  
>  void nfs_put_lock_context(struct nfs_lock_context *l_ctx)
>  {
> @@ -730,6 +731,7 @@ void nfs_put_lock_context(struct nfs_lock_context *l_ctx)
>  	spin_unlock(&inode->i_lock);
>  	kfree(l_ctx);
>  }
> +EXPORT_SYMBOL_GPL(nfs_put_lock_context);
>  
>  /**
>   * nfs_close_context - Common close_context() routine NFSv2/v3
> diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
> new file mode 100644
> index 0000000..d10333a
> --- /dev/null
> +++ b/fs/nfs/nfs42.h
> @@ -0,0 +1,14 @@
> +/*
> + * Copyright (c) 2014 Anna Schumaker <Anna.Schumaker@Netapp.com>
> + */
> +
> +#ifndef __LINUX_FS_NFS_NFS4_2_H
> +#define __LINUX_FS_NFS_NFS4_2_H
> +
> +/* nfs4.2proc.c */
> +loff_t nfs42_proc_llseek(struct file *, loff_t, int);
> +
> +/* nfs4.2xdr.h */
> +extern struct rpc_procinfo nfs4_2_procedures[];
> +
> +#endif /* __LINUX_FS_NFS_NFS4_2_H */
> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
> new file mode 100644
> index 0000000..0886f1d
> --- /dev/null
> +++ b/fs/nfs/nfs42proc.c
> @@ -0,0 +1,69 @@
> +/*
> + * Copyright (c) 2014 Anna Schumaker <Anna.Schumaker@Netapp.com>
> + */
> +#include <linux/fs.h>
> +#include <linux/sunrpc/sched.h>
> +#include <linux/nfs.h>
> +#include <linux/nfs3.h>
> +#include <linux/nfs4.h>
> +#include <linux/nfs_xdr.h>
> +#include <linux/nfs_fs.h>
> +#include "nfs4_fs.h"
> +#include "nfs42.h"
> +
> +static int nfs42_set_rw_stateid(nfs4_stateid *dst, struct file *file,
> +				fmode_t fmode)
> +{
> +	struct nfs_open_context *open;
> +	struct nfs_lock_context *lock;
> +	int ret;
> +
> +	open = get_nfs_open_context(nfs_file_open_context(file));
> +	lock = nfs_get_lock_context(open);
> +	if (IS_ERR(lock)) {
> +		put_nfs_open_context(open);
> +		return PTR_ERR(lock);
> +	}
> +
> +	ret = nfs4_set_rw_stateid(dst, open, lock, fmode);
> +
> +	nfs_put_lock_context(lock);
> +	put_nfs_open_context(open);
> +	return ret;
> +}
> +
> +loff_t nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
> +{
> +	struct inode *inode = file_inode(filep);
> +	struct nfs42_seek_args args = {
> +		.sa_fh		= NFS_FH(inode),
> +		.sa_offset	= offset,
> +		.sa_what	= (whence == SEEK_HOLE) ?
> +					NFS4_CONTENT_HOLE : NFS4_CONTENT_DATA,
> +	};
> +	struct nfs42_seek_res res;
> +	struct rpc_message msg = {
> +		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SEEK],
> +		.rpc_argp = &args,
> +		.rpc_resp = &res,
> +	};
> +	struct nfs_server *server = NFS_SERVER(inode);
> +	int status;
> +
> +	if (!(server->caps & NFS_CAP_SEEK))
> +		return -ENOTSUPP;
> +
> +	status = nfs42_set_rw_stateid(&args.sa_stateid, filep, FMODE_READ);
> +	if (status)
> +		return status;
> +
> +	nfs_wb_all(inode);
> +	status = nfs4_call_sync(server->client, server, &msg,
> +				&args.seq_args, &res.seq_res, 0);
> +	if (status == -ENOTSUPP)
> +		server->caps &= ~NFS_CAP_SEEK;
> +	if (status)
> +		return status;
> +
> +	return vfs_setpos(filep, res.sr_offset, inode->i_sb->s_maxbytes);
> +}
> diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
> new file mode 100644
> index 0000000..c90469b
> --- /dev/null
> +++ b/fs/nfs/nfs42xdr.c
> @@ -0,0 +1,98 @@
> +/*
> + * Copyright (c) 2014 Anna Schumaker <Anna.Schumaker@Netapp.com>
> + */
> +#ifndef __LINUX_FS_NFS_NFS4_2XDR_H
> +#define __LINUX_FS_NFS_NFS4_2XDR_H
> +
> +#define encode_seek_maxsz		(op_encode_hdr_maxsz + \
> +					 encode_stateid_maxsz + \
> +					 2 /* offset */ + \
> +					 1 /* whence */)
> +#define decode_seek_maxsz		(op_decode_hdr_maxsz + \
> +					 1 /* eof */ + \
> +					 1 /* whence */ + \
> +					 2 /* offset */ + \
> +					 2 /* length */)
> +
> +#define NFS4_enc_seek_sz		(compound_encode_hdr_maxsz + \
> +					 encode_putfh_maxsz + \
> +					 encode_seek_maxsz)
> +#define NFS4_dec_seek_sz		(compound_decode_hdr_maxsz + \
> +					 decode_putfh_maxsz + \
> +					 decode_seek_maxsz)
> +
> +
> +static void encode_seek(struct xdr_stream *xdr,
> +			struct nfs42_seek_args *args,
> +			struct compound_hdr *hdr)
> +{
> +	encode_op_hdr(xdr, OP_SEEK, decode_seek_maxsz, hdr);
> +	encode_nfs4_stateid(xdr, &args->sa_stateid);
> +	encode_uint64(xdr, args->sa_offset);
> +	encode_uint32(xdr, args->sa_what);
> +}
> +
> +/*
> + * Encode SEEK request
> + */
> +static void nfs4_xdr_enc_seek(struct rpc_rqst *req,
> +			      struct xdr_stream *xdr,
> +			      struct nfs42_seek_args *args)
> +{
> +	struct compound_hdr hdr = {
> +		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
> +	};
> +
> +	encode_compound_hdr(xdr, req, &hdr);
> +	encode_sequence(xdr, &args->seq_args, &hdr);
> +	encode_putfh(xdr, args->sa_fh, &hdr);
> +	encode_seek(xdr, args, &hdr);
> +	encode_nops(&hdr);
> +}
> +
> +static int decode_seek(struct xdr_stream *xdr, struct nfs42_seek_res *res)
> +{
> +	int status;
> +	__be32 *p;
> +
> +	status = decode_op_hdr(xdr, OP_SEEK);
> +	if (status)
> +		return status;
> +
> +	p = xdr_inline_decode(xdr, 4 + 8);
> +	if (unlikely(!p))
> +		goto out_overflow;
> +
> +	res->sr_eof = be32_to_cpup(p++);
> +	p = xdr_decode_hyper(p, &res->sr_offset);
> +	return 0;
> +
> +out_overflow:
> +	print_overflow_msg(__func__, xdr);
> +	return -EIO;
> +}
> +
> +/*
> + * Decode SEEK request
> + */
> +static int nfs4_xdr_dec_seek(struct rpc_rqst *rqstp,
> +			     struct xdr_stream *xdr,
> +			     struct nfs42_seek_res *res)
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
> +	status = decode_seek(xdr, res);
> +out:
> +	return status;
> +}
> +#endif /* __LINUX_FS_NFS_NFS4_2XDR_H */
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index a8b855a..be6cac3 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -226,6 +226,9 @@ int nfs4_replace_transport(struct nfs_server *server,
>  				const struct nfs4_fs_locations *locations);
>  
>  /* nfs4proc.c */
> +extern int nfs4_call_sync(struct rpc_clnt *, struct nfs_server *,
> +			  struct rpc_message *, struct nfs4_sequence_args *,
> +			  struct nfs4_sequence_res *, int);
>  extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struct rpc_cred *, struct nfs4_setclientid_res *);
>  extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct nfs4_setclientid_res *arg, struct rpc_cred *);
>  extern int nfs4_proc_get_rootfh(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *, bool);
> diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> index a816f06..4dffa3a 100644
> --- a/fs/nfs/nfs4file.c
> +++ b/fs/nfs/nfs4file.c
> @@ -8,6 +8,10 @@
>  #include "fscache.h"
>  #include "pnfs.h"
>  
> +#ifdef CONFIG_NFS_V4_2
> +#include "nfs42.h"
> +#endif
> +
>  #define NFSDBG_FACILITY		NFSDBG_FILE
>  
>  static int
> @@ -115,8 +119,29 @@ nfs4_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
>  	return ret;
>  }
>  
> +#ifdef CONFIG_NFS_V4_2
> +static loff_t nfs4_file_llseek(struct file *filep, loff_t offset, int whence)
> +{
> +	loff_t ret;
> +
> +	switch (whence) {
> +	case SEEK_HOLE:
> +	case SEEK_DATA:
> +		ret = nfs42_proc_llseek(filep, offset, whence);
> +		if (ret != -ENOTSUPP)
> +			return ret;
> +	default:
> +		return nfs_file_llseek(filep, offset, whence);
> +	}
> +}
> +#endif /* CONFIG_NFS_V4_2 */
> +
>  const struct file_operations nfs4_file_operations = {
> +#ifdef CONFIG_NFS_V4_2
> +	.llseek		= nfs4_file_llseek,
> +#else
>  	.llseek		= nfs_file_llseek,
> +#endif
>  	.read		= new_sync_read,
>  	.write		= new_sync_write,
>  	.read_iter	= nfs_file_read,
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 549d3b0..ba5eda3 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -885,7 +885,6 @@ static int nfs4_call_sync_sequence(struct rpc_clnt *clnt,
>  	return ret;
>  }
>  
> -static
>  int nfs4_call_sync(struct rpc_clnt *clnt,
>  		   struct nfs_server *server,
>  		   struct rpc_message *msg,
> @@ -8431,7 +8430,8 @@ static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
>  		| NFS_CAP_CHANGE_ATTR
>  		| NFS_CAP_POSIX_LOCK
>  		| NFS_CAP_STATEID_NFSV41
> -		| NFS_CAP_ATOMIC_OPEN_V1,
> +		| NFS_CAP_ATOMIC_OPEN_V1
> +		| NFS_CAP_SEEK,

This looks like it really does add the capability to nfs_v4_2_minor_ops, so I'm not sure how it ended up modifying nfs_v4_1_minor_ops instead.  Anyway, I just posted a fix to set the flag in the right place.

Anna

>  	.init_client = nfs41_init_client,
>  	.shutdown_client = nfs41_shutdown_client,
>  	.match_stateid = nfs41_match_stateid,
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 005d03c..206c08a 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -7321,6 +7321,10 @@ nfs4_stat_to_errno(int stat)
>  	return -stat;
>  }
>  
> +#ifdef CONFIG_NFS_V4_2
> +#include "nfs42xdr.c"
> +#endif /* CONFIG_NFS_V4_2 */
> +
>  #define PROC(proc, argtype, restype)				\
>  [NFSPROC4_CLNT_##proc] = {					\
>  	.p_proc   = NFSPROC4_COMPOUND,				\
> @@ -7388,6 +7392,9 @@ struct rpc_procinfo	nfs4_procedures[] = {
>  			enc_bind_conn_to_session, dec_bind_conn_to_session),
>  	PROC(DESTROY_CLIENTID,	enc_destroy_clientid,	dec_destroy_clientid),
>  #endif /* CONFIG_NFS_V4_1 */
> +#ifdef CONFIG_NFS_V4_2
> +	PROC(SEEK,		enc_seek,		dec_seek),
> +#endif /* CONFIG_NFS_V4_2 */
>  };
>  
>  const struct rpc_version nfs_version4 = {
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index 026b0c0..356acc2 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -487,6 +487,9 @@ enum {
>  	NFSPROC4_CLNT_GETDEVICELIST,
>  	NFSPROC4_CLNT_BIND_CONN_TO_SESSION,
>  	NFSPROC4_CLNT_DESTROY_CLIENTID,
> +
> +	/* nfs42 */
> +	NFSPROC4_CLNT_SEEK,
>  };
>  
>  /* nfs41 types */
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 922be2e..a32ba0d 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -230,5 +230,6 @@ struct nfs_server {
>  #define NFS_CAP_STATEID_NFSV41	(1U << 16)
>  #define NFS_CAP_ATOMIC_OPEN_V1	(1U << 17)
>  #define NFS_CAP_SECURITY_LABEL	(1U << 18)
> +#define NFS_CAP_SEEK		(1U << 19)
>  
>  #endif
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 6951c7d..983876f 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -1231,6 +1231,25 @@ struct pnfs_ds_commit_info {
>  
>  #endif /* CONFIG_NFS_V4_1 */
>  
> +#ifdef CONFIG_NFS_V4_2
> +struct nfs42_seek_args {
> +	struct nfs4_sequence_args	seq_args;
> +
> +	struct nfs_fh			*sa_fh;
> +	nfs4_stateid			sa_stateid;
> +	u64				sa_offset;
> +	u32				sa_what;
> +};
> +
> +struct nfs42_seek_res {
> +	struct nfs4_sequence_res	seq_res;
> +	unsigned int			status;
> +
> +	u32	sr_eof;
> +	u64	sr_offset;
> +};
> +#endif
> +
>  struct nfs_page;
>  
>  #define NFS_PAGEVEC_SIZE	(8U)

