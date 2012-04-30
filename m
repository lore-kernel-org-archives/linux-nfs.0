Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:12008 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756550Ab2D3Skf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Apr 2012 14:40:35 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 3/7] NFS: Consistent arguments to nfs_fscache_get_super_cookie()
Date: Mon, 30 Apr 2012 14:40:25 -0400
Message-Id: <1335811229-2989-4-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1335811229-2989-1-git-send-email-bjschuma@netapp.com>
References: <1335811229-2989-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I intend on creating a single nfs_fs_mount() function used by all our
mount paths.  To avoid checking between new mounts and clone mounts, I
instead pass both structures to the get_super_cookie() function and let
this function decide the best way to handle the situation.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/fscache.c |   13 ++++++++-----
 fs/nfs/fscache.h |    2 +-
 fs/nfs/super.c   |    4 ++--
 3 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
index ae65c16..35411f8 100644
--- a/fs/nfs/fscache.c
+++ b/fs/nfs/fscache.c
@@ -64,18 +64,21 @@ void nfs_fscache_release_client_cookie(struct nfs_client *clp)
  * either by the 'fsc=xxx' option to mount, or by inheriting it from the parent
  * superblock across an automount point of some nature.
  */
-void nfs_fscache_get_super_cookie(struct super_block *sb, const char *uniq,
-				  struct nfs_clone_mount *mntdata)
+void nfs_fscache_get_super_cookie(struct super_block *sb,
+				  struct nfs_parsed_mount_data *parsed,
+				  struct nfs_clone_mount *cloned)
 {
 	struct nfs_fscache_key *key, *xkey;
 	struct nfs_server *nfss = NFS_SB(sb);
 	struct rb_node **p, *parent;
+	char *uniq = NULL;
 	int diff, ulen;
 
-	if (uniq) {
+	if (parsed && parsed->fscache_uniq) {
+		uniq = parsed->fscache_uniq;
 		ulen = strlen(uniq);
-	} else if (mntdata) {
-		struct nfs_server *mnt_s = NFS_SB(mntdata->sb);
+	} else if (cloned) {
+		struct nfs_server *mnt_s = NFS_SB(cloned->sb);
 		if (mnt_s->fscache_key) {
 			uniq = mnt_s->fscache_key->key.uniquifier;
 			ulen = mnt_s->fscache_key->key.uniq_len;
diff --git a/fs/nfs/fscache.h b/fs/nfs/fscache.h
index b9c572d..0264bd6 100644
--- a/fs/nfs/fscache.h
+++ b/fs/nfs/fscache.h
@@ -74,7 +74,7 @@ extern void nfs_fscache_get_client_cookie(struct nfs_client *);
 extern void nfs_fscache_release_client_cookie(struct nfs_client *);
 
 extern void nfs_fscache_get_super_cookie(struct super_block *,
-					 const char *,
+					 struct nfs_parsed_mount_data *,
 					 struct nfs_clone_mount *);
 extern void nfs_fscache_release_super_cookie(struct super_block *);
 
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 75b1717..b7a071d 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2352,7 +2352,7 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	if (!s->s_root) {
 		/* initial superblock/root creation */
 		nfs_fill_super(s, data);
-		nfs_fscache_get_super_cookie(s, data->fscache_uniq, NULL);
+		nfs_fscache_get_super_cookie(s, data, NULL);
 	}
 
 	mntroot = nfs_get_root(s, mntfh, dev_name);
@@ -2724,7 +2724,7 @@ nfs4_remote_mount(struct file_system_type *fs_type, int flags,
 	if (!s->s_root) {
 		/* initial superblock/root creation */
 		nfs4_fill_super(s);
-		nfs_fscache_get_super_cookie(s, data->fscache_uniq, NULL);
+		nfs_fscache_get_super_cookie(s, data, NULL);
 	}
 
 	mntroot = nfs_get_root(s, mntfh, dev_name);
-- 
1.7.10

