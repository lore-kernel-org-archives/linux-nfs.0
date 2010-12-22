Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60146 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751886Ab0LVW0d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Dec 2010 17:26:33 -0500
Date: Wed, 22 Dec 2010 17:26:31 -0500
To: andros@netapp.com
Cc: trond.myklebust@netapp.com, bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH_V5 08/11] NFS reference nfs_client across cb_compound
 processing
Message-ID: <20101222222631.GE13243@fieldses.org>
References: <1292879088-7821-1-git-send-email-andros@netapp.com>
 <1292879088-7821-2-git-send-email-andros@netapp.com>
 <1292879088-7821-3-git-send-email-andros@netapp.com>
 <1292879088-7821-4-git-send-email-andros@netapp.com>
 <1292879088-7821-5-git-send-email-andros@netapp.com>
 <1292879088-7821-6-git-send-email-andros@netapp.com>
 <1292879088-7821-7-git-send-email-andros@netapp.com>
 <1292879088-7821-8-git-send-email-andros@netapp.com>
 <1292879088-7821-9-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1292879088-7821-9-git-send-email-andros@netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I think you let the one-line description (Subject:) get out of sync with
the patch contents here?

--b.

On Mon, Dec 20, 2010 at 04:04:45PM -0500, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> In the NFS layer, V4.0 clients are found using the callback_ident field in the
> CB_COMPOUND header.  V4.1 clients are found using the sessionID in the
> CB_SEQUENCE operation which is also compared against the sessionID assigned at
> back channel thread creation.
> 
> Each of these methods finds the one an only nfs_client associated
> with the incoming callback request - so nfs_find_client_next is not needed.
> 
> Pass the referenced nfs_client to each CB_COMPOUND operation being proceesed
> via the new cb_process_state structure.
> 
> In the RPC layer, the v4.0 callback identifier is not known for the
> pg_authenticate call, so a zero value (unset) is used to find the nfs_client.
> The sessionid for the sessions based callback service has (usually) not been
> set for the pg_authenticate on a CB_NULL call, so the sessionid is not used to
> find the client in pg_authenticate for CB_NULL calls. It is used for
> pg_authenticate CB_COMPOUND calls.
> 
> Use the new cb_process_state struct to move the NFS4ERR_RETRY_UNCACHED_REP
> processing from process_op into nfs4_callback_sequence where it belongs.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/callback.c              |   21 ++++-
>  fs/nfs/callback.h              |   28 +++++--
>  fs/nfs/callback_proc.c         |  167 ++++++++++++++++------------------------
>  fs/nfs/callback_xdr.c          |   40 ++++++----
>  fs/nfs/client.c                |  159 ++++++++++++++++++++++++--------------
>  fs/nfs/internal.h              |    7 +-
>  include/linux/sunrpc/bc_xprt.h |   13 +++
>  7 files changed, 247 insertions(+), 188 deletions(-)
> 
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index 8353c4a..541be39 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -16,9 +16,7 @@
>  #include <linux/freezer.h>
>  #include <linux/kthread.h>
>  #include <linux/sunrpc/svcauth_gss.h>
> -#if defined(CONFIG_NFS_V4_1)
>  #include <linux/sunrpc/bc_xprt.h>
> -#endif
>  
>  #include <net/inet_sock.h>
>  
> @@ -387,6 +385,23 @@ static int check_gss_callback_principal(struct nfs_client *clp,
>  	return SVC_OK;
>  }
>  
> +/* pg_authenticate method helper */
> +static struct nfs_client *nfs_cb_find_client(struct svc_rqst *rqstp)
> +{
> +	struct nfs4_sessionid *sessionid = bc_xprt_sid(rqstp);
> +	int is_cb_compound = rqstp->rq_proc == CB_COMPOUND ? 1 : 0;
> +
> +	dprintk("--> %s rq_proc %d\n", __func__, rqstp->rq_proc);
> +	if (svc_is_backchannel(rqstp))
> +		/* Sessionid (usually) set after CB_NULL ping */
> +		return nfs4_find_client_sessionid(svc_addr(rqstp), sessionid,
> +						  is_cb_compound);
> +	else
> +		/* No callback identifier in pg_authenticate */
> +		return nfs4_find_client_ident(svc_addr(rqstp), 0);
> +}
> +
> +/* pg_authenticate method for nfsv4 callback threads. */
>  static int nfs_callback_authenticate(struct svc_rqst *rqstp)
>  {
>  	struct nfs_client *clp;
> @@ -394,7 +409,7 @@ static int nfs_callback_authenticate(struct svc_rqst *rqstp)
>  	int ret = SVC_OK;
>  
>  	/* Don't talk to strangers */
> -	clp = nfs_find_client(svc_addr(rqstp), 4);
> +	clp = nfs_cb_find_client(rqstp);
>  	if (clp == NULL)
>  		return SVC_DROP;
>  
> diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
> index 58d61a8..25e8802 100644
> --- a/fs/nfs/callback.h
> +++ b/fs/nfs/callback.h
> @@ -34,10 +34,17 @@ enum nfs4_callback_opnum {
>  	OP_CB_ILLEGAL = 10044,
>  };
>  
> +struct cb_process_state {
> +	__be32			drc_status;
> +	struct nfs_client	*clp;
> +	struct nfs4_sessionid	*svc_sid; /* v4.1 callback service sessionid */
> +};
> +
>  struct cb_compound_hdr_arg {
>  	unsigned int taglen;
>  	const char *tag;
>  	unsigned int minorversion;
> +	unsigned int cb_ident; /* v4.0 callback identifier */
>  	unsigned nops;
>  };
>  
> @@ -103,8 +110,9 @@ struct cb_sequenceres {
>  	uint32_t			csr_target_highestslotid;
>  };
>  
> -extern unsigned nfs4_callback_sequence(struct cb_sequenceargs *args,
> -				       struct cb_sequenceres *res);
> +extern __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
> +				       struct cb_sequenceres *res,
> +				       struct cb_process_state *cps);
>  
>  extern int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation,
>  					     const nfs4_stateid *stateid);
> @@ -118,19 +126,25 @@ struct cb_recallanyargs {
>  	uint32_t	craa_type_mask;
>  };
>  
> -extern unsigned nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy);
> +extern __be32 nfs4_callback_recallany(struct cb_recallanyargs *args,
> +					void *dummy,
> +					struct cb_process_state *cps);
>  
>  struct cb_recallslotargs {
>  	struct sockaddr	*crsa_addr;
>  	uint32_t	crsa_target_max_slots;
>  };
> -extern unsigned nfs4_callback_recallslot(struct cb_recallslotargs *args,
> -					  void *dummy);
> +extern __be32 nfs4_callback_recallslot(struct cb_recallslotargs *args,
> +					 void *dummy,
> +					 struct cb_process_state *cps);
>  
>  #endif /* CONFIG_NFS_V4_1 */
>  
> -extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getattrres *res);
> -extern __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy);
> +extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
> +				    struct cb_getattrres *res,
> +				    struct cb_process_state *cps);
> +extern __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy,
> +				   struct cb_process_state *cps);
>  
>  #ifdef CONFIG_NFS_V4
>  extern int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt);
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index 2950fca..b70e46d 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -16,26 +16,28 @@
>  #ifdef NFS_DEBUG
>  #define NFSDBG_FACILITY NFSDBG_CALLBACK
>  #endif
> - 
> -__be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getattrres *res)
> +
> +__be32 nfs4_callback_getattr(struct cb_getattrargs *args,
> +			     struct cb_getattrres *res,
> +			     struct cb_process_state *cps)
>  {
> -	struct nfs_client *clp;
>  	struct nfs_delegation *delegation;
>  	struct nfs_inode *nfsi;
>  	struct inode *inode;
>  
> +	res->status = htonl(NFS4ERR_OP_NOT_IN_SESSION);
> +	if (!cps->clp) /* Always set for v4.0. Set in cb_sequence for v4.1 */
> +		goto out;
> +
>  	res->bitmap[0] = res->bitmap[1] = 0;
>  	res->status = htonl(NFS4ERR_BADHANDLE);
> -	clp = nfs_find_client(args->addr, 4);
> -	if (clp == NULL)
> -		goto out;
>  
>  	dprintk("NFS: GETATTR callback request from %s\n",
> -		rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR));
> +		rpc_peeraddr2str(cps->clp->cl_rpcclient, RPC_DISPLAY_ADDR));
>  
> -	inode = nfs_delegation_find_inode(clp, &args->fh);
> +	inode = nfs_delegation_find_inode(cps->clp, &args->fh);
>  	if (inode == NULL)
> -		goto out_putclient;
> +		goto out;
>  	nfsi = NFS_I(inode);
>  	rcu_read_lock();
>  	delegation = rcu_dereference(nfsi->delegation);
> @@ -55,49 +57,41 @@ __be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getattrres *
>  out_iput:
>  	rcu_read_unlock();
>  	iput(inode);
> -out_putclient:
> -	nfs_put_client(clp);
>  out:
>  	dprintk("%s: exit with status = %d\n", __func__, ntohl(res->status));
>  	return res->status;
>  }
>  
> -__be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy)
> +__be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy,
> +			    struct cb_process_state *cps)
>  {
> -	struct nfs_client *clp;
>  	struct inode *inode;
>  	__be32 res;
>  	
> -	res = htonl(NFS4ERR_BADHANDLE);
> -	clp = nfs_find_client(args->addr, 4);
> -	if (clp == NULL)
> +	res = htonl(NFS4ERR_OP_NOT_IN_SESSION);
> +	if (!cps->clp) /* Always set for v4.0. Set in cb_sequence for v4.1 */
>  		goto out;
>  
>  	dprintk("NFS: RECALL callback request from %s\n",
> -		rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR));
> -
> -	do {
> -		struct nfs_client *prev = clp;
> -
> -		inode = nfs_delegation_find_inode(clp, &args->fh);
> -		if (inode != NULL) {
> -			/* Set up a helper thread to actually return the delegation */
> -			switch (nfs_async_inode_return_delegation(inode, &args->stateid)) {
> -				case 0:
> -					res = 0;
> -					break;
> -				case -ENOENT:
> -					if (res != 0)
> -						res = htonl(NFS4ERR_BAD_STATEID);
> -					break;
> -				default:
> -					res = htonl(NFS4ERR_RESOURCE);
> -			}
> -			iput(inode);
> -		}
> -		clp = nfs_find_client_next(prev);
> -		nfs_put_client(prev);
> -	} while (clp != NULL);
> +		rpc_peeraddr2str(cps->clp->cl_rpcclient, RPC_DISPLAY_ADDR));
> +
> +	res = htonl(NFS4ERR_BADHANDLE);
> +	inode = nfs_delegation_find_inode(cps->clp, &args->fh);
> +	if (inode == NULL)
> +		goto out;
> +	/* Set up a helper thread to actually return the delegation */
> +	switch (nfs_async_inode_return_delegation(inode, &args->stateid)) {
> +	case 0:
> +		res = 0;
> +		break;
> +	case -ENOENT:
> +		if (res != 0)
> +			res = htonl(NFS4ERR_BAD_STATEID);
> +		break;
> +	default:
> +		res = htonl(NFS4ERR_RESOURCE);
> +	}
> +	iput(inode);
>  out:
>  	dprintk("%s: exit with status = %d\n", __func__, ntohl(res));
>  	return res;
> @@ -185,42 +179,6 @@ validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
>  }
>  
>  /*
> - * Returns a pointer to a held 'struct nfs_client' that matches the server's
> - * address, major version number, and session ID.  It is the caller's
> - * responsibility to release the returned reference.
> - *
> - * Returns NULL if there are no connections with sessions, or if no session
> - * matches the one of interest.
> - */
> - static struct nfs_client *find_client_with_session(
> -	const struct sockaddr *addr, u32 nfsversion,
> -	struct nfs4_sessionid *sessionid)
> -{
> -	struct nfs_client *clp;
> -
> -	clp = nfs_find_client(addr, 4);
> -	if (clp == NULL)
> -		return NULL;
> -
> -	do {
> -		struct nfs_client *prev = clp;
> -
> -		if (clp->cl_session != NULL) {
> -			if (memcmp(clp->cl_session->sess_id.data,
> -					sessionid->data,
> -					NFS4_MAX_SESSIONID_LEN) == 0) {
> -				/* Returns a held reference to clp */
> -				return clp;
> -			}
> -		}
> -		clp = nfs_find_client_next(prev);
> -		nfs_put_client(prev);
> -	} while (clp != NULL);
> -
> -	return NULL;
> -}
> -
> -/*
>   * For each referring call triple, check the session's slot table for
>   * a match.  If the slot is in use and the sequence numbers match, the
>   * client is still waiting for a response to the original request.
> @@ -276,20 +234,28 @@ out:
>  }
>  
>  __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
> -				struct cb_sequenceres *res)
> +			      struct cb_sequenceres *res,
> +			      struct cb_process_state *cps)
>  {
>  	struct nfs_client *clp;
>  	int i;
>  	__be32 status;
>  
> +	cps->clp = NULL;
> +
>  	status = htonl(NFS4ERR_BADSESSION);
> -	clp = find_client_with_session(args->csa_addr, 4, &args->csa_sessionid);
> +	/* Incoming session must match the callback session */
> +	if (memcmp(&args->csa_sessionid, cps->svc_sid, NFS4_MAX_SESSIONID_LEN))
> +		goto out;
> +
> +	clp = nfs4_find_client_sessionid(args->csa_addr,
> +					 &args->csa_sessionid, 1);
>  	if (clp == NULL)
>  		goto out;
>  
>  	status = validate_seqid(&clp->cl_session->bc_slot_table, args);
>  	if (status)
> -		goto out_putclient;
> +		goto out;
>  
>  	/*
>  	 * Check for pending referring calls.  If a match is found, a
> @@ -298,7 +264,7 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
>  	 */
>  	if (referring_call_exists(clp, args->csa_nrclists, args->csa_rclists)) {
>  		status = htonl(NFS4ERR_DELAY);
> -		goto out_putclient;
> +		goto out;
>  	}
>  
>  	memcpy(&res->csr_sessionid, &args->csa_sessionid,
> @@ -307,36 +273,36 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
>  	res->csr_slotid = args->csa_slotid;
>  	res->csr_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
>  	res->csr_target_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
> +	cps->clp = clp; /* put in nfs4_callback_compound */
>  
> -out_putclient:
> -	nfs_put_client(clp);
>  out:
>  	for (i = 0; i < args->csa_nrclists; i++)
>  		kfree(args->csa_rclists[i].rcl_refcalls);
>  	kfree(args->csa_rclists);
>  
> -	if (status == htonl(NFS4ERR_RETRY_UNCACHED_REP))
> -		res->csr_status = 0;
> -	else
> +	if (status == htonl(NFS4ERR_RETRY_UNCACHED_REP)) {
> +		cps->drc_status = status;
> +		status = 0;
> +	} else
>  		res->csr_status = status;
> +
>  	dprintk("%s: exit with status = %d res->csr_status %d\n", __func__,
>  		ntohl(status), ntohl(res->csr_status));
>  	return status;
>  }
>  
> -__be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy)
> +__be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy,
> +			       struct cb_process_state *cps)
>  {
> -	struct nfs_client *clp;
>  	__be32 status;
>  	fmode_t flags = 0;
>  
>  	status = htonl(NFS4ERR_OP_NOT_IN_SESSION);
> -	clp = nfs_find_client(args->craa_addr, 4);
> -	if (clp == NULL)
> +	if (!cps->clp) /* set in cb_sequence */
>  		goto out;
>  
>  	dprintk("NFS: RECALL_ANY callback request from %s\n",
> -		rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR));
> +		rpc_peeraddr2str(cps->clp->cl_rpcclient, RPC_DISPLAY_ADDR));
>  
>  	if (test_bit(RCA4_TYPE_MASK_RDATA_DLG, (const unsigned long *)
>  		     &args->craa_type_mask))
> @@ -346,7 +312,7 @@ __be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy)
>  		flags |= FMODE_WRITE;
>  
>  	if (flags)
> -		nfs_expire_all_delegation_types(clp, flags);
> +		nfs_expire_all_delegation_types(cps->clp, flags);
>  	status = htonl(NFS4_OK);
>  out:
>  	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
> @@ -354,36 +320,33 @@ out:
>  }
>  
>  /* Reduce the fore channel's max_slots to the target value */
> -__be32 nfs4_callback_recallslot(struct cb_recallslotargs *args, void *dummy)
> +__be32 nfs4_callback_recallslot(struct cb_recallslotargs *args, void *dummy,
> +				struct cb_process_state *cps)
>  {
> -	struct nfs_client *clp;
>  	struct nfs4_slot_table *fc_tbl;
>  	__be32 status;
>  
>  	status = htonl(NFS4ERR_OP_NOT_IN_SESSION);
> -	clp = nfs_find_client(args->crsa_addr, 4);
> -	if (clp == NULL)
> +	if (!cps->clp) /* set in cb_sequence */
>  		goto out;
>  
>  	dprintk("NFS: CB_RECALL_SLOT request from %s target max slots %d\n",
> -		rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR),
> +		rpc_peeraddr2str(cps->clp->cl_rpcclient, RPC_DISPLAY_ADDR),
>  		args->crsa_target_max_slots);
>  
> -	fc_tbl = &clp->cl_session->fc_slot_table;
> +	fc_tbl = &cps->clp->cl_session->fc_slot_table;
>  
>  	status = htonl(NFS4ERR_BAD_HIGH_SLOT);
>  	if (args->crsa_target_max_slots > fc_tbl->max_slots ||
>  	    args->crsa_target_max_slots < 1)
> -		goto out_putclient;
> +		goto out;
>  
>  	status = htonl(NFS4_OK);
>  	if (args->crsa_target_max_slots == fc_tbl->max_slots)
> -		goto out_putclient;
> +		goto out;
>  
>  	fc_tbl->target_max_slots = args->crsa_target_max_slots;
> -	nfs41_handle_recall_slot(clp);
> -out_putclient:
> -	nfs_put_client(clp);	/* balance nfs_find_client */
> +	nfs41_handle_recall_slot(cps->clp);
>  out:
>  	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
>  	return status;
> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> index 05af212..85cbb8f 100644
> --- a/fs/nfs/callback_xdr.c
> +++ b/fs/nfs/callback_xdr.c
> @@ -10,8 +10,10 @@
>  #include <linux/nfs4.h>
>  #include <linux/nfs_fs.h>
>  #include <linux/slab.h>
> +#include <linux/sunrpc/bc_xprt.h>
>  #include "nfs4_fs.h"
>  #include "callback.h"
> +#include "internal.h"
>  
>  #define CB_OP_TAGLEN_MAXSZ	(512)
>  #define CB_OP_HDR_RES_MAXSZ	(2 + CB_OP_TAGLEN_MAXSZ)
> @@ -33,7 +35,8 @@
>  /* Internal error code */
>  #define NFS4ERR_RESOURCE_HDR	11050
>  
> -typedef __be32 (*callback_process_op_t)(void *, void *);
> +typedef __be32 (*callback_process_op_t)(void *, void *,
> +					struct cb_process_state *);
>  typedef __be32 (*callback_decode_arg_t)(struct svc_rqst *, struct xdr_stream *, void *);
>  typedef __be32 (*callback_encode_res_t)(struct svc_rqst *, struct xdr_stream *, void *);
>  
> @@ -160,7 +163,7 @@ static __be32 decode_compound_hdr_arg(struct xdr_stream *xdr, struct cb_compound
>  	hdr->minorversion = ntohl(*p++);
>  	/* Check minor version is zero or one. */
>  	if (hdr->minorversion <= 1) {
> -		p++;	/* skip callback_ident */
> +		hdr->cb_ident = ntohl(*p++); /* ignored by v4.1 */
>  	} else {
>  		printk(KERN_WARNING "%s: NFSv4 server callback with "
>  			"illegal minor version %u!\n",
> @@ -621,7 +624,8 @@ preprocess_nfs4_op(unsigned int op_nr, struct callback_op **op)
>  static __be32 process_op(uint32_t minorversion, int nop,
>  		struct svc_rqst *rqstp,
>  		struct xdr_stream *xdr_in, void *argp,
> -		struct xdr_stream *xdr_out, void *resp, int* drc_status)
> +		struct xdr_stream *xdr_out, void *resp,
> +		struct cb_process_state *cps)
>  {
>  	struct callback_op *op = &callback_ops[0];
>  	unsigned int op_nr;
> @@ -644,8 +648,8 @@ static __be32 process_op(uint32_t minorversion, int nop,
>  	if (status)
>  		goto encode_hdr;
>  
> -	if (*drc_status) {
> -		status = *drc_status;
> +	if (cps->drc_status) {
> +		status = cps->drc_status;
>  		goto encode_hdr;
>  	}
>  
> @@ -653,16 +657,10 @@ static __be32 process_op(uint32_t minorversion, int nop,
>  	if (maxlen > 0 && maxlen < PAGE_SIZE) {
>  		status = op->decode_args(rqstp, xdr_in, argp);
>  		if (likely(status == 0))
> -			status = op->process_op(argp, resp);
> +			status = op->process_op(argp, resp, cps);
>  	} else
>  		status = htonl(NFS4ERR_RESOURCE);
>  
> -	/* Only set by OP_CB_SEQUENCE processing */
> -	if (status == htonl(NFS4ERR_RETRY_UNCACHED_REP)) {
> -		*drc_status = status;
> -		status = 0;
> -	}
> -
>  encode_hdr:
>  	res = encode_op_hdr(xdr_out, op_nr, status);
>  	if (unlikely(res))
> @@ -681,8 +679,11 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
>  	struct cb_compound_hdr_arg hdr_arg = { 0 };
>  	struct cb_compound_hdr_res hdr_res = { NULL };
>  	struct xdr_stream xdr_in, xdr_out;
> -	__be32 *p;
> -	__be32 status, drc_status = 0;
> +	__be32 *p, status;
> +	struct cb_process_state cps = {
> +		.drc_status = 0,
> +		.clp = NULL,
> +	};
>  	unsigned int nops = 0;
>  
>  	dprintk("%s: start\n", __func__);
> @@ -696,6 +697,14 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
>  	if (status == __constant_htonl(NFS4ERR_RESOURCE))
>  		return rpc_garbage_args;
>  
> +	if (hdr_arg.minorversion == 0) {
> +		cps.clp = nfs4_find_client_ident(svc_addr(rqstp),
> +						 hdr_arg.cb_ident);
> +		if (!cps.clp)
> +			return rpc_drop_reply;
> +	} else
> +		cps.svc_sid = bc_xprt_sid(rqstp);
> +
>  	hdr_res.taglen = hdr_arg.taglen;
>  	hdr_res.tag = hdr_arg.tag;
>  	if (encode_compound_hdr_res(&xdr_out, &hdr_res) != 0)
> @@ -703,7 +712,7 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
>  
>  	while (status == 0 && nops != hdr_arg.nops) {
>  		status = process_op(hdr_arg.minorversion, nops, rqstp,
> -				    &xdr_in, argp, &xdr_out, resp, &drc_status);
> +				    &xdr_in, argp, &xdr_out, resp, &cps);
>  		nops++;
>  	}
>  
> @@ -716,6 +725,7 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
>  
>  	*hdr_res.status = status;
>  	*hdr_res.nops = htonl(nops);
> +	nfs_put_client(cps.clp);
>  	dprintk("%s: done, status = %u\n", __func__, ntohl(status));
>  	return rpc_success;
>  }
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 855add6..17bfc25 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -359,70 +359,28 @@ static int nfs_sockaddr_cmp(const struct sockaddr *sa1,
>  	return 0;
>  }
>  
> -/*
> - * Find a client by IP address and protocol version
> - * - returns NULL if no such client
> - */
> -struct nfs_client *nfs_find_client(const struct sockaddr *addr, u32 nfsversion)
> -{
> -	struct nfs_client *clp;
> -
> -	spin_lock(&nfs_client_lock);
> -	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
> -		struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;
> -
> -		/* Don't match clients that failed to initialise properly */
> -		if (!(clp->cl_cons_state == NFS_CS_READY ||
> -		      clp->cl_cons_state == NFS_CS_SESSION_INITING))
> -			continue;
> -
> -		/* Different NFS versions cannot share the same nfs_client */
> -		if (clp->rpc_ops->version != nfsversion)
> -			continue;
> -
> -		/* Match only the IP address, not the port number */
> -		if (!nfs_sockaddr_match_ipaddr(addr, clap))
> -			continue;
> -
> -		atomic_inc(&clp->cl_count);
> -		spin_unlock(&nfs_client_lock);
> -		return clp;
> -	}
> -	spin_unlock(&nfs_client_lock);
> -	return NULL;
> -}
> -
> -/*
> - * Find a client by IP address and protocol version
> - * - returns NULL if no such client
> - */
> -struct nfs_client *nfs_find_client_next(struct nfs_client *clp)
> +/* Common match routine for v4.0 and v4.1 callback services */
> +bool
> +nfs4_cb_match_client(const struct sockaddr *addr, struct nfs_client *clp,
> +		     u32 minorversion)
>  {
> -	struct sockaddr *sap = (struct sockaddr *)&clp->cl_addr;
> -	u32 nfsvers = clp->rpc_ops->version;
> +	struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;
>  
> -	spin_lock(&nfs_client_lock);
> -	list_for_each_entry_continue(clp, &nfs_client_list, cl_share_link) {
> -		struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;
> -
> -		/* Don't match clients that failed to initialise properly */
> -		if (clp->cl_cons_state != NFS_CS_READY)
> -			continue;
> +	/* Don't match clients that failed to initialise */
> +	if (!(clp->cl_cons_state == NFS_CS_READY ||
> +	    clp->cl_cons_state == NFS_CS_SESSION_INITING))
> +		return false;
>  
> -		/* Different NFS versions cannot share the same nfs_client */
> -		if (clp->rpc_ops->version != nfsvers)
> -			continue;
> +	/* Match the version and minorversion */
> +	if (clp->rpc_ops->version != 4 ||
> +	    clp->cl_minorversion != minorversion)
> +		return false;
>  
> -		/* Match only the IP address, not the port number */
> -		if (!nfs_sockaddr_match_ipaddr(sap, clap))
> -			continue;
> +	/* Match only the IP address, not the port number */
> +	if (!nfs_sockaddr_match_ipaddr(addr, clap))
> +		return false;
>  
> -		atomic_inc(&clp->cl_count);
> -		spin_unlock(&nfs_client_lock);
> -		return clp;
> -	}
> -	spin_unlock(&nfs_client_lock);
> -	return NULL;
> +	return true;
>  }
>  
>  /*
> @@ -1121,6 +1079,89 @@ error:
>  
>  #ifdef CONFIG_NFS_V4
>  /*
> + * NFSv4.0 callback thread helper
> + *
> + * Find a client by IP address, protocol version, minorversion, and callback
> + * identifier.
> + *
> + * Called from the pg_authenticate method with a zero callback_ident
> + * because the callback identifier has not been decoded.
> + *
> + * Returns NULL if no such client
> + */
> +struct nfs_client *
> +nfs4_find_client_ident(const struct sockaddr *addr, u32 callback_ident)
> +{
> +	struct nfs_client *clp;
> +
> +	spin_lock(&nfs_client_lock);
> +	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
> +		if (nfs4_cb_match_client(addr, clp, 0) == false)
> +			continue;
> +
> +		/* Match the non-zero callback identifier */
> +		if (callback_ident != 0 && clp->cl_cb_ident != callback_ident)
> +			continue;
> +
> +		atomic_inc(&clp->cl_count);
> +		spin_unlock(&nfs_client_lock);
> +		return clp;
> +	}
> +	spin_unlock(&nfs_client_lock);
> +	return NULL;
> +}
> +
> +#if defined(CONFIG_NFS_V4_1)
> +/*
> + * NFSv4.1 callback thread helper
> + * For CB_COMPOUND calls, find a client by IP address, protocol version,
> + * minorversion, and sessionID
> + *
> + * CREATE_SESSION triggers a CB_NULL ping from servers. The callback service
> + * sessionid can only be set after the CREATE_SESSION return, so a CB_NULL
> + * can arrive before the callback sessionid is set. For CB_NULL calls,
> + * find a client by IP address protocol version, and minorversion.
> + *
> + * Returns NULL if no such client
> + */
> +struct nfs_client *
> +nfs4_find_client_sessionid(const struct sockaddr *addr,
> +			   struct nfs4_sessionid *sid, int is_cb_compound)
> +{
> +	struct nfs_client *clp;
> +
> +	spin_lock(&nfs_client_lock);
> +	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
> +		if (nfs4_cb_match_client(addr, clp, 1) == false)
> +			continue;
> +
> +		if (!nfs4_has_session(clp))
> +			continue;
> +
> +		/* Match sessionid unless cb_null call*/
> +		if (is_cb_compound && (memcmp(clp->cl_session->sess_id.data,
> +		    sid->data, NFS4_MAX_SESSIONID_LEN) != 0))
> +			continue;
> +
> +		atomic_inc(&clp->cl_count);
> +		spin_unlock(&nfs_client_lock);
> +		return clp;
> +	}
> +	spin_unlock(&nfs_client_lock);
> +	return NULL;
> +}
> +
> +#else /* CONFIG_NFS_V4_1 */
> +
> +struct nfs_client *
> +nfs4_find_client_sessionid(const struct sockaddr *addr,
> +			   struct nfs4_sessionid *sid, int is_cb_compound)
> +{
> +	return NULL;
> +}
> +#endif /* CONFIG_NFS_V4_1 */
> +
> +/*
>   * Initialize the NFS4 callback service
>   */
>  static int nfs4_init_callback(struct nfs_client *clp)
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index e6356b7..f65602c 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -129,8 +129,11 @@ extern void nfs_umount(const struct nfs_mount_request *info);
>  extern struct rpc_program nfs_program;
>  
>  extern void nfs_put_client(struct nfs_client *);
> -extern struct nfs_client *nfs_find_client(const struct sockaddr *, u32);
> -extern struct nfs_client *nfs_find_client_next(struct nfs_client *);
> +extern struct nfs_client *nfs4_find_client_ident(const struct sockaddr *,
> +						    u32);
> +extern struct nfs_client *
> +nfs4_find_client_sessionid(const struct sockaddr *, struct nfs4_sessionid *,
> +			   int);
>  extern struct nfs_server *nfs_create_server(
>  					const struct nfs_parsed_mount_data *,
>  					struct nfs_fh *);
> diff --git a/include/linux/sunrpc/bc_xprt.h b/include/linux/sunrpc/bc_xprt.h
> index 7c91260..2c60e09 100644
> --- a/include/linux/sunrpc/bc_xprt.h
> +++ b/include/linux/sunrpc/bc_xprt.h
> @@ -47,6 +47,14 @@ static inline int svc_is_backchannel(const struct svc_rqst *rqstp)
>  		return 1;
>  	return 0;
>  }
> +static inline struct nfs4_sessionid *bc_xprt_sid(struct svc_rqst *rqstp)
> +{
> +	if (svc_is_backchannel(rqstp))
> +		return (struct nfs4_sessionid *)
> +					rqstp->rq_server->bc_xprt->xpt_bc_sid;
> +	return NULL;
> +}
> +
>  #else /* CONFIG_NFS_V4_1 */
>  static inline int xprt_setup_backchannel(struct rpc_xprt *xprt,
>  					 unsigned int min_reqs)
> @@ -59,6 +67,11 @@ static inline int svc_is_backchannel(const struct svc_rqst *rqstp)
>  	return 0;
>  }
>  
> +static inline struct nfs4_sessionid *bc_xprt_sid(struct svc_rqst *rqstp)
> +{
> +	return NULL;
> +}
> +
>  static inline void xprt_free_bc_request(struct rpc_rqst *req)
>  {
>  }
> -- 
> 1.6.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
