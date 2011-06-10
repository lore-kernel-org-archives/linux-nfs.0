Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5591 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756921Ab1FJBbI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Jun 2011 21:31:08 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] NFSv4.1: Fix an off-by-one error in pnfs_generic_pg_test
Date: Thu,  9 Jun 2011 21:30:59 -0400
Message-Id: <1307669462-15764-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1307669462-15764-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1307669462-15764-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

And document what is going on there...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c |   21 ++++++++++++++++-----
 1 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 12b53ef..9a4ce7c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1073,11 +1073,22 @@ pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 			return true;
 	}
 
-	if (req_offset(req) > end_offset(pgio->pg_lseg->pls_range.offset,
-					 pgio->pg_lseg->pls_range.length))
-		return false;
-
-	return true;
+	/*
+	 * Test if a nfs_page is fully contained in the pnfs_layout_range.
+	 * Note that this test makes several assumptions:
+	 * - that the previous nfs_page in the struct nfs_pageio_descriptor
+	 *   is known to lie within the range.
+	 *   - that the nfs_page being tested is known to be contiguous with the
+	 *   previous nfs_page.
+	 *   - Layout ranges are page aligned, so we only have to test the
+	 *   start offset of the request.
+	 *
+	 * Please also note that 'end_offset' is actually the offset of the
+	 * first byte that lies outside the pnfs_layout_range. FIXME?
+	 *
+	 */
+	return req_offset(req) < end_offset(pgio->pg_lseg->pls_range.offset,
+					 pgio->pg_lseg->pls_range.length);
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_test);
 
-- 
1.7.5.2

