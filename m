Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:11792 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751696AbdHCSfU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 Aug 2017 14:35:20 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <linux-fsdevel@vger.kernel.org>, <linux-nfs@vger.kernel.org>
Subject: [RFC 2/3] NFS define vfs destroy_creds functions
Date: Thu, 3 Aug 2017 14:35:07 -0400
Message-ID: <20170803183508.24565-3-kolga@netapp.com>
In-Reply-To: <20170803183508.24565-1-kolga@netapp.com>
References: <20170803183508.24565-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Define the destroy_creds function for the NFS directory.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/dir.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 2ac00bf..2146aa5 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -54,6 +54,13 @@
 static loff_t nfs_llseek_dir(struct file *, loff_t, int);
 static void nfs_readdir_clear_array(struct page*);
 
+static int nfs_destroy_creds(struct file *file)
+{
+	struct rpc_auth *auth = NFS_SERVER(file_inode(file))->client->cl_auth;
+
+	return rpcauth_key_set_destroy(auth, rpc_lookup_cred());
+}
+
 const struct file_operations nfs_dir_operations = {
 	.llseek		= nfs_llseek_dir,
 	.read		= generic_read_dir,
@@ -61,6 +68,7 @@
 	.open		= nfs_opendir,
 	.release	= nfs_closedir,
 	.fsync		= nfs_fsync_dir,
+	.destroy_creds	= nfs_destroy_creds,
 };
 
 const struct address_space_operations nfs_dir_aops = {
-- 
1.8.3.1

