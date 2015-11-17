Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:34835 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753592AbbKQLxw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 06:53:52 -0500
Received: by qgec40 with SMTP id c40so3396332qge.2
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 03:53:51 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v1 33/38] nfs: add fh_to_dentry export op
Date: Tue, 17 Nov 2015 06:52:55 -0500
Message-Id: <1447761180-4250-34-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/export.c | 49 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 49 insertions(+)

diff --git a/fs/nfs/export.c b/fs/nfs/export.c
index d446f77b26b3..374dcc2590a0 100644
--- a/fs/nfs/export.c
+++ b/fs/nfs/export.c
@@ -6,10 +6,12 @@
  * Tao Peng <bergwolf@primarydata.com>
  */
 
+#include <linux/dcache.h>
 #include <linux/exportfs.h>
 #include <linux/nfs.h>
 #include <linux/nfs_fs.h>
 
+#include "internal.h"
 #include "nfstrace.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
@@ -40,7 +42,54 @@ nfs_encode_fh(struct inode *inode, __u32 *p, int *max_len, struct inode *parent)
 	return *max_len;
 }
 
+static struct dentry *
+nfs_fh_to_dentry(struct super_block *sb, struct fid *fid,
+		 int fh_len, int fh_type)
+{
+	struct nfs4_label *label = NULL;
+	struct nfs_fattr *fattr = NULL;
+	struct nfs_fh *server_fh = (struct nfs_fh *)fid->raw;
+	const struct nfs_rpc_ops *rpc_ops;
+	struct dentry *dentry = NULL;
+	struct inode *inode;
+	int len = server_fh->size / 4 + 1;
+	int ret;
+
+	/* NULL translates to ESTALE */
+	if (fh_len < len || fh_type != len)
+		return NULL;
+
+	fattr = nfs_alloc_fattr();
+	if (fattr == NULL) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	label = nfs4_label_alloc(NFS_SB(sb), GFP_KERNEL);
+	if (IS_ERR(label)) {
+		ret = PTR_ERR(label);
+		goto out;
+	}
+
+	rpc_ops = NFS_SB(sb)->nfs_client->rpc_ops;
+	ret = rpc_ops->getattr(NFS_SB(sb), server_fh, fattr, label);
+	if (ret) {
+		dprintk("%s: getattr failed %d\n", __func__, ret);
+		goto out;
+	}
+
+	inode = nfs_fhget(sb, server_fh, fattr, label);
+	dentry = d_obtain_alias(inode);
+
+out:
+	nfs4_label_free(label);
+	nfs_free_fattr(fattr);
+
+	return ret ? ERR_PTR(ret) : dentry;
+}
+
 const struct export_operations nfs_export_ops = {
 	.encode_fh = nfs_encode_fh,
+	.fh_to_dentry = nfs_fh_to_dentry,
 	.flags = EXPORT_OP_NOWCC|EXPORT_OP_NOSUBTREECHK|EXPORT_OP_CLOSE_BEFORE_UNLINK,
 };
-- 
2.4.3

