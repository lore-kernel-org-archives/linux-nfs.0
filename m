Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:51487 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755451Ab1FGRca (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:32:30 -0400
Date: Tue, 7 Jun 2011 13:32:28 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 54/88] SQUASHME: pnfsblock: get rid of threshold policy ops
Message-ID: <0a4015a24085c71684596103e1329799183262c3.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

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
1.7.4.1

