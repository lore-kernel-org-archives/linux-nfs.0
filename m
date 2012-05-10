Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:60449 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761180Ab2EJTH6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 May 2012 15:07:58 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 09/14] NFS: Let mount data parsing set the NFS version
Date: Thu, 10 May 2012 15:07:38 -0400
Message-Id: <1336676863-9698-10-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1336676863-9698-1-git-send-email-bjschuma@netapp.com>
References: <1336676863-9698-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This field is unconditionally set while parsing mount data, so there is
no need to fill it in here.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/super.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 1157189..db0952d 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -945,7 +945,7 @@ static void nfs_umount_begin(struct super_block *sb)
 		rpc_killall_tasks(rpc);
 }
 
-static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(unsigned int version)
+static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(void)
 {
 	struct nfs_parsed_mount_data *data;
 
@@ -960,7 +960,6 @@ static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(unsigned int ve
 		data->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 		data->auth_flavors[0]	= RPC_AUTH_UNIX;
 		data->auth_flavor_len	= 1;
-		data->version		= version;
 		data->minorversion	= 0;
 		data->net		= current->nsproxy->net_ns;
 		security_init_mnt_opts(&data->lsm_opts);
@@ -2416,7 +2415,7 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	struct dentry *mntroot = ERR_PTR(-ENOMEM);
 	int error;
 
-	data = nfs_alloc_parsed_mount_data(NFS_DEFAULT_VERSION);
+	data = nfs_alloc_parsed_mount_data();
 	mntfh = nfs_alloc_fhandle();
 	if (data == NULL || mntfh == NULL)
 		goto out;
@@ -2867,7 +2866,7 @@ static struct dentry *nfs4_mount(struct file_system_type *fs_type,
 	int error = -ENOMEM;
 	struct dentry *res = ERR_PTR(-ENOMEM);
 
-	data = nfs_alloc_parsed_mount_data(4);
+	data = nfs_alloc_parsed_mount_data();
 	if (data == NULL)
 		goto out;
 
-- 
1.7.10.1

