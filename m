Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753207Ab1BDVej (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:39 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 20/40] SQUASHME pnfs-submit wave3 remove nr_pages from read_pagelist
Date: Fri,  4 Feb 2011 16:33:42 -0500
Message-Id: <1296855242-2592-21-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-20-git-send-email-andros@netapp.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
 <1296855242-2592-2-git-send-email-andros@netapp.com>
 <1296855242-2592-3-git-send-email-andros@netapp.com>
 <1296855242-2592-4-git-send-email-andros@netapp.com>
 <1296855242-2592-5-git-send-email-andros@netapp.com>
 <1296855242-2592-6-git-send-email-andros@netapp.com>
 <1296855242-2592-7-git-send-email-andros@netapp.com>
 <1296855242-2592-8-git-send-email-andros@netapp.com>
 <1296855242-2592-9-git-send-email-andros@netapp.com>
 <1296855242-2592-10-git-send-email-andros@netapp.com>
 <1296855242-2592-11-git-send-email-andros@netapp.com>
 <1296855242-2592-12-git-send-email-andros@netapp.com>
 <1296855242-2592-13-git-send-email-andros@netapp.com>
 <1296855242-2592-14-git-send-email-andros@netapp.com>
 <1296855242-2592-15-git-send-email-andros@netapp.com>
 <1296855242-2592-16-git-send-email-andros@netapp.com>
 <1296855242-2592-17-git-send-email-andros@netapp.com>
 <1296855242-2592-18-git-send-email-andros@netapp.com>
 <1296855242-2592-19-git-send-email-andros@netapp.com>
 <1296855242-2592-20-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    2 +-
 fs/nfs/pnfs.c           |    3 +--
 fs/nfs/pnfs.h           |    2 +-
 3 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index dce90a0..2b5a38e 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -133,7 +133,7 @@ struct rpc_call_ops filelayout_read_call_ops = {
 };
 
 static enum pnfs_try_status
-filelayout_read_pagelist(struct nfs_read_data *data, unsigned nr_pages)
+filelayout_read_pagelist(struct nfs_read_data *data)
 {
 	struct pnfs_layout_segment *lseg = data->pdata.lseg;
 	struct nfs4_pnfs_ds *ds;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d06e9ea..4c49109 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -943,8 +943,7 @@ pnfs_try_to_read_data(struct nfs_read_data *rdata,
 	get_lseg(lseg);
 
 	rdata->pdata.lseg = lseg;
-	trypnfs = nfss->pnfs_curr_ld->read_pagelist(rdata,
-		nfs_page_array_len(rdata->args.pgbase, rdata->args.count));
+	trypnfs = nfss->pnfs_curr_ld->read_pagelist(rdata);
 	if (trypnfs == PNFS_NOT_ATTEMPTED) {
 		rdata->pdata.lseg = NULL;
 		put_lseg(lseg);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 2e231e3..cbbcdfa 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -84,7 +84,7 @@ struct pnfs_layoutdriver_type {
 	 * MUST be called.
 	 */
 	enum pnfs_try_status
-	(*read_pagelist) (struct nfs_read_data *nfs_data, unsigned nr_pages);
+	(*read_pagelist) (struct nfs_read_data *nfs_data);
 };
 
 struct pnfs_layout_hdr {
-- 
1.6.6

