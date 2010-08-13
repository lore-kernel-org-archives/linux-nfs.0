Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14051 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754279Ab0HMVcd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:33 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 34/50] pnfs_submit: filelayout policy operations
Date: Fri, 13 Aug 2010 17:31:46 -0400
Message-Id: <1281735122-1496-35-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-34-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
 <1281735122-1496-12-git-send-email-andros@netapp.com>
 <1281735122-1496-13-git-send-email-andros@netapp.com>
 <1281735122-1496-14-git-send-email-andros@netapp.com>
 <1281735122-1496-15-git-send-email-andros@netapp.com>
 <1281735122-1496-16-git-send-email-andros@netapp.com>
 <1281735122-1496-17-git-send-email-andros@netapp.com>
 <1281735122-1496-18-git-send-email-andros@netapp.com>
 <1281735122-1496-19-git-send-email-andros@netapp.com>
 <1281735122-1496-20-git-send-email-andros@netapp.com>
 <1281735122-1496-21-git-send-email-andros@netapp.com>
 <1281735122-1496-22-git-send-email-andros@netapp.com>
 <1281735122-1496-23-git-send-email-andros@netapp.com>
 <1281735122-1496-24-git-send-email-andros@netapp.com>
 <1281735122-1496-25-git-send-email-andros@netapp.com>
 <1281735122-1496-26-git-send-email-andros@netapp.com>
 <1281735122-1496-27-git-send-email-andros@netapp.com>
 <1281735122-1496-28-git-send-email-andros@netapp.com>
 <1281735122-1496-29-git-send-email-andros@netapp.com>
 <1281735122-1496-30-git-send-email-andros@netapp.com>
 <1281735122-1496-31-git-send-email-andros@netapp.com>
 <1281735122-1496-32-git-send-email-andros@netapp.com>
 <1281735122-1496-33-git-send-email-andros@netapp.com>
 <1281735122-1496-34-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   35 +++++++++++++++++++++++++++++++++++
 1 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 50620f4..4af089c 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -303,6 +303,39 @@ filelayout_free_lseg(struct pnfs_layout_segment *lseg)
 				   nfs4_fl_free_deviceid_callback);
 	_filelayout_free_lseg(lseg);
 }
+
+/* Return the stripesize for the specified file */
+ssize_t
+filelayout_get_stripesize(struct pnfs_layout_type *layoutid)
+{
+	struct nfs4_filelayout *flo = FILE_LO(layoutid);
+
+	return flo->stripe_unit;
+}
+
+/*
+ * filelayout_pg_test(). Called by nfs_can_coalesce_requests()
+ *
+ * return 1 :  coalesce page
+ * return 0 :  don't coalesce page
+ */
+int
+filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
+		   struct nfs_page *req)
+{
+	u64 p_stripe, r_stripe;
+
+	if (pgio->pg_boundary == 0)
+		return 1;
+	p_stripe = (u64)prev->wb_index << PAGE_CACHE_SHIFT;
+	r_stripe = (u64)req->wb_index << PAGE_CACHE_SHIFT;
+
+	do_div(p_stripe, pgio->pg_boundary);
+	do_div(r_stripe, pgio->pg_boundary);
+
+	return (p_stripe == r_stripe);
+}
+
 struct layoutdriver_io_operations filelayout_io_operations = {
 	.alloc_layout            = filelayout_alloc_layout,
 	.free_layout             = filelayout_free_layout,
@@ -313,6 +346,8 @@ struct layoutdriver_io_operations filelayout_io_operations = {
 };
 
 struct layoutdriver_policy_operations filelayout_policy_operations = {
+	.get_stripesize        = filelayout_get_stripesize,
+	.pg_test               = filelayout_pg_test,
 };
 
 struct pnfs_layoutdriver_type filelayout_type = {
-- 
1.6.2.5

