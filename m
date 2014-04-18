Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:53418 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753696AbaDRSpm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:45:42 -0400
Received: by mail-ig0-f181.google.com with SMTP id h18so960009igc.14
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:45:40 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 23/70] NFSd: Don't get a session reference without a client reference
Date: Fri, 18 Apr 2014 14:44:17 -0400
Message-Id: <1397846704-14567-24-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-23-git-send-email-trond.myklebust@primarydata.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the client were to disappear from underneath us while we're holding
a session reference, things would be bad. This cleanup ensures that
it cannot.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 112 +++++++++++++++++++++++++++++++---------------------
 fs/nfsd/state.h     |   2 -
 2 files changed, 68 insertions(+), 46 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9421e56454a2..ab66f73643a9 100644
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
@@ -1119,7 +1138,7 @@ static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, stru
 
 /* caller must hold client_lock */
 static struct nfsd4_session *
-find_in_sessionid_hashtbl(struct nfs4_sessionid *sessionid, struct net *net)
+__find_in_sessionid_hashtbl(struct nfs4_sessionid *sessionid, struct net *net)
 {
 	struct nfsd4_session *elem;
 	int idx;
@@ -1139,6 +1158,24 @@ find_in_sessionid_hashtbl(struct nfs4_sessionid *sessionid, struct net *net)
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
@@ -2152,17 +2189,17 @@ __be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
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
@@ -2176,6 +2213,8 @@ __be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
 	nfsd4_init_conn(rqstp, conn, session);
 	status = nfs_ok;
 out:
+	nfsd4_put_session(session);
+out_no_session:
 	nfs4_unlock_state();
 	return status;
 }
@@ -2195,7 +2234,8 @@ nfsd4_destroy_session(struct svc_rqst *r,
 	struct nfsd4_session *ses;
 	__be32 status;
 	int ref_held_by_me = 0;
-	struct nfsd_net *nn = net_generic(SVC_NET(r), nfsd_net_id);
+	struct net *net = SVC_NET(r);
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	nfs4_lock_state();
 	status = nfserr_not_only_op;
@@ -2206,14 +2246,12 @@ nfsd4_destroy_session(struct svc_rqst *r,
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
@@ -2225,7 +2263,7 @@ nfsd4_destroy_session(struct svc_rqst *r,
 	spin_lock(&nn->client_lock);
 	status = nfs_ok;
 out_put_session:
-	nfsd4_put_session(ses);
+	nfsd4_put_session_locked(ses);
 out_client_lock:
 	spin_unlock(&nn->client_lock);
 out:
@@ -2298,7 +2336,8 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	struct nfsd4_slot *slot;
 	struct nfsd4_conn *conn;
 	__be32 status;
-	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+	struct net *net = SVC_NET(rqstp);
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	if (resp->opcnt != 1)
 		return nfserr_sequence_pos;
@@ -2312,17 +2351,10 @@ nfsd4_sequence(struct svc_rqst *rqstp,
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
@@ -2396,9 +2428,7 @@ out_no_session:
 	spin_unlock(&nn->client_lock);
 	return status;
 out_put_session:
-	nfsd4_put_session(session);
-out_put_client:
-	put_client_renew_locked(clp);
+	nfsd4_put_session_locked(session);
 	goto out_no_session;
 }
 
@@ -2408,18 +2438,12 @@ nfsd4_sequence_done(struct nfsd4_compoundres *resp)
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
index e5444e0aedad..559134675b5a 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -213,8 +213,6 @@ struct nfsd4_session {
 	struct nfsd4_slot	*se_slots[];	/* forward channel slots */
 };
 
-extern void nfsd4_put_session(struct nfsd4_session *ses);
-
 /* formatted contents of nfs4_sessionid */
 struct nfsd4_sessionid {
 	clientid_t	clientid;
-- 
1.9.0

