Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:19326 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752997Ab1CPOtj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Mar 2011 10:49:39 -0400
Subject: Re: [PATCH v4 3/5] NFS: Add secinfo procedure
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4D7FC37A.5040103@netapp.com>
Date: Wed, 16 Mar 2011 10:49:31 -0400
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <35A5824F-18D5-4069-80AC-052EADE667ED@oracle.com>
References: <4D7FC37A.5040103@netapp.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Mar 15, 2011, at 3:52 PM, Bryan Schumaker wrote:

> 
> This patch adds the nfs4 operation secinfo as a
> valid nfs rpc operation.
> 
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
> fs/nfs/nfs4proc.c       |   35 ++++++++++++
> fs/nfs/nfs4xdr.c        |  137 +++++++++++++++++++++++++++++++++++++++++++++++
> include/linux/nfs4.h    |    1 +
> include/linux/nfs_xdr.h |   34 ++++++++++++
> 4 files changed, 207 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index ebb8146..c6a737e 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -4640,6 +4640,40 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
> 	return status;
> }
> 
> +static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct nfs4_secinfo_flavors *flavors)
> +{
> +	int status;
> +	struct nfs4_secinfo_arg args = {
> +		.dir_fh = NFS_FH(dir),
> +		.name   = name,
> +	};
> +	struct nfs4_secinfo_res res = {
> +		.flavors     = flavors,
> +	};
> +	struct rpc_message msg = {
> +		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SECINFO],
> +		.rpc_argp = &args,
> +		.rpc_resp = &res,
> +	};
> +
> +	dprintk("NFS call  secinfo %s\n", name->name);
> +	status = nfs4_call_sync(NFS_SERVER(dir)->client, NFS_SERVER(dir), &msg, &args.seq_args, &res.seq_res, 0);
> +	dprintk("NFS reply  secinfo: %d\n", status);
> +	return status;
> +}
> +
> +int nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct nfs4_secinfo_flavors *flavors)
> +{
> +	struct nfs4_exception exception = { };
> +	int err;
> +	do {
> +		err = nfs4_handle_exception(NFS_SERVER(dir),
> +				_nfs4_proc_secinfo(dir, name, flavors),
> +				&exception);
> +	} while (exception.retry);
> +	return err;
> +}
> +
> #ifdef CONFIG_NFS_V4_1
> /*
>  * Check the exchange flags returned by the server for invalid flags, having
> @@ -5757,6 +5791,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
> 	.close_context  = nfs4_close_context,
> 	.open_context	= nfs4_atomic_open,
> 	.init_client	= nfs4_init_client,
> +	.secinfo	= nfs4_proc_secinfo,
> };
> 
> static const struct xattr_handler nfs4_xattr_nfs4_acl_handler = {
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 0cf560f..d4d79ee 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -46,6 +46,7 @@
> #include <linux/kdev_t.h>
> #include <linux/sunrpc/clnt.h>
> #include <linux/sunrpc/msg_prot.h>
> +#include <linux/sunrpc/gss_api.h>
> #include <linux/nfs.h>
> #include <linux/nfs4.h>
> #include <linux/nfs_fs.h>
> @@ -253,6 +254,8 @@ static int nfs4_stat_to_errno(int);
> 				(encode_getattr_maxsz)
> #define decode_fs_locations_maxsz \
> 				(0)
> +#define encode_secinfo_maxsz	(op_encode_hdr_maxsz + nfs4_name_maxsz)
> +#define decode_secinfo_maxsz	(op_decode_hdr_maxsz + 4 + (NFS_MAX_SECFLAVORS * (16 + GSS_OID_MAX_LEN)))
> 
> #if defined(CONFIG_NFS_V4_1)
> #define NFS4_MAX_MACHINE_NAME_LEN (64)
> @@ -676,6 +679,14 @@ static int nfs4_stat_to_errno(int);
> 				 decode_putfh_maxsz + \
> 				 decode_lookup_maxsz + \
> 				 decode_fs_locations_maxsz)
> +#define NFS4_enc_secinfo_sz 	(compound_encode_hdr_maxsz + \
> +				encode_sequence_maxsz + \
> +				encode_putfh_maxsz + \
> +				encode_secinfo_maxsz)
> +#define NFS4_dec_secinfo_sz	(compound_decode_hdr_maxsz + \
> +				decode_sequence_maxsz + \
> +				decode_putfh_maxsz + \
> +				decode_secinfo_maxsz)
> #if defined(CONFIG_NFS_V4_1)
> #define NFS4_enc_exchange_id_sz \
> 				(compound_encode_hdr_maxsz + \
> @@ -1620,6 +1631,18 @@ static void encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *state
> 	hdr->replen += decode_delegreturn_maxsz;
> }
> 
> +static void encode_secinfo(struct xdr_stream *xdr, const struct qstr *name, struct compound_hdr *hdr)
> +{
> +	int len = name->len;
> +	__be32 *p;
> +
> +	p = reserve_space(xdr, 8 + len);
> +	*p++ = cpu_to_be32(OP_SECINFO);
> +	xdr_encode_opaque(p, name->name, len);
> +	hdr->nops++;
> +	hdr->replen += decode_secinfo_maxsz;
> +}
> +
> #if defined(CONFIG_NFS_V4_1)
> /* NFSv4.1 operations */
> static void encode_exchange_id(struct xdr_stream *xdr,
> @@ -2608,6 +2631,26 @@ static void nfs4_xdr_enc_layoutget(struct rpc_rqst *req,
> }
> #endif /* CONFIG_NFS_V4_1 */
> 
> +/*
> + * Encode SECINFO request
> + */
> +static int nfs4_xdr_enc_secinfo(struct rpc_rqst *req, uint32_t *p,
> +				struct nfs4_secinfo_arg *args)

You might know this already, but this API needs to be updated to use "struct xdr_stream *" for the second argument.

> +{
> +	struct xdr_stream xdr;
> +	struct compound_hdr hdr = {
> +		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
> +	};
> +
> +	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
> +	encode_compound_hdr(&xdr, req, &hdr);
> +	encode_sequence(&xdr, &args->seq_args, &hdr);
> +	encode_putfh(&xdr, args->dir_fh, &hdr);
> +	encode_secinfo(&xdr, args->name, &hdr);
> +	encode_nops(&hdr);
> +	return 0;
> +}
> +
> static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
> {
> 	dprintk("nfs: %s: prematurely hit end of receive buffer. "
> @@ -4680,6 +4723,71 @@ static int decode_delegreturn(struct xdr_stream *xdr)
> 	return decode_op_hdr(xdr, OP_DELEGRETURN);
> }
> 
> +static int decode_secinfo_gss(struct xdr_stream *xdr, struct nfs4_secinfo_flavor *flavor)
> +{
> +	__be32 *p;
> +
> +	p = xdr_inline_decode(xdr, 4);
> +	if (unlikely(!p))
> +		goto out_overflow;
> +	flavor->gss.sec_oid4.len = be32_to_cpup(p);
> +	if (flavor->gss.sec_oid4.len > GSS_OID_MAX_LEN)
> +		goto out_err;
> +
> +	p = xdr_inline_decode(xdr, flavor->gss.sec_oid4.len + 8);
> +	if (unlikely(!p))
> +		goto out_overflow;

I'm not sure, but I think we just decided in another thread this needs to be split into two xdr_inline_decode() calls.

> +
> +	memcpy(flavor->gss.sec_oid4.data, p, flavor->gss.sec_oid4.len);
> +	p += XDR_QUADLEN(flavor->gss.sec_oid4.len);
> +	flavor->gss.qop4 = be32_to_cpup(p++);
> +	flavor->gss.service = be32_to_cpup(p);
> +
> +	return 0;
> +
> +out_overflow:
> +	print_overflow_msg(__func__, xdr);
> +	return -EIO;
> +out_err:
> +	return -EINVAL;
> +}
> +
> +static int decode_secinfo(struct xdr_stream *xdr, struct nfs4_secinfo_res *res)
> +{
> +	struct nfs4_secinfo_flavor *sec_flavor;
> +	int status;
> +	__be32 *p;
> +	int i;
> +
> +	status = decode_op_hdr(xdr, OP_SECINFO);
> +	p = xdr_inline_decode(xdr, 4);
> +	if (unlikely(!p))
> +		goto out_overflow;
> +	res->flavors->num_flavors = be32_to_cpup(p);
> +
> +	for (i = 0; i < res->flavors->num_flavors; i++) {
> +		sec_flavor = &res->flavors->flavors[i];
> +		if ((char *)&sec_flavor[1] - (char *)res > PAGE_SIZE)
> +			break;
> +
> +		p = xdr_inline_decode(xdr, 4);
> +		if (unlikely(!p))
> +			goto out_overflow;
> +		sec_flavor->flavor = be32_to_cpup(p);
> +
> +		if (sec_flavor->flavor == RPC_AUTH_GSS) {
> +			if (decode_secinfo_gss(xdr, sec_flavor))
> +				break;
> +		}
> +	}
> +
> +	return 0;
> +
> +out_overflow:
> +	print_overflow_msg(__func__, xdr);
> +	return -EIO;
> +}
> +
> #if defined(CONFIG_NFS_V4_1)
> static int decode_exchange_id(struct xdr_stream *xdr,
> 			      struct nfs41_exchange_id_res *res)
> @@ -6068,6 +6176,34 @@ out:
> }
> #endif /* CONFIG_NFS_V4_1 */
> 
> +/*
> + * Decode SECINFO response
> + */
> +static int nfs4_xdr_dec_secinfo(struct rpc_rqst *rqstp, uint32_t *p,
> +				struct nfs4_secinfo_res *res)

Ditto, update second argument.

> +{
> +	struct xdr_stream xdr;
> +	struct compound_hdr hdr;
> +	int status;
> +
> +	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
> +	status = decode_compound_hdr(&xdr, &hdr);
> +	if (status)
> +		goto out;
> +	status = decode_sequence(&xdr, &res->seq_res, rqstp);
> +	if (status)
> +		goto out;
> +	status = decode_putfh(&xdr);
> +	if (status)
> +		goto out;
> +	status = decode_secinfo(&xdr, res);
> +	if (status)
> +		goto out;
> +out:
> +	return status;
> +	return NFS_OK;
> +}
> +
> /**
>  * nfs4_decode_dirent - Decode a single NFSv4 directory entry stored in
>  *                      the local page cache.
> @@ -6258,6 +6394,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
> 	PROC(SETACL,		enc_setacl,		dec_setacl),
> 	PROC(FS_LOCATIONS,	enc_fs_locations,	dec_fs_locations),
> 	PROC(RELEASE_LOCKOWNER,	enc_release_lockowner,	dec_release_lockowner),
> +	PROC(SECINFO,		enc_secinfo,		dec_secinfo),
> #if defined(CONFIG_NFS_V4_1)
> 	PROC(EXCHANGE_ID,	enc_exchange_id,	dec_exchange_id),
> 	PROC(CREATE_SESSION,	enc_create_session,	dec_create_session),
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index 134716e..7e7f6b7 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -550,6 +550,7 @@ enum {
> 	NFSPROC4_CLNT_SETACL,
> 	NFSPROC4_CLNT_FS_LOCATIONS,
> 	NFSPROC4_CLNT_RELEASE_LOCKOWNER,
> +	NFSPROC4_CLNT_SECINFO,
> 
> 	/* nfs41 */
> 	NFSPROC4_CLNT_EXCHANGE_ID,
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 71ee679..8f3d7b2 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -3,6 +3,7 @@
> 
> #include <linux/nfsacl.h>
> #include <linux/nfs3.h>
> +#include <linux/sunrpc/gss_api.h>
> 
> /*
>  * To change the maximum rsize and wsize supported by the NFS client, adjust
> @@ -936,6 +937,38 @@ struct nfs4_fs_locations_res {
> 	struct nfs4_sequence_res	seq_res;
> };
> 
> +struct nfs4_secinfo_oid {
> +	unsigned int len;
> +	char data[GSS_OID_MAX_LEN];
> +};
> +
> +struct nfs4_secinfo_gss {
> +	struct nfs4_secinfo_oid sec_oid4;
> +	unsigned int qop4;
> +	unsigned int service;
> +};
> +
> +struct nfs4_secinfo_flavor {
> +	unsigned int 		flavor;
> +	struct nfs4_secinfo_gss	gss;
> +};
> +
> +struct nfs4_secinfo_flavors {
> +	unsigned int num_flavors;
> +	struct nfs4_secinfo_flavor flavors[0];
> +};
> +
> +struct nfs4_secinfo_arg {
> +	const struct nfs_fh		*dir_fh;
> +	const struct qstr		*name;
> +	struct nfs4_sequence_args	seq_args;
> +};
> +
> +struct nfs4_secinfo_res {
> +	struct nfs4_secinfo_flavors	*flavors;
> +	struct nfs4_sequence_res	seq_res;
> +};
> +
> #endif /* CONFIG_NFS_V4 */
> 
> struct nfstime4 {
> @@ -1118,6 +1151,7 @@ struct nfs_rpc_ops {
> 				struct iattr *iattr);
> 	int	(*init_client) (struct nfs_client *, const struct rpc_timeout *,
> 				const char *, rpc_authflavor_t, int);
> +	int	(*secinfo)(struct inode *, const struct qstr *, struct nfs4_secinfo_flavors *);
> };
> 
> /*
> -- 
> 1.7.4.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




