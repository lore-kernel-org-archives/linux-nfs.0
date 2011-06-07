Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:52311 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756253Ab1FGRez (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:34:55 -0400
Date: Tue, 7 Jun 2011 13:34:54 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 76/88] SQUASHME: pnfs-block: deprecate get_stripesize
Message-ID: <d03acb5701313de109f1fb4c04f1e97122fb471b.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 23dbe91..57a7f04 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -1083,13 +1083,6 @@ bl_write_end_cleanup(struct file *filp, struct pnfs_fsdata *fsdata)
 	fsdata->private = NULL;
 }
 
-static ssize_t
-bl_get_stripesize(struct pnfs_layout_hdr *lo)
-{
-	dprintk("%s enter\n", __func__);
-	return 0;
-}
-
 /* This is called by nfs_can_coalesce_requests via nfs_pageio_do_add_request.
  * Should return False if there is a reason requests can not be coalesced,
  * otherwise, should default to returning True.
@@ -1123,7 +1116,6 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
 	.cleanup_layoutcommit		= bl_cleanup_layoutcommit,
 	.initialize_mountpoint		= bl_initialize_mountpoint,
 	.uninitialize_mountpoint	= bl_uninitialize_mountpoint,
-	.get_stripesize			= bl_get_stripesize,
 	.pg_test			= bl_pg_test,
 };
 
-- 
1.7.4.1

