From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/5] NFS: combine nfs_kill_super() and nfs4_kill_super()
Date: Sun, 30 Aug 2009 12:34:33 -0400
Message-ID: <20090830163432.3652.437.stgit@matisse.1015granger.net>
References: <20090830162211.3652.14638.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:49879
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753873AbZH3Qeg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Aug 2009 12:34:36 -0400
In-Reply-To: <20090830162211.3652.14638.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_kill_super() and nfs4_kill_super() do almost the same thing, so combine
them.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   45 +++++++++++++++++++++------------------------
 1 files changed, 21 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f3a95df..d215707 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -282,13 +282,12 @@ static int nfs4_referral_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt);
 static int nfs4_remote_referral_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt);
-static void nfs4_kill_super(struct super_block *sb);
 
 static struct file_system_type nfs4_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs4",
 	.get_sb		= nfs4_get_sb,
-	.kill_sb	= nfs4_kill_super,
+	.kill_sb	= nfs_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
 };
 
@@ -296,7 +295,7 @@ static struct file_system_type nfs4_remote_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs4",
 	.get_sb		= nfs4_remote_get_sb,
-	.kill_sb	= nfs4_kill_super,
+	.kill_sb	= nfs_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
 };
 
@@ -304,7 +303,7 @@ struct file_system_type nfs4_xdev_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs4",
 	.get_sb		= nfs4_xdev_get_sb,
-	.kill_sb	= nfs4_kill_super,
+	.kill_sb	= nfs_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
 };
 
@@ -312,7 +311,7 @@ static struct file_system_type nfs4_remote_referral_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs4",
 	.get_sb		= nfs4_remote_referral_get_sb,
-	.kill_sb	= nfs4_kill_super,
+	.kill_sb	= nfs_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
 };
 
@@ -320,7 +319,7 @@ struct file_system_type nfs4_referral_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs4",
 	.get_sb		= nfs4_referral_get_sb,
-	.kill_sb	= nfs4_kill_super,
+	.kill_sb	= nfs_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
 };
 
@@ -2127,16 +2126,27 @@ error_splat_super:
 }
 
 /*
- * Destroy an NFS2/3 superblock
+ * Destroy an NFS superblock
  */
-static void nfs_kill_super(struct super_block *s)
+static void nfs_kill_super(struct super_block *sb)
 {
-	struct nfs_server *server = NFS_SB(s);
+	struct nfs_server *server = NFS_SB(sb);
+
+	dprintk("--> %s\n", __func__);
+
+#ifdef CONFIG_NFS_V4
+	if (server->nfs_client->rpc_ops->version == 4) {
+		nfs_super_return_all_delegations(sb);
+		nfs4_renewd_prepare_shutdown(server);
+	}
+#endif	/* CONFIG_NFS_V4 */
 
 	bdi_unregister(&server->backing_dev_info);
-	kill_anon_super(s);
-	nfs_fscache_release_super_cookie(s);
+	kill_anon_super(sb);
+	nfs_fscache_release_super_cookie(sb);
 	nfs_free_server(server);
+
+	dprintk("<-- %s\n", __func__);
 }
 
 /*
@@ -2599,19 +2609,6 @@ out_free_data:
 	return error;
 }
 
-static void nfs4_kill_super(struct super_block *sb)
-{
-	struct nfs_server *server = NFS_SB(sb);
-
-	dprintk("--> %s\n", __func__);
-	nfs_super_return_all_delegations(sb);
-	kill_anon_super(sb);
-	nfs4_renewd_prepare_shutdown(server);
-	nfs_fscache_release_super_cookie(sb);
-	nfs_free_server(server);
-	dprintk("<-- %s\n", __func__);
-}
-
 /*
  * Clone an NFS4 server record on xdev traversal (FSID-change)
  */

