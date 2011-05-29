Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:46041 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497Ab1E2Kb5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 06:31:57 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 8/8] SQUASHME: pnfs-obj: objio_pg_test some checkpatch love
Date: Sun, 29 May 2011 13:31:46 +0300
Message-Id: <1306665106-1188-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DE21CD5.8070907@panasas.com>
References: <4DE21CD5.8070907@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Lines to long

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index f431c4b..9cf208d 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -995,13 +995,14 @@ ssize_t objio_write_pagelist(struct objlayout_io_state *ol_state, bool stable)
 	return _write_exec(ios);
 }
 
-static bool
-objio_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev, struct nfs_page *req)
+static bool objio_pg_test(struct nfs_pageio_descriptor *pgio,
+			  struct nfs_page *prev, struct nfs_page *req)
 {
 	if (!pnfs_generic_pg_test(pgio, prev, req))
 		return false;
 
-	return pgio->pg_count + req->wb_bytes <= OBJIO_LSEG(pgio->pg_lseg)->max_io_size;
+	return pgio->pg_count + req->wb_bytes <=
+			OBJIO_LSEG(pgio->pg_lseg)->max_io_size;
 }
 
 static struct pnfs_layoutdriver_type objlayout_type = {
-- 
1.7.2.3

