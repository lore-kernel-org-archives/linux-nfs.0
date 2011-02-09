Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46276 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750830Ab1BIEz5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Feb 2011 23:55:57 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/6] nfsd4: remove unused deleg dprintk's.
Date: Tue,  8 Feb 2011 23:55:50 -0500
Message-Id: <1297227351-15365-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1297227351-15365-1-git-send-email-bfields@redhat.com>
References: <1297227351-15365-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

These aren't all that useful, and get in the way of the next steps.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 77e94f0..0375e99 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -958,8 +958,6 @@ expire_client(struct nfs4_client *clp)
 	spin_lock(&recall_lock);
 	while (!list_empty(&clp->cl_delegations)) {
 		dp = list_entry(clp->cl_delegations.next, struct nfs4_delegation, dl_perclnt);
-		dprintk("NFSD: expire client. dp %p, fp %p\n", dp,
-				dp->dl_flock);
 		list_del_init(&dp->dl_perclnt);
 		list_move(&dp->dl_recall_lru, &reaplist);
 	}
@@ -2932,8 +2930,6 @@ nfs4_laundromat(void)
 				test_val = u;
 			break;
 		}
-		dprintk("NFSD: purging unused delegation dp %p, fp %p\n",
-			            dp, dp->dl_flock);
 		list_move(&dp->dl_recall_lru, &reaplist);
 	}
 	spin_unlock(&recall_lock);
-- 
1.7.1

