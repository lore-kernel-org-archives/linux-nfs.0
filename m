Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:6770 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752655Ab2KNPS4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Nov 2012 10:18:56 -0500
Subject: [PATCH v2 06/15] nfsd: make unconf_id_hashtbl allocated per net
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Wed, 14 Nov 2012 18:21:31 +0300
Message-ID: <20121114152131.4708.86778.stgit@localhost.localdomain>
In-Reply-To: <20121114152018.4708.63125.stgit@localhost.localdomain>
References: <20121114152018.4708.63125.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This hash holds nfs4_clients info, which are network namespace aware.
So let's make it allocated per network namespace.

Note: this hash can be allocated in per-net operations. But it looks
better to allocate it on nfsd state start and thus don't waste resources
if server is not running.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/netns.h     |    1 +
 fs/nfsd/nfs4state.c |   25 +++++++++++++++----------
 2 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index afd9116..1ff781f 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -55,6 +55,7 @@ struct nfsd_net {
 	int reclaim_str_hashtbl_size;
 	struct list_head *conf_id_hashtbl;
 	struct rb_root conf_name_tree;
+	struct list_head *unconf_id_hashtbl;
 };
 
 extern int nfsd_net_id;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ff03573..b967804 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -415,7 +415,6 @@ static unsigned int clientstr_hashval(const char *name)
  *
  * All of the above fields are protected by the client_mutex.
  */
-static struct list_head	unconf_id_hashtbl[CLIENT_HASH_SIZE];
 static struct rb_root unconf_name_tree;
 static struct list_head client_lru;
 static struct list_head close_lru;
@@ -1369,11 +1368,12 @@ static void
 add_to_unconfirmed(struct nfs4_client *clp)
 {
 	unsigned int idhashval;
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
 	clear_bit(NFSD4_CLIENT_CONFIRMED, &clp->cl_flags);
 	add_clp_to_name_tree(clp, &unconf_name_tree);
 	idhashval = clientid_hashval(clp->cl_clientid.cl_id);
-	list_add(&clp->cl_idhash, &unconf_id_hashtbl[idhashval]);
+	list_add(&clp->cl_idhash, &nn->unconf_id_hashtbl[idhashval]);
 	renew_client(clp);
 }
 
@@ -1409,12 +1409,12 @@ find_confirmed_client(clientid_t *clid, bool sessions, struct nfsd_net *nn)
 }
 
 static struct nfs4_client *
-find_unconfirmed_client(clientid_t *clid, bool sessions)
+find_unconfirmed_client(clientid_t *clid, bool sessions, struct nfsd_net *nn)
 {
 	struct nfs4_client *clp;
 	unsigned int idhashval = clientid_hashval(clid->cl_id);
 
-	list_for_each_entry(clp, &unconf_id_hashtbl[idhashval], cl_idhash) {
+	list_for_each_entry(clp, &nn->unconf_id_hashtbl[idhashval], cl_idhash) {
 		if (same_clid(&clp->cl_clientid, clid)) {
 			if ((bool)clp->cl_minorversion != sessions)
 				return NULL;
@@ -1799,7 +1799,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		goto out_free_session;
 
 	nfs4_lock_state();
-	unconf = find_unconfirmed_client(&cr_ses->clientid, true);
+	unconf = find_unconfirmed_client(&cr_ses->clientid, true, nn);
 	conf = find_confirmed_client(&cr_ses->clientid, true, nn);
 
 	if (conf) {
@@ -2143,7 +2143,7 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
 	nfs4_lock_state();
-	unconf = find_unconfirmed_client(&dc->clientid, true);
+	unconf = find_unconfirmed_client(&dc->clientid, true, nn);
 	conf = find_confirmed_client(&dc->clientid, true, nn);
 
 	if (conf) {
@@ -2280,7 +2280,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 	nfs4_lock_state();
 
 	conf = find_confirmed_client(clid, false, nn);
-	unconf = find_unconfirmed_client(clid, false);
+	unconf = find_unconfirmed_client(clid, false, nn);
 	/*
 	 * We try hard to give out unique clientid's, so if we get an
 	 * attempt to confirm the same clientid with a different cred,
@@ -4720,9 +4720,6 @@ nfs4_state_init(void)
 {
 	int i;
 
-	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
-		INIT_LIST_HEAD(&unconf_id_hashtbl[i]);
-	}
 	unconf_name_tree = RB_ROOT;
 	for (i = 0; i < SESSION_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&sessionid_hashtbl[i]);
@@ -4769,14 +4766,21 @@ static int nfs4_state_start_net(struct net *net)
 			CLIENT_HASH_SIZE, GFP_KERNEL);
 	if (!nn->conf_id_hashtbl)
 		goto err;
+	nn->unconf_id_hashtbl = kmalloc(sizeof(struct list_head) *
+			CLIENT_HASH_SIZE, GFP_KERNEL);
+	if (!nn->unconf_id_hashtbl)
+		goto err_unconf_id;
 
 	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&nn->conf_id_hashtbl[i]);
+		INIT_LIST_HEAD(&nn->unconf_id_hashtbl[i]);
 	}
 	nn->conf_name_tree = RB_ROOT;
 
 	return 0;
 
+err_unconf_id:
+	kfree(nn->conf_id_hashtbl);
 err:
 	return -ENOMEM;
 }
@@ -4794,6 +4798,7 @@ __nfs4_state_shutdown_net(struct net *net)
 			destroy_client(clp);
 		}
 	}
+	kfree(nn->unconf_id_hashtbl);
 	kfree(nn->conf_id_hashtbl);
 }
 

