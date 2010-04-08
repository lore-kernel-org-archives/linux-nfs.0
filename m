From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 3/8] nfsd4: remove dprintk
Date: Thu,  8 Apr 2010 11:59:17 -0400
Message-ID: <1270742362-9375-4-git-send-email-bfields@citi.umich.edu>
References: <1270742362-9375-1-git-send-email-bfields@citi.umich.edu>
 <1270742362-9375-2-git-send-email-bfields@citi.umich.edu>
 <1270742362-9375-3-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52045 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932678Ab0DHP4z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Apr 2010 11:56:55 -0400
In-Reply-To: <1270742362-9375-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I haven't found this useful.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9ce5831..5d86df1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -718,9 +718,6 @@ expire_client(struct nfs4_client *clp)
 	struct nfs4_delegation *dp;
 	struct list_head reaplist;
 
-	dprintk("NFSD: expire_client cl_count %d\n",
-	                    atomic_read(&clp->cl_count));
-
 	INIT_LIST_HEAD(&reaplist);
 	spin_lock(&recall_lock);
 	while (!list_empty(&clp->cl_delegations)) {
-- 
1.6.3.3

