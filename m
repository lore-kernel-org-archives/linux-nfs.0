From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT] Please pull NFS client fixes for 2.6.26...
Date: Mon, 23 Jun 2008 19:22:14 -0400
Message-ID: <1214263334.7205.61.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52608 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752413AbYFWXWQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jun 2008 19:22:16 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "hotfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git hotfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/mount_clnt.c |    5 ++-
 fs/nfs/super.c      |   76 +++++++++++++++++++++++++++++---------------------
 fs/nfs/write.c      |    7 +++--
 3 files changed, 51 insertions(+), 37 deletions(-)

commit 03fa9e84e5dc10aeacb0e4eb2f708cd9fc36a5b8
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Jun 5 16:02:35 2008 -0400

    NFS: nfs_updatepage(): don't mark page as dirty if an error occurred
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b7e2445737ff69cef892b6fd9cd71cae2c9e9515
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Jun 19 15:21:11 2008 -0400

    NFS: Fix filehandle size comparisons in the mount code
    
    Fix a sign issue in xdr_decode_fhstatus3()
    Fix incorrect comparison in nfs_validate_mount_data()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 33852a1f2bb014e4047a844556c0d76a2f790c37
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Jun 19 14:20:11 2008 -0400

    NFS: Reduce the NFS mount code stack usage.
    
    This appears to fix the Oops reported in
      http://bugzilla.kernel.org/show_bug.cgi?id=10826
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 49c7cd0..779d2eb 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -130,10 +130,11 @@ static int xdr_decode_fhstatus3(struct rpc_rqst *req, __be32 *p,
 				struct mnt_fhstatus *res)
 {
 	struct nfs_fh *fh = res->fh;
+	unsigned size;
 
 	if ((res->status = ntohl(*p++)) == 0) {
-		int size = ntohl(*p++);
-		if (size <= NFS3_FHSIZE) {
+		size = ntohl(*p++);
+		if (size <= NFS3_FHSIZE && size != 0) {
 			fh->size = size;
 			memcpy(fh->data, p, size);
 		} else
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2a4a024..614efee 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1216,8 +1216,6 @@ static int nfs_validate_mount_data(void *options,
 {
 	struct nfs_mount_data *data = (struct nfs_mount_data *)options;
 
-	memset(args, 0, sizeof(*args));
-
 	if (data == NULL)
 		goto out_no_data;
 
@@ -1251,13 +1249,13 @@ static int nfs_validate_mount_data(void *options,
 	case 5:
 		memset(data->context, 0, sizeof(data->context));
 	case 6:
-		if (data->flags & NFS_MOUNT_VER3)
+		if (data->flags & NFS_MOUNT_VER3) {
+			if (data->root.size > NFS3_FHSIZE || data->root.size == 0)
+				goto out_invalid_fh;
 			mntfh->size = data->root.size;
-		else
+		} else
 			mntfh->size = NFS2_FHSIZE;
 
-		if (mntfh->size > sizeof(mntfh->data))
-			goto out_invalid_fh;
 
 		memcpy(mntfh->data, data->root.data, mntfh->size);
 		if (mntfh->size < sizeof(mntfh->data))
@@ -1585,24 +1583,29 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 {
 	struct nfs_server *server = NULL;
 	struct super_block *s;
-	struct nfs_fh mntfh;
-	struct nfs_parsed_mount_data data;
+	struct nfs_parsed_mount_data *data;
+	struct nfs_fh *mntfh;
 	struct dentry *mntroot;
 	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
 	struct nfs_sb_mountdata sb_mntdata = {
 		.mntflags = flags,
 	};
-	int error;
+	int error = -ENOMEM;
+
+	data = kzalloc(sizeof(*data), GFP_KERNEL);
+	mntfh = kzalloc(sizeof(*mntfh), GFP_KERNEL);
+	if (data == NULL || mntfh == NULL)
+		goto out_free_fh;
 
-	security_init_mnt_opts(&data.lsm_opts);
+	security_init_mnt_opts(&data->lsm_opts);
 
 	/* Validate the mount data */
-	error = nfs_validate_mount_data(raw_data, &data, &mntfh, dev_name);
+	error = nfs_validate_mount_data(raw_data, data, mntfh, dev_name);
 	if (error < 0)
 		goto out;
 
 	/* Get a volume representation */
-	server = nfs_create_server(&data, &mntfh);
+	server = nfs_create_server(data, mntfh);
 	if (IS_ERR(server)) {
 		error = PTR_ERR(server);
 		goto out;
@@ -1630,16 +1633,16 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 
 	if (!s->s_root) {
 		/* initial superblock/root creation */
-		nfs_fill_super(s, &data);
+		nfs_fill_super(s, data);
 	}
 
-	mntroot = nfs_get_root(s, &mntfh);
+	mntroot = nfs_get_root(s, mntfh);
 	if (IS_ERR(mntroot)) {
 		error = PTR_ERR(mntroot);
 		goto error_splat_super;
 	}
 
-	error = security_sb_set_mnt_opts(s, &data.lsm_opts);
+	error = security_sb_set_mnt_opts(s, &data->lsm_opts);
 	if (error)
 		goto error_splat_root;
 
@@ -1649,9 +1652,12 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 	error = 0;
 
 out:
-	kfree(data.nfs_server.hostname);
-	kfree(data.mount_server.hostname);
-	security_free_mnt_opts(&data.lsm_opts);
+	kfree(data->nfs_server.hostname);
+	kfree(data->mount_server.hostname);
+	security_free_mnt_opts(&data->lsm_opts);
+out_free_fh:
+	kfree(mntfh);
+	kfree(data);
 	return error;
 
 out_err_nosb:
@@ -1800,8 +1806,6 @@ static int nfs4_validate_mount_data(void *options,
 	struct nfs4_mount_data *data = (struct nfs4_mount_data *)options;
 	char *c;
 
-	memset(args, 0, sizeof(*args));
-
 	if (data == NULL)
 		goto out_no_data;
 
@@ -1959,26 +1963,31 @@ out_no_client_address:
 static int nfs4_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt)
 {
-	struct nfs_parsed_mount_data data;
+	struct nfs_parsed_mount_data *data;
 	struct super_block *s;
 	struct nfs_server *server;
-	struct nfs_fh mntfh;
+	struct nfs_fh *mntfh;
 	struct dentry *mntroot;
 	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
 	struct nfs_sb_mountdata sb_mntdata = {
 		.mntflags = flags,
 	};
-	int error;
+	int error = -ENOMEM;
 
-	security_init_mnt_opts(&data.lsm_opts);
+	data = kzalloc(sizeof(*data), GFP_KERNEL);
+	mntfh = kzalloc(sizeof(*mntfh), GFP_KERNEL);
+	if (data == NULL || mntfh == NULL)
+		goto out_free_fh;
+
+	security_init_mnt_opts(&data->lsm_opts);
 
 	/* Validate the mount data */
-	error = nfs4_validate_mount_data(raw_data, &data, dev_name);
+	error = nfs4_validate_mount_data(raw_data, data, dev_name);
 	if (error < 0)
 		goto out;
 
 	/* Get a volume representation */
-	server = nfs4_create_server(&data, &mntfh);
+	server = nfs4_create_server(data, mntfh);
 	if (IS_ERR(server)) {
 		error = PTR_ERR(server);
 		goto out;
@@ -2009,13 +2018,13 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
 		nfs4_fill_super(s);
 	}
 
-	mntroot = nfs4_get_root(s, &mntfh);
+	mntroot = nfs4_get_root(s, mntfh);
 	if (IS_ERR(mntroot)) {
 		error = PTR_ERR(mntroot);
 		goto error_splat_super;
 	}
 
-	error = security_sb_set_mnt_opts(s, &data.lsm_opts);
+	error = security_sb_set_mnt_opts(s, &data->lsm_opts);
 	if (error)
 		goto error_splat_root;
 
@@ -2025,10 +2034,13 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
 	error = 0;
 
 out:
-	kfree(data.client_address);
-	kfree(data.nfs_server.export_path);
-	kfree(data.nfs_server.hostname);
-	security_free_mnt_opts(&data.lsm_opts);
+	kfree(data->client_address);
+	kfree(data->nfs_server.export_path);
+	kfree(data->nfs_server.hostname);
+	security_free_mnt_opts(&data->lsm_opts);
+out_free_fh:
+	kfree(mntfh);
+	kfree(data);
 	return error;
 
 out_free:
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 6d8ace3..f333848 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -739,12 +739,13 @@ int nfs_updatepage(struct file *file, struct page *page,
 	}
 
 	status = nfs_writepage_setup(ctx, page, offset, count);
-	__set_page_dirty_nobuffers(page);
+	if (status < 0)
+		nfs_set_pageerror(page);
+	else
+		__set_page_dirty_nobuffers(page);
 
         dprintk("NFS:      nfs_updatepage returns %d (isize %Ld)\n",
 			status, (long long)i_size_read(inode));
-	if (status < 0)
-		nfs_set_pageerror(page);
 	return status;
 }
 

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
