Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36775 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751308AbcLCU6I (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Dec 2016 15:58:08 -0500
Received: by mail-io0-f193.google.com with SMTP id s82so14800609ioi.3
        for <linux-nfs@vger.kernel.org>; Sat, 03 Dec 2016 12:57:36 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 07/10] pNFS/flexfiles: Clean up layoutstats
Date: Sat,  3 Dec 2016 15:57:22 -0500
Message-Id: <20161203205725.12961-8-trond.myklebust@primarydata.com>
In-Reply-To: <20161203205725.12961-7-trond.myklebust@primarydata.com>
References: <20161203205725.12961-1-trond.myklebust@primarydata.com>
 <20161203205725.12961-2-trond.myklebust@primarydata.com>
 <20161203205725.12961-3-trond.myklebust@primarydata.com>
 <20161203205725.12961-4-trond.myklebust@primarydata.com>
 <20161203205725.12961-5-trond.myklebust@primarydata.com>
 <20161203205725.12961-6-trond.myklebust@primarydata.com>
 <20161203205725.12961-7-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 27 +++++++--------------------
 1 file changed, 7 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 7f31c359a28a..f61df1641567 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -2227,14 +2227,13 @@ ff_layout_encode_layoutstats(struct xdr_stream *xdr,
 }
 
 static int
-ff_layout_mirror_prepare_stats(struct nfs42_layoutstat_args *args,
-			       struct pnfs_layout_hdr *lo,
+ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
+			       struct nfs42_layoutstat_devinfo *devinfo,
 			       int dev_limit)
 {
 	struct nfs4_flexfile_layout *ff_layout = FF_LAYOUT_FROM_HDR(lo);
 	struct nfs4_ff_layout_mirror *mirror;
 	struct nfs4_deviceid_node *dev;
-	struct nfs42_layoutstat_devinfo *devinfo;
 	int i = 0;
 
 	list_for_each_entry(mirror, &ff_layout->mirrors, mirrors) {
@@ -2248,7 +2247,6 @@ ff_layout_mirror_prepare_stats(struct nfs42_layoutstat_args *args,
 		if (!atomic_inc_not_zero(&mirror->ref))
 			continue;
 		dev = &mirror->mirror_ds->id_node; 
-		devinfo = &args->devinfo[i];
 		memcpy(&devinfo->dev_id, &dev->deviceid, NFS4_DEVICEID4_SIZE);
 		devinfo->offset = 0;
 		devinfo->length = NFS4_MAX_UINT64;
@@ -2260,6 +2258,7 @@ ff_layout_mirror_prepare_stats(struct nfs42_layoutstat_args *args,
 		devinfo->layoutstats_encode = ff_layout_encode_layoutstats;
 		devinfo->layout_private = mirror;
 
+		devinfo++;
 		i++;
 	}
 	return i;
@@ -2269,29 +2268,17 @@ static int
 ff_layout_prepare_layoutstats(struct nfs42_layoutstat_args *args)
 {
 	struct nfs4_flexfile_layout *ff_layout;
-	struct nfs4_ff_layout_mirror *mirror;
-	int dev_count = 0;
+	const int dev_count = PNFS_LAYOUTSTATS_MAXDEV;
 
-	spin_lock(&args->inode->i_lock);
-	ff_layout = FF_LAYOUT_FROM_HDR(NFS_I(args->inode)->layout);
-	list_for_each_entry(mirror, &ff_layout->mirrors, mirrors) {
-		if (atomic_read(&mirror->ref) != 0)
-			dev_count ++;
-	}
-	spin_unlock(&args->inode->i_lock);
 	/* For now, send at most PNFS_LAYOUTSTATS_MAXDEV statistics */
-	if (dev_count > PNFS_LAYOUTSTATS_MAXDEV) {
-		dprintk("%s: truncating devinfo to limit (%d:%d)\n",
-			__func__, dev_count, PNFS_LAYOUTSTATS_MAXDEV);
-		dev_count = PNFS_LAYOUTSTATS_MAXDEV;
-	}
 	args->devinfo = kmalloc_array(dev_count, sizeof(*args->devinfo), GFP_NOIO);
 	if (!args->devinfo)
 		return -ENOMEM;
 
 	spin_lock(&args->inode->i_lock);
-	args->num_dev = ff_layout_mirror_prepare_stats(args,
-			&ff_layout->generic_hdr, dev_count);
+	ff_layout = FF_LAYOUT_FROM_HDR(NFS_I(args->inode)->layout);
+	args->num_dev = ff_layout_mirror_prepare_stats(&ff_layout->generic_hdr,
+			&args->devinfo[0], dev_count);
 	spin_unlock(&args->inode->i_lock);
 	if (!args->num_dev) {
 		kfree(args->devinfo);
-- 
2.9.3

