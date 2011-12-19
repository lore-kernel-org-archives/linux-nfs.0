Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qw0-f53.google.com ([209.85.216.53]:50257 "EHLO
	mail-qw0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752277Ab1LSTu3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Dec 2011 14:50:29 -0500
Received: by qadb15 with SMTP id b15so3542063qad.19
        for <linux-nfs@vger.kernel.org>; Mon, 19 Dec 2011 11:50:28 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: eparis@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: fix regression in handling of context= option in NFSv4
Date: Mon, 19 Dec 2011 14:50:23 -0500
Message-Id: <1324324223-9933-1-git-send-email-jlayton@redhat.com>
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
nfs_alloc_parsed_mount_data, and the freeing of the same into the
functions that allocate the nfs_parsed_mount_data.

I believe this regression was introduced quite some time ago, probably
by commit c02d7adf.

Cc: stable@vger.kernel.org
Acked-by: Eric Paris <eparis@redhat.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/super.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 1347774..5e112f6 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -909,6 +909,7 @@ static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(unsigned int ve
 		data->auth_flavor_len	= 1;
 		data->version		= version;
 		data->minorversion	= 0;
+		security_init_mnt_opts(&data->lsm_opts);
 	}
 	return data;
 }
@@ -2222,8 +2223,6 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	if (data == NULL || mntfh == NULL)
 		goto out_free_fh;
 
-	security_init_mnt_opts(&data->lsm_opts);
-
 	/* Validate the mount data */
 	error = nfs_validate_mount_data(raw_data, data, mntfh, dev_name);
 	if (error < 0) {
@@ -2623,9 +2622,7 @@ nfs4_remote_mount(struct file_system_type *fs_type, int flags,
 
 	mntfh = nfs_alloc_fhandle();
 	if (data == NULL || mntfh == NULL)
-		goto out_free_fh;
-
-	security_init_mnt_opts(&data->lsm_opts);
+		goto out;
 
 	/* Get a volume representation */
 	server = nfs4_create_server(data, mntfh);
@@ -2677,13 +2674,10 @@ nfs4_remote_mount(struct file_system_type *fs_type, int flags,
 
 	s->s_flags |= MS_ACTIVE;
 
-	security_free_mnt_opts(&data->lsm_opts);
 	nfs_free_fhandle(mntfh);
 	return mntroot;
 
 out:
-	security_free_mnt_opts(&data->lsm_opts);
-out_free_fh:
 	nfs_free_fhandle(mntfh);
 	return ERR_PTR(error);
 
@@ -2856,6 +2850,7 @@ out:
 	kfree(data->nfs_server.export_path);
 	kfree(data->nfs_server.hostname);
 	kfree(data->fscache_uniq);
+	security_free_mnt_opts(&data->lsm_opts);
 out_free_data:
 	kfree(data);
 	dprintk("<-- nfs4_mount() = %d%s\n", error,
-- 
1.7.7.3

