From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/3] SQUASHME: pnfs-submit: filelayout: add nr_pages back to write_pagelist api
Date: Tue, 20 Jul 2010 08:57:36 +0300
Message-ID: <1279605456-7349-1-git-send-email-bhalevy@panasas.com>
References: <4C453A50.7070009@panasas.com>
Cc: andros@netapp.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:25077 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754402Ab0GTF5j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 01:57:39 -0400
In-Reply-To: <4C453A50.7070009@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4filelayout.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 9b6ba8d..b2ce478 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -244,7 +244,7 @@ filelayout_read_pagelist(struct nfs_read_data *data, unsigned nr_pages)
 
 /* Perform async writes. */
 static enum pnfs_try_status
-filelayout_write_pagelist(struct nfs_write_data *data, int sync)
+filelayout_write_pagelist(struct nfs_write_data *data, unsigned nr_pages, int sync)
 {
 	struct pnfs_layout_segment *lseg = data->pdata.lseg;
 	struct nfs4_pnfs_ds *ds;
-- 
1.7.1.1

