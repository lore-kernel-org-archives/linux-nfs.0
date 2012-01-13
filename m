Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:56184 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932561Ab2AMULW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:22 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 22/44] NFS: Split nfs_fs_mount() into two functions
Date: Fri, 13 Jan 2012 15:10:31 -0500
Message-Id: <1326485453-1350-23-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I keep the generic setup stuff where it already is.  Then it calls one
function if v4 and another for v2 and v3.  Finally, it references the
module and exits.  This patch prepares for calling the approriate
function through the struct nfs_subversion.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/super.c |   81 +++++++++++++++++++++++++++++++++-----------------------
 1 files changed, 48 insertions(+), 33 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index d7cdc50..60d065f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2218,46 +2218,19 @@ static int nfs_bdi_register(struct nfs_server *server)
 	return bdi_register_dev(&server->backing_dev_info, server->s_dev);
 }
 
-static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *raw_data)
+struct dentry *generic_nfs_fs_mount(struct file_system_type *fs_type, int flags,
+				    const char *dev_name, struct nfs_fh *mntfh,
+				    struct nfs_parsed_mount_data *data)
 {
 	struct nfs_server *server = NULL;
 	struct super_block *s;
-	struct nfs_parsed_mount_data *data;
-	struct nfs_fh *mntfh;
 	struct dentry *mntroot = ERR_PTR(-ENOMEM);
 	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
 	struct nfs_sb_mountdata sb_mntdata = {
 		.mntflags = flags,
 	};
-	struct nfs_subversion *nfs_mod;
 	int error;
 
-	data = nfs_alloc_parsed_mount_data(NFS_DEFAULT_VERSION);
-	mntfh = nfs_alloc_fhandle();
-	if (data == NULL || mntfh == NULL)
-		goto out;
-
-	/* Validate the mount data */
-	error = nfs_validate_mount_data(raw_data, data, mntfh, dev_name);
-	if (error < 0) {
-		mntroot = ERR_PTR(error);
-		goto out;
-	}
-
-	nfs_mod = get_nfs_version(data->version);
-	if (IS_ERR(nfs_mod)) {
-		mntroot = (struct dentry *)nfs_mod;
-		goto out;
-	}
-
-#ifdef CONFIG_NFS_V4
-	if (data->version == 4) {
-		mntroot = nfs4_try_mount(flags, dev_name, data);
-		goto out;
-	}
-#endif	/* CONFIG_NFS_V4 */
-
 	/* Get a volume representation */
 	server = nfs_create_server(data, mntfh);
 	if (IS_ERR(server)) {
@@ -2305,12 +2278,9 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	if (error)
 		goto error_splat_root;
 
-	nfs_mod->reference();
 	s->s_flags |= MS_ACTIVE;
 
 out:
-	nfs_free_parsed_mount_data(data);
-	nfs_free_fhandle(mntfh);
 	return mntroot;
 
 out_err_nosb:
@@ -2326,6 +2296,51 @@ error_splat_super:
 error_splat_bdi:
 	deactivate_locked_super(s);
 	goto out;
+
+}
+
+static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
+	int flags, const char *dev_name, void *raw_data)
+{
+	struct nfs_parsed_mount_data *data;
+	struct nfs_fh *mntfh;
+	struct dentry *mntroot = ERR_PTR(-ENOMEM);
+	struct nfs_subversion *nfs_mod;
+	int error;
+
+	data = nfs_alloc_parsed_mount_data(NFS_DEFAULT_VERSION);
+	mntfh = nfs_alloc_fhandle();
+	if (data == NULL || mntfh == NULL)
+		goto out;
+
+	/* Validate the mount data */
+	error = nfs_validate_mount_data(raw_data, data, mntfh, dev_name);
+	if (error < 0) {
+		mntroot = ERR_PTR(error);
+		goto out;
+	}
+
+	nfs_mod = get_nfs_version(data->version);
+	if (IS_ERR(nfs_mod)) {
+		mntroot = (struct dentry *)nfs_mod;
+		goto out;
+	}
+
+#ifdef CONFIG_NFS_V4
+	if (data->version == 4)
+		mntroot = nfs4_try_mount(flags, dev_name, data);
+	else
+#endif	/* CONFIG_NFS_V4 */
+		mntroot = generic_nfs_fs_mount(fs_type, flags, dev_name, mntfh, data);
+
+	if (!IS_ERR(mntroot))
+		nfs_mod->reference();
+
+out:
+	nfs_free_parsed_mount_data(data);
+	nfs_free_fhandle(mntfh);
+	return mntroot;
+
 }
 
 /*
-- 
1.7.8.3

