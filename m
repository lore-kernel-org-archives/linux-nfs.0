Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:52145 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092Ab1CNM5E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Mar 2011 08:57:04 -0400
Received: by mail-iy0-f174.google.com with SMTP id 26so4900509iyb.19
        for <linux-nfs@vger.kernel.org>; Mon, 14 Mar 2011 05:57:03 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/12] NFS: Add a client-side function to display file handles
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 14 Mar 2011 08:57:01 -0400
Message-ID: <20110314125701.2413.7021.stgit@matisse.1015granger.net>
In-Reply-To: <20110314125204.2413.8870.stgit@matisse.1015granger.net>
References: <20110314125204.2413.8870.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

For debugging, introduce a simplistic function to print file handles
on the system console.  It's hooked into the dprintk debugging
facility, but you can call _nfs_display_fhandle() directly if you
always want to print a handle.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/inode.c         |   45 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs_fs.h |   14 ++++++++++++++
 2 files changed, 59 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 1cc600e..552c47b 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1033,6 +1033,51 @@ struct nfs_fh *nfs_alloc_fhandle(void)
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
index 6023efa..a3ed01d 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -384,6 +384,20 @@ static inline void nfs_free_fhandle(const struct nfs_fh *fh)
 	kfree(fh);
 }
 
+#ifdef RPC_DEBUG
+extern void _nfs_display_fhandle(const struct nfs_fh *fh, const char *caption);
+#define nfs_display_fhandle(fh, caption)			\
+	do {							\
+		if (unlikely(nfs_debug & NFSDBG_FACILITY))	\
+			_nfs_display_fhandle(fh, caption);	\
+	} while(0)
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

