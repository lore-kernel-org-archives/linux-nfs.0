Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:30827 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757382Ab2EGSmx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 May 2012 14:42:53 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v2 3/8] NFS: Don't pass mount data to nfs_fscache_get_super_cookie()
Date: Mon,  7 May 2012 14:42:41 -0400
Message-Id: <1336416166-20533-4-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1336416166-20533-1-git-send-email-bjschuma@netapp.com>
References: <1336416166-20533-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I intend on creating a single nfs_fs_mount() function used by all our
mount paths.  To avoid checking between new mounts and clone mounts, I
instead pass both structures to a new function in super.c that finds the
cache key and then looks up the super cookie.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/fscache.c |   15 ++-------------
 fs/nfs/fscache.h |    4 +---
 fs/nfs/super.c   |   31 ++++++++++++++++++++++++++-----
 3 files changed, 29 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
index ae65c16..c817787 100644
--- a/fs/nfs/fscache.c
+++ b/fs/nfs/fscache.c
@@ -64,23 +64,12 @@ void nfs_fscache_release_client_cookie(struct nfs_client *clp)
  * either by the 'fsc=xxx' option to mount, or by inheriting it from the parent
  * superblock across an automount point of some nature.
  */
-void nfs_fscache_get_super_cookie(struct super_block *sb, const char *uniq,
-				  struct nfs_clone_mount *mntdata)
+void nfs_fscache_get_super_cookie(struct super_block *sb, const char *uniq, int ulen)
 {
 	struct nfs_fscache_key *key, *xkey;
 	struct nfs_server *nfss = NFS_SB(sb);
 	struct rb_node **p, *parent;
-	int diff, ulen;
-
-	if (uniq) {
-		ulen = strlen(uniq);
-	} else if (mntdata) {
-		struct nfs_server *mnt_s = NFS_SB(mntdata->sb);
-		if (mnt_s->fscache_key) {
-			uniq = mnt_s->fscache_key->key.uniquifier;
-			ulen = mnt_s->fscache_key->key.uniq_len;
-		}
-	}
+	int diff;
 
 	if (!uniq) {
 		uniq = "";
diff --git a/fs/nfs/fscache.h b/fs/nfs/fscache.h
index b9c572d..2a08b91 100644
--- a/fs/nfs/fscache.h
+++ b/fs/nfs/fscache.h
@@ -73,9 +73,7 @@ extern void nfs_fscache_unregister(void);
 extern void nfs_fscache_get_client_cookie(struct nfs_client *);
 extern void nfs_fscache_release_client_cookie(struct nfs_client *);
 
-extern void nfs_fscache_get_super_cookie(struct super_block *,
-					 const char *,
-					 struct nfs_clone_mount *);
+extern void nfs_fscache_get_super_cookie(struct super_block *, const char *, int);
 extern void nfs_fscache_release_super_cookie(struct super_block *);
 
 extern void nfs_fscache_init_inode_cookie(struct inode *);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 75b1717..f56fb35 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2278,6 +2278,27 @@ static int nfs_compare_super(struct super_block *sb, void *data)
 	return nfs_compare_mount_options(sb, server, mntflags);
 }
 
+static void nfs_get_cache_cookie(struct super_block *sb,
+				 struct nfs_parsed_mount_data *parsed,
+				 struct nfs_clone_mount *cloned)
+{
+	char *uniq = NULL;
+	int ulen = 0;
+
+	if (parsed && parsed->fscache_uniq) {
+		uniq = parsed->fscache_uniq;
+		ulen = strlen(parsed->fscache_uniq);
+	} else if (cloned) {
+		struct nfs_server *mnt_s = NFS_SB(cloned->sb);
+		if (mnt_s->fscache_key) {
+			uniq = mnt_s->fscache_key->key.uniquifier;
+			ulen = mnt_s->fscache_key->key.uniq_len;
+		};
+	}
+
+	nfs_fscache_get_super_cookie(sb, uniq, ulen);
+}
+
 static int nfs_bdi_register(struct nfs_server *server)
 {
 	return bdi_register_dev(&server->backing_dev_info, server->s_dev);
@@ -2352,7 +2373,7 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	if (!s->s_root) {
 		/* initial superblock/root creation */
 		nfs_fill_super(s, data);
-		nfs_fscache_get_super_cookie(s, data->fscache_uniq, NULL);
+		nfs_get_cache_cookie(s, data, NULL);
 	}
 
 	mntroot = nfs_get_root(s, mntfh, dev_name);
@@ -2461,7 +2482,7 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 	if (!s->s_root) {
 		/* initial superblock/root creation */
 		nfs_clone_super(s, data->sb);
-		nfs_fscache_get_super_cookie(s, NULL, data);
+		nfs_get_cache_cookie(s, NULL, data);
 	}
 
 	mntroot = nfs_get_root(s, data->fh, dev_name);
@@ -2724,7 +2745,7 @@ nfs4_remote_mount(struct file_system_type *fs_type, int flags,
 	if (!s->s_root) {
 		/* initial superblock/root creation */
 		nfs4_fill_super(s);
-		nfs_fscache_get_super_cookie(s, data->fscache_uniq, NULL);
+		nfs_get_cache_cookie(s, data, NULL);
 	}
 
 	mntroot = nfs_get_root(s, mntfh, dev_name);
@@ -2988,7 +3009,7 @@ nfs4_xdev_mount(struct file_system_type *fs_type, int flags,
 	if (!s->s_root) {
 		/* initial superblock/root creation */
 		nfs4_clone_super(s, data->sb);
-		nfs_fscache_get_super_cookie(s, NULL, data);
+		nfs_get_cache_cookie(s, NULL, data);
 	}
 
 	mntroot = nfs_get_root(s, data->fh, dev_name);
@@ -3079,7 +3100,7 @@ nfs4_remote_referral_mount(struct file_system_type *fs_type, int flags,
 	if (!s->s_root) {
 		/* initial superblock/root creation */
 		nfs4_fill_super(s);
-		nfs_fscache_get_super_cookie(s, NULL, data);
+		nfs_get_cache_cookie(s, NULL, data);
 	}
 
 	mntroot = nfs_get_root(s, mntfh, dev_name);
-- 
1.7.10.1

