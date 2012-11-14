Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:25627 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422677Ab2KNPTQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Nov 2012 10:19:16 -0500
Subject: [PATCH v2 07/15] nfsd: make unconf_name_tree per net
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Wed, 14 Nov 2012 18:21:36 +0300
Message-ID: <20121114152136.4708.89742.stgit@localhost.localdomain>
In-Reply-To: <20121114152018.4708.63125.stgit@localhost.localdomain>
References: <20121114152018.4708.63125.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This hash holds nfs4_clients info, which are network namespace aware.
So let's make it allocated per network namespace.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/netns.h     |    4 ++++
 fs/nfsd/nfs4state.c |   42 +++++++++++++++++++-----------------------
 2 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 1ff781f..1e76030 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -50,12 +50,16 @@ struct nfsd_net {
 	 *
 	 * conf_id_hashtbl[], and conf_name_tree hold confirmed
 	 * setclientid_confirmed info.
+	 *
+	 * unconf_str_hastbl[] and unconf_name_tree hold unconfirmed
+	 * setclientid info.
 	 */
 	struct list_head *reclaim_str_hashtbl;
 	int reclaim_str_hashtbl_size;
 	struct list_head *conf_id_hashtbl;
 	struct rb_root conf_name_tree;
 	struct list_head *unconf_id_hashtbl;
+	struct rb_root unconf_name_tree;
 };
 
 extern int nfsd_net_id;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b967804..c38fea9 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -404,9 +404,6 @@ static unsigned int clientstr_hashval(const char *name)
 }
 
 /*
- * unconf_id_hashtbl[] and unconf_name_tree hold unconfirmed
- * setclientid info.
- *
  * client_lru holds client queue ordered by nfs4_client.cl_time
  * for lease renewal.
  *
@@ -415,7 +412,6 @@ static unsigned int clientstr_hashval(const char *name)
  *
  * All of the above fields are protected by the client_mutex.
  */
-static struct rb_root unconf_name_tree;
 static struct list_head client_lru;
 static struct list_head close_lru;
 
@@ -1134,7 +1130,7 @@ destroy_client(struct nfs4_client *clp)
 	if (test_bit(NFSD4_CLIENT_CONFIRMED, &clp->cl_flags))
 		rb_erase(&clp->cl_namenode, &nn->conf_name_tree);
 	else
-		rb_erase(&clp->cl_namenode, &unconf_name_tree);
+		rb_erase(&clp->cl_namenode, &nn->unconf_name_tree);
 	spin_lock(&client_lock);
 	unhash_client_locked(clp);
 	if (atomic_read(&clp->cl_refcount) == 0)
@@ -1371,7 +1367,7 @@ add_to_unconfirmed(struct nfs4_client *clp)
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
 	clear_bit(NFSD4_CLIENT_CONFIRMED, &clp->cl_flags);
-	add_clp_to_name_tree(clp, &unconf_name_tree);
+	add_clp_to_name_tree(clp, &nn->unconf_name_tree);
 	idhashval = clientid_hashval(clp->cl_clientid.cl_id);
 	list_add(&clp->cl_idhash, &nn->unconf_id_hashtbl[idhashval]);
 	renew_client(clp);
@@ -1385,7 +1381,7 @@ move_to_confirmed(struct nfs4_client *clp)
 
 	dprintk("NFSD: move_to_confirm nfs4_client %p\n", clp);
 	list_move(&clp->cl_idhash, &nn->conf_id_hashtbl[idhashval]);
-	rb_erase(&clp->cl_namenode, &unconf_name_tree);
+	rb_erase(&clp->cl_namenode, &nn->unconf_name_tree);
 	add_clp_to_name_tree(clp, &nn->conf_name_tree);
 	set_bit(NFSD4_CLIENT_CONFIRMED, &clp->cl_flags);
 	renew_client(clp);
@@ -1436,9 +1432,9 @@ find_confirmed_client_by_name(struct xdr_netobj *name, struct nfsd_net *nn)
 }
 
 static struct nfs4_client *
-find_unconfirmed_client_by_name(struct xdr_netobj *name)
+find_unconfirmed_client_by_name(struct xdr_netobj *name, struct nfsd_net *nn)
 {
-	return find_clp_in_name_tree(name, &unconf_name_tree);
+	return find_clp_in_name_tree(name, &nn->unconf_name_tree);
 }
 
 static void
@@ -1677,7 +1673,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 		goto out;
 	}
 
-	unconf  = find_unconfirmed_client_by_name(&exid->clname);
+	unconf  = find_unconfirmed_client_by_name(&exid->clname, nn);
 	if (unconf) /* case 4, possible retry or client restart */
 		expire_client(unconf);
 
@@ -2239,7 +2235,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			goto out;
 		}
 	}
-	unconf = find_unconfirmed_client_by_name(&clname);
+	unconf = find_unconfirmed_client_by_name(&clname, nn);
 	if (unconf)
 		expire_client(unconf);
 	status = nfserr_jukebox;
@@ -4720,7 +4716,6 @@ nfs4_state_init(void)
 {
 	int i;
 
-	unconf_name_tree = RB_ROOT;
 	for (i = 0; i < SESSION_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&sessionid_hashtbl[i]);
 	for (i = 0; i < FILE_HASH_SIZE; i++) {
@@ -4776,6 +4771,7 @@ static int nfs4_state_start_net(struct net *net)
 		INIT_LIST_HEAD(&nn->unconf_id_hashtbl[i]);
 	}
 	nn->conf_name_tree = RB_ROOT;
+	nn->unconf_name_tree = RB_ROOT;
 
 	return 0;
 
@@ -4791,6 +4787,7 @@ __nfs4_state_shutdown_net(struct net *net)
 	int i;
 	struct nfs4_client *clp = NULL;
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+	struct rb_node *node, *tmp;
 
 	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
 		while (!list_empty(&nn->conf_id_hashtbl[i])) {
@@ -4798,6 +4795,16 @@ __nfs4_state_shutdown_net(struct net *net)
 			destroy_client(clp);
 		}
 	}
+
+	node = rb_first(&nn->unconf_name_tree);
+	while (node != NULL) {
+		tmp = node;
+		node = rb_next(tmp);
+		clp = rb_entry(tmp, struct nfs4_client, cl_namenode);
+		rb_erase(tmp, &nn->unconf_name_tree);
+		destroy_client(clp);
+	}
+
 	kfree(nn->unconf_id_hashtbl);
 	kfree(nn->conf_id_hashtbl);
 }
@@ -4857,22 +4864,11 @@ out_recovery:
 static void
 __nfs4_state_shutdown(struct net *net)
 {
-	struct nfs4_client *clp = NULL;
 	struct nfs4_delegation *dp = NULL;
 	struct list_head *pos, *next, reaplist;
-	struct rb_node *node, *tmp;
 
 	__nfs4_state_shutdown_net(net);
 
-	node = rb_first(&unconf_name_tree);
-	while (node != NULL) {
-		tmp = node;
-		node = rb_next(tmp);
-		clp = rb_entry(tmp, struct nfs4_client, cl_namenode);
-		rb_erase(tmp, &unconf_name_tree);
-		destroy_client(clp);
-	}
-
 	INIT_LIST_HEAD(&reaplist);
 	spin_lock(&recall_lock);
 	list_for_each_safe(pos, next, &del_recall_lru) {

