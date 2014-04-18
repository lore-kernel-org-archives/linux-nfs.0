Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:41865 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754234AbaDRSq2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:46:28 -0400
Received: by mail-ie0-f175.google.com with SMTP id to1so1883299ieb.34
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:46:28 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 53/70] NFSd: Ensure struct nfs4_client is unhashed before we try to destroy it
Date: Fri, 18 Apr 2014 14:44:47 -0400
Message-Id: <1397846704-14567-54-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-53-git-send-email-trond.myklebust@primarydata.com>
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
 <1397846704-14567-24-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-25-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-26-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-27-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-28-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-29-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-30-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-31-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-32-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-33-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-34-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-35-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-36-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-37-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-38-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-39-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-40-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-41-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-42-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-43-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-44-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-45-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-46-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-47-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-48-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-49-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-50-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-51-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-52-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-53-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we remove the nfs4_lock_state() protection, we will need to ensure
that it can't be found by other threads while we're destroying it.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 43 +++++++++++++++++++++++++++++++++----------
 1 file changed, 33 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1708f6b7e9e7..19f7739a156e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1273,12 +1273,23 @@ free_client(struct nfs4_client *clp)
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
@@ -1286,7 +1297,17 @@ unhash_client_locked(struct nfs4_client *clp)
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
@@ -1318,22 +1339,24 @@ destroy_client(struct nfs4_client *clp)
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
1.9.0

