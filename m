From: andros@netapp.com
Subject: [PATCH 12/13] SQUASHME pnfs_submit: fall back to MDS on filelayout_commit error
Date: Wed, 28 Apr 2010 18:24:24 -0400
Message-ID: <1272493465-3398-13-git-send-email-andros@netapp.com>
References: <1272493465-3398-1-git-send-email-andros@netapp.com>
 <1272493465-3398-2-git-send-email-andros@netapp.com>
 <1272493465-3398-3-git-send-email-andros@netapp.com>
 <1272493465-3398-4-git-send-email-andros@netapp.com>
 <1272493465-3398-5-git-send-email-andros@netapp.com>
 <1272493465-3398-6-git-send-email-andros@netapp.com>
 <1272493465-3398-7-git-send-email-andros@netapp.com>
 <1272493465-3398-8-git-send-email-andros@netapp.com>
 <1272493465-3398-9-git-send-email-andros@netapp.com>
 <1272493465-3398-10-git-send-email-andros@netapp.com>
 <1272493465-3398-11-git-send-email-andros@netapp.com>
 <1272493465-3398-12-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30259 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932237Ab0D1VYi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Apr 2010 17:24:38 -0400
In-Reply-To: <1272493465-3398-12-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 80eb481..dc762d9 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -563,6 +563,7 @@ filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
 	loff_t file_offset, comp_offset;
 	size_t stripesz, cbytes;
 	int status;
+	enum pnfs_try_status trypnfs = PNFS_ATTEMPTED;
 	struct nfs4_file_layout_dsaddr *dsaddr;
 	u32 idx1, idx2;
 
@@ -662,11 +663,12 @@ out:
 		       data->pdata.pnfs_error);
 
 	/* XXX should we send COMMIT to MDS e.g. not free data and return 1 ? */
-	return PNFS_ATTEMPTED;
+	return trypnfs;
 err_rewind:
 	/* put remaining pages back onto the original data->pages */
 	list_add(&data->pages, &head);
 	list_del_init(&head);
+	trypnfs = PNFS_NOT_ATTEMPTED;
 	goto out;
 }
 
-- 
1.6.6

