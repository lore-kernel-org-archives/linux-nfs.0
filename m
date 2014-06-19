Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:33721 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932295AbaFSOwm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:42 -0400
Received: by mail-qa0-f46.google.com with SMTP id i13so2005378qae.19
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:41 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 072/104] NFSd: Protect session creation and client confirm using client_lock
Date: Thu, 19 Jun 2014 10:50:18 -0400
Message-Id: <1403189450-18729-73-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In particular, we want to ensure that the move_to_confirmed() is
protected by the nn->client_lock spin lock, so that we can use that
when looking up the clientid etc.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 63 ++++++++++++++++++++++++++++++++---------------------
 1 file changed, 38 insertions(+), 25 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1beea0b19744..be84ac190052 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -143,17 +143,6 @@ static __be32 mark_client_expired_locked(struct nfs4_client *clp)
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
@@ -1246,12 +1235,10 @@ static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, stru
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
@@ -2232,6 +2219,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 {
 	struct sockaddr *sa = svc_addr(rqstp);
 	struct nfs4_client *conf, *unconf;
+	struct nfs4_client *old = NULL;
 	struct nfsd4_session *new;
 	struct nfsd4_conn *conn;
 	struct nfsd4_clid_slot *cs_slot = NULL;
@@ -2258,6 +2246,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		goto out_free_session;
 
 	nfs4_lock_state();
+	spin_lock(&nn->client_lock);
 	unconf = find_unconfirmed_client(&cr_ses->clientid, true, nn);
 	conf = find_confirmed_client(&cr_ses->clientid, true, nn);
 	WARN_ON_ONCE(conf && unconf);
@@ -2276,7 +2265,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 			goto out_free_conn;
 		}
 	} else if (unconf) {
-		struct nfs4_client *old;
 		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
 		    !rpc_cmp_addr(sa, (struct sockaddr *) &unconf->cl_addr)) {
 			status = nfserr_clid_inuse;
@@ -2294,10 +2282,10 @@ nfsd4_create_session(struct svc_rqst *rqstp,
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
@@ -2313,7 +2301,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	cr_ses->flags &= ~SESSION4_RDMA;
 
 	init_session(rqstp, new, conf, cr_ses);
-	nfsd4_init_conn(rqstp, conn, new);
+	nfsd4_get_session_locked(new);
 
 	memcpy(cr_ses->sessionid.data, new->se_sessionid.data,
 	       NFS4_MAX_SESSIONID_LEN);
@@ -2322,11 +2310,20 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 
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
@@ -2786,6 +2783,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 			 struct nfsd4_setclientid_confirm *setclientid_confirm)
 {
 	struct nfs4_client *conf, *unconf;
+	struct nfs4_client *old = NULL;
 	nfs4_verifier confirm = setclientid_confirm->sc_confirm; 
 	clientid_t * clid = &setclientid_confirm->sc_clientid;
 	__be32 status;
@@ -2795,6 +2793,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		return nfserr_stale_clientid;
 	nfs4_lock_state();
 
+	spin_lock(&nn->client_lock);
 	conf = find_confirmed_client(clid, false, nn);
 	unconf = find_unconfirmed_client(clid, false, nn);
 	/*
@@ -2818,21 +2817,29 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
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
@@ -5491,7 +5498,13 @@ nfs4_check_open_reclaim(clientid_t *clid,
 
 u64 nfsd_forget_client(struct nfs4_client *clp, u64 max)
 {
-	if (mark_client_expired(clp))
+	__be32 ret;
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+
+	spin_lock(&nn->client_lock);
+	ret = mark_client_expired_locked(clp);
+	spin_unlock(&nn->client_lock);
+	if (ret != nfs_ok)
 		return 0;
 	expire_client(clp);
 	return 1;
-- 
1.9.3

