Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753082Ab1BDVeW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:22 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@citi.umich.edu>,
        Dean Hildebrand <dhildeb@us.ibm.com>,
        Oleg Drokin <green@linuxhacker.ru>, Tao Guo <guotao@nrchpc.ac.cn>,
        Andy Adamson <andros@netapp.com>, Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 07/40] pnfs_submit: filelayout policy operations
Date: Fri,  4 Feb 2011 16:33:29 -0500
Message-Id: <1296855242-2592-8-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-7-git-send-email-andros@netapp.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
 <1296855242-2592-2-git-send-email-andros@netapp.com>
 <1296855242-2592-3-git-send-email-andros@netapp.com>
 <1296855242-2592-4-git-send-email-andros@netapp.com>
 <1296855242-2592-5-git-send-email-andros@netapp.com>
 <1296855242-2592-6-git-send-email-andros@netapp.com>
 <1296855242-2592-7-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4filelayout.c |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 23f930c..8b1c4ad 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -252,6 +252,33 @@ filelayout_free_lseg(struct pnfs_layout_segment *lseg)
 	_filelayout_free_lseg(fl);
 }
 
+/*
+ * filelayout_pg_test(). Called by nfs_can_coalesce_requests()
+ *
+ * return 1 :  coalesce page
+ * return 0 :  don't coalesce page
+ *
+ * By the time this is called, we know req->wb_lseg == prev->wb_lseg
+ */
+int
+filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
+		   struct nfs_page *req)
+{
+	u64 p_stripe, r_stripe;
+	u32 stripe_unit;
+
+	if (!req->wb_lseg)
+		return 1;
+	p_stripe = (u64)prev->wb_index << PAGE_CACHE_SHIFT;
+	r_stripe = (u64)req->wb_index << PAGE_CACHE_SHIFT;
+	stripe_unit = FILELAYOUT_LSEG(req->wb_lseg)->stripe_unit;
+
+	do_div(p_stripe, stripe_unit);
+	do_div(r_stripe, stripe_unit);
+
+	return (p_stripe == r_stripe);
+}
+
 static struct pnfs_layoutdriver_type filelayout_type = {
 	.id = LAYOUT_NFSV4_1_FILES,
 	.name = "LAYOUT_NFSV4_1_FILES",
@@ -260,6 +287,7 @@ static struct pnfs_layoutdriver_type filelayout_type = {
 	.clear_layoutdriver = filelayout_clear_layoutdriver,
 	.alloc_lseg              = filelayout_alloc_lseg,
 	.free_lseg               = filelayout_free_lseg,
+	.pg_test                 = filelayout_pg_test,
 };
 
 static int __init nfs4filelayout_init(void)
-- 
1.6.6

