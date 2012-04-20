Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:61571 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932171Ab2DTSsM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 14:48:12 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH v3 11/25] NFS: use req_offset where appropriate
Date: Fri, 20 Apr 2012 14:47:43 -0400
Message-Id: <1334947677-28864-12-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
References: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 31afd81..c536328 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -776,8 +776,8 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	    !nfs_generic_pg_test(pgio, prev, req))
 		return false;
 
-	p_stripe = (u64)prev->wb_index << PAGE_CACHE_SHIFT;
-	r_stripe = (u64)req->wb_index << PAGE_CACHE_SHIFT;
+	p_stripe = (u64)req_offset(prev);
+	r_stripe = (u64)req_offset(req);
 	stripe_unit = FILELAYOUT_LSEG(pgio->pg_lseg)->stripe_unit;
 
 	do_div(p_stripe, stripe_unit);
@@ -896,8 +896,7 @@ filelayout_choose_commit_list(struct nfs_page *req,
 	 * to store the value calculated in filelayout_write_pagelist
 	 * and just use that here.
 	 */
-	j = nfs4_fl_calc_j_index(lseg,
-				 (loff_t)req->wb_index << PAGE_CACHE_SHIFT);
+	j = nfs4_fl_calc_j_index(lseg, req_offset(req));
 	i = select_bucket_index(fl, j);
 	buckets = FILELAYOUT_FROM_HDR(lseg->pls_layout)->commit_info.buckets;
 	list = &buckets[i].written;
-- 
1.7.2.1

