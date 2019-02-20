Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E662FC43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 02:35:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B26C121773
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 02:35:38 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729793AbfBTCfi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 21:35:38 -0500
Received: from fieldses.org ([173.255.197.46]:47934 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728427AbfBTCfh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Feb 2019 21:35:37 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 5AD421E29; Tue, 19 Feb 2019 21:35:36 -0500 (EST)
Date:   Tue, 19 Feb 2019 21:35:36 -0500
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     bfields@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v2 06/10] NFSD add COPY_NOTIFY operation
Message-ID: <20190220023536.GH19603@fieldses.org>
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
 <20181130200348.59524-7-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181130200348.59524-7-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 30, 2018 at 03:03:44PM -0500, Olga Kornievskaia wrote:
> Introducing the COPY_NOTIFY operation.
> 
> Create a new unique stateid that will keep track of the copy
> state and the upcoming READs that will use that stateid. Keep
> it in the list associated with parent stateid.
> 
> Return single netaddr to advertise to the copy.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfsd/nfs4proc.c  | 72 +++++++++++++++++++++++++++++++++++----
>  fs/nfsd/nfs4state.c | 64 +++++++++++++++++++++++++++++++----
>  fs/nfsd/nfs4xdr.c   | 97 +++++++++++++++++++++++++++++++++++++++++++++++++++--
>  fs/nfsd/state.h     | 18 ++++++++--
>  fs/nfsd/xdr4.h      | 13 +++++++
>  5 files changed, 248 insertions(+), 16 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 0152b34..51fca9e 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -37,6 +37,7 @@
>  #include <linux/falloc.h>
>  #include <linux/slab.h>
>  #include <linux/kthread.h>
> +#include <linux/sunrpc/addr.h>
>  
>  #include "idmap.h"
>  #include "cache.h"
> @@ -1035,7 +1036,8 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
>  static __be32
>  nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		  stateid_t *src_stateid, struct file **src,
> -		  stateid_t *dst_stateid, struct file **dst)
> +		  stateid_t *dst_stateid, struct file **dst,
> +		  struct nfs4_stid **stid)
>  {
>  	__be32 status;
>  
> @@ -1052,7 +1054,7 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
>  
>  	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
>  					    dst_stateid, WR_STATE, dst, NULL,
> -					    NULL);
> +					    stid);
>  	if (status) {
>  		dprintk("NFSD: %s: couldn't process dst stateid!\n", __func__);
>  		goto out_put_src;
> @@ -1083,7 +1085,7 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
>  	__be32 status;
>  
>  	status = nfsd4_verify_copy(rqstp, cstate, &clone->cl_src_stateid, &src,
> -				   &clone->cl_dst_stateid, &dst);
> +				   &clone->cl_dst_stateid, &dst, NULL);
>  	if (status)
>  		goto out;
>  
> @@ -1230,7 +1232,7 @@ static void dup_copy_fields(struct nfsd4_copy *src, struct nfsd4_copy *dst)
>  
>  static void cleanup_async_copy(struct nfsd4_copy *copy)
>  {
> -	nfs4_free_cp_state(copy);
> +	nfs4_free_copy_state(copy);
>  	fput(copy->file_dst);
>  	fput(copy->file_src);
>  	spin_lock(&copy->cp_clp->async_lock);
> @@ -1270,7 +1272,7 @@ static int nfsd4_do_async_copy(void *data)
>  
>  	status = nfsd4_verify_copy(rqstp, cstate, &copy->cp_src_stateid,
>  				   &copy->file_src, &copy->cp_dst_stateid,
> -				   &copy->file_dst);
> +				   &copy->file_dst, NULL);
>  	if (status)
>  		goto out;
>  
> @@ -1284,7 +1286,7 @@ static int nfsd4_do_async_copy(void *data)
>  		async_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
>  		if (!async_copy)
>  			goto out;
> -		if (!nfs4_init_cp_state(nn, copy)) {
> +		if (!nfs4_init_copy_state(nn, copy)) {
>  			kfree(async_copy);
>  			goto out;
>  		}
> @@ -1348,6 +1350,43 @@ struct nfsd4_copy *
>  }
>  
>  static __be32
> +nfsd4_copy_notify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> +		  union nfsd4_op_u *u)
> +{
> +	struct nfsd4_copy_notify *cn = &u->copy_notify;
> +	__be32 status;
> +	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
> +	struct nfs4_stid *stid;
> +	struct nfs4_cpntf_state *cps;
> +
> +	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
> +					&cn->cpn_src_stateid, RD_STATE, NULL,
> +					NULL, &stid);
> +	if (status)
> +		return status;
> +
> +	cn->cpn_sec = nn->nfsd4_lease;
> +	cn->cpn_nsec = 0;
> +
> +	status = nfserrno(-ENOMEM);
> +	cps = nfs4_alloc_init_cpntf_state(nn, stid);
> +	if (!cps)
> +		return status;
> +	memcpy(&cn->cpn_cnr_stateid, &cps->cp_stateid, sizeof(stateid_t));
> +
> +	/**
> +	 * For now, only return one server address in cpn_src, the
> +	 * address used by the client to connect to this server.
> +	 */
> +	cn->cpn_src.nl4_type = NL4_NETADDR;
> +	status = nfsd4_set_netaddr((struct sockaddr *)&rqstp->rq_daddr,
> +				 &cn->cpn_src.u.nl4_addr);
> +	WARN_ON_ONCE(status);
> +
> +	return status;
> +}
> +
> +static __be32
>  nfsd4_fallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		struct nfsd4_fallocate *fallocate, int flags)
>  {
> @@ -2299,6 +2338,21 @@ static inline u32 nfsd4_offload_status_rsize(struct svc_rqst *rqstp,
>  		1 /* osr_complete<1> optional 0 for now */) * sizeof(__be32);
>  }
>  
> +static inline u32 nfsd4_copy_notify_rsize(struct svc_rqst *rqstp,
> +					struct nfsd4_op *op)
> +{
> +	return (op_encode_hdr_size +
> +		3 /* cnr_lease_time */ +
> +		1 /* We support one cnr_source_server */ +
> +		1 /* cnr_stateid seq */ +
> +		op_encode_stateid_maxsz /* cnr_stateid */ +
> +		1 /* num cnr_source_server*/ +
> +		1 /* nl4_type */ +
> +		1 /* nl4 size */ +
> +		XDR_QUADLEN(NFS4_OPAQUE_LIMIT) /*nl4_loc + nl4_loc_sz */)
> +		* sizeof(__be32);
> +}
> +
>  #ifdef CONFIG_NFSD_PNFS
>  static inline u32 nfsd4_getdeviceinfo_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
>  {
> @@ -2723,6 +2777,12 @@ static inline u32 nfsd4_seek_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
>  		.op_name = "OP_OFFLOAD_CANCEL",
>  		.op_rsize_bop = nfsd4_only_status_rsize,
>  	},
> +	[OP_COPY_NOTIFY] = {
> +		.op_func = nfsd4_copy_notify,
> +		.op_flags = OP_MODIFIES_SOMETHING,
> +		.op_name = "OP_COPY_NOTIFY",
> +		.op_rsize_bop = nfsd4_copy_notify_rsize,
> +	},
>  };
>  
>  /**
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index be3e967..eaa136f 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -697,6 +697,7 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
>  	/* Will be incremented before return to client: */
>  	refcount_set(&stid->sc_count, 1);
>  	spin_lock_init(&stid->sc_lock);
> +	INIT_LIST_HEAD(&stid->sc_cp_list);
>  
>  	/*
>  	 * It shouldn't be a problem to reuse an opaque stateid value.
> @@ -716,24 +717,53 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
>  /*
>   * Create a unique stateid_t to represent each COPY.
>   */
> -int nfs4_init_cp_state(struct nfsd_net *nn, struct nfsd4_copy *copy)
> +static int nfs4_init_cp_state(struct nfsd_net *nn, void *ptr, stateid_t *stid)
>  {
>  	int new_id;
>  
>  	idr_preload(GFP_KERNEL);
>  	spin_lock(&nn->s2s_cp_lock);
> -	new_id = idr_alloc_cyclic(&nn->s2s_cp_stateids, copy, 0, 0, GFP_NOWAIT);
> +	new_id = idr_alloc_cyclic(&nn->s2s_cp_stateids, ptr, 0, 0, GFP_NOWAIT);
>  	spin_unlock(&nn->s2s_cp_lock);
>  	idr_preload_end();
>  	if (new_id < 0)
>  		return 0;
> -	copy->cp_stateid.si_opaque.so_id = new_id;
> -	copy->cp_stateid.si_opaque.so_clid.cl_boot = nn->boot_time;
> -	copy->cp_stateid.si_opaque.so_clid.cl_id = nn->s2s_cp_cl_id;
> +	stid->si_opaque.so_id = new_id;
> +	stid->si_opaque.so_clid.cl_boot = nn->boot_time;
> +	stid->si_opaque.so_clid.cl_id = nn->s2s_cp_cl_id;
>  	return 1;
>  }
>  
> -void nfs4_free_cp_state(struct nfsd4_copy *copy)
> +int nfs4_init_copy_state(struct nfsd_net *nn, struct nfsd4_copy *copy)
> +{
> +	return nfs4_init_cp_state(nn, copy, &copy->cp_stateid);
> +}
> +
> +struct nfs4_cpntf_state *nfs4_alloc_init_cpntf_state(struct nfsd_net *nn,
> +						     struct nfs4_stid *p_stid)
> +{
> +	struct nfs4_cpntf_state *cps;
> +
> +	cps = kzalloc(sizeof(struct nfs4_cpntf_state), GFP_KERNEL);
> +	if (!cps)
> +		return NULL;
> +	if (!nfs4_init_cp_state(nn, cps, &cps->cp_stateid))
> +		goto out_free;
> +	cps->cp_p_stid = p_stid;
> +	cps->cp_active = false;
> +	cps->cp_timeout = jiffies + (nn->nfsd4_lease * HZ);
> +	INIT_LIST_HEAD(&cps->cp_list);
> +	spin_lock(&nn->s2s_cp_lock);
> +	list_add(&cps->cp_list, &p_stid->sc_cp_list);
> +	spin_unlock(&nn->s2s_cp_lock);
> +
> +	return cps;
> +out_free:
> +	kfree(cps);
> +	return NULL;
> +}
> +
> +void nfs4_free_copy_state(struct nfsd4_copy *copy)
>  {
>  	struct nfsd_net *nn;
>  
> @@ -743,6 +773,27 @@ void nfs4_free_cp_state(struct nfsd4_copy *copy)
>  	spin_unlock(&nn->s2s_cp_lock);
>  }
>  
> +static void nfs4_free_cpntf_statelist(struct net *net, struct nfs4_stid *stid)
> +{
> +	struct nfs4_cpntf_state *cps;
> +	struct nfsd_net *nn;
> +
> +	nn = net_generic(net, nfsd_net_id);
> +
> +	might_sleep();

What's that for?  Just remove it unless you've got some good reason.

--b.
