Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:33595 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755130Ab3HEWc6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Aug 2013 18:32:58 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs4.1: Minimal SP4_MACH_CRED implementation
Date: Mon, 5 Aug 2013 22:32:56 +0000
Message-ID: <00A4D3B2-C452-405D-9C6D-A44CFF3FB7F3@netapp.com>
References: <1375734410-6060-1-git-send-email-dros@netapp.com>
In-Reply-To: <1375734410-6060-1-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 5, 2013, at 4:26 PM, Weston Andros Adamson <dros@netapp.com> wrote:

> This is a minimal client side implementation of SP4_MACH_CRED.  It will
> attempt to negotiate SP4_MACH_CRED iff the EXCHANGE_ID is using
> krb5i or krb5p auth.  SP4_MACH_CRED will be used if the server supports the
> minimal operations:
> 
> BACKCHANNEL_CTL
> BIND_CONN_TO_SESSION
> CREATE_SESSION
> DESTROY_SESSION
> DESTROY_CLIENTID
> 
> This implementation only includes the EXCHANGE_ID negotiation code because
> the client will already use the machine cred for these operations.
> 
> This patch also lays the groundwork for adding more SP4_MACH_CRED "features" -
> instead of just using SP4_MACH_CRED wherever the server says it's ok, we will
> make sure that appropriate sets of operations are supported in the initial
> negotiation and then only use these negotiated features. The hope is that this
> will limit the scope of testing.
> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
> 
> Version 2: fixed a couple of comment typos and a style cleanup
> 
> fs/nfs/nfs4proc.c         | 115 +++++++++++++++++++++++++++++++++++++++++++---
> fs/nfs/nfs4xdr.c          |  73 +++++++++++++++++++++++++----
> include/linux/nfs_fs_sb.h |   4 ++
> include/linux/nfs_xdr.h   |  19 ++++++++
> 4 files changed, 194 insertions(+), 17 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 0e64ccc..2564d1b 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5915,16 +5915,63 @@ out:
> }
> 
> /*
> - * nfs4_proc_exchange_id()
> + * Minimum set of SP4_MACH_CRED operations from RFC 5661
> + */
> +static uint32_t _nfs4_spo_must_enforce[NFS4_OP_MAP_NUM_WORDS] = {
> +	[1] = 1 << (OP_BIND_CONN_TO_SESSION - 32) |
> +	      1 << (OP_EXCHANGE_ID - 32) |
> +	      1 << (OP_CREATE_SESSION - 32) |
> +	      1 << (OP_DESTROY_SESSION - 32) |
> +	      1 << (OP_DESTROY_CLIENTID - 32)
> +};

This should be const - I'll repost once I get comments.

-dros

> +
> +/*
> + * Select the state protection mode for client `clp' given the server results
> + * from exchange_id in `sp'.
>  *
> - * Returns zero, a negative errno, or a negative NFS4ERR status code.
> + * Returns 0 on success, negative errno otherwise.
> + */
> +static int _nfs4_sp4_select_mode(struct nfs_client *clp,
> +				 struct nfs41_state_protection *sp)
> +{
> +	unsigned int i;
> +
> +	if (sp->how == SP4_MACH_CRED) {
> +		/* Print state protect result */
> +		dfprintk(MOUNT, "Server SP4_MACH_CRED support:\n");
> +		for (i = 0; i <= LAST_NFS4_OP; i++) {
> +			if (test_bit(i, sp->enforce.u.longs))
> +				dfprintk(MOUNT, "  enforce op %d\n", i);
> +			if (test_bit(i, sp->allow.u.longs))
> +				dfprintk(MOUNT, "  allow op %d\n", i);
> +		}
> +
> +		/*
> +		 * Minimal mode - state operations are allowed to use machine
> +		 * credential.  Note this already happens by default, so the
> +		 * client doesn't have to do anything more than the negotiation.
> +		 */
> +		if (memcmp(sp->enforce.u.words, _nfs4_spo_must_enforce,
> +			   sizeof(sp->enforce.u.words)) == 0)
> +			set_bit(NFS_SP4_MACH_CRED_MINIMAL, &clp->cl_sp4_flags);
> +
> +		if (!clp->cl_sp4_flags) {
> +			dfprintk(MOUNT, "sp4_mach_cred: disabled\n");
> +			return -EINVAL;
> +		} else
> +			dfprintk(MOUNT, "sp4_mach_cred: enabled\n");
> +	}
> +
> +	return 0;
> +}
> +
> +/*
> + * _nfs4_proc_exchange_id()
>  *
> - * Since the clientid has expired, all compounds using sessions
> - * associated with the stale clientid will be returning
> - * NFS4ERR_BADSESSION in the sequence operation, and will therefore
> - * be in some phase of session reset.
> + * Wrapper for EXCHANGE_ID operation.
>  */
> -int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
> +static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
> +	u32 sp4_how)
> {
> 	nfs4_verifier verifier;
> 	struct nfs41_exchange_id_args args = {
> @@ -5971,10 +6018,35 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
> 		goto out_server_scope;
> 	}
> 
> +	switch (sp4_how) {
> +	case SP4_NONE:
> +		args.state_protect.how = SP4_NONE;
> +		break;
> +
> +	case SP4_MACH_CRED:
> +		args.state_protect.how = SP4_MACH_CRED;
> +
> +		/* request minumum set of operations */
> +		memcpy(args.state_protect.enforce.u.words,
> +		       &_nfs4_spo_must_enforce,
> +		       sizeof(uint32_t) * NFS4_OP_MAP_NUM_WORDS);
> +
> +		break;
> +
> +	default:
> +		/* unsupported! */
> +		WARN_ON_ONCE(1);
> +		status = -EINVAL;
> +		goto out_server_scope;
> +	}
> +
> 	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
> 	if (status == 0)
> 		status = nfs4_check_cl_exchange_flags(res.flags);
> 
> +	if (status == 0)
> +		status = _nfs4_sp4_select_mode(clp, &res.state_protect);
> +
> 	if (status == 0) {
> 		clp->cl_clientid = res.clientid;
> 		clp->cl_exchange_flags = (res.flags & ~EXCHGID4_FLAG_CONFIRMED_R);
> @@ -6021,6 +6093,35 @@ out:
> 	return status;
> }
> 
> +/*
> + * nfs4_proc_exchange_id()
> + *
> + * Returns zero, a negative errno, or a negative NFS4ERR status code.
> + *
> + * Since the clientid has expired, all compounds using sessions
> + * associated with the stale clientid will be returning
> + * NFS4ERR_BADSESSION in the sequence operation, and will therefore
> + * be in some phase of session reset.
> + *
> + * Will attempt to negotiate SP4_MACH_CRED if krb5i / krb5p auth is used.
> + */
> +int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
> +{
> +	rpc_authflavor_t authflavor = clp->cl_rpcclient->cl_auth->au_flavor;
> +	int status;
> +
> +	/* try SP4_MACH_CRED if krb5i/p	*/
> +	if (authflavor == RPC_AUTH_GSS_KRB5I ||
> +	    authflavor == RPC_AUTH_GSS_KRB5P) {
> +		status = _nfs4_proc_exchange_id(clp, cred, SP4_MACH_CRED);
> +		if (!status)
> +			return 0;
> +	}
> +
> +	/* try SP4_NONE */
> +	return _nfs4_proc_exchange_id(clp, cred, SP4_NONE);
> +}
> +
> static int _nfs4_proc_destroy_clientid(struct nfs_client *clp,
> 		struct rpc_cred *cred)
> {
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 1a4a3bd..0a645f7 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -294,7 +294,9 @@ static int nfs4_stat_to_errno(int);
> 				XDR_QUADLEN(NFS4_EXCHANGE_ID_LEN) + \
> 				1 /* flags */ + \
> 				1 /* spa_how */ + \
> -				0 /* SP4_NONE (for now) */ + \
> +				/* max is SP4_MACH_CRED (for now) */ + \
> +				1 + NFS4_OP_MAP_NUM_WORDS + \
> +				1 + NFS4_OP_MAP_NUM_WORDS + \
> 				1 /* implementation id array of size 1 */ + \
> 				1 /* nii_domain */ + \
> 				XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + \
> @@ -306,7 +308,9 @@ static int nfs4_stat_to_errno(int);
> 				1 /* eir_sequenceid */ + \
> 				1 /* eir_flags */ + \
> 				1 /* spr_how */ + \
> -				0 /* SP4_NONE (for now) */ + \
> +				  /* max is SP4_MACH_CRED (for now) */ + \
> +				1 + NFS4_OP_MAP_NUM_WORDS + \
> +				1 + NFS4_OP_MAP_NUM_WORDS + \
> 				2 /* eir_server_owner.so_minor_id */ + \
> 				/* eir_server_owner.so_major_id<> */ \
> 				XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + 1 + \
> @@ -1726,6 +1730,14 @@ static void encode_bind_conn_to_session(struct xdr_stream *xdr,
> 	*p = 0;	/* use_conn_in_rdma_mode = False */
> }
> 
> +static void encode_op_map(struct xdr_stream *xdr, struct nfs4_op_map *op_map)
> +{
> +	unsigned int i;
> +	encode_uint32(xdr, NFS4_OP_MAP_NUM_WORDS);
> +	for (i = 0; i < NFS4_OP_MAP_NUM_WORDS; i++)
> +		encode_uint32(xdr, op_map->u.words[i]);
> +}
> +
> static void encode_exchange_id(struct xdr_stream *xdr,
> 			       struct nfs41_exchange_id_args *args,
> 			       struct compound_hdr *hdr)
> @@ -1739,9 +1751,19 @@ static void encode_exchange_id(struct xdr_stream *xdr,
> 
> 	encode_string(xdr, args->id_len, args->id);
> 
> -	p = reserve_space(xdr, 12);
> -	*p++ = cpu_to_be32(args->flags);
> -	*p++ = cpu_to_be32(0);	/* zero length state_protect4_a */
> +	encode_uint32(xdr, args->flags);
> +	encode_uint32(xdr, args->state_protect.how);
> +
> +	switch (args->state_protect.how) {
> +	case SP4_NONE:
> +		break;
> +	case SP4_MACH_CRED:
> +		encode_op_map(xdr, &args->state_protect.enforce);
> +		encode_op_map(xdr, &args->state_protect.allow);
> +		break;
> +	default:
> +		BUG();
> +	}
> 
> 	if (send_implementation_id &&
> 	    sizeof(CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN) > 1 &&
> @@ -1752,7 +1774,7 @@ static void encode_exchange_id(struct xdr_stream *xdr,
> 			       utsname()->version, utsname()->machine);
> 
> 	if (len > 0) {
> -		*p = cpu_to_be32(1);	/* implementation id array length=1 */
> +		encode_uint32(xdr, 1);	/* implementation id array length=1 */
> 
> 		encode_string(xdr,
> 			sizeof(CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN) - 1,
> @@ -1763,7 +1785,7 @@ static void encode_exchange_id(struct xdr_stream *xdr,
> 		p = xdr_encode_hyper(p, 0);
> 		*p = cpu_to_be32(0);
> 	} else
> -		*p = cpu_to_be32(0);	/* implementation id array length=0 */
> +		encode_uint32(xdr, 0);	/* implementation id array length=0 */
> }
> 
> static void encode_create_session(struct xdr_stream *xdr,
> @@ -5375,6 +5397,23 @@ static int decode_secinfo_no_name(struct xdr_stream *xdr, struct nfs4_secinfo_re
> 	return decode_secinfo_common(xdr, res);
> }
> 
> +static int decode_op_map(struct xdr_stream *xdr, struct nfs4_op_map *op_map)
> +{
> +	__be32 *p;
> +	uint32_t bitmap_words;
> +	unsigned int i;
> +
> +	p = xdr_inline_decode(xdr, 4);
> +	bitmap_words = be32_to_cpup(p++);
> +	if (bitmap_words > NFS4_OP_MAP_NUM_WORDS)
> +		return -EIO;
> +	p = xdr_inline_decode(xdr, 4 * bitmap_words);
> +	for (i = 0; i < bitmap_words; i++)
> +		op_map->u.words[i] = be32_to_cpup(p++);
> +
> +	return 0;
> +}
> +
> static int decode_exchange_id(struct xdr_stream *xdr,
> 			      struct nfs41_exchange_id_res *res)
> {
> @@ -5398,10 +5437,24 @@ static int decode_exchange_id(struct xdr_stream *xdr,
> 	res->seqid = be32_to_cpup(p++);
> 	res->flags = be32_to_cpup(p++);
> 
> -	/* We ask for SP4_NONE */
> -	dummy = be32_to_cpup(p);
> -	if (dummy != SP4_NONE)
> +	res->state_protect.how = be32_to_cpup(p);
> +	switch (res->state_protect.how) {
> +	case SP4_NONE:
> +		break;
> +	case SP4_MACH_CRED:
> +		status = decode_op_map(xdr, &res->state_protect.enforce);
> +		if (status)
> +			return status;
> +		status = decode_op_map(xdr, &res->state_protect.allow);
> +		if (status)
> +			return status;
> +		break;
> +	default:
> +		/* completely unexpected since we only ever ask for SP_NONE or
> +		 * SP4_MACH_CRED */
> +		WARN_ON_ONCE(1);
> 		return -EIO;
> +	}
> 
> 	/* server_owner4.so_minor_id */
> 	p = xdr_inline_decode(xdr, 8);
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index d221243..a0af429 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -87,6 +87,10 @@ struct nfs_client {
> 	struct nfs41_server_owner *cl_serverowner;
> 	struct nfs41_server_scope *cl_serverscope;
> 	struct nfs41_impl_id	*cl_implid;
> +	/* nfs 4.1+ state protection modes: */
> +	unsigned long		cl_sp4_flags;
> +#define NFS_SP4_MACH_CRED_MINIMAL  1	/* Minimal sp4_mach_cred - state ops
> +					 * must use machine cred */
> #endif /* CONFIG_NFS_V4 */
> 
> #ifdef CONFIG_NFS_FSCACHE
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 8651574..18681d9 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -1107,6 +1107,23 @@ struct pnfs_ds_commit_info {
> 	struct pnfs_commit_bucket *buckets;
> };
> 
> +#define NFS4_OP_MAP_NUM_LONGS \
> +	DIV_ROUND_UP(LAST_NFS4_OP, 8 * sizeof(unsigned long))
> +#define NFS4_OP_MAP_NUM_WORDS \
> +	(NFS4_OP_MAP_NUM_LONGS * sizeof(unsigned long) / sizeof(u32))
> +struct nfs4_op_map {
> +	union {
> +		unsigned long longs[NFS4_OP_MAP_NUM_LONGS];
> +		u32 words[NFS4_OP_MAP_NUM_WORDS];
> +	} u;
> +};
> +
> +struct nfs41_state_protection {
> +	u32 how;
> +	struct nfs4_op_map enforce;
> +	struct nfs4_op_map allow;
> +};
> +
> #define NFS4_EXCHANGE_ID_LEN	(48)
> struct nfs41_exchange_id_args {
> 	struct nfs_client		*client;
> @@ -1114,6 +1131,7 @@ struct nfs41_exchange_id_args {
> 	unsigned int 			id_len;
> 	char 				id[NFS4_EXCHANGE_ID_LEN];
> 	u32				flags;
> +	struct nfs41_state_protection	state_protect;
> };
> 
> struct nfs41_server_owner {
> @@ -1146,6 +1164,7 @@ struct nfs41_exchange_id_res {
> 	struct nfs41_server_owner	*server_owner;
> 	struct nfs41_server_scope	*server_scope;
> 	struct nfs41_impl_id		*impl_id;
> +	struct nfs41_state_protection	state_protect;
> };
> 
> struct nfs41_create_session_args {
> -- 
> 1.7.12.4 (Apple Git-37)
> 

