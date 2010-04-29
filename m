From: andros@netapp.com
Subject: [PATCH 12/13] SQUASHME pnfs_submit: fall back to MDS on filelayout_commit error
Date: Thu, 29 Apr 2010 16:34:50 -0400
Message-ID: <1272573291-8986-13-git-send-email-andros@netapp.com>
References: <1272573291-8986-1-git-send-email-andros@netapp.com>
 <1272573291-8986-2-git-send-email-andros@netapp.com>
 <1272573291-8986-3-git-send-email-andros@netapp.com>
 <1272573291-8986-4-git-send-email-andros@netapp.com>
 <1272573291-8986-5-git-send-email-andros@netapp.com>
 <1272573291-8986-6-git-send-email-andros@netapp.com>
 <1272573291-8986-7-git-send-email-andros@netapp.com>
 <1272573291-8986-8-git-send-email-andros@netapp.com>
 <1272573291-8986-9-git-send-email-andros@netapp.com>
 <1272573291-8986-10-git-send-email-andros@netapp.com>
 <1272573291-8986-11-git-send-email-andros@netapp.com>
 <1272573291-8986-12-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52317 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757122Ab0D3Qs7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Apr 2010 12:48:59 -0400
In-Reply-To: <1272573291-8986-12-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index aff11d3..021c853 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -575,6 +575,7 @@ filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
 	loff_t file_offset, comp_offset;
 	size_t stripesz, cbytes;
 	int status;
+	enum pnfs_try_status trypnfs = PNFS_ATTEMPTED;
 	struct nfs4_file_layout_dsaddr *dsaddr;
 	u32 idx1, idx2;
 
@@ -674,11 +675,12 @@ out:
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

