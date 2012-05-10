Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:28800 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760084Ab2EJPUl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 May 2012 11:20:41 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v3 13/14] NFS: Allocate parsed mount data directly to the nfs_mount_info structure
Date: Thu, 10 May 2012 11:20:04 -0400
Message-Id: <1336663205-23886-14-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1336663205-23886-1-git-send-email-bjschuma@netapp.com>
References: <1336663205-23886-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/super.c |   16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 466b299..61b47da 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2468,7 +2468,6 @@ error_splat_bdi:
 static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data)
 {
-	struct nfs_parsed_mount_data *data = NULL;
 	struct nfs_mount_info mount_info = {
 		.fill_super = nfs_fill_super,
 		.set_security = nfs_set_sb_security,
@@ -2477,30 +2476,29 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	struct dentry *mntroot = ERR_PTR(-ENOMEM);
 	int error;
 
-	data = nfs_alloc_parsed_mount_data();
+	mount_info.parsed = nfs_alloc_parsed_mount_data();
 	mntfh = nfs_alloc_fhandle();
-	if (data == NULL || mntfh == NULL)
+	if (mount_info.parsed == NULL || mntfh == NULL)
 		goto out;
 
 	/* Validate the mount data */
-	error = nfs_validate_mount_data(fs_type, raw_data, data, mntfh, dev_name);
+	error = nfs_validate_mount_data(fs_type, raw_data, mount_info.parsed, mntfh, dev_name);
 	if (error == NFS_TEXT_DATA)
-		error = nfs_validate_text_mount_data(raw_data, data, dev_name);
+		error = nfs_validate_text_mount_data(raw_data, mount_info.parsed, dev_name);
 	if (error < 0) {
 		mntroot = ERR_PTR(error);
 		goto out;
 	}
-	mount_info.parsed = data;
 
 #ifdef CONFIG_NFS_V4
-	if (data->version == 4)
-		mntroot = nfs4_try_mount(flags, dev_name, data);
+	if (mount_info.parsed->version == 4)
+		mntroot = nfs4_try_mount(flags, dev_name, mount_info.parsed);
 	else
 #endif	/* CONFIG_NFS_V4 */
 		mntroot = nfs_try_mount(flags, dev_name, mntfh, &mount_info);
 
 out:
-	nfs_free_parsed_mount_data(data);
+	nfs_free_parsed_mount_data(mount_info.parsed);
 	nfs_free_fhandle(mntfh);
 	return mntroot;
 }
-- 
1.7.10.1

