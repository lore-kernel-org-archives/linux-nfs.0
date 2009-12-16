From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 02/11] nfsd: mark client state as expired in expire_client
Date: Wed, 16 Dec 2009 19:40:46 +0200
Message-ID: <1260985246-21410-1-git-send-email-bhalevy@panasas.com>
References: <4B291B4C.3060603@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:11295 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757976AbZLPRkt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Dec 2009 12:40:49 -0500
In-Reply-To: <4B291B4C.3060603@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f19ed86..dd76682 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -724,6 +724,7 @@ expire_client(struct nfs4_client *clp)
 	dprintk("NFSD: expire_client cl_count %d\n",
 	                    atomic_read(&clp->cl_count));
 
+	atomic_set(&clp->cl_state, CL_STATE_EXPIRED);
 	INIT_LIST_HEAD(&reaplist);
 	spin_lock(&recall_lock);
 	while (!list_empty(&clp->cl_delegations)) {
-- 
1.6.5.1

