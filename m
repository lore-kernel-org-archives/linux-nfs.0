Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:61101 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755367Ab2KIUHB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Nov 2012 15:07:01 -0500
Received: by mail-vc0-f174.google.com with SMTP id fk26so4183151vcb.19
        for <linux-nfs@vger.kernel.org>; Fri, 09 Nov 2012 12:07:01 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC 6/7] nfsd: move the confirmed and unconfirmed hlists to a rbtree
Date: Fri,  9 Nov 2012 15:06:43 -0500
Message-Id: <1352491604-21605-7-git-send-email-jlayton@redhat.com>
In-Reply-To: <1352491604-21605-1-git-send-email-jlayton@redhat.com>
References: <1352491604-21605-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current code requires that we md5 hash the name in order to store
the client in the confirmed and unconfirmed trees. Change it instead
to store the clients in a pair of rbtrees, and simply compare the
cl_names directly instead of hashing them. This also necessitates that
we add a new flag to the clp->cl_flags field to indicate which tree
the client is currently in.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c | 144 +++++++++++++++++++++++++++++++++-------------------
 fs/nfsd/state.h     |   3 +-
 2 files changed, 95 insertions(+), 52 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f26a7e6..3894376 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -412,10 +412,10 @@ static unsigned int clientstr_hashval(const char *name)
  * reclaim_str_hashtbl[] holds known client info from previous reset/reboot
  * used in reboot/reset lease grace period processing
  *
- * conf_id_hashtbl[], and conf_str_hashtbl[] hold confirmed
+ * conf_id_hashtbl[], and conf_name_tree hold confirmed
  * setclientid_confirmed info. 
  *
- * unconf_str_hastbl[] and unconf_id_hashtbl[] hold unconfirmed 
+ * unconf_id_hashtbl[] and unconf_name_tree hold unconfirmed
  * setclientid info.
  *
  * client_lru holds client queue ordered by nfs4_client.cl_time
@@ -423,13 +423,15 @@ static unsigned int clientstr_hashval(const char *name)
  *
  * close_lru holds (open) stateowner queue ordered by nfs4_stateowner.so_time
  * for last close replay.
+ *
+ * All of the above fields are protected by the client_mutex.
  */
 static struct list_head	reclaim_str_hashtbl[CLIENT_HASH_SIZE];
 static int reclaim_str_hashtbl_size = 0;
 static struct list_head	conf_id_hashtbl[CLIENT_HASH_SIZE];
-static struct list_head	conf_str_hashtbl[CLIENT_HASH_SIZE];
-static struct list_head	unconf_str_hashtbl[CLIENT_HASH_SIZE];
 static struct list_head	unconf_id_hashtbl[CLIENT_HASH_SIZE];
+static struct rb_root conf_name_tree;
+static struct rb_root unconf_name_tree;
 static struct list_head client_lru;
 static struct list_head close_lru;
 
@@ -1144,7 +1146,10 @@ destroy_client(struct nfs4_client *clp)
 	if (clp->cl_cb_conn.cb_xprt)
 		svc_xprt_put(clp->cl_cb_conn.cb_xprt);
 	list_del(&clp->cl_idhash);
-	list_del(&clp->cl_strhash);
+	if (test_bit(NFSD4_CLIENT_CONFIRMED, &clp->cl_flags))
+		rb_erase(&clp->cl_namenode, &conf_name_tree);
+	else
+		rb_erase(&clp->cl_namenode, &unconf_name_tree);
 	spin_lock(&client_lock);
 	unhash_client_locked(clp);
 	if (atomic_read(&clp->cl_refcount) == 0)
@@ -1187,6 +1192,17 @@ static int copy_cred(struct svc_cred *target, struct svc_cred *source)
 	return 0;
 }
 
+static long
+compare_blob(const struct xdr_netobj *o1, const struct xdr_netobj *o2)
+{
+	long res;
+
+	res = o1->len - o2->len;
+	if (res)
+		return (int)res;
+	return (long)memcmp(o1->data, o2->data, o1->len);
+}
+
 static int same_name(const char *n1, const char *n2)
 {
 	return 0 == memcmp(n1, n2, HEXDIR_LEN);
@@ -1307,7 +1323,6 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
 	atomic_set(&clp->cl_refcount, 0);
 	clp->cl_cb_state = NFSD4_CB_UNKNOWN;
 	INIT_LIST_HEAD(&clp->cl_idhash);
-	INIT_LIST_HEAD(&clp->cl_strhash);
 	INIT_LIST_HEAD(&clp->cl_openowners);
 	INIT_LIST_HEAD(&clp->cl_delegations);
 	INIT_LIST_HEAD(&clp->cl_lru);
@@ -1325,11 +1340,52 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
 }
 
 static void
-add_to_unconfirmed(struct nfs4_client *clp, unsigned int strhashval)
+add_clp_to_name_tree(struct nfs4_client *new_clp, struct rb_root *root)
+{
+	struct rb_node **new = &(root->rb_node), *parent = NULL;
+	struct nfs4_client *clp;
+
+	while (*new) {
+		clp = rb_entry(*new, struct nfs4_client, cl_namenode);
+		parent = *new;
+
+		if (compare_blob(&clp->cl_name, &new_clp->cl_name) > 0)
+			new = &((*new)->rb_left);
+		else
+			new = &((*new)->rb_right);
+	}
+
+	rb_link_node(&new_clp->cl_namenode, parent, new);
+	rb_insert_color(&new_clp->cl_namenode, root);
+}
+
+static struct nfs4_client *
+find_clp_in_name_tree(struct xdr_netobj *name, struct rb_root *root)
+{
+	long cmp;
+	struct rb_node *node = root->rb_node;
+	struct nfs4_client *clp;
+
+	while (node) {
+		clp = rb_entry(node, struct nfs4_client, cl_namenode);
+		cmp = compare_blob(&clp->cl_name, name);
+		if (cmp > 0)
+			node = node->rb_left;
+		else if (cmp < 0)
+			node = node->rb_right;
+		else
+			return clp;
+	}
+	return NULL;
+}
+
+static void
+add_to_unconfirmed(struct nfs4_client *clp)
 {
 	unsigned int idhashval;
 
-	list_add(&clp->cl_strhash, &unconf_str_hashtbl[strhashval]);
+	clear_bit(NFSD4_CLIENT_CONFIRMED, &clp->cl_flags);
+	add_clp_to_name_tree(clp, &unconf_name_tree);
 	idhashval = clientid_hashval(clp->cl_clientid.cl_id);
 	list_add(&clp->cl_idhash, &unconf_id_hashtbl[idhashval]);
 	renew_client(clp);
@@ -1339,12 +1395,12 @@ static void
 move_to_confirmed(struct nfs4_client *clp)
 {
 	unsigned int idhashval = clientid_hashval(clp->cl_clientid.cl_id);
-	unsigned int strhashval;
 
 	dprintk("NFSD: move_to_confirm nfs4_client %p\n", clp);
 	list_move(&clp->cl_idhash, &conf_id_hashtbl[idhashval]);
-	strhashval = clientstr_hashval(clp->cl_recdir);
-	list_move(&clp->cl_strhash, &conf_str_hashtbl[strhashval]);
+	rb_erase(&clp->cl_namenode, &unconf_name_tree);
+	add_clp_to_name_tree(clp, &conf_name_tree);
+	set_bit(NFSD4_CLIENT_CONFIRMED, &clp->cl_flags);
 	renew_client(clp);
 }
 
@@ -1387,27 +1443,15 @@ static bool clp_used_exchangeid(struct nfs4_client *clp)
 } 
 
 static struct nfs4_client *
-find_confirmed_client_by_str(const char *dname, unsigned int hashval)
+find_confirmed_client_by_name(struct xdr_netobj *name)
 {
-	struct nfs4_client *clp;
-
-	list_for_each_entry(clp, &conf_str_hashtbl[hashval], cl_strhash) {
-		if (same_name(clp->cl_recdir, dname))
-			return clp;
-	}
-	return NULL;
+	return find_clp_in_name_tree(name, &conf_name_tree);
 }
 
 static struct nfs4_client *
-find_unconfirmed_client_by_str(const char *dname, unsigned int hashval)
+find_unconfirmed_client_by_name(struct xdr_netobj *name)
 {
-	struct nfs4_client *clp;
-
-	list_for_each_entry(clp, &unconf_str_hashtbl[hashval], cl_strhash) {
-		if (same_name(clp->cl_recdir, dname))
-			return clp;
-	}
-	return NULL;
+	return find_clp_in_name_tree(name, &unconf_name_tree);
 }
 
 static void
@@ -1572,7 +1616,6 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 {
 	struct nfs4_client *unconf, *conf, *new;
 	__be32 status;
-	unsigned int		strhashval;
 	char			dname[HEXDIR_LEN];
 	char			addr_str[INET6_ADDRSTRLEN];
 	nfs4_verifier		verf = exid->verifier;
@@ -1605,11 +1648,9 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 	if (status)
 		return status;
 
-	strhashval = clientstr_hashval(dname);
-
 	/* Cases below refer to rfc 5661 section 18.35.4: */
 	nfs4_lock_state();
-	conf = find_confirmed_client_by_str(dname, strhashval);
+	conf = find_confirmed_client_by_name(&exid->clname);
 	if (conf) {
 		bool creds_match = same_creds(&conf->cl_cred, &rqstp->rq_cred);
 		bool verfs_match = same_verf(&verf, &conf->cl_verifier);
@@ -1654,7 +1695,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 		goto out;
 	}
 
-	unconf  = find_unconfirmed_client_by_str(dname, strhashval);
+	unconf  = find_unconfirmed_client_by_name(&exid->clname);
 	if (unconf) /* case 4, possible retry or client restart */
 		expire_client(unconf);
 
@@ -1668,7 +1709,7 @@ out_new:
 	new->cl_minorversion = 1;
 
 	gen_clid(new);
-	add_to_unconfirmed(new, strhashval);
+	add_to_unconfirmed(new);
 out_copy:
 	exid->clientid.cl_boot = new->cl_clientid.cl_boot;
 	exid->clientid.cl_id = new->cl_clientid.cl_id;
@@ -1789,7 +1830,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 			goto out_free_conn;
 		}
 	} else if (unconf) {
-		unsigned int hash;
 		struct nfs4_client *old;
 		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
 		    !rpc_cmp_addr(sa, (struct sockaddr *) &unconf->cl_addr)) {
@@ -1803,8 +1843,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 			status = nfserr_seq_misordered;
 			goto out_free_conn;
 		}
-		hash = clientstr_hashval(unconf->cl_recdir);
-		old = find_confirmed_client_by_str(unconf->cl_recdir, hash);
+		old = find_confirmed_client_by_name(&unconf->cl_name);
 		if (old)
 			expire_client(old);
 		move_to_confirmed(unconf);
@@ -2181,7 +2220,6 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	struct xdr_netobj 	clname = setclid->se_name;
 	nfs4_verifier		clverifier = setclid->se_verf;
-	unsigned int 		strhashval;
 	struct nfs4_client	*conf, *unconf, *new;
 	__be32 			status;
 	char                    dname[HEXDIR_LEN];
@@ -2190,11 +2228,9 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (status)
 		return status;
 
-	strhashval = clientstr_hashval(dname);
-
 	/* Cases below refer to rfc 3530 section 14.2.33: */
 	nfs4_lock_state();
-	conf = find_confirmed_client_by_str(dname, strhashval);
+	conf = find_confirmed_client_by_name(&clname);
 	if (conf) {
 		/* case 0: */
 		status = nfserr_clid_inuse;
@@ -2209,7 +2245,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			goto out;
 		}
 	}
-	unconf = find_unconfirmed_client_by_str(dname, strhashval);
+	unconf = find_unconfirmed_client_by_name(&clname);
 	if (unconf)
 		expire_client(unconf);
 	status = nfserr_jukebox;
@@ -2223,7 +2259,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		gen_clid(new);
 	new->cl_minorversion = 0;
 	gen_callback(new, setclid, rqstp);
-	add_to_unconfirmed(new, strhashval);
+	add_to_unconfirmed(new);
 	setclid->se_clientid.cl_boot = new->cl_clientid.cl_boot;
 	setclid->se_clientid.cl_id = new->cl_clientid.cl_id;
 	memcpy(setclid->se_confirm.data, new->cl_confirm.data, sizeof(setclid->se_confirm.data));
@@ -2276,9 +2312,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		nfsd4_probe_callback(conf);
 		expire_client(unconf);
 	} else { /* case 3: normal case; new or rebooted client */
-		unsigned int hash = clientstr_hashval(unconf->cl_recdir);
-
-		conf = find_confirmed_client_by_str(unconf->cl_recdir, hash);
+		conf = find_confirmed_client_by_name(&unconf->cl_name);
 		if (conf)
 			expire_client(conf);
 		move_to_confirmed(unconf);
@@ -4687,11 +4721,11 @@ nfs4_state_init(void)
 
 	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&conf_id_hashtbl[i]);
-		INIT_LIST_HEAD(&conf_str_hashtbl[i]);
-		INIT_LIST_HEAD(&unconf_str_hashtbl[i]);
 		INIT_LIST_HEAD(&unconf_id_hashtbl[i]);
 		INIT_LIST_HEAD(&reclaim_str_hashtbl[i]);
 	}
+	conf_name_tree = RB_ROOT;
+	unconf_name_tree = RB_ROOT;
 	for (i = 0; i < SESSION_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&sessionid_hashtbl[i]);
 	for (i = 0; i < FILE_HASH_SIZE; i++) {
@@ -4776,6 +4810,7 @@ out_recovery:
 	return ret;
 }
 
+/* should be called with the state lock held */
 static void
 __nfs4_state_shutdown(void)
 {
@@ -4783,17 +4818,24 @@ __nfs4_state_shutdown(void)
 	struct nfs4_client *clp = NULL;
 	struct nfs4_delegation *dp = NULL;
 	struct list_head *pos, *next, reaplist;
+	struct rb_node *node, *tmp;
 
 	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
 		while (!list_empty(&conf_id_hashtbl[i])) {
 			clp = list_entry(conf_id_hashtbl[i].next, struct nfs4_client, cl_idhash);
 			destroy_client(clp);
 		}
-		while (!list_empty(&unconf_str_hashtbl[i])) {
-			clp = list_entry(unconf_str_hashtbl[i].next, struct nfs4_client, cl_strhash);
-			destroy_client(clp);
-		}
 	}
+
+	node = rb_first(&unconf_name_tree);
+	while (node != NULL) {
+		tmp = node;
+		node = rb_next(tmp);
+		clp = rb_entry(tmp, struct nfs4_client, cl_namenode);
+		rb_erase(tmp, &unconf_name_tree);
+		destroy_client(clp);
+	}
+
 	INIT_LIST_HEAD(&reaplist);
 	spin_lock(&recall_lock);
 	list_for_each_safe(pos, next, &del_recall_lru) {
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index e1b39b9..5ee88bf 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -221,7 +221,7 @@ struct nfsd4_sessionid {
  */
 struct nfs4_client {
 	struct list_head	cl_idhash; 	/* hash by cl_clientid.id */
-	struct list_head	cl_strhash; 	/* hash by cl_name */
+	struct rb_node		cl_namenode;	/* link into by-name trees */
 	struct list_head	cl_openowners;
 	struct idr		cl_stateids;	/* stateid lookup */
 	struct list_head	cl_delegations;
@@ -242,6 +242,7 @@ struct nfs4_client {
 #define NFSD4_CLIENT_CB_KILL		(1)
 #define NFSD4_CLIENT_STABLE		(2)	/* client on stable storage */
 #define NFSD4_CLIENT_RECLAIM_COMPLETE	(3)	/* reclaim_complete done */
+#define NFSD4_CLIENT_CONFIRMED		(4)	/* client is confirmed */
 #define NFSD4_CLIENT_CB_FLAG_MASK	(1 << NFSD4_CLIENT_CB_UPDATE | \
 					 1 << NFSD4_CLIENT_CB_KILL)
 	unsigned long		cl_flags;
-- 
1.7.11.7

