Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36916 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030313AbdKQRqN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Nov 2017 12:46:13 -0500
Received: by mail-it0-f68.google.com with SMTP id m191so4973268itg.2
        for <linux-nfs@vger.kernel.org>; Fri, 17 Nov 2017 09:46:13 -0800 (PST)
From: Joshua Watt <jpewhacker@gmail.com>
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        David Howells <dhowells@redhat.com>,
        Joshua Watt <JPEWhacker@gmail.com>
Subject: [RFC v4 5/9] NFS: Kill RPCs for the duration of umount
Date: Fri, 17 Nov 2017 11:45:48 -0600
Message-Id: <20171117174552.18722-6-JPEWhacker@gmail.com>
In-Reply-To: <20171117174552.18722-1-JPEWhacker@gmail.com>
References: <20171117174552.18722-1-JPEWhacker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RPCs are now killed for the duration of the umount operation when
MNT_FORCE is specified. Specifically, if the umount flags are MNT_FORCE
| MNT_DETACH, all future RPCs will be killed.

Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
---
 fs/nfs/internal.h  |  1 +
 fs/nfs/nfs4super.c |  1 +
 fs/nfs/super.c     | 36 +++++++++++++++++++++++++++++-------
 3 files changed, 31 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index f9a4a5524bd5..3ec165368a08 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -461,6 +461,7 @@ extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
 
 /* super.c */
 void nfs_umount_begin(struct super_block *);
+void nfs_umount_end(struct super_block *sb);
 int  nfs_statfs(struct dentry *, struct kstatfs *);
 int  nfs_show_options(struct seq_file *, struct dentry *);
 int  nfs_show_devname(struct seq_file *, struct dentry *);
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 6fb7cb6b3f4b..e9788f9c3394 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -56,6 +56,7 @@ static const struct super_operations nfs4_sops = {
 	.statfs		= nfs_statfs,
 	.evict_inode	= nfs4_evict_inode,
 	.umount_begin	= nfs_umount_begin,
+	.umount_end	= nfs_umount_end,
 	.show_options	= nfs_show_options,
 	.show_devname	= nfs_show_devname,
 	.show_path	= nfs_show_path,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 216f67d628b3..71361ca6d6b4 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -315,6 +315,7 @@ const struct super_operations nfs_sops = {
 	.statfs		= nfs_statfs,
 	.evict_inode	= nfs_evict_inode,
 	.umount_begin	= nfs_umount_begin,
+	.umount_end	= nfs_umount_end,
 	.show_options	= nfs_show_options,
 	.show_devname	= nfs_show_devname,
 	.show_path	= nfs_show_path,
@@ -890,6 +891,15 @@ int nfs_show_stats(struct seq_file *m, struct dentry *root)
 }
 EXPORT_SYMBOL_GPL(nfs_show_stats);
 
+static void
+kill_rpc(struct rpc_clnt *rpc)
+{
+	if (!IS_ERR(rpc)) {
+		atomic_inc(&rpc->cl_kill_new_tasks);
+		rpc_killall_tasks(rpc);
+	}
+}
+
 /*
  * Begin unmount by attempting to remove all automounted mountpoints we added
  * in response to xdev traversals and referrals
@@ -897,19 +907,31 @@ EXPORT_SYMBOL_GPL(nfs_show_stats);
 void nfs_umount_begin(struct super_block *sb)
 {
 	struct nfs_server *server;
-	struct rpc_clnt *rpc;
 
 	server = NFS_SB(sb);
 	/* -EIO all pending I/O */
-	rpc = server->client_acl;
-	if (!IS_ERR(rpc))
-		rpc_killall_tasks(rpc);
-	rpc = server->client;
-	if (!IS_ERR(rpc))
-		rpc_killall_tasks(rpc);
+	kill_rpc(server->client_acl);
+	kill_rpc(server->client);
 }
 EXPORT_SYMBOL_GPL(nfs_umount_begin);
 
+static void
+restore_rpc(struct rpc_clnt *rpc)
+{
+	if (!IS_ERR(rpc))
+		__atomic_add_unless(&rpc->cl_kill_new_tasks, -1, 0);
+}
+
+void
+nfs_umount_end(struct super_block *sb)
+{
+	struct nfs_server *server = NFS_SB(sb);
+
+	restore_rpc(server->client_acl);
+	restore_rpc(server->client);
+}
+EXPORT_SYMBOL_GPL(nfs_umount_end);
+
 static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(void)
 {
 	struct nfs_parsed_mount_data *data;
-- 
2.13.6

