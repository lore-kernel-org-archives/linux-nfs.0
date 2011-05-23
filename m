Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:53579 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753707Ab1EWKpN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 06:45:13 -0400
Message-ID: <4DDA3AA4.8000205@panasas.com>
Date: Mon, 23 May 2011 13:44:52 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: [PTACH] SQUASHME: pnfs-obj: Important fallout from the last rebase
References: <4DD99F9B.2040406@panasas.com> <1306108883-29089-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <1306108883-29089-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On the last rebase I dropped this hunk it needs to go into  the:
	[PATCH v5 31/38] pnfs-obj: osd raid engine read/write implementation

With out this the code does not work

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 105d8a6..74b5d3f 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -989,19 +990,6 @@ ssize_t objio_write_pagelist(struct objlayout_io_state *ol_state, bool stable)
 	return _write_exec(ios);
 }
 
-/*
- * objlayout_pg_test(). Called by nfs_can_coalesce_requests()
- *
- * return 1 :  coalesce page
- * return 0 :  don't coalesce page
- */
-int
-objlayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
-		   struct nfs_page *req)
-{
-	return 1;
-}
-
 static struct pnfs_layoutdriver_type objlayout_type = {
 	.id = LAYOUT_OSD2_OBJECTS,
 	.name = "LAYOUT_OSD2_OBJECTS",
@@ -1021,8 +1009,6 @@ static struct pnfs_layoutdriver_type objlayout_type = {
 
 	.encode_layoutcommit	 = objlayout_encode_layoutcommit,
 	.encode_layoutreturn     = objlayout_encode_layoutreturn,
-
-	.pg_test		= objlayout_pg_test,
 };
 
 void *objio_init_mt(void)
