Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:36893 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754327AbaDRSqk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:46:40 -0400
Received: by mail-ie0-f182.google.com with SMTP id y20so1882175ier.41
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:46:39 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 58/70] NFSd: Protect session creation and client confirm using client_lock
Date: Fri, 18 Apr 2014 14:44:52 -0400
Message-Id: <1397846704-14567-59-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-58-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-8-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-11-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-13-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-14-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-15-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-16-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-17-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-18-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-19-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-20-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-21-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-22-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-23-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-24-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-25-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-26-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-27-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-28-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-29-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-30-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-31-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-32-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-33-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-34-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-35-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-36-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-37-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-38-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-39-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-40-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-41-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-42-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-43-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-44-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-45-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-46-git-send-email-trond.myklebust@primarydata.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In particular, we want to ensure that the move_to_confirmed() is
protected by the nn->client_lock spin lock, so that we can use that
when looking up the clientid etc.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 55 ++++++++++++++++++++++++++++++-----------------------
 1 file changed, 31 insertions(+), 24 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9c24031757d2..f047341678c0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -130,17 +130,6 @@ static __be32 mark_client_expired_locked(struct nfs4_client *clp)
 	return nfs_ok;
 }
 
-static __be32 mark_client_expired(struct nfs4_client *clp)
-{
-	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
-	__be32 ret;
-
-	spin_lock(&nn->client_lock);
-	ret = mark_client_expired_locked(clp);
-	spin_unlock(&nn->client_lock);
-	return ret;
-}
-
 static __be32 get_client_locked(struct nfs4_client *clp)
 {
 	if (is_client_expired(clp))
@@ -1134,12 +1123,10 @@ static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, stru
 	new->se_cb_sec = cses->cb_sec;
 	atomic_set(&new->se_ref, 0);
 	idx = hash_sessionid(&new->se_sessionid);
-	spin_lock(&nn->client_lock);
 	list_add(&new->se_hash, &nn->sessionid_hashtbl[idx]);
 	spin_lock(&clp->cl_lock);
 	list_add(&new->se_perclnt, &clp->cl_sessions);
 	spin_unlock(&clp->cl_lock);
-	spin_unlock(&nn->client_lock);
 
 	if (cses->flags & SESSION4_BACK_CHAN) {
 		struct sockaddr *sa = svc_addr(rqstp);
@@ -2118,6 +2105,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 {
 	struct sockaddr *sa = svc_addr(rqstp);
 	struct nfs4_client *conf, *unconf;
+	struct nfs4_client *old = NULL;
 	struct nfsd4_session *new;
 	struct nfsd4_conn *conn;
 	struct nfsd4_clid_slot *cs_slot = NULL;
@@ -2144,6 +2132,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		goto out_free_session;
 
 	nfs4_lock_state();
+	spin_lock(&nn->client_lock);
 	unconf = find_unconfirmed_client(&cr_ses->clientid, true, nn);
 	conf = find_confirmed_client(&cr_ses->clientid, true, nn);
 	WARN_ON_ONCE(conf && unconf);
@@ -2162,7 +2151,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 			goto out_free_conn;
 		}
 	} else if (unconf) {
-		struct nfs4_client *old;
 		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
 		    !rpc_cmp_addr(sa, (struct sockaddr *) &unconf->cl_addr)) {
 			status = nfserr_clid_inuse;
@@ -2180,10 +2168,10 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		}
 		old = find_confirmed_client_by_name(&unconf->cl_name, nn);
 		if (old) {
-			status = mark_client_expired(old);
+			status = mark_client_expired_locked(old);
 			if (status)
 				goto out_free_conn;
-			expire_client(old);
+			unhash_client_locked(old);
 		}
 		move_to_confirmed(unconf);
 		conf = unconf;
@@ -2199,7 +2187,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	cr_ses->flags &= ~SESSION4_RDMA;
 
 	init_session(rqstp, new, conf, cr_ses);
-	nfsd4_init_conn(rqstp, conn, new);
+	nfsd4_get_session_locked(new);
 
 	memcpy(cr_ses->sessionid.data, new->se_sessionid.data,
 	       NFS4_MAX_SESSIONID_LEN);
@@ -2208,11 +2196,20 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 
 	/* cache solo and embedded create sessions under the state lock */
 	nfsd4_cache_create_session(cr_ses, cs_slot, status);
+	spin_unlock(&nn->client_lock);
+	/* init connection and backchannel */
+	nfsd4_init_conn(rqstp, conn, new);
+	nfsd4_put_session(new);
 	nfs4_unlock_state();
+	if (old)
+		expire_client(old);
 	return status;
 out_free_conn:
+	spin_unlock(&nn->client_lock);
 	nfs4_unlock_state();
 	free_conn(conn);
+	if (old)
+		expire_client(old);
 out_free_session:
 	__free_session(new);
 out_release_drc_mem:
@@ -2657,6 +2654,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 			 struct nfsd4_setclientid_confirm *setclientid_confirm)
 {
 	struct nfs4_client *conf, *unconf;
+	struct nfs4_client *old = NULL;
 	nfs4_verifier confirm = setclientid_confirm->sc_confirm; 
 	clientid_t * clid = &setclientid_confirm->sc_clientid;
 	__be32 status;
@@ -2666,6 +2664,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		return nfserr_stale_clientid;
 	nfs4_lock_state();
 
+	spin_lock(&nn->client_lock);
 	conf = find_confirmed_client(clid, false, nn);
 	unconf = find_unconfirmed_client(clid, false, nn);
 	/*
@@ -2689,21 +2688,29 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 	}
 	status = nfs_ok;
 	if (conf) { /* case 1: callback update */
+		old = unconf;
+		unhash_client_locked(old);
 		nfsd4_change_callback(conf, &unconf->cl_cb_conn);
-		nfsd4_probe_callback(conf);
-		expire_client(unconf);
 	} else { /* case 3: normal case; new or rebooted client */
-		conf = find_confirmed_client_by_name(&unconf->cl_name, nn);
-		if (conf) {
-			status = mark_client_expired(conf);
+		old = find_confirmed_client_by_name(&unconf->cl_name, nn);
+		if (old) {
+			status = mark_client_expired_locked(old);
 			if (status)
 				goto out;
-			expire_client(conf);
+			unhash_client_locked(old);
 		}
 		move_to_confirmed(unconf);
-		nfsd4_probe_callback(unconf);
+		conf = unconf;
 	}
+	get_client_locked(conf);
+	spin_unlock(&nn->client_lock);
+	nfsd4_probe_callback(conf);
+	spin_lock(&nn->client_lock);
+	put_client_renew_locked(conf);
 out:
+	spin_unlock(&nn->client_lock);
+	if (old)
+		expire_client(old);
 	nfs4_unlock_state();
 	return status;
 }
-- 
1.9.0

