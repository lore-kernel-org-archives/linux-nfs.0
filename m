Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f169.google.com ([74.125.82.169]:52576 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664Ab3JJMtA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Oct 2013 08:49:00 -0400
Received: by mail-we0-f169.google.com with SMTP id q58so2512684wes.0
        for <linux-nfs@vger.kernel.org>; Thu, 10 Oct 2013 05:48:59 -0700 (PDT)
From: Nadav Shemer <nadav@primarydata.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, bhalevy@primarydata.com
Subject: [PATCH] nfsd: unhash client before expiring it
Date: Thu, 10 Oct 2013 14:47:28 +0200
Message-Id: <1381409248-1858-1-git-send-email-nadav@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some client_expire operations (pnfs_expire_client) may release the state
lock. To prevent two threads from concurrently expiring the same client,
the client is unhashed before any other operation

Signed-off-by: Nadav Shemer <nadav@primarydata.com>
---
Related to the recent patchset from Benny Halevy, expire_client releases the state lock (expire_client->destroy_client->pnfs_expire_client).
A different thread processing a SET_CLIENTID/EXCHANGE_ID/etc. might find the client on the confirmed/unconfirmed hash table and also call expire_client on it.

To correct this, I reshuffled destroy_client to remove the client from hash tables first thing, before the state lock may be released

Benny: my previous version of this patch had some plays with reference counts (taking a reference for the duration of the destroy).
In the current version of the tree, destroy_client assumes cl_refcount==0 and is the only caller of free_client besides create_client. So I dropped it

 fs/nfsd/nfs4state.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b4a28ef..d42434b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1154,57 +1154,60 @@ unhash_client_locked(struct nfs4_client *clp)
 	list_del(&clp->cl_lru);
 	spin_lock(&clp->cl_lock);
 	list_for_each_entry(ses, &clp->cl_sessions, se_perclnt)
 		list_del_init(&ses->se_hash);
 	spin_unlock(&clp->cl_lock);
 }
 
 static void
 destroy_client(struct nfs4_client *clp)
 {
 	struct nfs4_openowner *oo;
 	struct nfs4_delegation *dp;
 	struct list_head reaplist;
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
+	list_del(&clp->cl_idhash);
+	if (test_bit(NFSD4_CLIENT_CONFIRMED, &clp->cl_flags))
+		rb_erase(&clp->cl_namenode, &nn->conf_name_tree);
+	else
+		rb_erase(&clp->cl_namenode, &nn->unconf_name_tree);
+	spin_lock(&nn->client_lock);
+	unhash_client_locked(clp);
+	spin_unlock(&nn->client_lock);
+
 	INIT_LIST_HEAD(&reaplist);
 	spin_lock(&recall_lock);
 	while (!list_empty(&clp->cl_delegations)) {
 		dp = list_entry(clp->cl_delegations.next, struct nfs4_delegation, dl_perclnt);
 		list_del_init(&dp->dl_perclnt);
 		list_move(&dp->dl_recall_lru, &reaplist);
 	}
 	spin_unlock(&recall_lock);
 	while (!list_empty(&reaplist)) {
 		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
 		destroy_delegation(dp);
 	}
 	while (!list_empty(&clp->cl_openowners)) {
 		oo = list_entry(clp->cl_openowners.next, struct nfs4_openowner, oo_perclient);
 		release_openowner(oo);
 	}
 	pnfs_expire_client(clp);
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
 
 static void expire_client(struct nfs4_client *clp)
 {
 	nfsd4_client_record_remove(clp);
 	destroy_client(clp);
 }
 
 static void copy_verf(struct nfs4_client *target, nfs4_verifier *source)
 {
 	memcpy(target->cl_verifier.data, source->data,
 			sizeof(target->cl_verifier.data));
-- 
1.8.3.3.754.g9c3c367

