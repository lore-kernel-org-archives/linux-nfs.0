From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 06/11] nfsd4: remove dprintk
Date: Tue,  9 Mar 2010 19:28:11 -0500
Message-ID: <1268180896-30921-7-git-send-email-bfields@citi.umich.edu>
References: <1268180896-30921-1-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-2-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-3-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-4-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-5-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-6-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42167 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755551Ab0CJA0v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Mar 2010 19:26:51 -0500
In-Reply-To: <1268180896-30921-6-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I haven't found this useful.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9762fc0..1b2637b 100644
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

