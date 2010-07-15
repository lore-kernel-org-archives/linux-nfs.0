From: andros@netapp.com
Subject: [PATCH 3/7] SQUASHME pnfs-submit filelayout use new read_pagelist API
Date: Thu, 15 Jul 2010 12:13:50 -0400
Message-ID: <1279210434-2772-4-git-send-email-andros@netapp.com>
References: <1279210434-2772-1-git-send-email-andros@netapp.com>
 <1279210434-2772-2-git-send-email-andros@netapp.com>
 <1279210434-2772-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7766 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933636Ab0GOQNq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jul 2010 12:13:46 -0400
In-Reply-To: <1279210434-2772-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index d60fa1f..45b0dcc 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -199,22 +199,17 @@ struct rpc_call_ops filelayout_write_call_ops = {
  * TODO: join with write_pagelist?
  */
 static enum pnfs_try_status
-filelayout_read_pagelist(struct pnfs_layout_type *layoutid,
-			 struct page **pages,
-			 unsigned int pgbase,
-			 unsigned nr_pages,
-			 loff_t offset,
-			 size_t count,
-			 struct nfs_read_data *data)
+filelayout_read_pagelist(struct nfs_read_data *data, unsigned nr_pages)
 {
-	struct inode *inode = PNFS_INODE(layoutid);
 	struct pnfs_layout_segment *lseg = data->pdata.lseg;
 	struct nfs4_pnfs_ds *ds;
+	loff_t offset = data->args.offset;
 	u32 idx;
 	struct nfs_fh *fh;
 
 	dprintk("--> %s ino %lu nr_pages %d pgbase %u req %Zu@%llu\n",
-		__func__, inode->i_ino, nr_pages, pgbase, count, offset);
+		__func__, data->inode->i_ino, nr_pages,
+		data->args.pgbase, (size_t)data->args.count, offset);
 
 	/* Retrieve the correct rpc_client for the byte range */
 	idx = nfs4_fl_calc_ds_index(lseg, offset);
-- 
1.6.6

