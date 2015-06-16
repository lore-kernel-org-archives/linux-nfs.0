Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:35137 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756616AbbFPOtK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jun 2015 10:49:10 -0400
Received: by pdbnf5 with SMTP id nf5so16058011pdb.2
        for <linux-nfs@vger.kernel.org>; Tue, 16 Jun 2015 07:49:10 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Cc: Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 07/11] pnfs/flexfiles: add ff_layout_prepare_layoutstats
Date: Tue, 16 Jun 2015 22:47:28 +0800
Message-Id: <1434466052-10491-8-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1434466052-10491-1-git-send-email-tao.peng@primarydata.com>
References: <1434466052-10491-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It fills in the generic part of LAYOUTSTATS call. One thing to note
is that we don't really track if IO is continuous or not. So just fake
to use the completed bytes for it.

Still missing flexfiles specific part, which will be included in the next patch.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 71 ++++++++++++++++++++++++++++++++++
 1 file changed, 71 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 42f79c6..1efbef5 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -20,6 +20,7 @@
 #include "../nfs4trace.h"
 #include "../iostat.h"
 #include "../nfs.h"
+#include "../nfs42.h"
 
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
 
@@ -1661,6 +1662,75 @@ out:
 	dprintk("%s: Return\n", __func__);
 }
 
+static bool
+ff_layout_mirror_prepare_stats(struct nfs42_layoutstat_args *args,
+			       struct pnfs_layout_segment *pls,
+			       int *dev_count, int dev_limit)
+{
+	struct nfs4_ff_layout_mirror *mirror;
+	struct nfs4_deviceid_node *dev;
+	struct nfs42_layoutstat_devinfo *devinfo;
+	int i;
+
+	for (i = 0; i <= FF_LAYOUT_MIRROR_COUNT(pls); i++) {
+		if (*dev_count >= dev_limit)
+			break;
+		mirror = FF_LAYOUT_COMP(pls, i);
+		dev = FF_LAYOUT_DEVID_NODE(pls, i);
+		devinfo = &args->devinfo[*dev_count];
+		memcpy(&devinfo->dev_id, &dev->deviceid, NFS4_DEVICEID4_SIZE);
+		devinfo->offset = pls->pls_range.offset;
+		devinfo->length = pls->pls_range.length;
+		/* well, we don't really know if IO is continuous or not! */
+		devinfo->read_count = mirror->read_stat.io_stat.bytes_completed;
+		devinfo->read_bytes = mirror->read_stat.io_stat.bytes_completed;
+		devinfo->write_count = mirror->write_stat.io_stat.bytes_completed;
+		devinfo->write_bytes = mirror->write_stat.io_stat.bytes_completed;
+		devinfo->layout_type = LAYOUT_FLEX_FILES;
+		devinfo->layoutstats_encode = NULL;
+		devinfo->layout_private = NULL;
+
+		++(*dev_count);
+	}
+
+	return *dev_count < dev_limit;
+}
+
+static int
+ff_layout_prepare_layoutstats(struct nfs42_layoutstat_args *args)
+{
+	struct pnfs_layout_segment *pls;
+	int dev_count = 0;
+
+	spin_lock(&args->inode->i_lock);
+	list_for_each_entry(pls, &NFS_I(args->inode)->layout->plh_segs, pls_list) {
+		dev_count += FF_LAYOUT_MIRROR_COUNT(pls);
+	}
+	spin_unlock(&args->inode->i_lock);
+	/* For now, send at most PNFS_LAYOUTSTATS_MAXDEV statistics */
+	if (dev_count > PNFS_LAYOUTSTATS_MAXDEV) {
+		dprintk("%s: truncating devinfo to limit (%d:%d)\n",
+			__func__, dev_count, PNFS_LAYOUTSTATS_MAXDEV);
+		dev_count = PNFS_LAYOUTSTATS_MAXDEV;
+	}
+	args->devinfo = kmalloc(dev_count * sizeof(*args->devinfo), GFP_KERNEL);
+	if (!args->devinfo)
+		return -ENOMEM;
+
+	dev_count = 0;
+	spin_lock(&args->inode->i_lock);
+	list_for_each_entry(pls, &NFS_I(args->inode)->layout->plh_segs, pls_list) {
+		if (!ff_layout_mirror_prepare_stats(args, pls, &dev_count,
+						    PNFS_LAYOUTSTATS_MAXDEV)) {
+			break;
+		}
+	}
+	spin_unlock(&args->inode->i_lock);
+	args->num_dev = dev_count;
+
+	return 0;
+}
+
 static struct pnfs_layoutdriver_type flexfilelayout_type = {
 	.id			= LAYOUT_FLEX_FILES,
 	.name			= "LAYOUT_FLEX_FILES",
@@ -1683,6 +1753,7 @@ static struct pnfs_layoutdriver_type flexfilelayout_type = {
 	.alloc_deviceid_node    = ff_layout_alloc_deviceid_node,
 	.encode_layoutreturn    = ff_layout_encode_layoutreturn,
 	.sync			= pnfs_nfs_generic_sync,
+	.prepare_layoutstats	= ff_layout_prepare_layoutstats,
 };
 
 static int __init nfs4flexfilelayout_init(void)
-- 
1.8.3.1

