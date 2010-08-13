Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48989 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753888Ab0HMVcV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:21 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 20/50] pnfs_submit: filelayout alloc_layout and free_layout
Date: Fri, 13 Aug 2010 17:31:32 -0400
Message-Id: <1281735122-1496-21-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-20-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
 <1281735122-1496-12-git-send-email-andros@netapp.com>
 <1281735122-1496-13-git-send-email-andros@netapp.com>
 <1281735122-1496-14-git-send-email-andros@netapp.com>
 <1281735122-1496-15-git-send-email-andros@netapp.com>
 <1281735122-1496-16-git-send-email-andros@netapp.com>
 <1281735122-1496-17-git-send-email-andros@netapp.com>
 <1281735122-1496-18-git-send-email-andros@netapp.com>
 <1281735122-1496-19-git-send-email-andros@netapp.com>
 <1281735122-1496-20-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   24 ++++++++++++++++++++++++
 fs/nfs/nfs4filelayout.h |   10 ++++++++++
 2 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 7039d9d..e1a09a8 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -82,7 +82,31 @@ filelayout_uninitialize_mountpoint(struct nfs_server *nfss)
 	return 0;
 }
 
+/*
+ * Create a filelayout layout structure and return it.  The pNFS client
+ * will use the pnfs_layout_type type to refer to the layout for this
+ * inode from now on.
+ */
+static struct pnfs_layout_type *
+filelayout_alloc_layout(struct inode *inode)
+{
+	struct nfs4_filelayout *flp;
+
+	dprintk("NFS_FILELAYOUT: allocating layout\n");
+	flp =  kzalloc(sizeof(struct nfs4_filelayout), GFP_KERNEL);
+	return flp ? &flp->fl_layout : NULL;
+}
+
+/* Free a filelayout layout structure */
+static void
+filelayout_free_layout(struct pnfs_layout_type *lo)
+{
+	dprintk("NFS_FILELAYOUT: freeing layout\n");
+	kfree(FILE_LO(lo));
+}
 struct layoutdriver_io_operations filelayout_io_operations = {
+	.alloc_layout            = filelayout_alloc_layout,
+	.free_layout             = filelayout_free_layout,
 	.initialize_mountpoint   = filelayout_initialize_mountpoint,
 	.uninitialize_mountpoint = filelayout_uninitialize_mountpoint,
 };
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index be3c9fe..ad975fd 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -41,6 +41,16 @@ struct nfs4_file_layout_dsaddr {
 	struct nfs4_pnfs_ds	*ds_list[1];
 };
 
+struct nfs4_filelayout {
+	struct pnfs_layout_type fl_layout;
+	u32 stripe_unit;
+};
+
+static inline struct nfs4_filelayout *
+FILE_LO(struct pnfs_layout_type *lo)
+{
+	return container_of(lo, struct nfs4_filelayout, fl_layout);
+}
 
 extern struct pnfs_client_operations *pnfs_callback_ops;
 
-- 
1.6.2.5

