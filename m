From: andros@netapp.com
Subject: [PATCH 5/7] SQUASHME pnfs-submit filelayout use new write_pagelist API
Date: Thu, 15 Jul 2010 12:13:52 -0400
Message-ID: <1279210434-2772-6-git-send-email-andros@netapp.com>
References: <1279210434-2772-1-git-send-email-andros@netapp.com>
 <1279210434-2772-2-git-send-email-andros@netapp.com>
 <1279210434-2772-3-git-send-email-andros@netapp.com>
 <1279210434-2772-4-git-send-email-andros@netapp.com>
 <1279210434-2772-5-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7766 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933646Ab0GOQNq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jul 2010 12:13:46 -0400
In-Reply-To: <1279210434-2772-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   18 ++++--------------
 1 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 45b0dcc..d7f0f62 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -244,24 +244,14 @@ filelayout_read_pagelist(struct nfs_read_data *data, unsigned nr_pages)
 
 /* Perform async writes. */
 static enum pnfs_try_status
-filelayout_write_pagelist(struct pnfs_layout_type *layoutid,
-			  struct page **pages,
-			  unsigned int pgbase,
-			  unsigned nr_pages,
-			  loff_t offset,
-			  size_t count,
-			  int sync,
-			  struct nfs_write_data *data)
+filelayout_write_pagelist(struct nfs_write_data *data, int sync)
 {
-	struct inode *inode = PNFS_INODE(layoutid);
 	struct pnfs_layout_segment *lseg = data->pdata.lseg;
 	struct nfs4_pnfs_ds *ds;
+	loff_t offset = data->args.offset;
 	u32 idx;
 	struct nfs_fh *fh;
 
-	dprintk("--> %s ino %lu nr_pages %d pgbase %u req %Zu@%llu sync %d\n",
-		__func__, inode->i_ino, nr_pages, pgbase, count, offset, sync);
-
 	/* Retrieve the correct rpc_client for the byte range */
 	idx = nfs4_fl_calc_ds_index(lseg, offset);
 	ds = nfs4_fl_prepare_ds(lseg, idx);
@@ -269,8 +259,8 @@ filelayout_write_pagelist(struct pnfs_layout_type *layoutid,
 		printk(KERN_ERR "%s: prepare_ds failed, use MDS\n", __func__);
 		return PNFS_NOT_ATTEMPTED;
 	}
-	dprintk("%s ino %lu %Zu@%llu DS:%x:%hu %s\n",
-		__func__, inode->i_ino, count, offset,
+	dprintk("%s ino %lu sync %d req %Zu@%llu DS:%x:%hu %s\n", __func__,
+		data->inode->i_ino, sync, (size_t) data->args.count, offset,
 		htonl(ds->ds_ip_addr), ntohs(ds->ds_port), ds->r_addr);
 
 	data->fldata.ds_nfs_client = ds->ds_clp;
-- 
1.6.6

