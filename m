Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:9093 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755021Ab2KZMTr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 07:19:47 -0500
Subject: [PATCH 1/5] nfsd: make client_lock per net
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Mon, 26 Nov 2012 15:21:58 +0300
Message-ID: <20121126122158.955.18686.stgit@localhost.localdomain>
In-Reply-To: <20121126121907.955.25349.stgit@localhost.localdomain>
References: <20121126121907.955.25349.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This lock protects the client lru list and session hash table, which are
allocated per network namespace already.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/netns.h     |    3 ++
 fs/nfsd/nfs4state.c |   73 ++++++++++++++++++++++++++++++---------------------
 2 files changed, 46 insertions(+), 30 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 227b93e..08d5fa1 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -81,6 +81,9 @@ struct nfsd_net {
 	struct list_head close_lru;
 
 	struct delayed_work laundromat_work;
+
+	/* client_lock protects the client lru list and session hash table */
+	spinlock_t client_lock;
 };
 
 extern int nfsd_net_id;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d41cc71..bf6edeb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -388,9 +388,6 @@ unhash_delegation(struct nfs4_delegation *dp)
  * SETCLIENTID state 
  */
 
-/* client_lock protects the client lru list and session hash table */
-static DEFINE_SPINLOCK(client_lock);
-
 static unsigned int clientid_hashval(u32 id)
 {
 	return id & CLIENT_HASH_MASK;
@@ -871,18 +868,23 @@ static void __free_session(struct nfsd4_session *ses)
 static void free_session(struct kref *kref)
 {
 	struct nfsd4_session *ses;
+	struct nfsd_net *nn;
 
-	lockdep_assert_held(&client_lock);
 	ses = container_of(kref, struct nfsd4_session, se_ref);
+	nn = net_generic(ses->se_client->net, nfsd_net_id);
+
+	lockdep_assert_held(&nn->client_lock);
 	nfsd4_del_conns(ses);
 	__free_session(ses);
 }
 
 void nfsd4_put_session(struct nfsd4_session *ses)
 {
-	spin_lock(&client_lock);
+	struct nfsd_net *nn = net_generic(ses->se_client->net, nfsd_net_id);
+
+	spin_lock(&nn->client_lock);
 	nfsd4_put_session_locked(ses);
-	spin_unlock(&client_lock);
+	spin_unlock(&nn->client_lock);
 }
 
 static struct nfsd4_session *alloc_session(struct nfsd4_channel_attrs *fchan)
@@ -926,12 +928,12 @@ static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, stru
 	new->se_cb_sec = cses->cb_sec;
 	kref_init(&new->se_ref);
 	idx = hash_sessionid(&new->se_sessionid);
-	spin_lock(&client_lock);
+	spin_lock(&nn->client_lock);
 	list_add(&new->se_hash, &nn->sessionid_hashtbl[idx]);
 	spin_lock(&clp->cl_lock);
 	list_add(&new->se_perclnt, &clp->cl_sessions);
 	spin_unlock(&clp->cl_lock);
-	spin_unlock(&client_lock);
+	spin_unlock(&nn->client_lock);
 
 	if (cses->flags & SESSION4_BACK_CHAN) {
 		struct sockaddr *sa = svc_addr(rqstp);
@@ -1004,9 +1006,11 @@ renew_client_locked(struct nfs4_client *clp)
 static inline void
 renew_client(struct nfs4_client *clp)
 {
-	spin_lock(&client_lock);
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+
+	spin_lock(&nn->client_lock);
 	renew_client_locked(clp);
-	spin_unlock(&client_lock);
+	spin_unlock(&nn->client_lock);
 }
 
 /* SETCLIENTID and SETCLIENTID_CONFIRM Helper functions */
@@ -1044,7 +1048,9 @@ static struct nfs4_client *alloc_client(struct xdr_netobj name)
 static inline void
 free_client(struct nfs4_client *clp)
 {
-	lockdep_assert_held(&client_lock);
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+
+	lockdep_assert_held(&nn->client_lock);
 	while (!list_empty(&clp->cl_sessions)) {
 		struct nfsd4_session *ses;
 		ses = list_entry(clp->cl_sessions.next, struct nfsd4_session,
@@ -1061,15 +1067,16 @@ void
 release_session_client(struct nfsd4_session *session)
 {
 	struct nfs4_client *clp = session->se_client;
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
-	if (!atomic_dec_and_lock(&clp->cl_refcount, &client_lock))
+	if (!atomic_dec_and_lock(&clp->cl_refcount, &nn->client_lock))
 		return;
 	if (is_client_expired(clp)) {
 		free_client(clp);
 		session->se_client = NULL;
 	} else
 		renew_client_locked(clp);
-	spin_unlock(&client_lock);
+	spin_unlock(&nn->client_lock);
 }
 
 /* must be called under the client_lock */
@@ -1118,11 +1125,11 @@ destroy_client(struct nfs4_client *clp)
 		rb_erase(&clp->cl_namenode, &nn->conf_name_tree);
 	else
 		rb_erase(&clp->cl_namenode, &nn->unconf_name_tree);
-	spin_lock(&client_lock);
+	spin_lock(&nn->client_lock);
 	unhash_client_locked(clp);
 	if (atomic_read(&clp->cl_refcount) == 0)
 		free_client(clp);
-	spin_unlock(&client_lock);
+	spin_unlock(&nn->client_lock);
 }
 
 static void expire_client(struct nfs4_client *clp)
@@ -1273,6 +1280,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
 	struct sockaddr *sa = svc_addr(rqstp);
 	int ret;
 	struct net *net = SVC_NET(rqstp);
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	clp = alloc_client(name);
 	if (clp == NULL)
@@ -1281,9 +1289,9 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
 	INIT_LIST_HEAD(&clp->cl_sessions);
 	ret = copy_cred(&clp->cl_cred, &rqstp->rq_cred);
 	if (ret) {
-		spin_lock(&client_lock);
+		spin_lock(&nn->client_lock);
 		free_client(clp);
-		spin_unlock(&client_lock);
+		spin_unlock(&nn->client_lock);
 		return NULL;
 	}
 	idr_init(&clp->cl_stateids);
@@ -1873,11 +1881,12 @@ static __be32 nfsd4_map_bcts_dir(u32 *dir)
 __be32 nfsd4_backchannel_ctl(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, struct nfsd4_backchannel_ctl *bc)
 {
 	struct nfsd4_session *session = cstate->session;
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
-	spin_lock(&client_lock);
+	spin_lock(&nn->client_lock);
 	session->se_cb_prog = bc->bc_cb_program;
 	session->se_cb_sec = bc->bc_cb_sec;
-	spin_unlock(&client_lock);
+	spin_unlock(&nn->client_lock);
 
 	nfsd4_probe_callback(session->se_client);
 
@@ -1890,10 +1899,11 @@ __be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
 {
 	__be32 status;
 	struct nfsd4_conn *conn;
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
 	if (!nfsd4_last_compound_op(rqstp))
 		return nfserr_not_only_op;
-	spin_lock(&client_lock);
+	spin_lock(&nn->client_lock);
 	cstate->session = find_in_sessionid_hashtbl(&bcts->sessionid, SVC_NET(rqstp));
 	/* Sorta weird: we only need the refcnt'ing because new_conn acquires
 	 * client_lock iself: */
@@ -1901,7 +1911,7 @@ __be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
 		nfsd4_get_session(cstate->session);
 		atomic_inc(&cstate->session->se_client->cl_refcount);
 	}
-	spin_unlock(&client_lock);
+	spin_unlock(&nn->client_lock);
 	if (!cstate->session)
 		return nfserr_badsession;
 
@@ -1929,6 +1939,7 @@ nfsd4_destroy_session(struct svc_rqst *r,
 {
 	struct nfsd4_session *ses;
 	__be32 status = nfserr_badsession;
+	struct nfsd_net *nn = net_generic(SVC_NET(r), nfsd_net_id);
 
 	/* Notes:
 	 * - The confirmed nfs4_client->cl_sessionid holds destroyed sessinid
@@ -1942,24 +1953,24 @@ nfsd4_destroy_session(struct svc_rqst *r,
 			return nfserr_not_only_op;
 	}
 	dump_sessionid(__func__, &sessionid->sessionid);
-	spin_lock(&client_lock);
+	spin_lock(&nn->client_lock);
 	ses = find_in_sessionid_hashtbl(&sessionid->sessionid, SVC_NET(r));
 	if (!ses) {
-		spin_unlock(&client_lock);
+		spin_unlock(&nn->client_lock);
 		goto out;
 	}
 
 	unhash_session(ses);
-	spin_unlock(&client_lock);
+	spin_unlock(&nn->client_lock);
 
 	nfs4_lock_state();
 	nfsd4_probe_callback_sync(ses->se_client);
 	nfs4_unlock_state();
 
-	spin_lock(&client_lock);
+	spin_lock(&nn->client_lock);
 	nfsd4_del_conns(ses);
 	nfsd4_put_session_locked(ses);
-	spin_unlock(&client_lock);
+	spin_unlock(&nn->client_lock);
 	status = nfs_ok;
 out:
 	dprintk("%s returns %d\n", __func__, ntohl(status));
@@ -2025,6 +2036,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	struct nfsd4_slot *slot;
 	struct nfsd4_conn *conn;
 	__be32 status;
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
 	if (resp->opcnt != 1)
 		return nfserr_sequence_pos;
@@ -2037,7 +2049,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	if (!conn)
 		return nfserr_jukebox;
 
-	spin_lock(&client_lock);
+	spin_lock(&nn->client_lock);
 	status = nfserr_badsession;
 	session = find_in_sessionid_hashtbl(&seq->sessionid, SVC_NET(rqstp));
 	if (!session)
@@ -2113,7 +2125,7 @@ out:
 		}
 	}
 	kfree(conn);
-	spin_unlock(&client_lock);
+	spin_unlock(&nn->client_lock);
 	dprintk("%s: return %d\n", __func__, ntohl(status));
 	return status;
 }
@@ -3191,7 +3203,7 @@ nfs4_laundromat(struct nfsd_net *nn)
 	dprintk("NFSD: laundromat service - starting\n");
 	nfsd4_end_grace(nn);
 	INIT_LIST_HEAD(&reaplist);
-	spin_lock(&client_lock);
+	spin_lock(&nn->client_lock);
 	list_for_each_safe(pos, next, &nn->client_lru) {
 		clp = list_entry(pos, struct nfs4_client, cl_lru);
 		if (time_after((unsigned long)clp->cl_time, (unsigned long)cutoff)) {
@@ -3208,7 +3220,7 @@ nfs4_laundromat(struct nfsd_net *nn)
 		unhash_client_locked(clp);
 		list_add(&clp->cl_lru, &reaplist);
 	}
-	spin_unlock(&client_lock);
+	spin_unlock(&nn->client_lock);
 	list_for_each_safe(pos, next, &reaplist) {
 		clp = list_entry(pos, struct nfs4_client, cl_lru);
 		dprintk("NFSD: purging unused client (clientid %08x)\n",
@@ -4792,6 +4804,7 @@ static int nfs4_state_start_net(struct net *net)
 	nn->unconf_name_tree = RB_ROOT;
 	INIT_LIST_HEAD(&nn->client_lru);
 	INIT_LIST_HEAD(&nn->close_lru);
+	spin_lock_init(&nn->client_lock);
 
 	INIT_DELAYED_WORK(&nn->laundromat_work, laundromat_main);
 

