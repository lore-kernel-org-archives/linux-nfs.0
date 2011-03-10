Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:52953 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752690Ab1CJRc1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Mar 2011 12:32:27 -0500
Received: by gxk8 with SMTP id 8so745972gxk.19
        for <linux-nfs@vger.kernel.org>; Thu, 10 Mar 2011 09:32:27 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/8] NFS: Add a lame client-side function to display file
	handles
To: linux-nfs@vger.kernel.org
Date: Thu, 10 Mar 2011 12:29:40 -0500
Message-ID: <20110310172940.8878.11138.stgit@matisse.1015granger.net>
In-Reply-To: <20110310171345.8878.25548.stgit@matisse.1015granger.net>
References: <20110310171345.8878.25548.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

nfs_display_fhandle() is a lame client-side function to display
file handles on the console.  It is for debugging only.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/inode.c         |   44 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs_fs.h |   13 +++++++++++++
 2 files changed, 57 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 1cc600e..1325160 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1033,6 +1033,50 @@ struct nfs_fh *nfs_alloc_fhandle(void)
 }
 
 /**
+ * _nfs_display_fhandle - display an NFS file handle on the console
+ *
+ * @fh: file handle to display
+ *
+ * For debugging only.
+ */
+#ifdef RPC_DEBUG
+void _nfs_display_fhandle(const struct nfs_fh *fh)
+{
+	unsigned short i;
+
+	if (fh->size == 0 || fh == NULL) {
+		printk(KERN_NOTICE "Empty NFS file handle at %p\n", fh);
+		return;
+	}
+
+	printk(KERN_NOTICE "NFS file handle at %p (size %u):\n", fh, fh->size);
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
index 6023efa..511e22a 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -384,6 +384,19 @@ static inline void nfs_free_fhandle(const struct nfs_fh *fh)
 	kfree(fh);
 }
 
+#ifdef RPC_DEBUG
+extern void _nfs_display_fhandle(const struct nfs_fh *fh);
+#define nfs_display_fhandle(fh)					\
+	do {							\
+		if (unlikely(nfs_debug & NFSDBG_FACILITY))	\
+			_nfs_display_fhandle(fh);		\
+	} while(0)
+#else
+static inline void nfs_display_fhandle(const struct nfs_fh *fh)
+{
+}
+#endif
+
 /*
  * linux/fs/nfs/nfsroot.c
  */

