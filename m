Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60990 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753472Ab3CUO4Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Mar 2013 10:56:24 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 8/9] nfsd4: don't destroy in-use clients
Date: Thu, 21 Mar 2013 10:56:19 -0400
Message-Id: <1363877780-28825-9-git-send-email-bfields@redhat.com>
In-Reply-To: <1363877780-28825-1-git-send-email-bfields@redhat.com>
References: <1363877780-28825-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

When a setclientid_confirm or create_session confirms a client after a
client reboot, it also destroys any previous state held by that client.

The shutdown of that previous state must be careful not to free the
client out from under threads processing other requests that refer to
the client.

This is a particular problem in the NFSv4.1 case when we hold a
reference to a session (hence a client) throughout compound processing.

The server attempts to handle this by unhashing the client at the time
it's destroyed, then delaying the final free to the end.  But this still
leaves some races in the current code.

I believe it's simpler just to fail the attempt to destroy the client by
returning NFS4ERR_DELAY.  This is a case that should never happen
anyway.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |  203 +++++++++++++++++++++++++++++++--------------------
 fs/nfsd/nfs4xdr.c   |    2 +-
 fs/nfsd/state.h     |   14 +---
 3 files changed, 127 insertions(+), 92 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0ff616f..2a84a31 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -113,6 +113,90 @@ nfs4_unlock_state(void)
 	mutex_unlock(&client_mutex);
 }
 
+static bool is_client_expired(struct nfs4_client *clp)
+{
+	return clp->cl_time == 0;
+}
+
+static __be32 mark_client_expired_locked(struct nfs4_client *clp)
+{
+	if (atomic_read(&clp->cl_refcount))
+		return nfserr_jukebox;
+	clp->cl_time = 0;
+	return nfs_ok;
+}
+
+static __be32 mark_client_expired(struct nfs4_client *clp)
+{
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+	__be32 ret;
+
+	spin_lock(&nn->client_lock);
+	ret = mark_client_expired_locked(clp);
+	spin_unlock(&nn->client_lock);
+	return ret;
+}
+
+static __be32 get_client_locked(struct nfs4_client *clp)
+{
+	if (is_client_expired(clp))
+		return nfserr_expired;
+	atomic_inc(&clp->cl_refcount);
+	return nfs_ok;
+}
+
+/* must be called under the client_lock */
+static inline void
+renew_client_locked(struct nfs4_client *clp)
+{
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+
+	if (is_client_expired(clp)) {
+		WARN_ON(1);
+		printk("%s: client (clientid %08x/%08x) already expired\n",
+			__func__,
+			clp->cl_clientid.cl_boot,
+			clp->cl_clientid.cl_id);
+		return;
+	}
+
+	dprintk("renewing client (clientid %08x/%08x)\n", 
+			clp->cl_clientid.cl_boot, 
+			clp->cl_clientid.cl_id);
+	list_move_tail(&clp->cl_lru, &nn->client_lru);
+	clp->cl_time = get_seconds();
+}
+
+static inline void
+renew_client(struct nfs4_client *clp)
+{
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+
+	spin_lock(&nn->client_lock);
+	renew_client_locked(clp);
+	spin_unlock(&nn->client_lock);
+}
+
+void put_client_renew_locked(struct nfs4_client *clp)
+{
+	if (!atomic_dec_and_test(&clp->cl_refcount))
+		return;
+	if (!is_client_expired(clp))
+		renew_client_locked(clp);
+}
+
+void put_client_renew(struct nfs4_client *clp)
+{
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+
+	if (!atomic_dec_and_lock(&clp->cl_refcount, &nn->client_lock))
+		return;
+	if (!is_client_expired(clp))
+		renew_client_locked(clp);
+	spin_unlock(&nn->client_lock);
+}
+
+
 static inline u32
 opaque_hashval(const void *ptr, int nbytes)
 {
@@ -968,38 +1052,6 @@ unhash_session(struct nfsd4_session *ses)
 	spin_unlock(&ses->se_client->cl_lock);
 }
 
-/* must be called under the client_lock */
-static inline void
-renew_client_locked(struct nfs4_client *clp)
-{
-	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
-
-	if (is_client_expired(clp)) {
-		WARN_ON(1);
-		printk("%s: client (clientid %08x/%08x) already expired\n",
-			__func__,
-			clp->cl_clientid.cl_boot,
-			clp->cl_clientid.cl_id);
-		return;
-	}
-
-	dprintk("renewing client (clientid %08x/%08x)\n", 
-			clp->cl_clientid.cl_boot, 
-			clp->cl_clientid.cl_id);
-	list_move_tail(&clp->cl_lru, &nn->client_lru);
-	clp->cl_time = get_seconds();
-}
-
-static inline void
-renew_client(struct nfs4_client *clp)
-{
-	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
-
-	spin_lock(&nn->client_lock);
-	renew_client_locked(clp);
-	spin_unlock(&nn->client_lock);
-}
-
 /* SETCLIENTID and SETCLIENTID_CONFIRM Helper functions */
 static int
 STALE_CLIENTID(clientid_t *clid, struct nfsd_net *nn)
@@ -1051,29 +1103,12 @@ free_client(struct nfs4_client *clp)
 	kfree(clp);
 }
 
-void
-release_session_client(struct nfsd4_session *session)
-{
-	struct nfs4_client *clp = session->se_client;
-	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
-
-	if (!atomic_dec_and_lock(&clp->cl_refcount, &nn->client_lock))
-		return;
-	if (is_client_expired(clp)) {
-		free_client(clp);
-		session->se_client = NULL;
-	} else
-		renew_client_locked(clp);
-	spin_unlock(&nn->client_lock);
-}
-
 /* must be called under the client_lock */
 static inline void
 unhash_client_locked(struct nfs4_client *clp)
 {
 	struct nfsd4_session *ses;
 
-	mark_client_expired(clp);
 	list_del(&clp->cl_lru);
 	spin_lock(&clp->cl_lock);
 	list_for_each_entry(ses, &clp->cl_sessions, se_perclnt)
@@ -1115,8 +1150,8 @@ destroy_client(struct nfs4_client *clp)
 		rb_erase(&clp->cl_namenode, &nn->unconf_name_tree);
 	spin_lock(&nn->client_lock);
 	unhash_client_locked(clp);
-	if (atomic_read(&clp->cl_refcount) == 0)
-		free_client(clp);
+	WARN_ON_ONCE(atomic_read(&clp->cl_refcount));
+	free_client(clp);
 	spin_unlock(&nn->client_lock);
 }
 
@@ -1811,8 +1846,12 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 			goto out_free_conn;
 		}
 		old = find_confirmed_client_by_name(&unconf->cl_name, nn);
-		if (old)
+		if (old) {
+			status = mark_client_expired(old);
+			if (status)
+				goto out_free_conn;
 			expire_client(old);
+		}
 		move_to_confirmed(unconf);
 		conf = unconf;
 	} else {
@@ -2010,6 +2049,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 {
 	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	struct nfsd4_session *session;
+	struct nfs4_client *clp;
 	struct nfsd4_slot *slot;
 	struct nfsd4_conn *conn;
 	__be32 status;
@@ -2030,19 +2070,23 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	status = nfserr_badsession;
 	session = find_in_sessionid_hashtbl(&seq->sessionid, SVC_NET(rqstp));
 	if (!session)
-		goto out;
+		goto out_no_session;
+	clp = session->se_client;
+	status = get_client_locked(clp);
+	if (status)
+		goto out_no_session;
 
 	status = nfserr_too_many_ops;
 	if (nfsd4_session_too_many_ops(rqstp, session))
-		goto out;
+		goto out_put_client;
 
 	status = nfserr_req_too_big;
 	if (nfsd4_request_too_big(rqstp, session))
-		goto out;
+		goto out_put_client;
 
 	status = nfserr_badslot;
 	if (seq->slotid >= session->se_fchannel.maxreqs)
-		goto out;
+		goto out_put_client;
 
 	slot = session->se_slots[seq->slotid];
 	dprintk("%s: slotid %d\n", __func__, seq->slotid);
@@ -2057,7 +2101,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	if (status == nfserr_replay_cache) {
 		status = nfserr_seq_misordered;
 		if (!(slot->sl_flags & NFSD4_SLOT_INITIALIZED))
-			goto out;
+			goto out_put_client;
 		cstate->slot = slot;
 		cstate->session = session;
 		/* Return the cached reply status and set cstate->status
@@ -2067,7 +2111,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 		goto out;
 	}
 	if (status)
-		goto out;
+		goto out_put_client;
 
 	nfsd4_sequence_check_conn(conn, session);
 	conn = NULL;
@@ -2084,26 +2128,24 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	cstate->session = session;
 
 out:
-	/* Hold a session reference until done processing the compound. */
-	if (cstate->session) {
-		struct nfs4_client *clp = session->se_client;
-
-		nfsd4_get_session(cstate->session);
-		atomic_inc(&clp->cl_refcount);
-		switch (clp->cl_cb_state) {
-		case NFSD4_CB_DOWN:
-			seq->status_flags = SEQ4_STATUS_CB_PATH_DOWN;
-			break;
-		case NFSD4_CB_FAULT:
-			seq->status_flags = SEQ4_STATUS_BACKCHANNEL_FAULT;
-			break;
-		default:
-			seq->status_flags = 0;
-		}
+	nfsd4_get_session(cstate->session);
+	switch (clp->cl_cb_state) {
+	case NFSD4_CB_DOWN:
+		seq->status_flags = SEQ4_STATUS_CB_PATH_DOWN;
+		break;
+	case NFSD4_CB_FAULT:
+		seq->status_flags = SEQ4_STATUS_BACKCHANNEL_FAULT;
+		break;
+	default:
+		seq->status_flags = 0;
 	}
+out_no_session:
 	kfree(conn);
 	spin_unlock(&nn->client_lock);
 	return status;
+out_put_client:
+	put_client_renew_locked(clp);
+	goto out_no_session;
 }
 
 __be32
@@ -2272,8 +2314,12 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		expire_client(unconf);
 	} else { /* case 3: normal case; new or rebooted client */
 		conf = find_confirmed_client_by_name(&unconf->cl_name, nn);
-		if (conf)
+		if (conf) {
+			status = mark_client_expired(conf);
+			if (status)
+				goto out;
 			expire_client(conf);
+		}
 		move_to_confirmed(unconf);
 		nfsd4_probe_callback(unconf);
 	}
@@ -3185,13 +3231,12 @@ nfs4_laundromat(struct nfsd_net *nn)
 				clientid_val = t;
 			break;
 		}
-		if (atomic_read(&clp->cl_refcount)) {
+		if (mark_client_expired_locked(clp)) {
 			dprintk("NFSD: client in use (clientid %08x)\n",
 				clp->cl_clientid.cl_id);
 			continue;
 		}
-		unhash_client_locked(clp);
-		list_add(&clp->cl_lru, &reaplist);
+		list_move(&clp->cl_lru, &reaplist);
 	}
 	spin_unlock(&nn->client_lock);
 	list_for_each_safe(pos, next, &reaplist) {
@@ -4576,6 +4621,8 @@ nfs4_check_open_reclaim(clientid_t *clid, bool sessions, struct nfsd_net *nn)
 
 u64 nfsd_forget_client(struct nfs4_client *clp, u64 max)
 {
+	if (mark_client_expired(clp))
+		return 0;
 	expire_client(clp);
 	return 1;
 }
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 0116886..5d35941 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3683,7 +3683,7 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 			cs->slot->sl_flags &= ~NFSD4_SLOT_INUSE;
 		}
 		/* Renew the clientid on success and on replay */
-		release_session_client(cs->session);
+		put_client_renew(cs->session->se_client);
 		nfsd4_put_session(cs->session);
 	}
 	return 1;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 1a8c739..07f8a82 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -286,18 +286,6 @@ struct nfs4_client {
 	struct net		*net;
 };
 
-static inline void
-mark_client_expired(struct nfs4_client *clp)
-{
-	clp->cl_time = 0;
-}
-
-static inline bool
-is_client_expired(struct nfs4_client *clp)
-{
-	return clp->cl_time == 0;
-}
-
 /* struct nfs4_client_reset
  * one per old client. Populates reset_str_hashtbl. Filled from conf_id_hashtbl
  * upon lease reset, or from upcall to state_daemon (to read in state
@@ -486,7 +474,7 @@ extern void nfs4_put_delegation(struct nfs4_delegation *dp);
 extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 							struct nfsd_net *nn);
 extern bool nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn);
-extern void release_session_client(struct nfsd4_session *);
+extern void put_client_renew(struct nfs4_client *clp);
 extern void nfsd4_purge_closed_stateid(struct nfs4_stateowner *);
 
 /* nfs4recover operations */
-- 
1.7.9.5

