Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:45757 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758615Ab2CBV7l (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Mar 2012 16:59:41 -0500
Received: by mail-iy0-f174.google.com with SMTP id z16so2853208iag.19
        for <linux-nfs@vger.kernel.org>; Fri, 02 Mar 2012 13:59:41 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/12] NFS: Add a client-side function to display NFS file
 handles
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 02 Mar 2012 16:59:40 -0500
Message-ID: <20120302215939.12758.77566.stgit@degas.1015granger.net>
In-Reply-To: <20120302215559.12758.39526.stgit@degas.1015granger.net>
References: <20120302215559.12758.39526.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For debugging, introduce a simplistic function to print NFS file
handles on the system console.  The main function is hooked into the
dprintk debugging facility, but you can directly call the helper,
_nfs_display_fhandle(), if you want to print a handle unconditionally.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/inode.c         |   45 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs_fs.h |   14 ++++++++++++++
 2 files changed, 59 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 6c66259..99a4f52 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1046,6 +1046,51 @@ struct nfs_fh *nfs_alloc_fhandle(void)
 }
 
 /**
+ * _nfs_display_fhandle - display an NFS file handle on the console
+ *
+ * @fh: file handle to display
+ * @caption: display caption
+ *
+ * For debugging only.
+ */
+#ifdef RPC_DEBUG
+void _nfs_display_fhandle(const struct nfs_fh *fh, const char *caption)
+{
+	unsigned short i;
+
+	if (fh->size == 0 || fh == NULL) {
+		printk(KERN_DEFAULT "%s at %p is empty\n", caption, fh);
+		return;
+	}
+
+	printk(KERN_DEFAULT "%s at %p is %u bytes:\n", caption, fh, fh->size);
+	for (i = 0; i < fh->size; i += 16) {
+		__be32 *pos = (__be32 *)&fh->data[i];
+
+		switch ((fh->size - i - 1) >> 2) {
+		case 0:
+			printk(KERN_DEFAULT " %08x\n",
+				be32_to_cpup(pos));
+			break;
+		case 1:
+			printk(KERN_DEFAULT " %08x %08x\n",
+				be32_to_cpup(pos), be32_to_cpup(pos + 1));
+			break;
+		case 2:
+			printk(KERN_DEFAULT " %08x %08x %08x\n",
+				be32_to_cpup(pos), be32_to_cpup(pos + 1),
+				be32_to_cpup(pos + 2));
+			break;
+		default:
+			printk(KERN_DEFAULT " %08x %08x %08x %08x\n",
+				be32_to_cpup(pos), be32_to_cpup(pos + 1),
+				be32_to_cpup(pos + 2), be32_to_cpup(pos + 3));
+		}
+	}
+}
+#endif
+
+/**
  * nfs_inode_attrs_need_update - check if the inode attributes need updating
  * @inode - pointer to inode
  * @fattr - attributes
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 8c29950..c07a757 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -395,6 +395,20 @@ static inline void nfs_free_fhandle(const struct nfs_fh *fh)
 	kfree(fh);
 }
 
+#ifdef RPC_DEBUG
+extern void _nfs_display_fhandle(const struct nfs_fh *fh, const char *caption);
+#define nfs_display_fhandle(fh, caption)			\
+	do {							\
+		if (unlikely(nfs_debug & NFSDBG_FACILITY))	\
+			_nfs_display_fhandle(fh, caption);	\
+	} while (0)
+#else
+static inline void nfs_display_fhandle(const struct nfs_fh *fh,
+				       const char *caption)
+{
+}
+#endif
+
 /*
  * linux/fs/nfs/nfsroot.c
  */

