From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/2] SQUASHME: pnfsblock: get rid of threshold policy ops
Date: Mon, 17 May 2010 23:58:07 +0300
Message-ID: <1274129887-810-1-git-send-email-bhalevy@panasas.com>
References: <4BF1AC63.8000301@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:31400 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752656Ab0EQU6J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 May 2010 16:58:09 -0400
In-Reply-To: <4BF1AC63.8000301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 688984f..66044d4 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -1105,13 +1105,6 @@ bl_get_stripesize(struct pnfs_layout_type *lo)
 	return 0;
 }
 
-static ssize_t
-bl_get_io_threshold(struct pnfs_layout_type *lo, struct inode *inode)
-{
-	dprintk("%s enter\n", __func__);
-	return 0;
-}
-
 /* This is called by nfs_can_coalesce_requests via nfs_pageio_do_add_request.
  * Should return False if there is a reason requests can not be coalesced,
  * otherwise, should default to returning True.
@@ -1162,8 +1155,6 @@ static struct layoutdriver_io_operations blocklayout_io_operations = {
 
 static struct layoutdriver_policy_operations blocklayout_policy_operations = {
 	.get_stripesize			= bl_get_stripesize,
-	.get_read_threshold		= bl_get_io_threshold,
-	.get_write_threshold		= bl_get_io_threshold,
 	.pg_test			= bl_pg_test,
 	.do_flush			= bl_do_flush,
 };
-- 
1.6.6.1

