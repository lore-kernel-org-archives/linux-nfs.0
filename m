Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:33464 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751510AbdF0PoP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Jun 2017 11:44:15 -0400
From: Christoph Hellwig <hch@lst.de>
To: trond.myklebust@primarydata.com
Cc: jlayton@poochiereds.net, linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] nfs: add export operations
Date: Tue, 27 Jun 2017 08:44:03 -0700
Message-Id: <20170627154403.20944-5-hch@lst.de>
In-Reply-To: <20170627154403.20944-1-hch@lst.de>
References: <20170627154403.20944-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

This support for opening files on NFS by file handle, both through the
open_by_handle syscall, and for re-exporting NFS (for example using a
different version).  The support is very basic for now, as each open by
handle will have to do an NFSv4 open operation on the wire.  In the
future this will hopefully be mitigated by an open file cache, as well
as various optimizations in NFS for this specific case.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
[hch: incorporated various changes, resplit the patches, new changelog]
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/Makefile   |   2 +-
 fs/nfs/export.c   | 177 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/internal.h |   2 +
 fs/nfs/super.c    |   2 +
 4 files changed, 182 insertions(+), 1 deletion(-)
 create mode 100644 fs/nfs/export.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 98f4e5728a67..1fb118902d57 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -7,7 +7,7 @@ obj-$(CONFIG_NFS_FS) += nfs.o
 CFLAGS_nfstrace.o += -I$(src)
 nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o \
 			   io.o direct.o pagelist.o read.o symlink.o unlink.o \
-			   write.o namespace.o mount_clnt.o nfstrace.o
+			   write.o namespace.o mount_clnt.o nfstrace.o export.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
 nfs-$(CONFIG_SYSCTL)	+= sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
diff --git a/fs/nfs/export.c b/fs/nfs/export.c
new file mode 100644
index 000000000000..249cb96cc5b5
--- /dev/null
+++ b/fs/nfs/export.c
@@ -0,0 +1,177 @@
+/*
+ * Copyright (c) 2015, Primary Data, Inc. All rights reserved.
+ *
+ * Tao Peng <bergwolf@primarydata.com>
+ */
+#include <linux/dcache.h>
+#include <linux/exportfs.h>
+#include <linux/nfs.h>
+#include <linux/nfs_fs.h>
+
+#include "internal.h"
+#include "nfstrace.h"
+
+#define NFSDBG_FACILITY		NFSDBG_VFS
+
+enum {
+	FILEID_HIGH_OFF = 0,	/* inode fileid high */
+	FILEID_LOW_OFF,		/* inode fileid low */
+	FILE_I_TYPE_OFF,	/* inode type */
+	EMBED_FH_OFF		/* embeded server fh */
+};
+
+
+static struct nfs_fh *nfs_exp_embedfh(__u32 *p)
+{
+	return (struct nfs_fh *)(p + EMBED_FH_OFF);
+}
+
+/*
+ * Let's break subtree checking for now... otherwise we'll have to embed parent fh
+ * but there might not be enough space.
+ */
+static int
+nfs_encode_fh(struct inode *inode, __u32 *p, int *max_len, struct inode *parent)
+{
+	struct nfs_fh *server_fh = NFS_FH(inode);
+	struct nfs_fh *clnt_fh = nfs_exp_embedfh(p);
+	size_t fh_size = offsetof(struct nfs_fh, data) + server_fh->size;
+	int len = EMBED_FH_OFF + XDR_QUADLEN(fh_size);
+
+	dprintk("%s: max fh len %d inode %p parent %p",
+		__func__, *max_len, inode, parent);
+
+	if (*max_len < len || IS_AUTOMOUNT(inode)) {
+		dprintk("%s: fh len %d too small, required %d\n",
+			__func__, *max_len, len);
+		*max_len = len;
+		return FILEID_INVALID;
+	}
+	if (IS_AUTOMOUNT(inode)) {
+		*max_len = FILEID_INVALID;
+		goto out;
+	}
+
+	p[FILEID_HIGH_OFF] = NFS_FILEID(inode) >> 32;
+	p[FILEID_LOW_OFF] = NFS_FILEID(inode);
+	p[FILE_I_TYPE_OFF] = inode->i_mode & S_IFMT;
+	p[len - 1] = 0; /* Padding */
+	nfs_copy_fh(clnt_fh, server_fh);
+	*max_len = len;
+out:
+	dprintk("%s: result fh fileid %llu mode %u size %d\n",
+		__func__, NFS_FILEID(inode), inode->i_mode, *max_len);
+	return *max_len;
+}
+
+static struct dentry *
+nfs_fh_to_dentry(struct super_block *sb, struct fid *fid,
+		 int fh_len, int fh_type)
+{
+	struct nfs4_label *label = NULL;
+	struct nfs_fattr *fattr = NULL;
+	struct nfs_fh *server_fh = nfs_exp_embedfh(fid->raw);
+	size_t fh_size = offsetof(struct nfs_fh, data) + server_fh->size;
+	const struct nfs_rpc_ops *rpc_ops;
+	struct dentry *dentry;
+	struct inode *inode;
+	int len = EMBED_FH_OFF + XDR_QUADLEN(fh_size);
+	u32 *p = fid->raw;
+	int ret;
+
+	/* NULL translates to ESTALE */
+	if (fh_len < len || fh_type != len)
+		return NULL;
+
+	fattr = nfs_alloc_fattr();
+	if (fattr == NULL) {
+		dentry = ERR_PTR(-ENOMEM);
+		goto out;
+	}
+
+	fattr->fileid = ((u64)p[FILEID_HIGH_OFF] << 32) + p[FILEID_LOW_OFF];
+	fattr->mode = p[FILE_I_TYPE_OFF];
+	fattr->valid |= NFS_ATTR_FATTR_FILEID | NFS_ATTR_FATTR_TYPE;
+
+	dprintk("%s: fileid %llu mode %d\n", __func__, fattr->fileid, fattr->mode);
+
+	inode = nfs_ilookup(sb, fattr, server_fh);
+	if (inode)
+		goto out_found;
+
+	label = nfs4_label_alloc(NFS_SB(sb), GFP_KERNEL);
+	if (IS_ERR(label)) {
+		dentry = ERR_CAST(label);
+		goto out_free_fattr;
+	}
+
+	rpc_ops = NFS_SB(sb)->nfs_client->rpc_ops;
+	ret = rpc_ops->getattr(NFS_SB(sb), server_fh, fattr, label);
+	if (ret) {
+		dprintk("%s: getattr failed %d\n", __func__, ret);
+		dentry = ERR_PTR(ret);
+		goto out_free_label;
+	}
+
+	inode = nfs_fhget(sb, server_fh, fattr, label);
+
+out_found:
+	dentry = d_obtain_alias(inode);
+
+out_free_label:
+	nfs4_label_free(label);
+out_free_fattr:
+	nfs_free_fattr(fattr);
+out:
+	return dentry;
+}
+
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
+		goto out_free_fattr;
+	}
+
+	ret = ops->lookupp(inode, &fh, fattr, label);
+	if (ret) {
+		parent = ERR_PTR(ret);
+		goto out_free_label;
+	}
+
+	pinode = nfs_fhget(sb, &fh, fattr, label);
+	parent = d_obtain_alias(pinode);
+out_free_label:
+	nfs4_label_free(label);
+out_free_fattr:
+	nfs_free_fattr(fattr);
+out:
+	return parent;
+}
+
+const struct export_operations nfs_export_ops = {
+	.encode_fh = nfs_encode_fh,
+	.fh_to_dentry = nfs_fh_to_dentry,
+	.get_parent = nfs_get_parent,
+};
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 3e24392f2caa..cb38c3cd6a49 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -10,6 +10,8 @@
 
 #define NFS_MS_MASK (MS_RDONLY|MS_NOSUID|MS_NODEV|MS_NOEXEC|MS_SYNCHRONOUS)
 
+extern const struct export_operations nfs_export_ops;
+
 struct nfs_string;
 
 /* Maximum number of readahead requests
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index eceb4eabb064..86781a630c22 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2339,6 +2339,7 @@ void nfs_fill_super(struct super_block *sb, struct nfs_mount_info *mount_info)
 		 */
 		sb->s_flags |= MS_POSIXACL;
 		sb->s_time_gran = 1;
+		sb->s_export_op = &nfs_export_ops;
 	}
 
  	nfs_initialise_sb(sb);
@@ -2360,6 +2361,7 @@ static void nfs_clone_super(struct super_block *sb,
 	sb->s_xattr = old_sb->s_xattr;
 	sb->s_op = old_sb->s_op;
 	sb->s_time_gran = 1;
+	sb->s_export_op = old_sb->s_export_op;
 
 	if (server->nfs_client->rpc_ops->version != 2) {
 		/* The VFS shouldn't apply the umask to mode bits. We will do
-- 
2.11.0

