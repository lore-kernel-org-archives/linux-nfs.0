Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46148 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751955AbcILLQN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 12 Sep 2016 07:16:13 -0400
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: Andreas Gruenbacher <agruenba@redhat.com>, linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: Set s_time_gran consistently on NFSv2
Date: Mon, 12 Sep 2016 13:16:08 +0200
Message-Id: <1473678968-13124-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond and Anna,

is it true that nfs_clone_super accidentally sets s_time_gran to 1 on NFSv2?
If so, could you please merge the following patch?

Thanks,
Andreas

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/nfs/super.c | 25 +++++++++----------------
 1 file changed, 9 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index d396013..4c72fec 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2312,6 +2312,15 @@ inline void nfs_initialise_sb(struct super_block *sb)
 {
 	struct nfs_server *server = NFS_SB(sb);
 
+	if (server->nfs_client->rpc_ops->version != 2) {
+		sb->s_time_gran = 1;
+		/*
+		 * The VFS shouldn't apply the umask to mode bits. We will do
+		 * so ourselves when necessary.
+		 */
+		sb->s_flags |= MS_POSIXACL;
+	}
+
 	sb->s_magic = NFS_SUPER_MAGIC;
 
 	/* We probably want something more informative here */
@@ -2342,14 +2351,6 @@ void nfs_fill_super(struct super_block *sb, struct nfs_mount_info *mount_info)
 	if (data && data->bsize)
 		sb->s_blocksize = nfs_block_size(data->bsize, &sb->s_blocksize_bits);
 
-	if (server->nfs_client->rpc_ops->version != 2) {
-		/* The VFS shouldn't apply the umask to mode bits. We will do
-		 * so ourselves when necessary.
-		 */
-		sb->s_flags |= MS_POSIXACL;
-		sb->s_time_gran = 1;
-	}
-
  	nfs_initialise_sb(sb);
 }
 EXPORT_SYMBOL_GPL(nfs_fill_super);
@@ -2367,14 +2368,6 @@ void nfs_clone_super(struct super_block *sb, struct nfs_mount_info *mount_info)
 	sb->s_maxbytes = old_sb->s_maxbytes;
 	sb->s_xattr = old_sb->s_xattr;
 	sb->s_op = old_sb->s_op;
-	sb->s_time_gran = 1;
-
-	if (server->nfs_client->rpc_ops->version != 2) {
-		/* The VFS shouldn't apply the umask to mode bits. We will do
-		 * so ourselves when necessary.
-		 */
-		sb->s_flags |= MS_POSIXACL;
-	}
 
  	nfs_initialise_sb(sb);
 }
-- 
2.7.4

