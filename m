From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/4] NFS: Move details of nfs4_get_sb() to a helper
Date: Tue, 01 Sep 2009 10:21:24 -0400
Message-ID: <20090901142124.3700.45454.stgit@matisse.1015granger.net>
References: <20090901141615.3700.41738.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:51789
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754954AbZIAOV2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Sep 2009 10:21:28 -0400
In-Reply-To: <20090901141615.3700.41738.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Refactor nfs4_get_sb() to allow its guts to be invoked by
other functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   44 +++++++++++++++++++++++++++++++-------------
 1 files changed, 31 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 599e8c5..c105e12 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -274,6 +274,8 @@ static const struct super_operations nfs_sops = {
 #ifdef CONFIG_NFS_V4
 static int nfs4_validate_text_mount_data(void *options,
 	struct nfs_parsed_mount_data *args, const char *dev_name);
+static int nfs4_try_mount(int flags, const char *dev_name,
+	struct nfs_parsed_mount_data *data, struct vfsmount *mnt);
 static int nfs4_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt);
 static int nfs4_remote_get_sb(struct file_system_type *fs_type,
@@ -2565,6 +2567,34 @@ out_err:
 	return ret;
 }
 
+static int nfs4_try_mount(int flags, const char *dev_name,
+			 struct nfs_parsed_mount_data *data,
+			 struct vfsmount *mnt)
+{
+	char *export_path;
+	struct vfsmount *root_mnt;
+	int error;
+
+	dfprintk(MOUNT, "--> nfs4_try_mount()\n");
+
+	export_path = data->nfs_server.export_path;
+	data->nfs_server.export_path = "/";
+	root_mnt = nfs_do_root_mount(&nfs4_remote_fs_type, flags, data,
+			data->nfs_server.hostname);
+	data->nfs_server.export_path = export_path;
+
+	error = PTR_ERR(root_mnt);
+	if (IS_ERR(root_mnt))
+		goto out;
+
+	error = nfs_follow_remote_path(root_mnt, export_path, mnt);
+
+out:
+	dfprintk(MOUNT, "<-- nfs4_try_mount() = %d%s\n", error,
+			error != 0 ? " [error]" : "");
+	return error;
+}
+
 /*
  * Get the superblock for an NFS4 mountpoint
  */
@@ -2572,8 +2602,6 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt)
 {
 	struct nfs_parsed_mount_data *data;
-	char *export_path;
-	struct vfsmount *root_mnt;
 	int error = -ENOMEM;
 
 	data = kzalloc(sizeof(*data), GFP_KERNEL);
@@ -2585,17 +2613,7 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
 	if (error < 0)
 		goto out;
 
-	export_path = data->nfs_server.export_path;
-	data->nfs_server.export_path = "/";
-	root_mnt = nfs_do_root_mount(&nfs4_remote_fs_type, flags, data,
-			data->nfs_server.hostname);
-	data->nfs_server.export_path = export_path;
-
-	error = PTR_ERR(root_mnt);
-	if (IS_ERR(root_mnt))
-		goto out;
-
-	error = nfs_follow_remote_path(root_mnt, export_path, mnt);
+	error = nfs4_try_mount(flags, dev_name, data, mnt);
 
 out:
 	kfree(data->client_address);

