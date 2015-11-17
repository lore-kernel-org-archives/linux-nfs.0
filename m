Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:36298 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753569AbbKQLx4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 06:53:56 -0500
Received: by qgad10 with SMTP id d10so3415510qga.3
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 03:53:56 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v1 37/38] nfs: set export ops
Date: Tue, 17 Nov 2015 06:52:59 -0500
Message-Id: <1447761180-4250-38-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

All the pieces are in place. We can now set the export ops in the
superblock.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/internal.h | 2 ++
 fs/nfs/super.c    | 4 ++++
 2 files changed, 6 insertions(+)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 56cfde26fb9c..fb83d83c959e 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -10,6 +10,8 @@
 
 #define NFS_MS_MASK (MS_RDONLY|MS_NOSUID|MS_NODEV|MS_NOEXEC|MS_SYNCHRONOUS)
 
+extern const struct export_operations nfs_export_ops;
+
 struct nfs_string;
 
 /* Maximum number of readahead requests
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f1268280244e..ee3cc13c92cb 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2321,6 +2321,9 @@ void nfs_fill_super(struct super_block *sb, struct nfs_mount_info *mount_info)
 		 */
 		sb->s_flags |= MS_POSIXACL;
 		sb->s_time_gran = 1;
+#if IS_ENABLED(CONFIG_NFS_REEXPORT)
+		sb->s_export_op = &nfs_export_ops;
+#endif
 	}
 
  	nfs_initialise_sb(sb);
@@ -2341,6 +2344,7 @@ void nfs_clone_super(struct super_block *sb, struct nfs_mount_info *mount_info)
 	sb->s_xattr = old_sb->s_xattr;
 	sb->s_op = old_sb->s_op;
 	sb->s_time_gran = 1;
+	sb->s_export_op = old_sb->s_export_op;
 
 	if (server->nfs_client->rpc_ops->version != 2) {
 		/* The VFS shouldn't apply the umask to mode bits. We will do
-- 
2.4.3

