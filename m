Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:35881 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753582AbbKQLxv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 06:53:51 -0500
Received: by qkda6 with SMTP id a6so1677525qkd.3
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 03:53:50 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v1 32/38] nfs: add encode_fh export op
Date: Tue, 17 Nov 2015 06:52:54 -0500
Message-Id: <1447761180-4250-33-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

A very first step of re-exporting nfs via knfsd. For now, it's just
copying the underlying server's filehandle. Later patches will add
the piece that embeds it in a new FH instead.

[jlayton: add export ops flags field]

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/Makefile |  1 +
 fs/nfs/export.c | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 47 insertions(+)
 create mode 100644 fs/nfs/export.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 8664417955a2..f1443f14be79 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -11,6 +11,7 @@ nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o \
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
 nfs-$(CONFIG_SYSCTL)	+= sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
+nfs-$(CONFIG_NFS_REEXPORT) += export.o
 
 obj-$(CONFIG_NFS_V2) += nfsv2.o
 nfsv2-y := nfs2super.o proc.o nfs2xdr.o
diff --git a/fs/nfs/export.c b/fs/nfs/export.c
new file mode 100644
index 000000000000..d446f77b26b3
--- /dev/null
+++ b/fs/nfs/export.c
@@ -0,0 +1,46 @@
+/*
+ * Module for pnfs flexfile layout driver.
+ *
+ * Copyright (c) 2015, Primary Data, Inc. All rights reserved.
+ *
+ * Tao Peng <bergwolf@primarydata.com>
+ */
+
+#include <linux/exportfs.h>
+#include <linux/nfs.h>
+#include <linux/nfs_fs.h>
+
+#include "nfstrace.h"
+
+#define NFSDBG_FACILITY		NFSDBG_VFS
+
+/*
+ * Let's break subtree checking for now... otherwise we'll have to embed parent fh
+ * but there might not be enough space.
+ */
+static int
+nfs_encode_fh(struct inode *inode, __u32 *p, int *max_len, struct inode *parent)
+{
+	struct nfs_fh *server_fh = NFS_FH(inode);
+	struct nfs_fh *clnt_fh = (struct nfs_fh *)p;
+	int disconnected_fh_len = server_fh->size / 4 + 1;
+
+	dprintk("%s: max fh len %d inode %p parent %p",
+		__func__, *max_len, inode, parent);
+
+	if (*max_len < disconnected_fh_len) {
+		*max_len = disconnected_fh_len;
+		return FILEID_INVALID;
+	}
+
+	nfs_copy_fh(clnt_fh, server_fh);
+	*max_len = disconnected_fh_len;
+
+	dprintk("%s: result fh size %d\n", __func__, *max_len);
+	return *max_len;
+}
+
+const struct export_operations nfs_export_ops = {
+	.encode_fh = nfs_encode_fh,
+	.flags = EXPORT_OP_NOWCC|EXPORT_OP_NOSUBTREECHK|EXPORT_OP_CLOSE_BEFORE_UNLINK,
+};
-- 
2.4.3

