Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f48.google.com ([209.85.192.48]:44291 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754640AbaG3M1q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 08:27:46 -0400
Received: by mail-qg0-f48.google.com with SMTP id i50so1292405qgf.7
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 05:27:45 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 01/37] nfsd: Ensure struct nfs4_client is unhashed before we try to destroy it
Date: Wed, 30 Jul 2014 08:27:02 -0400
Message-Id: <1406723258-8512-2-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
References: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

When we remove the client_mutex protection, we will need to ensure
that it can't be found by other threads while we're destroying it.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 43 +++++++++++++++++++++++++++++++++----------
 1 file changed, 33 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 52ec47de1185..cb630db015b0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1588,12 +1588,23 @@ free_client(struct nfs4_client *clp)
 }
 
 /* must be called under the client_lock */
-static inline void
+static void
 unhash_client_locked(struct nfs4_client *clp)
 {
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 	struct nfsd4_session *ses;
 
-	list_del(&clp->cl_lru);
+	/* Mark the client as expired! */
+	clp->cl_time = 0;
+	/* Make it invisible */
+	if (!list_empty(&clp->cl_idhash)) {
+		list_del_init(&clp->cl_idhash);
+		if (test_bit(NFSD4_CLIENT_CONFIRMED, &clp->cl_flags))
+			rb_erase(&clp->cl_namenode, &nn->conf_name_tree);
+		else
+			rb_erase(&clp->cl_namenode, &nn->unconf_name_tree);
+	}
+	list_del_init(&clp->cl_lru);
 	spin_lock(&clp->cl_lock);
 	list_for_each_entry(ses, &clp->cl_sessions, se_perclnt)
 		list_del_init(&ses->se_hash);
@@ -1601,7 +1612,17 @@ unhash_client_locked(struct nfs4_client *clp)
 }
 
 static void
-destroy_client(struct nfs4_client *clp)
+unhash_client(struct nfs4_client *clp)
+{
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+
+	spin_lock(&nn->client_lock);
+	unhash_client_locked(clp);
+	spin_unlock(&nn->client_lock);
+}
+
+static void
+__destroy_client(struct nfs4_client *clp)
 {
 	struct nfs4_openowner *oo;
 	struct nfs4_delegation *dp;
@@ -1634,22 +1655,24 @@ destroy_client(struct nfs4_client *clp)
 	nfsd4_shutdown_callback(clp);
 	if (clp->cl_cb_conn.cb_xprt)
 		svc_xprt_put(clp->cl_cb_conn.cb_xprt);
-	list_del(&clp->cl_idhash);
-	if (test_bit(NFSD4_CLIENT_CONFIRMED, &clp->cl_flags))
-		rb_erase(&clp->cl_namenode, &nn->conf_name_tree);
-	else
-		rb_erase(&clp->cl_namenode, &nn->unconf_name_tree);
 	spin_lock(&nn->client_lock);
-	unhash_client_locked(clp);
 	WARN_ON_ONCE(atomic_read(&clp->cl_refcount));
 	free_client(clp);
 	spin_unlock(&nn->client_lock);
 }
 
+static void
+destroy_client(struct nfs4_client *clp)
+{
+	unhash_client(clp);
+	__destroy_client(clp);
+}
+
 static void expire_client(struct nfs4_client *clp)
 {
+	unhash_client(clp);
 	nfsd4_client_record_remove(clp);
-	destroy_client(clp);
+	__destroy_client(clp);
 }
 
 static void copy_verf(struct nfs4_client *target, nfs4_verifier *source)
-- 
1.9.3

