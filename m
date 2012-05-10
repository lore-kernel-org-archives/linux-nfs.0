Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:28800 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760091Ab2EJPUl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 May 2012 11:20:41 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v3 10/14] NFS: Create a new nfs_try_mount()
Date: Thu, 10 May 2012 11:20:01 -0400
Message-Id: <1336663205-23886-11-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1336663205-23886-1-git-send-email-bjschuma@netapp.com>
References: <1336663205-23886-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This function returns the same same return type as nfs4_try_mount() so
they two can be more easily substituted.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/super.c |   46 +++++++++++++++++++++++++++-------------------
 1 file changed, 27 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 0c4826e..8ebdd5f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -290,6 +290,9 @@ static int  nfs_show_options(struct seq_file *, struct dentry *);
 static int  nfs_show_devname(struct seq_file *, struct dentry *);
 static int  nfs_show_path(struct seq_file *, struct dentry *);
 static int  nfs_show_stats(struct seq_file *, struct dentry *);
+static struct dentry *nfs_fs_mount_common(struct file_system_type *,
+		struct nfs_server *, int, const char *, struct nfs_fh *,
+		struct nfs_mount_info *);
 static struct dentry *nfs_fs_mount(struct file_system_type *,
 		int, const char *, void *);
 static struct dentry *nfs_xdev_mount(struct file_system_type *fs_type,
@@ -1680,8 +1683,8 @@ static int nfs_walk_authlist(struct nfs_parsed_mount_data *args,
  * Use the remote server's MOUNT service to request the NFS file handle
  * corresponding to the provided path.
  */
-static int nfs_try_mount(struct nfs_parsed_mount_data *args,
-			 struct nfs_fh *root_fh)
+static int nfs_request_mount(struct nfs_parsed_mount_data *args,
+			     struct nfs_fh *root_fh)
 {
 	rpc_authflavor_t server_authlist[NFS_MAX_SECFLAVORS];
 	unsigned int server_authlist_len = ARRAY_SIZE(server_authlist);
@@ -1744,6 +1747,25 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 	return nfs_walk_authlist(args, &request);
 }
 
+static struct dentry *nfs_try_mount(int flags, const char *dev_name,
+				    struct nfs_fh *mntfh,
+				    struct nfs_mount_info *mount_info)
+{
+	int status;
+	struct nfs_server *server;
+
+	status = nfs_request_mount(mount_info->parsed, mntfh);
+	if (status)
+		return ERR_PTR(status);
+
+	/* Get a volume representation */
+	server = nfs_create_server(mount_info->parsed, mntfh);
+	if (IS_ERR(server))
+		return ERR_CAST(server);
+
+	return nfs_fs_mount_common(&nfs_fs_type, server, flags, dev_name, mntfh, mount_info);
+}
+
 /*
  * Split "dev_name" into "hostname:export_path".
  *
@@ -1966,11 +1988,6 @@ static int nfs_validate_mount_data(void *options,
 					   PAGE_SIZE,
 					   &args->nfs_server.export_path,
 					   NFS_MAXPATHLEN);
-		if (!status)
-			status = nfs_try_mount(args, mntfh);
-
-		kfree(args->nfs_server.export_path);
-		args->nfs_server.export_path = NULL;
 
 		if (status)
 			return status;
@@ -2405,7 +2422,6 @@ error_splat_bdi:
 static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data)
 {
-	struct nfs_server *server;
 	struct nfs_parsed_mount_data *data = NULL;
 	struct nfs_mount_info mount_info = {
 		.fill_super = nfs_fill_super,
@@ -2429,20 +2445,12 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	mount_info.parsed = data;
 
 #ifdef CONFIG_NFS_V4
-	if (data->version == 4) {
+	if (data->version == 4)
 		mntroot = nfs4_try_mount(flags, dev_name, data);
-		goto out;
-	}
+	else
 #endif	/* CONFIG_NFS_V4 */
+		mntroot = nfs_try_mount(flags, dev_name, mntfh, &mount_info);
 
-	/* Get a volume representation */
-	server = nfs_create_server(data, mntfh);
-	if (IS_ERR(server)) {
-		mntroot = ERR_CAST(server);
-		goto out;
-	}
-
-	mntroot = nfs_fs_mount_common(fs_type, server, flags, dev_name, mntfh, &mount_info);
 out:
 	nfs_free_parsed_mount_data(data);
 	nfs_free_fhandle(mntfh);
-- 
1.7.10.1

