From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/1] SQUASHME: pnfs-obj: get rid of threshold policy ops
Date: Mon, 17 May 2010 23:57:55 +0300
Message-ID: <1274129875-772-1-git-send-email-bhalevy@panasas.com>
References: <4BF1AC63.8000301@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:10883 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752656Ab0EQU55 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 May 2010 16:57:57 -0400
In-Reply-To: <4BF1AC63.8000301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c  |   13 -------------
 fs/nfs/objlayout/panfs_shim.c |   14 --------------
 2 files changed, 0 insertions(+), 27 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 642d6fa..315f8c6 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -1022,17 +1022,6 @@ objlayout_get_blocksize(void)
 	return sz;
 }
 
-/*
- * Get the I/O threshold
- */
-static ssize_t
-objlayout_get_io_threshold(struct pnfs_layout_type *layoutid,
-			   struct inode *inode)
-{
-	ssize_t sz = -1;
-	return sz;
-}
-
 static struct layoutdriver_policy_operations objlayout_policy_operations = {
 /*
  * Don't gather across stripes, but rather gather (coalesce) up to
@@ -1044,8 +1033,6 @@ static struct layoutdriver_policy_operations objlayout_policy_operations = {
 				 PNFS_LAYOUTRET_ON_SETATTR,
 	.get_stripesize        = objlayout_get_stripesize,
 	.get_blocksize         = objlayout_get_blocksize,
-	.get_read_threshold    = objlayout_get_io_threshold,
-	.get_write_threshold   = objlayout_get_io_threshold,
 };
 
 static struct pnfs_layoutdriver_type objlayout_type = {
diff --git a/fs/nfs/objlayout/panfs_shim.c b/fs/nfs/objlayout/panfs_shim.c
index 6033d2b..4468703 100644
--- a/fs/nfs/objlayout/panfs_shim.c
+++ b/fs/nfs/objlayout/panfs_shim.c
@@ -663,18 +663,6 @@ panlayout_get_blocksize(void)
 	return sz;
 }
 
-/*
- * Get the I/O threshold
- */
-static ssize_t
-panlayout_get_io_threshold(struct pnfs_layout_type *layoutid,
-			   struct inode *inode)
-{
-	ssize_t sz = -1;
-	dprintk("%s: Return %Zd\n", __func__, sz);
-	return sz;
-}
-
 static struct layoutdriver_policy_operations panlayout_policy_operations = {
 /*
  * Don't gather across stripes, but rather gather (coalesce) up to
@@ -686,8 +674,6 @@ static struct layoutdriver_policy_operations panlayout_policy_operations = {
 				 PNFS_LAYOUTRET_ON_SETATTR,
 	.get_stripesize        = panlayout_get_stripesize,
 	.get_blocksize         = panlayout_get_blocksize,
-	.get_read_threshold    = panlayout_get_io_threshold,
-	.get_write_threshold   = panlayout_get_io_threshold,
 };
 
 #define PNFS_LAYOUT_PANOSD (NFS4_PNFS_PRIVATE_LAYOUT | LAYOUT_OSD2_OBJECTS)
-- 
1.6.6.1

