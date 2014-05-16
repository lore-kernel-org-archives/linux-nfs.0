Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f48.google.com ([209.85.220.48]:60141 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753813AbaEPSTZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 May 2014 14:19:25 -0400
Received: by mail-pa0-f48.google.com with SMTP id rd3so2851980pab.7
        for <linux-nfs@vger.kernel.org>; Fri, 16 May 2014 11:19:25 -0700 (PDT)
Date: Fri, 16 May 2014 14:19:20 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 58/70] NFSd: Protect session creation and client confirm
 using client_lock
Message-ID: <20140516141920.696928ac@poochiereds.net>
In-Reply-To: <1397846704-14567-59-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-47-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-48-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-49-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-50-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-51-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-52-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-53-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-54-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-55-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-56-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-57-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-58-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-59-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/Q8gsngUcugSZ5AQuu5j1Y9d"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--MP_/Q8gsngUcugSZ5AQuu5j1Y9d
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Fri, 18 Apr 2014 14:44:52 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> In particular, we want to ensure that the move_to_confirmed() is
> protected by the nn->client_lock spin lock, so that we can use that
> when looking up the clientid etc.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 55 ++++++++++++++++++++++++++++++-----------------------
>  1 file changed, 31 insertions(+), 24 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 9c24031757d2..f047341678c0 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -130,17 +130,6 @@ static __be32 mark_client_expired_locked(struct nfs4_client *clp)
>  	return nfs_ok;
>  }
>  
> -static __be32 mark_client_expired(struct nfs4_client *clp)
> -{
> -	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
> -	__be32 ret;
> -
> -	spin_lock(&nn->client_lock);
> -	ret = mark_client_expired_locked(clp);
> -	spin_unlock(&nn->client_lock);
> -	return ret;
> -}
> 

This patch breaks the build when CONFIG_NFSD_FAULT_INJECTION is enabled
as mark_client_expired is still referenced by nfsd_forget_clients. The
attached patch should do the right thing.

Trond, feel free to roll it into your patch on the next iteration.


>  static __be32 get_client_locked(struct nfs4_client *clp)
>  {
>  	if (is_client_expired(clp))
> @@ -1134,12 +1123,10 @@ static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, stru
>  	new->se_cb_sec = cses->cb_sec;
>  	atomic_set(&new->se_ref, 0);
>  	idx = hash_sessionid(&new->se_sessionid);
> -	spin_lock(&nn->client_lock);
>  	list_add(&new->se_hash, &nn->sessionid_hashtbl[idx]);
>  	spin_lock(&clp->cl_lock);
>  	list_add(&new->se_perclnt, &clp->cl_sessions);
>  	spin_unlock(&clp->cl_lock);
> -	spin_unlock(&nn->client_lock);
>  
>  	if (cses->flags & SESSION4_BACK_CHAN) {
>  		struct sockaddr *sa = svc_addr(rqstp);
> @@ -2118,6 +2105,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  {
>  	struct sockaddr *sa = svc_addr(rqstp);
>  	struct nfs4_client *conf, *unconf;
> +	struct nfs4_client *old = NULL;
>  	struct nfsd4_session *new;
>  	struct nfsd4_conn *conn;
>  	struct nfsd4_clid_slot *cs_slot = NULL;
> @@ -2144,6 +2132,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  		goto out_free_session;
>  
>  	nfs4_lock_state();
> +	spin_lock(&nn->client_lock);
>  	unconf = find_unconfirmed_client(&cr_ses->clientid, true, nn);
>  	conf = find_confirmed_client(&cr_ses->clientid, true, nn);
>  	WARN_ON_ONCE(conf && unconf);
> @@ -2162,7 +2151,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  			goto out_free_conn;
>  		}
>  	} else if (unconf) {
> -		struct nfs4_client *old;
>  		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
>  		    !rpc_cmp_addr(sa, (struct sockaddr *) &unconf->cl_addr)) {
>  			status = nfserr_clid_inuse;
> @@ -2180,10 +2168,10 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  		}
>  		old = find_confirmed_client_by_name(&unconf->cl_name, nn);
>  		if (old) {
> -			status = mark_client_expired(old);
> +			status = mark_client_expired_locked(old);
>  			if (status)
>  				goto out_free_conn;
> -			expire_client(old);
> +			unhash_client_locked(old);
>  		}
>  		move_to_confirmed(unconf);
>  		conf = unconf;
> @@ -2199,7 +2187,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  	cr_ses->flags &= ~SESSION4_RDMA;
>  
>  	init_session(rqstp, new, conf, cr_ses);
> -	nfsd4_init_conn(rqstp, conn, new);
> +	nfsd4_get_session_locked(new);
>  
>  	memcpy(cr_ses->sessionid.data, new->se_sessionid.data,
>  	       NFS4_MAX_SESSIONID_LEN);
> @@ -2208,11 +2196,20 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  
>  	/* cache solo and embedded create sessions under the state lock */
>  	nfsd4_cache_create_session(cr_ses, cs_slot, status);
> +	spin_unlock(&nn->client_lock);
> +	/* init connection and backchannel */
> +	nfsd4_init_conn(rqstp, conn, new);
> +	nfsd4_put_session(new);
>  	nfs4_unlock_state();
> +	if (old)
> +		expire_client(old);
>  	return status;
>  out_free_conn:
> +	spin_unlock(&nn->client_lock);
>  	nfs4_unlock_state();
>  	free_conn(conn);
> +	if (old)
> +		expire_client(old);
>  out_free_session:
>  	__free_session(new);
>  out_release_drc_mem:
> @@ -2657,6 +2654,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
>  			 struct nfsd4_setclientid_confirm *setclientid_confirm)
>  {
>  	struct nfs4_client *conf, *unconf;
> +	struct nfs4_client *old = NULL;
>  	nfs4_verifier confirm = setclientid_confirm->sc_confirm; 
>  	clientid_t * clid = &setclientid_confirm->sc_clientid;
>  	__be32 status;
> @@ -2666,6 +2664,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
>  		return nfserr_stale_clientid;
>  	nfs4_lock_state();
>  
> +	spin_lock(&nn->client_lock);
>  	conf = find_confirmed_client(clid, false, nn);
>  	unconf = find_unconfirmed_client(clid, false, nn);
>  	/*
> @@ -2689,21 +2688,29 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
>  	}
>  	status = nfs_ok;
>  	if (conf) { /* case 1: callback update */
> +		old = unconf;
> +		unhash_client_locked(old);
>  		nfsd4_change_callback(conf, &unconf->cl_cb_conn);
> -		nfsd4_probe_callback(conf);
> -		expire_client(unconf);
>  	} else { /* case 3: normal case; new or rebooted client */
> -		conf = find_confirmed_client_by_name(&unconf->cl_name, nn);
> -		if (conf) {
> -			status = mark_client_expired(conf);
> +		old = find_confirmed_client_by_name(&unconf->cl_name, nn);
> +		if (old) {
> +			status = mark_client_expired_locked(old);
>  			if (status)
>  				goto out;
> -			expire_client(conf);
> +			unhash_client_locked(old);
>  		}
>  		move_to_confirmed(unconf);
> -		nfsd4_probe_callback(unconf);
> +		conf = unconf;
>  	}
> +	get_client_locked(conf);
> +	spin_unlock(&nn->client_lock);
> +	nfsd4_probe_callback(conf);
> +	spin_lock(&nn->client_lock);
> +	put_client_renew_locked(conf);
>  out:
> +	spin_unlock(&nn->client_lock);
> +	if (old)
> +		expire_client(old);
>  	nfs4_unlock_state();
>  	return status;
>  }


-- 
Jeff Layton <jlayton@poochiereds.net>

--MP_/Q8gsngUcugSZ5AQuu5j1Y9d
Content-Type: text/x-patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename=0001-nfsd-fix-build-when-CONFIG_NFSD_FAULT_INJECTION-is-e.patch

>From 67ed21725cee08343b25ebec364636110b904c41 Mon Sep 17 00:00:00 2001
From: Jeff Layton <jlayton@primarydata.com>
Date: Fri, 16 May 2014 14:15:04 -0400
Subject: [PATCH] nfsd: fix build when CONFIG_NFSD_FAULT_INJECTION is enabled

The patch entitled:

    NFSd: Protect session creation and client confirm using client_lock

...removes the mark_client_expired function, but doesn't fix the caller
in nfsd_forget_clients. Have that function call
mark_client_expired_locked after taking the cl_lock.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index eedbbcf7be27..f5a7a08728b3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5435,7 +5435,13 @@ nfs4_check_open_reclaim(clientid_t *clid,
 
 u64 nfsd_forget_client(struct nfs4_client *clp, u64 max)
 {
-	if (mark_client_expired(clp))
+	int ret;
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+
+	spin_lock(&nn->client_lock);
+	ret = mark_client_expired_locked(clp);
+	spin_unlock(&nn->client_lock);
+	if (ret)
 		return 0;
 	expire_client(clp);
 	return 1;
-- 
1.9.0


--MP_/Q8gsngUcugSZ5AQuu5j1Y9d--
