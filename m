Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:33319 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753626AbbKQLxz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 06:53:55 -0500
Received: by qgea14 with SMTP id a14so3422570qge.0
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 03:53:54 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v1 36/38] nfs: add a get_parent export operation for NFS
Date: Tue, 17 Nov 2015 06:52:58 -0500
Message-Id: <1447761180-4250-37-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to connect disconnected dentries into the tree, we must be
able to determine their parent. Add a get_parent routine for NFS
which does a LOOKUPP operation (in the case of NFSv4), finds the
parent inode and then obtains the dentry for it.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/export.c | 43 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/fs/nfs/export.c b/fs/nfs/export.c
index a40a9fc31d13..e1c8165652c5 100644
--- a/fs/nfs/export.c
+++ b/fs/nfs/export.c
@@ -119,8 +119,51 @@ out:
 	return ret ? ERR_PTR(ret) : dentry;
 }
 
+static struct dentry *
+nfs_get_parent(struct dentry *dentry)
+{
+	int ret;
+	struct inode *inode = d_inode(dentry), *pinode;
+	struct super_block *sb = inode->i_sb;
+	struct nfs_server *server = NFS_SB(sb);
+	struct nfs_fattr *fattr = NULL;
+	struct nfs4_label *label = NULL;
+	struct dentry *parent;
+	struct nfs_rpc_ops const *ops = server->nfs_client->rpc_ops;
+	struct nfs_fh fh;
+
+	if (!ops->lookupp)
+		return ERR_PTR(-EACCES);
+
+	fattr = nfs_alloc_fattr();
+	if (fattr == NULL) {
+		parent = ERR_PTR(-ENOMEM);
+		goto out;
+	}
+
+	label = nfs4_label_alloc(server, GFP_KERNEL);
+	if (IS_ERR(label)) {
+		parent = ERR_CAST(label);
+		goto out;
+	}
+
+	ret = ops->lookupp(inode, &fh, fattr, label);
+	if (ret) {
+		parent = ERR_PTR(ret);
+		goto out;
+	}
+
+	pinode = nfs_fhget(sb, &fh, fattr, label);
+	parent = d_obtain_alias(pinode);
+out:
+	nfs4_label_free(label);
+	nfs_free_fattr(fattr);
+	return parent;
+}
+
 const struct export_operations nfs_export_ops = {
 	.encode_fh = nfs_encode_fh,
 	.fh_to_dentry = nfs_fh_to_dentry,
+	.get_parent = nfs_get_parent,
 	.flags = EXPORT_OP_NOWCC|EXPORT_OP_NOSUBTREECHK|EXPORT_OP_CLOSE_BEFORE_UNLINK,
 };
-- 
2.4.3

