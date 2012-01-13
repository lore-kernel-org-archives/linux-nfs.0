Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21401 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932746Ab2AMULZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:25 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 26/44] NFS: Create an idr_lock to protect the cb_idr
Date: Fri, 13 Jan 2012 15:10:35 -0500
Message-Id: <1326485453-1350-27-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I eventually plan to move the code protecting the cb_ident_idr to a file
in the nfs4/ directory.  This patch creates a new lock to prepare for
the move.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c |   26 +++++++++++++++-----------
 1 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 998c3be..dc10b2e 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -61,7 +61,8 @@ static LIST_HEAD(nfs_client_list);
 static LIST_HEAD(nfs_volume_list);
 static DECLARE_WAIT_QUEUE_HEAD(nfs_client_active_wq);
 #ifdef CONFIG_NFS_V4
-static DEFINE_IDR(cb_ident_idr); /* Protected by nfs_client_lock */
+static DEFINE_SPINLOCK(nfs_idr_lock);
+static DEFINE_IDR(cb_ident_idr); /* Protected by nfs_idr_lock */
 
 /*
  * Get a unique NFSv4.0 callback identifier which will be used
@@ -76,9 +77,9 @@ static int nfs_get_cb_ident_idr(struct nfs_client *clp, int minorversion)
 retry:
 	if (!idr_pre_get(&cb_ident_idr, GFP_KERNEL))
 		return -ENOMEM;
-	spin_lock(&nfs_client_lock);
+	spin_lock(&nfs_idr_lock);
 	ret = idr_get_new(&cb_ident_idr, clp, &clp->cl_cb_ident);
-	spin_unlock(&nfs_client_lock);
+	spin_unlock(&nfs_idr_lock);
 	if (ret == -EAGAIN)
 		goto retry;
 	return ret;
@@ -291,11 +292,12 @@ void nfs_cleanup_cb_ident_idr(void)
 	idr_destroy(&cb_ident_idr);
 }
 
-/* nfs_client_lock held */
-static void nfs_cb_idr_remove_locked(struct nfs_client *clp)
+static void nfs_cb_idr_remove(struct nfs_client *clp)
 {
+	spin_lock(&nfs_idr_lock);
 	if (clp->cl_cb_ident)
 		idr_remove(&cb_ident_idr, clp->cl_cb_ident);
+	spin_unlock(&nfs_idr_lock);
 }
 
 static void pnfs_init_server(struct nfs_server *server)
@@ -314,7 +316,7 @@ void nfs_cleanup_cb_ident_idr(void)
 {
 }
 
-static void nfs_cb_idr_remove_locked(struct nfs_client *clp)
+static void nfs_cb_idr_remove(struct nfs_client *clp)
 {
 }
 
@@ -364,7 +366,7 @@ void nfs_put_client(struct nfs_client *clp)
 
 	if (atomic_dec_and_lock(&clp->cl_count, &nfs_client_lock)) {
 		list_del(&clp->cl_share_link);
-		nfs_cb_idr_remove_locked(clp);
+		nfs_cb_idr_remove(clp);
 		spin_unlock(&nfs_client_lock);
 
 		BUG_ON(!list_empty(&clp->cl_superblocks));
@@ -1246,11 +1248,13 @@ nfs4_find_client_ident(int cb_ident)
 {
 	struct nfs_client *clp;
 
-	spin_lock(&nfs_client_lock);
+	spin_lock(&nfs_idr_lock);
 	clp = idr_find(&cb_ident_idr, cb_ident);
-	if (clp)
-		atomic_inc(&clp->cl_count);
-	spin_unlock(&nfs_client_lock);
+	if (clp) {
+		if (!atomic_inc_not_zero(&clp->cl_count))
+			clp = NULL;
+	}
+	spin_unlock(&nfs_idr_lock);
 	return clp;
 }
 
-- 
1.7.8.3

