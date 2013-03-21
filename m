Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60988 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753371Ab3CUO4Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Mar 2013 10:56:24 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 9/9] nfsd4: don't destroy in-use session
Date: Thu, 21 Mar 2013 10:56:20 -0400
Message-Id: <1363877780-28825-10-git-send-email-bfields@redhat.com>
In-Reply-To: <1363877780-28825-1-git-send-email-bfields@redhat.com>
References: <1363877780-28825-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This changes session destruction to be similar to client destruction in
that attempts to destroy a session while in use (which should be rare
corner cases) result in DELAY.  This simplifies things somewhat and
helps meet a coming 4.2 requirement.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   72 ++++++++++++++++++++++++++++-----------------------
 fs/nfsd/state.h     |    4 ++-
 2 files changed, 43 insertions(+), 33 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2a84a31..6f536dc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -94,17 +94,32 @@ nfs4_lock_state(void)
 	mutex_lock(&client_mutex);
 }
 
-static void free_session(struct kref *);
+static void free_session(struct nfsd4_session *);
 
-/* Must be called under the client_lock */
-static void nfsd4_put_session_locked(struct nfsd4_session *ses)
+void nfsd4_put_session(struct nfsd4_session *ses)
+{
+	atomic_dec(&ses->se_ref);
+}
+
+static bool is_session_dead(struct nfsd4_session *ses)
 {
-	kref_put(&ses->se_ref, free_session);
+	return ses->se_flags & NFS4_SESSION_DEAD;
+}
+
+static __be32 mark_session_dead_locked(struct nfsd4_session *ses)
+{
+	if (atomic_read(&ses->se_ref))
+		return nfserr_jukebox;
+	ses->se_flags |= NFS4_SESSION_DEAD;
+	return nfs_ok;
 }
 
-static void nfsd4_get_session(struct nfsd4_session *ses)
+static __be32 nfsd4_get_session_locked(struct nfsd4_session *ses)
 {
-	kref_get(&ses->se_ref);
+	if (is_session_dead(ses))
+		return nfserr_badsession;
+	atomic_inc(&ses->se_ref);
+	return nfs_ok;
 }
 
 void
@@ -935,28 +950,15 @@ static void __free_session(struct nfsd4_session *ses)
 	kfree(ses);
 }
 
-static void free_session(struct kref *kref)
+static void free_session(struct nfsd4_session *ses)
 {
-	struct nfsd4_session *ses;
-	struct nfsd_net *nn;
-
-	ses = container_of(kref, struct nfsd4_session, se_ref);
-	nn = net_generic(ses->se_client->net, nfsd_net_id);
+	struct nfsd_net *nn = net_generic(ses->se_client->net, nfsd_net_id);
 
 	lockdep_assert_held(&nn->client_lock);
 	nfsd4_del_conns(ses);
 	__free_session(ses);
 }
 
-void nfsd4_put_session(struct nfsd4_session *ses)
-{
-	struct nfsd_net *nn = net_generic(ses->se_client->net, nfsd_net_id);
-
-	spin_lock(&nn->client_lock);
-	nfsd4_put_session_locked(ses);
-	spin_unlock(&nn->client_lock);
-}
-
 static struct nfsd4_session *alloc_session(struct nfsd4_channel_attrs *fchan,
 					   struct nfsd_net *nn)
 {
@@ -997,7 +999,7 @@ static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, stru
 	new->se_flags = cses->flags;
 	new->se_cb_prog = cses->callback_prog;
 	new->se_cb_sec = cses->cb_sec;
-	kref_init(&new->se_ref);
+	atomic_set(&new->se_ref, 0);
 	idx = hash_sessionid(&new->se_sessionid);
 	spin_lock(&nn->client_lock);
 	list_add(&new->se_hash, &nn->sessionid_hashtbl[idx]);
@@ -1095,7 +1097,8 @@ free_client(struct nfs4_client *clp)
 		ses = list_entry(clp->cl_sessions.next, struct nfsd4_session,
 				se_perclnt);
 		list_del(&ses->se_perclnt);
-		nfsd4_put_session_locked(ses);
+		WARN_ON_ONCE(atomic_read(&ses->se_ref));
+		free_session(ses);
 	}
 	free_svc_cred(&clp->cl_cred);
 	kfree(clp->cl_name.data);
@@ -1976,15 +1979,16 @@ nfsd4_destroy_session(struct svc_rqst *r,
 	status = nfserr_badsession;
 	if (!ses)
 		goto out_client_lock;
-
+	status = mark_session_dead_locked(ses);
+	if (status)
+		goto out_client_lock;
 	unhash_session(ses);
 	spin_unlock(&nn->client_lock);
 
 	nfsd4_probe_callback_sync(ses->se_client);
 
 	spin_lock(&nn->client_lock);
-	nfsd4_del_conns(ses);
-	nfsd4_put_session_locked(ses);
+	free_session(ses);
 	status = nfs_ok;
 out_client_lock:
 	spin_unlock(&nn->client_lock);
@@ -2075,18 +2079,21 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	status = get_client_locked(clp);
 	if (status)
 		goto out_no_session;
+	status = nfsd4_get_session_locked(session);
+	if (status)
+		goto out_put_client;
 
 	status = nfserr_too_many_ops;
 	if (nfsd4_session_too_many_ops(rqstp, session))
-		goto out_put_client;
+		goto out_put_session;
 
 	status = nfserr_req_too_big;
 	if (nfsd4_request_too_big(rqstp, session))
-		goto out_put_client;
+		goto out_put_session;
 
 	status = nfserr_badslot;
 	if (seq->slotid >= session->se_fchannel.maxreqs)
-		goto out_put_client;
+		goto out_put_session;
 
 	slot = session->se_slots[seq->slotid];
 	dprintk("%s: slotid %d\n", __func__, seq->slotid);
@@ -2101,7 +2108,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	if (status == nfserr_replay_cache) {
 		status = nfserr_seq_misordered;
 		if (!(slot->sl_flags & NFSD4_SLOT_INITIALIZED))
-			goto out_put_client;
+			goto out_put_session;
 		cstate->slot = slot;
 		cstate->session = session;
 		/* Return the cached reply status and set cstate->status
@@ -2111,7 +2118,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 		goto out;
 	}
 	if (status)
-		goto out_put_client;
+		goto out_put_session;
 
 	nfsd4_sequence_check_conn(conn, session);
 	conn = NULL;
@@ -2128,7 +2135,6 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	cstate->session = session;
 
 out:
-	nfsd4_get_session(cstate->session);
 	switch (clp->cl_cb_state) {
 	case NFSD4_CB_DOWN:
 		seq->status_flags = SEQ4_STATUS_CB_PATH_DOWN;
@@ -2143,6 +2149,8 @@ out_no_session:
 	kfree(conn);
 	spin_unlock(&nn->client_lock);
 	return status;
+out_put_session:
+	nfsd4_put_session(session);
 out_put_client:
 	put_client_renew_locked(clp);
 	goto out_no_session;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 07f8a82..f6ae4db 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -194,9 +194,11 @@ struct nfsd4_conn {
 };
 
 struct nfsd4_session {
-	struct kref		se_ref;
+	atomic_t		se_ref;
 	struct list_head	se_hash;	/* hash by sessionid */
 	struct list_head	se_perclnt;
+/* See SESSION4_PERSIST, etc. for standard flags; this is internal-only: */
+#define NFS4_SESSION_DEAD	0x010
 	u32			se_flags;
 	struct nfs4_client	*se_client;
 	struct nfs4_sessionid	se_sessionid;
-- 
1.7.9.5

