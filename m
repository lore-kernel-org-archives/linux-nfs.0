Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:23572 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753506Ab0EKWZS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 May 2010 18:25:18 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: bharrosh@panasas.com, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] SQUASHME pnfs_submit: move unmount_pnfs_layoutdriver call
Date: Tue, 11 May 2010 18:24:51 -0400
Message-Id: <1273616691-4299-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

from nfs4_kill_super to nfs_free_server. Fixes a bug reported by Boaz Harrosh
where the deviceid cache is not defererenced on super block creation error or
for two mounts that share a super block.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c |    9 +++++++++
 fs/nfs/super.c  |    3 ---
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 56f3d50..0337330 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -884,6 +884,14 @@ static void nfs4_init_pnfs(struct nfs_server *server, struct nfs_fsinfo *fsinfo)
 #endif /* CONFIG_NFS_V4_1 */
 }
 
+static void nfs4_uninit_pnfs(struct nfs_server *server)
+{
+#if defined(CONFIG_NFS_V4_1)
+	if (nfs4_has_session(server->nfs_client))
+		unmount_pnfs_layoutdriver(server);
+#endif /* CONFIG_NFS_V4_1 */
+}
+
 /*
  * Load up the server record from information gained in an fsinfo record
  */
@@ -1039,6 +1047,7 @@ void nfs_free_server(struct nfs_server *server)
 {
 	dprintk("--> nfs_free_server()\n");
 
+	nfs4_uninit_pnfs(server);
 	spin_lock(&nfs_client_lock);
 	list_del(&server->client_link);
 	list_del(&server->master_link);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 5fc60cf..7822187 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2799,9 +2799,6 @@ static void nfs4_kill_super(struct super_block *sb)
 	dprintk("--> %s\n", __func__);
 	nfs_super_return_all_delegations(sb);
 	kill_anon_super(sb);
-#ifdef CONFIG_NFS_V4_1
-	unmount_pnfs_layoutdriver(server);
-#endif
 	nfs_fscache_release_super_cookie(sb);
 	nfs_free_server(server);
 	dprintk("<-- %s\n", __func__);
-- 
1.6.6

