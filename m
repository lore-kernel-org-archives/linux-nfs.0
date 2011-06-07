Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:51646 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755451Ab1FGRc5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:32:57 -0400
Date: Tue, 7 Jun 2011 13:32:54 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 58/88] SQUASHME: pnfsblock: bl_write_pagelist support
 functions adjust for missing PG_USE_PNFS
Message-ID: <69f4c98effee682abf2cbcda04b2def84bb1963c.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@netapp.com>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/blocklayout/blocklayout.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 43a5617..77e9512 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -1115,12 +1115,10 @@ bl_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	   struct nfs_page *req)
 {
 	dprintk("%s enter\n", __func__);
-	if (pgio->pg_iswrite) {
-		return test_bit(PG_USE_PNFS, &prev->wb_flags) ==
-			test_bit(PG_USE_PNFS, &req->wb_flags);
-	} else {
+	if (pgio->pg_iswrite)
+		return prev->wb_lseg == req->wb_lseg;
+	else
 		return 1;
-	}
 }
 
 static struct layoutdriver_io_operations blocklayout_io_operations = {
-- 
1.7.4.1

