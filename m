From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH 4/6] SQUASHME: pnfs-submit: Move _pnfs_clear_lseg_from_pages to pnfs.c
Date: Tue,  6 Jul 2010 17:06:56 +0300
Message-ID: <1278425216-22435-1-git-send-email-bharrosh@panasas.com>
References: <4C3334E3.7070600@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
	Andy Adamson <andros@netapp.com>,
	Fred Isaman <iisaman@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:7618 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753127Ab0GFOG7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jul 2010 10:06:59 -0400
In-Reply-To: <4C3334E3.7070600@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No longer needed at header (and inline)

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/pnfs.c |   10 ++++++++++
 fs/nfs/pnfs.h |   10 ----------
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a30a8c3..6ff8d63 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1510,6 +1510,16 @@ pnfs_writeback_done(struct nfs_write_data *data)
 	}
 }
 
+static void _pnfs_clear_lseg_from_pages(struct list_head *head)
+{
+	struct nfs_page *req;
+
+	list_for_each_entry(req, head, wb_list) {
+		put_lseg(req->wb_lseg);
+		req->wb_lseg = NULL;
+	}
+}
+
 /*
  * Call the appropriate parallel I/O subsystem write function.
  * If no I/O device driver exists, or one does match the returned
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 1a320f6..55f3028 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -100,16 +100,6 @@ static inline int pnfs_enabled_sb(struct nfs_server *nfss)
 	return nfss->pnfs_curr_ld != NULL;
 }
 
-static inline void _pnfs_clear_lseg_from_pages(struct list_head *head)
-{
-	struct nfs_page *req;
-
-	list_for_each_entry(req, head, wb_list) {
-		put_lseg(req->wb_lseg);
-		req->wb_lseg = NULL;
-	}
-}
-
 static inline int pnfs_grow_ok(struct pnfs_layout_segment *lseg,
 			       struct pnfs_fsdata *fsdata)
 {
-- 
1.6.6.1

