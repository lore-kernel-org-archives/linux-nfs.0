From: andros@netapp.com
Subject: [PATCH 03/10] SQUASHME pnfs-submit: clear page lseg on partial i/o
Date: Wed, 23 Jun 2010 15:21:11 -0400
Message-ID: <1277320878-3726-4-git-send-email-andros@netapp.com>
References: <1277320878-3726-1-git-send-email-andros@netapp.com>
 <1277320878-3726-2-git-send-email-andros@netapp.com>
 <1277320878-3726-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5004 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753411Ab0FWTW2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jun 2010 15:22:28 -0400
In-Reply-To: <1277320878-3726-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

partial reads or writes use a single page not the page list.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.h |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index c60eff6..70f1d97 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -91,10 +91,18 @@ static inline int pnfs_enabled_sb(struct nfs_server *nfss)
 	return nfss->pnfs_curr_ld != NULL;
 }
 
-static inline void _pnfs_clear_lseg_from_pages(struct list_head *head)
+static inline void _pnfs_clear_lseg_from_pages(struct nfs_page *partial,
+					       struct list_head *head)
 {
 	struct nfs_page *req;
 
+	/* partial_read or partial_write */
+	if (list_empty(head)) {
+		put_lseg(partial->wb_lseg);
+		partial->wb_lseg = NULL;
+		return;
+	}
+	/* full_read or full_write */
 	list_for_each_entry(req, head, wb_list) {
 		put_lseg(req->wb_lseg);
 		req->wb_lseg = NULL;
@@ -114,7 +122,7 @@ pnfs_try_to_read_data(struct nfs_read_data *data,
 	if (ret == PNFS_ATTEMPTED)
 		nfs_inc_stats(inode, NFSIOS_PNFS_READ);
 	else
-		_pnfs_clear_lseg_from_pages(&data->pages);
+		_pnfs_clear_lseg_from_pages(data->req, &data->pages);
 	return ret;
 }
 
@@ -132,7 +140,7 @@ pnfs_try_to_write_data(struct nfs_write_data *data,
 	if (ret == PNFS_ATTEMPTED)
 		nfs_inc_stats(inode, NFSIOS_PNFS_WRITE);
 	else
-		_pnfs_clear_lseg_from_pages(&data->pages);
+		_pnfs_clear_lseg_from_pages(data->req, &data->pages);
 	return ret;
 }
 
@@ -153,7 +161,7 @@ pnfs_try_to_commit(struct nfs_write_data *data,
 	if (ret == PNFS_ATTEMPTED)
 		nfs_inc_stats(inode, NFSIOS_PNFS_COMMIT);
 	else
-		_pnfs_clear_lseg_from_pages(&data->pages);
+		_pnfs_clear_lseg_from_pages(data->req, &data->pages);
 	return ret;
 }
 
-- 
1.6.6

