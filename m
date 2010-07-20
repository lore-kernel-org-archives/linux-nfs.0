From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/3] SQUASHME: pnfs-submit: add nr_pages back to write_pagelist api
Date: Tue, 20 Jul 2010 08:57:27 +0300
Message-ID: <1279605447-7315-1-git-send-email-bhalevy@panasas.com>
References: <4C453A50.7070009@panasas.com>
Cc: andros@netapp.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:9116 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754377Ab0GTF5b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 01:57:31 -0400
In-Reply-To: <4C453A50.7070009@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Keep it symmetrical with read_pagelist, using nfs_page_array_len.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c             |    4 +++-
 include/linux/nfs4_pnfs.h |    2 +-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4de0b73..6ab1938 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1269,7 +1269,9 @@ pnfs_try_to_write_data(struct nfs_write_data *wdata,
 	get_lseg(lseg);
 
 	wdata->pdata.lseg = lseg;
-	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->write_pagelist(wdata, how);
+	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->write_pagelist(wdata,
+		nfs_page_array_len(wdata->args.pgbase, wdata->args.count),
+								how);
 
 	if (trypnfs == PNFS_NOT_ATTEMPTED) {
 		wdata->pdata.lseg = NULL;
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 1c3cd49..6236687 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -130,7 +130,7 @@ struct layoutdriver_io_operations {
 	enum pnfs_try_status
 	(*read_pagelist) (struct nfs_read_data *nfs_data, unsigned nr_pages);
 	enum pnfs_try_status
-	(*write_pagelist) (struct nfs_write_data *nfs_data, int how);
+	(*write_pagelist) (struct nfs_write_data *nfs_data, unsigned nr_pages, int how);
 
 	/* Consistency ops */
 	/* 2 problems:
-- 
1.7.1.1

