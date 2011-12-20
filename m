Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qw0-f53.google.com ([209.85.216.53]:55997 "EHLO
	mail-qw0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809Ab1LTL5v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Dec 2011 06:57:51 -0500
Received: by qadb15 with SMTP id b15so3945423qad.19
        for <linux-nfs@vger.kernel.org>; Tue, 20 Dec 2011 03:57:51 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, eparis@redhat.com
Subject: [PATCH] nfs: fix regression in handling of context= option in NFSv4
Date: Tue, 20 Dec 2011 06:57:45 -0500
Message-Id: <1324382265-16254-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Setting the security context of a NFSv4 mount via the context= mount
option is currently broken. The NFSv4 codepath allocates a parsed
options struct, and then parses the mount options to fill it. It
eventually calls nfs4_remote_mount which calls security_init_mnt_opts.
That clobbers the lsm_opts struct that was populated earlier. This bug
also looks like it causes a small memory leak on each v4 mount where
context= is used.

Fix this by moving the initialization of the lsm_opts into
nfs_alloc_parsed_mount_data. Also, add a destructor for
nfs_parsed_mount_data to make it easier to free all of the allocations
hanging off of it, and to ensure that the security_free_mnt_opts is
called whenever security_init_mnt_opts is.

I believe this regression was introduced quite some time ago, probably
by commit c02d7adf.

Cc: stable@vger.kernel.org
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/super.c |   43 +++++++++++++++++++------------------------
 1 files changed, 19 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 6a73e57..5c9feb0 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -909,10 +909,24 @@ static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(unsigned int ve
 		data->auth_flavor_len	= 1;
 		data->version		= version;
 		data->minorversion	= 0;
+		security_init_mnt_opts(&data->lsm_opts);
 	}
 	return data;
 }
 
+static void nfs_free_parsed_mount_data(struct nfs_parsed_mount_data *data)
+{
+	if (data) {
+		kfree(data->client_address);
+		kfree(data->mount_server.hostname);
+		kfree(data->nfs_server.export_path);
+		kfree(data->nfs_server.hostname);
+		kfree(data->fscache_uniq);
+		security_free_mnt_opts(&data->lsm_opts);
+		kfree(data);
+	}
+}
+
 /*
  * Sanity-check a server address provided by the mount command.
  *
@@ -2220,9 +2234,7 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	data = nfs_alloc_parsed_mount_data(NFS_DEFAULT_VERSION);
 	mntfh = nfs_alloc_fhandle();
 	if (data == NULL || mntfh == NULL)
-		goto out_free_fh;
-
-	security_init_mnt_opts(&data->lsm_opts);
+		goto out;
 
 	/* Validate the mount data */
 	error = nfs_validate_mount_data(raw_data, data, mntfh, dev_name);
@@ -2234,8 +2246,6 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 #ifdef CONFIG_NFS_V4
 	if (data->version == 4) {
 		mntroot = nfs4_try_mount(flags, dev_name, data);
-		kfree(data->client_address);
-		kfree(data->nfs_server.export_path);
 		goto out;
 	}
 #endif	/* CONFIG_NFS_V4 */
@@ -2290,13 +2300,8 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	s->s_flags |= MS_ACTIVE;
 
 out:
-	kfree(data->nfs_server.hostname);
-	kfree(data->mount_server.hostname);
-	kfree(data->fscache_uniq);
-	security_free_mnt_opts(&data->lsm_opts);
-out_free_fh:
+	nfs_free_parsed_mount_data(data);
 	nfs_free_fhandle(mntfh);
-	kfree(data);
 	return mntroot;
 
 out_err_nosb:
@@ -2623,9 +2628,7 @@ nfs4_remote_mount(struct file_system_type *fs_type, int flags,
 
 	mntfh = nfs_alloc_fhandle();
 	if (data == NULL || mntfh == NULL)
-		goto out_free_fh;
-
-	security_init_mnt_opts(&data->lsm_opts);
+		goto out;
 
 	/* Get a volume representation */
 	server = nfs4_create_server(data, mntfh);
@@ -2676,13 +2679,10 @@ nfs4_remote_mount(struct file_system_type *fs_type, int flags,
 
 	s->s_flags |= MS_ACTIVE;
 
-	security_free_mnt_opts(&data->lsm_opts);
 	nfs_free_fhandle(mntfh);
 	return mntroot;
 
 out:
-	security_free_mnt_opts(&data->lsm_opts);
-out_free_fh:
 	nfs_free_fhandle(mntfh);
 	return ERR_PTR(error);
 
@@ -2837,7 +2837,7 @@ static struct dentry *nfs4_mount(struct file_system_type *fs_type,
 
 	data = nfs_alloc_parsed_mount_data(4);
 	if (data == NULL)
-		goto out_free_data;
+		goto out;
 
 	/* Validate the mount data */
 	error = nfs4_validate_mount_data(raw_data, data, dev_name);
@@ -2851,12 +2851,7 @@ static struct dentry *nfs4_mount(struct file_system_type *fs_type,
 		error = PTR_ERR(res);
 
 out:
-	kfree(data->client_address);
-	kfree(data->nfs_server.export_path);
-	kfree(data->nfs_server.hostname);
-	kfree(data->fscache_uniq);
-out_free_data:
-	kfree(data);
+	nfs_free_parsed_mount_data(data);
 	dprintk("<-- nfs4_mount() = %d%s\n", error,
 			error != 0 ? " [error]" : "");
 	return res;
-- 
1.7.7.3

