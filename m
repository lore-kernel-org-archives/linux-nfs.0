Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:4531 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964821Ab2KNPSv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Nov 2012 10:18:51 -0500
Subject: [PATCH v2 05/15] nfsd: make conf_name_tree per net
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Wed, 14 Nov 2012 18:21:26 +0300
Message-ID: <20121114152126.4708.32046.stgit@localhost.localdomain>
In-Reply-To: <20121114152018.4708.63125.stgit@localhost.localdomain>
References: <20121114152018.4708.63125.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This tree holds nfs4_clients info, which are network namespace aware.
So let's make it per network namespace.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/netns.h     |    4 ++++
 fs/nfsd/nfs4state.c |   31 ++++++++++++++++---------------
 2 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 0cc85e9..afd9116 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -47,10 +47,14 @@ struct nfsd_net {
 	/*
 	 * reclaim_str_hashtbl[] holds known client info from previous reset/reboot
 	 * used in reboot/reset lease grace period processing
+	 *
+	 * conf_id_hashtbl[], and conf_name_tree hold confirmed
+	 * setclientid_confirmed info.
 	 */
 	struct list_head *reclaim_str_hashtbl;
 	int reclaim_str_hashtbl_size;
 	struct list_head *conf_id_hashtbl;
+	struct rb_root conf_name_tree;
 };
 
 extern int nfsd_net_id;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7b02c47..ff03573 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -404,9 +404,6 @@ static unsigned int clientstr_hashval(const char *name)
 }
 
 /*
- * conf_id_hashtbl[], and conf_name_tree hold confirmed
- * setclientid_confirmed info.
- *
  * unconf_id_hashtbl[] and unconf_name_tree hold unconfirmed
  * setclientid info.
  *
@@ -419,7 +416,6 @@ static unsigned int clientstr_hashval(const char *name)
  * All of the above fields are protected by the client_mutex.
  */
 static struct list_head	unconf_id_hashtbl[CLIENT_HASH_SIZE];
-static struct rb_root conf_name_tree;
 static struct rb_root unconf_name_tree;
 static struct list_head client_lru;
 static struct list_head close_lru;
@@ -1114,6 +1110,7 @@ destroy_client(struct nfs4_client *clp)
 	struct nfs4_openowner *oo;
 	struct nfs4_delegation *dp;
 	struct list_head reaplist;
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
 	INIT_LIST_HEAD(&reaplist);
 	spin_lock(&recall_lock);
@@ -1136,7 +1133,7 @@ destroy_client(struct nfs4_client *clp)
 		svc_xprt_put(clp->cl_cb_conn.cb_xprt);
 	list_del(&clp->cl_idhash);
 	if (test_bit(NFSD4_CLIENT_CONFIRMED, &clp->cl_flags))
-		rb_erase(&clp->cl_namenode, &conf_name_tree);
+		rb_erase(&clp->cl_namenode, &nn->conf_name_tree);
 	else
 		rb_erase(&clp->cl_namenode, &unconf_name_tree);
 	spin_lock(&client_lock);
@@ -1389,7 +1386,7 @@ move_to_confirmed(struct nfs4_client *clp)
 	dprintk("NFSD: move_to_confirm nfs4_client %p\n", clp);
 	list_move(&clp->cl_idhash, &nn->conf_id_hashtbl[idhashval]);
 	rb_erase(&clp->cl_namenode, &unconf_name_tree);
-	add_clp_to_name_tree(clp, &conf_name_tree);
+	add_clp_to_name_tree(clp, &nn->conf_name_tree);
 	set_bit(NFSD4_CLIENT_CONFIRMED, &clp->cl_flags);
 	renew_client(clp);
 }
@@ -1433,9 +1430,9 @@ static bool clp_used_exchangeid(struct nfs4_client *clp)
 } 
 
 static struct nfs4_client *
-find_confirmed_client_by_name(struct xdr_netobj *name)
+find_confirmed_client_by_name(struct xdr_netobj *name, struct nfsd_net *nn)
 {
-	return find_clp_in_name_tree(name, &conf_name_tree);
+	return find_clp_in_name_tree(name, &nn->conf_name_tree);
 }
 
 static struct nfs4_client *
@@ -1635,7 +1632,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 
 	/* Cases below refer to rfc 5661 section 18.35.4: */
 	nfs4_lock_state();
-	conf = find_confirmed_client_by_name(&exid->clname);
+	conf = find_confirmed_client_by_name(&exid->clname, nn);
 	if (conf) {
 		bool creds_match = same_creds(&conf->cl_cred, &rqstp->rq_cred);
 		bool verfs_match = same_verf(&verf, &conf->cl_verifier);
@@ -1829,7 +1826,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 			status = nfserr_seq_misordered;
 			goto out_free_conn;
 		}
-		old = find_confirmed_client_by_name(&unconf->cl_name);
+		old = find_confirmed_client_by_name(&unconf->cl_name, nn);
 		if (old)
 			expire_client(old);
 		move_to_confirmed(unconf);
@@ -2227,7 +2224,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	/* Cases below refer to rfc 3530 section 14.2.33: */
 	nfs4_lock_state();
-	conf = find_confirmed_client_by_name(&clname);
+	conf = find_confirmed_client_by_name(&clname, nn);
 	if (conf) {
 		/* case 0: */
 		status = nfserr_clid_inuse;
@@ -2309,7 +2306,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		nfsd4_probe_callback(conf);
 		expire_client(unconf);
 	} else { /* case 3: normal case; new or rebooted client */
-		conf = find_confirmed_client_by_name(&unconf->cl_name);
+		conf = find_confirmed_client_by_name(&unconf->cl_name, nn);
 		if (conf)
 			expire_client(conf);
 		move_to_confirmed(unconf);
@@ -4726,7 +4723,6 @@ nfs4_state_init(void)
 	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&unconf_id_hashtbl[i]);
 	}
-	conf_name_tree = RB_ROOT;
 	unconf_name_tree = RB_ROOT;
 	for (i = 0; i < SESSION_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&sessionid_hashtbl[i]);
@@ -4772,12 +4768,17 @@ static int nfs4_state_start_net(struct net *net)
 	nn->conf_id_hashtbl = kmalloc(sizeof(struct list_head) *
 			CLIENT_HASH_SIZE, GFP_KERNEL);
 	if (!nn->conf_id_hashtbl)
-		return -ENOMEM;
+		goto err;
 
-	for (i = 0; i < CLIENT_HASH_SIZE; i++)
+	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&nn->conf_id_hashtbl[i]);
+	}
+	nn->conf_name_tree = RB_ROOT;
 
 	return 0;
+
+err:
+	return -ENOMEM;
 }
 
 static void

