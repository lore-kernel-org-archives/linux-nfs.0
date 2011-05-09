Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:58964 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754072Ab1EIThM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 15:37:12 -0400
Received: by mail-yx0-f174.google.com with SMTP id 7so1914279yxs.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 May 2011 12:37:12 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/16] NFS: Add a client-side function to display file handles
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 09 May 2011 15:37:10 -0400
Message-ID: <20110509193710.16568.68115.stgit@matisse.1015granger.net>
In-Reply-To: <20110509192522.16568.59082.stgit@matisse.1015granger.net>
References: <20110509192522.16568.59082.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

For debugging, introduce a simplistic function to print file handles
on the system console.  It's hooked into the dprintk debugging
facility, but you can call _nfs_display_fhandle() directly if you
want to print a handle unconditionally.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/inode.c         |   45 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs_fs.h |   14 ++++++++++++++
 2 files changed, 59 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 57bb31a..9a444d0 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1039,6 +1039,51 @@ struct nfs_fh *nfs_alloc_fhandle(void)
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
+		printk(KERN_NOTICE "%s at %p is empty\n", caption, fh);
+		return;
+	}
+
+	printk(KERN_NOTICE "%s at %p is %u bytes:\n", caption, fh, fh->size);
+	for (i = 0; i < fh->size; i += 16) {
+		__be32 *pos = (__be32 *)&fh->data[i];
+
+		switch ((fh->size - i - 1) >> 2) {
+		case 0:
+			printk(KERN_NOTICE " %08x",
+				be32_to_cpup(pos));
+			break;
+		case 1:
+			printk(KERN_NOTICE " %08x %08x\n",
+				be32_to_cpup(pos), be32_to_cpup(pos + 1));
+			break;
+		case 2:
+			printk(KERN_NOTICE " %08x %08x %08x\n",
+				be32_to_cpup(pos), be32_to_cpup(pos + 1),
+				be32_to_cpup(pos + 2));
+			break;
+		default:
+			printk(KERN_NOTICE " %08x %08x %08x %08x\n",
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
index 1b93b9c..0e3eb70 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -394,6 +394,20 @@ static inline void nfs_free_fhandle(const struct nfs_fh *fh)
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

