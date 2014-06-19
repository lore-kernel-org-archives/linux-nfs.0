Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:36698 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757959AbaFSOvV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:51:21 -0400
Received: by mail-qc0-f169.google.com with SMTP id c9so2285624qcz.28
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:51:20 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 016/104] NFSd: Don't get a session reference without a client reference
Date: Thu, 19 Jun 2014 10:49:22 -0400
Message-Id: <1403189450-18729-17-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

If the client were to disappear from underneath us while we're holding
a session reference, things would be bad. This cleanup ensures that
it cannot.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 112 +++++++++++++++++++++++++++++++---------------------
 fs/nfsd/state.h     |   2 -
 2 files changed, 68 insertions(+), 46 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 20e23dbf39e5..bd753abdc405 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -102,12 +102,6 @@ static bool is_session_dead(struct nfsd4_session *ses)
 	return ses->se_flags & NFS4_SESSION_DEAD;
 }
 
-void nfsd4_put_session(struct nfsd4_session *ses)
-{
-	if (atomic_dec_and_test(&ses->se_ref) && is_session_dead(ses))
-		free_session(ses);
-}
-
 static __be32 mark_session_dead_locked(struct nfsd4_session *ses, int ref_held_by_me)
 {
 	if (atomic_read(&ses->se_ref) > ref_held_by_me)
@@ -116,14 +110,6 @@ static __be32 mark_session_dead_locked(struct nfsd4_session *ses, int ref_held_b
 	return nfs_ok;
 }
 
-static __be32 nfsd4_get_session_locked(struct nfsd4_session *ses)
-{
-	if (is_session_dead(ses))
-		return nfserr_badsession;
-	atomic_inc(&ses->se_ref);
-	return nfs_ok;
-}
-
 void
 nfs4_unlock_state(void)
 {
@@ -202,6 +188,39 @@ static void put_client_renew_locked(struct nfs4_client *clp)
 		renew_client_locked(clp);
 }
 
+static __be32 nfsd4_get_session_locked(struct nfsd4_session *ses)
+{
+	__be32 status;
+
+	if (is_session_dead(ses))
+		return nfserr_badsession;
+	status = get_client_locked(ses->se_client);
+	if (status)
+		return status;
+	atomic_inc(&ses->se_ref);
+	return nfs_ok;
+}
+
+static void nfsd4_put_session_locked(struct nfsd4_session *ses)
+{
+	struct nfs4_client *clp = ses->se_client;
+
+	if (atomic_dec_and_test(&ses->se_ref) && is_session_dead(ses))
+		free_session(ses);
+	put_client_renew_locked(clp);
+}
+
+static void nfsd4_put_session(struct nfsd4_session *ses)
+{
+	struct nfs4_client *clp = ses->se_client;
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+
+	spin_lock(&nn->client_lock);
+	nfsd4_put_session_locked(ses);
+	spin_unlock(&nn->client_lock);
+}
+
+
 static inline u32
 opaque_hashval(const void *ptr, int nbytes)
 {
@@ -1154,7 +1173,7 @@ static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, stru
 
 /* caller must hold client_lock */
 static struct nfsd4_session *
-find_in_sessionid_hashtbl(struct nfs4_sessionid *sessionid, struct net *net)
+__find_in_sessionid_hashtbl(struct nfs4_sessionid *sessionid, struct net *net)
 {
 	struct nfsd4_session *elem;
 	int idx;
@@ -1174,6 +1193,24 @@ find_in_sessionid_hashtbl(struct nfs4_sessionid *sessionid, struct net *net)
 	return NULL;
 }
 
+static struct nfsd4_session *
+find_in_sessionid_hashtbl(struct nfs4_sessionid *sessionid, struct net *net,
+		__be32 *ret)
+{
+	struct nfsd4_session *session;
+	__be32 status = nfserr_badsession;
+
+	session = __find_in_sessionid_hashtbl(sessionid, net);
+	if (!session)
+		goto out;
+	status = nfsd4_get_session_locked(session);
+	if (status)
+		session = NULL;
+out:
+	*ret = status;
+	return session;
+}
+
 /* caller must hold client_lock */
 static void
 unhash_session(struct nfsd4_session *ses)
@@ -2194,17 +2231,17 @@ __be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
 	__be32 status;
 	struct nfsd4_conn *conn;
 	struct nfsd4_session *session;
-	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+	struct net *net = SVC_NET(rqstp);
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	if (!nfsd4_last_compound_op(rqstp))
 		return nfserr_not_only_op;
 	nfs4_lock_state();
 	spin_lock(&nn->client_lock);
-	session = find_in_sessionid_hashtbl(&bcts->sessionid, SVC_NET(rqstp));
+	session = find_in_sessionid_hashtbl(&bcts->sessionid, net, &status);
 	spin_unlock(&nn->client_lock);
-	status = nfserr_badsession;
 	if (!session)
-		goto out;
+		goto out_no_session;
 	status = nfserr_wrong_cred;
 	if (!mach_creds_match(session->se_client, rqstp))
 		goto out;
@@ -2218,6 +2255,8 @@ __be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
 	nfsd4_init_conn(rqstp, conn, session);
 	status = nfs_ok;
 out:
+	nfsd4_put_session(session);
+out_no_session:
 	nfs4_unlock_state();
 	return status;
 }
@@ -2237,7 +2276,8 @@ nfsd4_destroy_session(struct svc_rqst *r,
 	struct nfsd4_session *ses;
 	__be32 status;
 	int ref_held_by_me = 0;
-	struct nfsd_net *nn = net_generic(SVC_NET(r), nfsd_net_id);
+	struct net *net = SVC_NET(r);
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	nfs4_lock_state();
 	status = nfserr_not_only_op;
@@ -2248,14 +2288,12 @@ nfsd4_destroy_session(struct svc_rqst *r,
 	}
 	dump_sessionid(__func__, &sessionid->sessionid);
 	spin_lock(&nn->client_lock);
-	ses = find_in_sessionid_hashtbl(&sessionid->sessionid, SVC_NET(r));
-	status = nfserr_badsession;
+	ses = find_in_sessionid_hashtbl(&sessionid->sessionid, net, &status);
 	if (!ses)
 		goto out_client_lock;
 	status = nfserr_wrong_cred;
 	if (!mach_creds_match(ses->se_client, r))
-		goto out_client_lock;
-	nfsd4_get_session_locked(ses);
+		goto out_put_session;
 	status = mark_session_dead_locked(ses, 1 + ref_held_by_me);
 	if (status)
 		goto out_put_session;
@@ -2267,7 +2305,7 @@ nfsd4_destroy_session(struct svc_rqst *r,
 	spin_lock(&nn->client_lock);
 	status = nfs_ok;
 out_put_session:
-	nfsd4_put_session(ses);
+	nfsd4_put_session_locked(ses);
 out_client_lock:
 	spin_unlock(&nn->client_lock);
 out:
@@ -2342,7 +2380,8 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	struct nfsd4_conn *conn;
 	__be32 status;
 	int buflen;
-	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+	struct net *net = SVC_NET(rqstp);
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	if (resp->opcnt != 1)
 		return nfserr_sequence_pos;
@@ -2356,17 +2395,10 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 		return nfserr_jukebox;
 
 	spin_lock(&nn->client_lock);
-	status = nfserr_badsession;
-	session = find_in_sessionid_hashtbl(&seq->sessionid, SVC_NET(rqstp));
+	session = find_in_sessionid_hashtbl(&seq->sessionid, net, &status);
 	if (!session)
 		goto out_no_session;
 	clp = session->se_client;
-	status = get_client_locked(clp);
-	if (status)
-		goto out_no_session;
-	status = nfsd4_get_session_locked(session);
-	if (status)
-		goto out_put_client;
 
 	status = nfserr_too_many_ops;
 	if (nfsd4_session_too_many_ops(rqstp, session))
@@ -2450,9 +2482,7 @@ out_no_session:
 	spin_unlock(&nn->client_lock);
 	return status;
 out_put_session:
-	nfsd4_put_session(session);
-out_put_client:
-	put_client_renew_locked(clp);
+	nfsd4_put_session_locked(session);
 	goto out_no_session;
 }
 
@@ -2462,18 +2492,12 @@ nfsd4_sequence_done(struct nfsd4_compoundres *resp)
 	struct nfsd4_compound_state *cs = &resp->cstate;
 
 	if (nfsd4_has_session(cs)) {
-		struct nfs4_client *clp = cs->session->se_client;
-		struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
-
 		if (cs->status != nfserr_replay_cache) {
 			nfsd4_store_cache_entry(resp);
 			cs->slot->sl_flags &= ~NFSD4_SLOT_INUSE;
 		}
-		/* Renew the clientid on success and on replay */
-		spin_lock(&nn->client_lock);
+		/* Drop session reference that was taken in nfsd4_sequence() */
 		nfsd4_put_session(cs->session);
-		put_client_renew_locked(clp);
-		spin_unlock(&nn->client_lock);
 	}
 }
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index dee801d67e4a..d928c444f91e 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -212,8 +212,6 @@ struct nfsd4_session {
 	struct nfsd4_slot	*se_slots[];	/* forward channel slots */
 };
 
-extern void nfsd4_put_session(struct nfsd4_session *ses);
-
 /* formatted contents of nfs4_sessionid */
 struct nfsd4_sessionid {
 	clientid_t	clientid;
-- 
1.9.3

