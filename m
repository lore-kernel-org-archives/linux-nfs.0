Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48348 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757066Ab3EOUTw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 May 2013 16:19:52 -0400
Date: Wed, 15 May 2013 16:19:49 -0400
To: Zach Brown <zab@redhat.com>
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [RFC v0 4/4] nfs, nfsd: rough sys_copy_range and COPY support
Message-ID: <20130515201949.GD25994@fieldses.org>
References: <1368566126-17610-1-git-send-email-zab@redhat.com>
 <1368566126-17610-5-git-send-email-zab@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1368566126-17610-5-git-send-email-zab@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 14, 2013 at 02:15:26PM -0700, Zach Brown wrote:
> This crude patch illustrates the simplest plumbing involved in
> supporting sys_call_range with the NFS COPY operation that's pending in
> the 4.2 draft spec.
> 
> The patch is based on a previous prototype that used the COPY op to
> implement sys_copyfileat which created a new file (based on the ocfs2
> reflink ioctl).  By contrast, this copies file contents between existing
> files.
> 
> There's still a lot of implementation and testing to do, but this can
> get discussion going.

I'm using:

	git://github.com/loghyr/NFSv4.2

as my reference for the draft protocol.

On a quick skim, one thing this is missing before it complies is a
client implementation of CB_OFFLOAD: "If a client desires an
intra-server file copy, then it MUST support the COPY and CB_OFFLOAD
operations."

The server doesn't have to implement CB_OFFLOAD, though, so we should
ditch these todo's:

> +/*
> + * XXX:
> + *  - do something with stateids :)
> + *  - implement callback results and OFFLOAD_ABORT
> + *  - inter-server copies?
> + */

...

> +	/* don't support async callbacks yet */

...

lest someone go try to implement them for no reason.  (Stranger things
have happened.)

Nits, possibly to ignore for now:

> +	copy->u.ok.cr_callback_id_length = 0;
> +
> +	return status;
> +}
> +
>  /* This routine never returns NFS_OK!  If there are no other errors, it
>   * will return NFSERR_SAME or NFSERR_NOT_SAME depending on whether the
>   * attributes matched.  VERIFY is implemented by mapping NFSERR_SAME
> @@ -1798,6 +1829,10 @@ static struct nfsd4_operation nfsd4_ops[] = {
>  		.op_get_currentstateid = (stateid_getter)nfsd4_get_freestateid,
>  		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
>  	},
> +	[OP_COPY] = {
> +		.op_func = (nfsd4op_func)nfsd4_copy,
> +		.op_name = "OP_COPY",
> +	},

There's some more boilerplate to fill in (see other ops).

> +static __be32
>  nfsd4_decode_noop(struct nfsd4_compoundargs *argp, void *p)
>  {
>  	return nfs_ok;
> @@ -1557,6 +1577,7 @@ static nfsd4_dec nfsd41_dec_ops[] = {
>  	[OP_WANT_DELEGATION]	= (nfsd4_dec)nfsd4_decode_notsupp,
>  	[OP_DESTROY_CLIENTID]	= (nfsd4_dec)nfsd4_decode_destroy_clientid,
>  	[OP_RECLAIM_COMPLETE]	= (nfsd4_dec)nfsd4_decode_reclaim_complete,
> +	[OP_COPY]               = (nfsd4_dec)nfsd4_decode_copy,

And this should be made 4.2-specific.

>  };
>  
>  struct nfsd4_minorversion_ops {
> @@ -3394,6 +3415,27 @@ nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, __be32 nfserr,
>  }
>  
>  static __be32
> +nfsd4_encode_copy(struct nfsd4_compoundres *resp, __be32 nfserr,
> +			struct nfsd4_copy *copy)
> +{
> +	__be32 *p;
> +
> +	if (!nfserr) {
> +		RESERVE_SPACE(4);
> +		WRITE32(copy->u.ok.cr_callback_id_length);
> +		ADJUST_ARGS();
> +		if (copy->u.ok.cr_callback_id_length == 1)
> +			nfsd4_encode_stateid(resp, copy->u.ok.cr_callback_id);
> +	} else {
> +		RESERVE_SPACE(8);
> +		WRITE64(copy->u.cr_bytes_copied);
> +		ADJUST_ARGS();
> +	}
> +
> +	return nfserr;
> +}
> +
> +static __be32
>  nfsd4_encode_noop(struct nfsd4_compoundres *resp, __be32 nfserr, void *p)
>  {
>  	return nfserr;
> @@ -3465,6 +3507,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
>  	[OP_WANT_DELEGATION]	= (nfsd4_enc)nfsd4_encode_noop,
>  	[OP_DESTROY_CLIENTID]	= (nfsd4_enc)nfsd4_encode_noop,
>  	[OP_RECLAIM_COMPLETE]	= (nfsd4_enc)nfsd4_encode_noop,
> +	[OP_COPY]		= (nfsd4_enc)nfsd4_encode_copy,
>  };
>  
>  /*
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 84ce601..0c1b427 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -28,6 +28,8 @@
>  #include <asm/uaccess.h>
>  #include <linux/exportfs.h>
>  #include <linux/writeback.h>
> +#include <linux/fs_struct.h>
> +#include <linux/kmod.h>
>  
>  #ifdef CONFIG_NFSD_V3
>  #include "xdr3.h"
> @@ -621,6 +623,45 @@ int nfsd4_is_junction(struct dentry *dentry)
>  		return 0;
>  	return 1;
>  }
> +
> +__be32
> +nfsd_copy_range(struct svc_rqst *rqstp, struct svc_fh *fhp_in, u64 pos_in,
> +		struct svc_fh *fhp_out, u64 pos_out, u64 count)
> +{
> +	struct file *filp_in = NULL;
> +	struct file *filp_out = NULL;
> +	int err;
> +
> +	/* XXX verify pos and count within sane limits? */
> +
> +	err = nfsd_open(rqstp, fhp_in, S_IFREG, NFSD_MAY_READ, &filp_in);
> +	if (err)
> +		goto out;
> +
> +	err = nfsd_open(rqstp, fhp_out, S_IFREG, NFSD_MAY_WRITE, &filp_out);
> +	if (err)
> +		goto out;

Looking at the xdr... the COPY operation takes stateid's, which nfsd can
use to look up files, so the opens shouldn't be required.

--b.

> +
> +	err = vfs_copy_range(filp_in, pos_in, filp_out, pos_out, count);
> +	/* fall back if .copy_range isn't supported */
> +
> +	if (!err && EX_ISSYNC(fhp_out->fh_export))
> +		err = vfs_fsync_range(filp_out, pos_out, pos_out + count-1, 0);
> +
> +out:
> +	if (filp_in)
> +		nfsd_close(filp_in);
> +	if (filp_out)
> +		nfsd_close(filp_out);
> +
> +	if (err < 0)
> +		err = nfserrno(err);
> +	else
> +		err = 0;
> +
> +	return err;
> +}
> +
>  #endif /* defined(CONFIG_NFSD_V4) */
>  
>  #ifdef CONFIG_NFSD_V3
> diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
> index 5b58941..bbc9483 100644
> --- a/fs/nfsd/vfs.h
> +++ b/fs/nfsd/vfs.h
> @@ -85,6 +85,9 @@ __be32		nfsd_symlink(struct svc_rqst *, struct svc_fh *,
>  				struct svc_fh *res, struct iattr *);
>  __be32		nfsd_link(struct svc_rqst *, struct svc_fh *,
>  				char *, int, struct svc_fh *);
> +__be32		nfsd_copy_range(struct svc_rqst *,
> +				struct svc_fh *, u64,
> +				struct svc_fh *, u64, u64);
>  __be32		nfsd_rename(struct svc_rqst *,
>  				struct svc_fh *, char *, int,
>  				struct svc_fh *, char *, int);
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index 3b271d2..95fd1c3 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -426,6 +426,26 @@ struct nfsd4_reclaim_complete {
>  	u32 rca_one_fs;
>  };
>  
> +struct nfsd4_copy {
> +	/* request */
> +	u64             ca_src_offset;
> +	u64             ca_dst_offset;
> +	u64             ca_count;
> +	u32             ca_flags;
> +	u32             ca_destinationlen;
> +	char *          ca_destination;
> +
> +	/* response */
> +	union {
> +		struct {
> +			u32			cr_callback_id_length;
> +			stateid_t *             cr_callback_id;
> +		} ok;
> +		u64	cr_bytes_copied;
> +	} u;
> +
> +};
> +
>  struct nfsd4_op {
>  	int					opnum;
>  	__be32					status;
> @@ -471,6 +491,7 @@ struct nfsd4_op {
>  		struct nfsd4_reclaim_complete	reclaim_complete;
>  		struct nfsd4_test_stateid	test_stateid;
>  		struct nfsd4_free_stateid	free_stateid;
> +		struct nfsd4_copy		copy;
>  	} u;
>  	struct nfs4_replay *			replay;
>  };
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index 7b8fc73..6be484e 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -100,6 +100,7 @@ enum nfs_opnum4 {
>  	OP_WANT_DELEGATION = 56,
>  	OP_DESTROY_CLIENTID = 57,
>  	OP_RECLAIM_COMPLETE = 58,
> +	OP_COPY = 59,
>  
>  	OP_ILLEGAL = 10044,
>  };
> @@ -108,7 +109,7 @@ enum nfs_opnum4 {
>  Needs to be updated if more operations are defined in future.*/
>  
>  #define FIRST_NFS4_OP	OP_ACCESS
> -#define LAST_NFS4_OP 	OP_RECLAIM_COMPLETE
> +#define LAST_NFS4_OP	OP_COPY
>  
>  enum nfsstat4 {
>  	NFS4_OK = 0,
> @@ -456,6 +457,9 @@ enum {
>  	NFSPROC4_CLNT_GETDEVICELIST,
>  	NFSPROC4_CLNT_BIND_CONN_TO_SESSION,
>  	NFSPROC4_CLNT_DESTROY_CLIENTID,
> +
> +	/* nfs42 */
> +	NFSPROC4_CLNT_COPY,
>  };
>  
>  /* nfs41 types */
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 104b62f..2256e31 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -1184,6 +1184,28 @@ struct nfs41_free_stateid_res {
>  	unsigned int			status;
>  };
>  
> +struct nfs_copy_args {
> +	struct nfs_fh			*fh;
> +	struct nfs_fh			*dir_fh;
> +	u32				*bitmask;
> +	__u64				src_offset;
> +	__u64				dst_offset;
> +	__u64				count;
> +	__u32				flags;
> +	const struct qstr		*destination;
> +	struct nfs4_sequence_args	seq_args;
> +};
> +
> +struct nfs_copy_res {
> +	struct nfs_fh			*fh;
> +	struct nfs_fattr		*fattr;
> +	__u32				callback_id_length;
> +	nfs4_stateid			*callback_id;
> +	__u64				bytes_copied;
> +	const struct nfs_server		*server;
> +	struct nfs4_sequence_res	seq_res;
> +};
> +
>  #else
>  
>  struct pnfs_ds_commit_info {
> @@ -1433,6 +1455,8 @@ struct nfs_rpc_ops {
>  	struct nfs_server *(*create_server)(struct nfs_mount_info *, struct nfs_subversion *);
>  	struct nfs_server *(*clone_server)(struct nfs_server *, struct nfs_fh *,
>  					   struct nfs_fattr *, rpc_authflavor_t);
> +	loff_t  (*copy)    (struct inode *, struct inode *, struct qstr *,
> +				int, loff_t, loff_t, loff_t);
>  };
>  
>  /*
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
