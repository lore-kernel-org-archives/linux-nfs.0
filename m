Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:47039 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932757Ab2AMULf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:35 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 35/44] NFS: Register the v4 filesystem type from nfs4/module.c
Date: Fri, 13 Jan 2012 15:10:44 -0500
Message-Id: <1326485453-1350-36-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

With this change, nfs v4 will completely configure itself through its
init() and exit() functions.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4/module.c |    6 ++++++
 fs/nfs/nfs4/nfs4.h   |    2 ++
 fs/nfs/super.c       |   10 ++--------
 3 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4/module.c b/fs/nfs/nfs4/module.c
index 9edd174..c57b642 100644
--- a/fs/nfs/nfs4/module.c
+++ b/fs/nfs/nfs4/module.c
@@ -48,9 +48,14 @@ int __init init_nfs_v4(void)
 	ret = nfs4_register_sysctl();
 	if (ret < 0)
 		goto error_0;
+	ret = register_filesystem(&nfs4_fs_type);
+	if (ret < 0)
+		goto error_1;
 	register_nfs_version(&nfs_v4);
 	return 0;
 
+error_1:
+	nfs4_unregister_sysctl();
 error_0:
 	return ret;
 }
@@ -58,5 +63,6 @@ error_0:
 void exit_nfs_v4(void)
 {
 	unregister_nfs_version(&nfs_v4);
+	unregister_filesystem(&nfs4_fs_type);
 	nfs4_unregister_sysctl();
 }
diff --git a/fs/nfs/nfs4/nfs4.h b/fs/nfs/nfs4/nfs4.h
index 5f69528..c24fb13 100644
--- a/fs/nfs/nfs4/nfs4.h
+++ b/fs/nfs/nfs4/nfs4.h
@@ -3,6 +3,8 @@
 
 #include "../nfs.h"
 
+extern struct file_system_type nfs4_fs_type;
+
 int init_nfs_v4(void);
 void exit_nfs_v4(void);
 
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 3306c43..f5c5cd9 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -321,7 +321,7 @@ static struct dentry *nfs4_remote_referral_mount(struct file_system_type *fs_typ
 	int flags, const char *dev_name, void *raw_data);
 static void nfs4_kill_super(struct super_block *sb);
 
-static struct file_system_type nfs4_fs_type = {
+struct file_system_type nfs4_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs4",
 	.mount		= nfs4_mount,
@@ -400,18 +400,13 @@ int __init register_nfs_fs(void)
 	ret = init_nfs_v4();
 	if (ret < 0)
 		goto error_2;
-	ret = register_filesystem(&nfs4_fs_type);
-	if (ret < 0)
-		goto error_3;
 #endif
 	register_shrinker(&acl_shrinker);
 	return 0;
 
 #ifdef CONFIG_NFS_V4
-error_3:
-	nfs_unregister_sysctl();
 error_2:
-	exit_nfs_v4();
+	nfs_unregister_sysctl();
 #endif
 error_1:
 	unregister_filesystem(&nfs_fs_type);
@@ -426,7 +421,6 @@ void __exit unregister_nfs_fs(void)
 {
 	unregister_shrinker(&acl_shrinker);
 #ifdef CONFIG_NFS_V4
-	unregister_filesystem(&nfs4_fs_type);
 	exit_nfs_v4();
 #endif
 	nfs_unregister_sysctl();
-- 
1.7.8.3

