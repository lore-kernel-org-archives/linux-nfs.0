Return-Path: <SRS0=wnB3=NQ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D5B2C0044C
	for <linux-nfs@archiver.kernel.org>; Mon,  5 Nov 2018 17:50:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4F18520700
	for <linux-nfs@archiver.kernel.org>; Mon,  5 Nov 2018 17:50:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F18520700
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387656AbeKFDKx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 5 Nov 2018 22:10:53 -0500
Received: from fieldses.org ([173.255.197.46]:33608 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2387590AbeKFDKx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 5 Nov 2018 22:10:53 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 7B6EF1E31; Mon,  5 Nov 2018 12:50:06 -0500 (EST)
Date:   Mon, 5 Nov 2018 12:50:06 -0500
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 09/13] NFSD add COPY_NOTIFY operation
Message-ID: <20181105175006.GA9111@fieldses.org>
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-10-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181019152905.32418-10-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Oct 19, 2018 at 11:29:01AM -0400, Olga Kornievskaia wrote:
> @@ -1345,6 +1347,44 @@ struct nfsd4_copy *
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
> +	if (status != 0)
> +		nfs4_free_cpntf_state(cps);

It looks like this would free cps while it was still on the parent's
sc_cp_list.

Is an error actually possible here? If not, just remove this check or
replace it by WARN_ON_ONCE(status).

> +
> +	return status;
> +}
...
> @@ -2720,6 +2775,12 @@ static inline u32 nfsd4_seek_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
>  		.op_name = "OP_OFFLOAD_CANCEL",
>  		.op_rsize_bop = nfsd4_only_status_rsize,
>  	},
> +	[OP_COPY_NOTIFY] = {
> +		.op_func = nfsd4_copy_notify,
> +		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,

CACHEME is actually only used for 4.0, let's drop it from
nfs4.1/4.2-only operations.

> +		.op_name = "OP_COPY_NOTIFY",
> +		.op_rsize_bop = nfsd4_copy_notify_rsize,
> +	},
>  };
>  
>  /**
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index e263fd0..7764a8b 100644
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
> @@ -716,33 +717,85 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
>  /*
>   * Create a unique stateid_t to represent each COPY.
>   */
> -int nfs4_init_cp_state(struct nfsd_net *nn, struct nfsd4_copy *copy)
> +int _nfs4_init_state(struct nfsd_net *nn, void *ptr, stateid_t *stid)

This is still copy-specific code, so the names might be more
helpful if they left that in.  Maybe:

	_nfs4_init_state -> nfs4_init_cp_state
	nfs4_init_cp_state -> nfs4_init_copy_state
	nfs4_init_cp_state -> nfs4_init_cpnotify_state

?  Unless you can think of something better.

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
> +int nfs4_init_cp_state(struct nfsd_net *nn, struct nfsd4_copy *copy)
> +{
> +	return _nfs4_init_state(nn, copy, &copy->cp_stateid);
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
> +	if (!_nfs4_init_state(nn, cps, &cps->cp_stateid))
> +		goto out_free;
> +	cps->cp_p_stid = p_stid;
> +	cps->cp_active = false;
> +	cps->cp_timeout = jiffies + (nn->nfsd4_lease * HZ);
> +	INIT_LIST_HEAD(&cps->cp_list);
> +	list_add(&cps->cp_list, &p_stid->sc_cp_list);

What prevents concurrent nfs4_alloc_init_cpntf_state()s from running and
corrupting this list?

> +
> +	return cps;
> +out_free:
> +	kfree(cps);
> +	return NULL;
> +}
> +
> +void _nfs4_free_state(struct net *n, stateid_t *stid)

Ditto on the naming.

>  {
>  	struct nfsd_net *nn;
>  
> -	nn = net_generic(copy->cp_clp->net, nfsd_net_id);
> +	nn = net_generic(n, nfsd_net_id);
>  	spin_lock(&nn->s2s_cp_lock);
> -	idr_remove(&nn->s2s_cp_stateids, copy->cp_stateid.si_opaque.so_id);
> +	idr_remove(&nn->s2s_cp_stateids, stid->si_opaque.so_id);
>  	spin_unlock(&nn->s2s_cp_lock);
>  }
>  
> +void nfs4_free_cp_state(struct nfsd4_copy *copy)
> +{
> +	_nfs4_free_state(copy->cp_clp->net, &copy->cp_stateid);
> +}
> +
> +void nfs4_free_cpntf_state(struct nfs4_cpntf_state *cps)
> +{
> +	_nfs4_free_state(cps->cp_p_stid->sc_client->net, &cps->cp_stateid);
> +	kfree(cps);
> +}
> +
> +static void nfs4_free_cpntf_statelist(struct nfs4_stid *stid)
> +{
> +	struct nfs4_cpntf_state *cps;
> +
> +	might_sleep();
> +
> +	while (!list_empty(&stid->sc_cp_list)) {
> +		cps = list_first_entry(&stid->sc_cp_list,
> +				       struct nfs4_cpntf_state, cp_list);
> +		list_del(&cps->cp_list);
> +		nfs4_free_cpntf_state(cps);
> +	}

Same question on concurrent modifications of this lock--do we need some
more locking?

--b.
