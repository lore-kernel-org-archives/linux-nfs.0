Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:62360 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932491Ab0I3VVx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Sep 2010 17:21:53 -0400
Message-ID: <4CA4FF6E.3030907@panasas.com>
Date: Thu, 30 Sep 2010 23:21:50 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 11/16] nfsd4: keep per-session list of connections
References: <1285863553-8945-1-git-send-email-bfields@redhat.com> <1285863553-8945-12-git-send-email-bfields@redhat.com>
In-Reply-To: <1285863553-8945-12-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-09-30 18:19, J. Bruce Fields wrote:
> From: J. Bruce Fields <bfields@citi.umich.edu>
> 
> The spec requires us in various places to keep track of the connections
> associated with each session.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/nfsd/nfs4state.c  |   69 +++++++++++++++++++++++++++++++++++++++-----------
>  fs/nfsd/state.h      |    8 ++++++
>  include/linux/nfs4.h |    3 ++
>  3 files changed, 65 insertions(+), 15 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index f86476c..c7c1a7a 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -625,11 +625,58 @@ static void init_forechannel_attrs(struct nfsd4_channel_attrs *new, struct nfsd4
>  	new->maxops = min_t(u32, req->maxops, NFSD_MAX_OPS_PER_COMPOUND);
>  }
>  
> +static __be32 nfsd4_new_conn(struct svc_rqst *rqstp, struct nfsd4_session *ses)
> +{
> +	struct nfs4_client *clp = ses->se_client;
> +	struct nfsd4_conn *conn;
> +
> +	conn = kmalloc(sizeof(struct nfsd4_conn), GFP_KERNEL);
> +	if (!conn)
> +		return nfserr_jukebox;
> +	conn->cn_flags = NFS4_CDFC4_FORE;
> +	svc_xprt_get(rqstp->rq_xprt);
> +	conn->cn_xprt = rqstp->rq_xprt;
> +
> +	spin_lock(&clp->cl_lock);
> +	list_add(&conn->cn_persession, &ses->se_conns);
> +	spin_unlock(&clp->cl_lock);
> +
> +	return nfs_ok;
> +}
> +
> +static void free_conn(struct nfsd4_conn *c)
> +{
> +	svc_xprt_put(c->cn_xprt);
> +	kfree(c);
> +}
> +
> +void free_session(struct kref *kref)
> +{
> +	struct nfsd4_session *ses;
> +	int mem;
> +
> +	ses = container_of(kref, struct nfsd4_session, se_ref);
> +	while (!list_empty(&ses->se_conns)) {
> +		struct nfsd4_conn *c;
> +		c = list_first_entry(&ses->se_conns, struct nfsd4_conn, cn_persession);
> +		list_del(&c->cn_persession);
> +		free_conn(c);
> +	}
> +	spin_lock(&nfsd_drc_lock);
> +	mem = ses->se_fchannel.maxreqs * slot_bytes(&ses->se_fchannel);
> +	nfsd_drc_mem_used -= mem;
> +	spin_unlock(&nfsd_drc_lock);
> +	free_session_slots(ses);
> +	kfree(ses);
> +}
> +
> +
>  static __be32 alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp, struct nfsd4_create_session *cses)
>  {
>  	struct nfsd4_session *new;
>  	struct nfsd4_channel_attrs *fchan = &cses->fore_channel;
>  	int numslots, slotsize;
> +	int status;
>  	int idx;
>  
>  	/*
> @@ -654,6 +701,8 @@ static __be32 alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp
>  	memcpy(clp->cl_sessionid.data, new->se_sessionid.data,
>  	       NFS4_MAX_SESSIONID_LEN);
>  
> +	INIT_LIST_HEAD(&new->se_conns);
> +
>  	new->se_flags = cses->flags;
>  	kref_init(&new->se_ref);
>  	idx = hash_sessionid(&new->se_sessionid);
> @@ -662,6 +711,11 @@ static __be32 alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp
>  	list_add(&new->se_perclnt, &clp->cl_sessions);
>  	spin_unlock(&client_lock);
>  
> +	status = nfsd4_new_conn(rqstp, new);
> +	if (status) {
> +		free_session(&new->se_ref);
> +		return nfserr_jukebox;

why not return status?

> +	}
>  	return nfs_ok;
>  }
>  
> @@ -694,21 +748,6 @@ unhash_session(struct nfsd4_session *ses)
>  	list_del(&ses->se_perclnt);
>  }
>  
> -void
> -free_session(struct kref *kref)
> -{
> -	struct nfsd4_session *ses;
> -	int mem;
> -
> -	ses = container_of(kref, struct nfsd4_session, se_ref);
> -	spin_lock(&nfsd_drc_lock);
> -	mem = ses->se_fchannel.maxreqs * slot_bytes(&ses->se_fchannel);
> -	nfsd_drc_mem_used -= mem;
> -	spin_unlock(&nfsd_drc_lock);
> -	free_session_slots(ses);
> -	kfree(ses);
> -}
> -
>  /* must be called under the client_lock */
>  static inline void
>  renew_client_locked(struct nfs4_client *clp)
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index 58bc2a6..29413c2 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -152,6 +152,13 @@ struct nfsd4_clid_slot {
>  	struct nfsd4_create_session	sl_cr_ses;
>  };
>  
> +struct nfsd4_conn {
> +	struct list_head cn_persession;
> +	struct svc_xprt *cn_xprt;
> +/* CDFC4_FORE, CDFC4_BACK: */
> +	unsigned char cn_flags;
> +};
> +
>  struct nfsd4_session {
>  	struct kref		se_ref;
>  	struct list_head	se_hash;	/* hash by sessionid */
> @@ -161,6 +168,7 @@ struct nfsd4_session {
>  	struct nfs4_sessionid	se_sessionid;
>  	struct nfsd4_channel_attrs se_fchannel;
>  	struct nfsd4_channel_attrs se_bchannel;
> +	struct list_head	se_conns;
>  	struct nfsd4_slot	*se_slots[];	/* forward channel slots */
>  };
>  
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index 07e40c6..79b15fb 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -61,6 +61,9 @@
>  #define NFS4_SHARE_SIGNAL_DELEG_WHEN_RESRC_AVAIL	0x10000
>  #define NFS4_SHARE_PUSH_DELEG_WHEN_UNCONTENDED		0x20000
>  
> +#define NFS4_CDFC4_FORE	0x1
> +#define NFS4_CDFC4_BACK 0x2
> +

nit: I think that defining flags shifted bits is clearer, e.g.:

enum nfsd4_channel_dir {
	NFS4_CDFC4_FORE	 = 1 << 0,
	NFS4_CDFC4_BACK = 1 << 1,
};

Benny

>  #define NFS4_SET_TO_SERVER_TIME	0
>  #define NFS4_SET_TO_CLIENT_TIME	1
>  
