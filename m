Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:60449 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761468Ab2EJTIB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 May 2012 15:08:01 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 12/14] NFS: Create a single nfs_validate_mount_data() function
Date: Thu, 10 May 2012 15:07:41 -0400
Message-Id: <1336676863-9698-13-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1336676863-9698-1-git-send-email-bjschuma@netapp.com>
References: <1336676863-9698-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This new function chooses between the v2/3 parser and the v4 parser by
filesystem type.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/super.c |   36 ++++++++++++++++++++++++++++++------
 1 file changed, 30 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index db636d7..5b025b0 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -335,6 +335,8 @@ static const struct super_operations nfs_sops = {
 
 #ifdef CONFIG_NFS_V4
 static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *);
+static int nfs4_validate_mount_data(void *options,
+	struct nfs_parsed_mount_data *args, const char *dev_name);
 static struct dentry *nfs4_try_mount(int flags, const char *dev_name,
 	struct nfs_parsed_mount_data *data);
 static struct dentry *nfs4_mount(struct file_system_type *fs_type,
@@ -1857,10 +1859,10 @@ out_path:
  * + breaking back: trying proto=udp after proto=tcp, v2 after v3,
  *   mountproto=tcp after mountproto=udp, and so on
  */
-static int nfs_validate_mount_data(void *options,
-				   struct nfs_parsed_mount_data *args,
-				   struct nfs_fh *mntfh,
-				   const char *dev_name)
+static int nfs23_validate_mount_data(void *options,
+				     struct nfs_parsed_mount_data *args,
+				     struct nfs_fh *mntfh,
+				     const char *dev_name)
 {
 	struct nfs_mount_data *data = (struct nfs_mount_data *)options;
 	struct sockaddr *sap = (struct sockaddr *)&args->nfs_server.address;
@@ -2009,6 +2011,28 @@ out_invalid_fh:
 	return -EINVAL;
 }
 
+#ifdef CONFIG_NFS_V4
+static int nfs_validate_mount_data(struct file_system_type *fs_type,
+				   void *options,
+				   struct nfs_parsed_mount_data *args,
+				   struct nfs_fh *mntfh,
+				   const char *dev_name)
+{
+	if (fs_type == &nfs_fs_type)
+		return nfs23_validate_mount_data(options, args, mntfh, dev_name);
+	return nfs4_validate_mount_data(options, args, dev_name);
+}
+#else
+static int nfs_validate_mount_data(struct file_system_type *fs_type,
+				   void *options,
+				   struct nfs_parsed_mount_data *args,
+				   struct nfs_fh *mntfh,
+				   const char *dev_name)
+{
+	return nfs23_validate_mount_data(options, args, mntfh, dev_name);
+}
+#endif
+
 static int nfs_validate_text_mount_data(void *options,
 					struct nfs_parsed_mount_data *args,
 					const char *dev_name)
@@ -2459,7 +2483,7 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 		goto out;
 
 	/* Validate the mount data */
-	error = nfs_validate_mount_data(raw_data, data, mntfh, dev_name);
+	error = nfs_validate_mount_data(fs_type, raw_data, data, mntfh, dev_name);
 	if (error == NFS_TEXT_DATA)
 		error = nfs_validate_text_mount_data(raw_data, data, dev_name);
 	if (error < 0) {
@@ -2866,7 +2890,7 @@ static struct dentry *nfs4_mount(struct file_system_type *fs_type,
 		goto out;
 
 	/* Validate the mount data */
-	error = nfs4_validate_mount_data(raw_data, data, dev_name);
+	error = nfs_validate_mount_data(fs_type, raw_data, data, NULL, dev_name);
 	if (error == NFS_TEXT_DATA)
 		error = nfs_validate_text_mount_data(raw_data, data, dev_name);
 	if (error < 0) {
-- 
1.7.10.1

