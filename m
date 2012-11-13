Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:46211 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753488Ab2KMPqW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Nov 2012 10:46:22 -0500
Subject: [PATCH 07/15] nfsd: make unconf_str_hastbl allocated per net
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Tue, 13 Nov 2012 18:48:54 +0300
Message-ID: <20121113154854.12577.7404.stgit@localhost.localdomain>
In-Reply-To: <20121113154722.12577.57671.stgit@localhost.localdomain>
References: <20121113154722.12577.57671.stgit@localhost.localdomain>
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
 fs/nfsd/netns.h     |    3 +++
 fs/nfsd/nfs4state.c |   27 ++++++++++++++-------------
 2 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 0577780..ad08208 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -51,12 +51,15 @@ struct nfsd_net {
 	 * conf_id_hashtbl[], and conf_str_hashtbl[] hold confirmed
 	 * setclientid_confirmed info.
 	 *
+	 * unconf_str_hastbl[] and unconf_id_hashtbl[] hold unconfirmed
+	 * setclientid info.
 	 */
 	struct list_head *reclaim_str_hashtbl;
 	int reclaim_str_hashtbl_size;
 	struct list_head *conf_id_hashtbl;
 	struct list_head *conf_str_hashtbl;
 	struct list_head *unconf_str_hashtbl;
+	struct list_head *unconf_id_hashtbl;
 };
 
 extern int nfsd_net_id;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7e44015..10ee3ec 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -404,16 +404,12 @@ static unsigned int clientstr_hashval(const char *name)
 }
 
 /*
- * unconf_str_hastbl[] and unconf_id_hashtbl[] hold unconfirmed 
- * setclientid info.
- *
  * client_lru holds client queue ordered by nfs4_client.cl_time
  * for lease renewal.
  *
  * close_lru holds (open) stateowner queue ordered by nfs4_stateowner.so_time
  * for last close replay.
  */
-static struct list_head	unconf_id_hashtbl[CLIENT_HASH_SIZE];
 static struct list_head client_lru;
 static struct list_head close_lru;
 
@@ -1317,7 +1313,7 @@ add_to_unconfirmed(struct nfs4_client *clp, unsigned int strhashval)
 
 	list_add(&clp->cl_strhash, &nn->unconf_str_hashtbl[strhashval]);
 	idhashval = clientid_hashval(clp->cl_clientid.cl_id);
-	list_add(&clp->cl_idhash, &unconf_id_hashtbl[idhashval]);
+	list_add(&clp->cl_idhash, &nn->unconf_id_hashtbl[idhashval]);
 	renew_client(clp);
 }
 
@@ -1353,12 +1349,12 @@ find_confirmed_client(clientid_t *clid, bool sessions, struct nfsd_net *nn)
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
@@ -1766,7 +1762,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		goto out_free_session;
 
 	nfs4_lock_state();
-	unconf = find_unconfirmed_client(&cr_ses->clientid, true);
+	unconf = find_unconfirmed_client(&cr_ses->clientid, true, nn);
 	conf = find_confirmed_client(&cr_ses->clientid, true, nn);
 
 	if (conf) {
@@ -2112,7 +2108,7 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
 	nfs4_lock_state();
-	unconf = find_unconfirmed_client(&dc->clientid, true);
+	unconf = find_unconfirmed_client(&dc->clientid, true, nn);
 	conf = find_confirmed_client(&dc->clientid, true, nn);
 
 	if (conf) {
@@ -2257,7 +2253,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 	nfs4_lock_state();
 
 	conf = find_confirmed_client(clid, false, nn);
-	unconf = find_unconfirmed_client(clid, false);
+	unconf = find_unconfirmed_client(clid, false, nn);
 	/*
 	 * We try hard to give out unique clientid's, so if we get an
 	 * attempt to confirm the same clientid with a different cred,
@@ -4700,9 +4696,6 @@ nfs4_state_init(void)
 {
 	int i;
 
-	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
-		INIT_LIST_HEAD(&unconf_id_hashtbl[i]);
-	}
 	for (i = 0; i < SESSION_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&sessionid_hashtbl[i]);
 	for (i = 0; i < FILE_HASH_SIZE; i++) {
@@ -4756,15 +4749,22 @@ static int nfs4_state_start_net(struct net *net)
 			CLIENT_HASH_SIZE, GFP_KERNEL);
 	if (!nn->unconf_str_hashtbl)
 		goto err_unconf_str;
+	nn->unconf_id_hashtbl = kmalloc(sizeof(struct list_head) *
+			CLIENT_HASH_SIZE, GFP_KERNEL);
+	if (!nn->unconf_id_hashtbl)
+		goto err_unconf_id;
 
 	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&nn->conf_id_hashtbl[i]);
 		INIT_LIST_HEAD(&nn->conf_str_hashtbl[i]);
 		INIT_LIST_HEAD(&nn->unconf_str_hashtbl[i]);
+		INIT_LIST_HEAD(&nn->unconf_id_hashtbl[i]);
 	}
 
 	return 0;
 
+err_unconf_id:
+	kfree(nn->unconf_str_hashtbl);
 err_unconf_str:
 	kfree(nn->conf_str_hashtbl);
 err_conf_str:
@@ -4790,6 +4790,7 @@ __nfs4_state_shutdown_net(struct net *net)
 			destroy_client(clp);
 		}
 	}
+	kfree(nn->unconf_id_hashtbl);
 	kfree(nn->unconf_str_hashtbl);
 	kfree(nn->conf_str_hashtbl);
 	kfree(nn->conf_id_hashtbl);

