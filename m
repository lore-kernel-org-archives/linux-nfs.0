From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 15/21] SQUASHME: nfsd41: no need to INIT_LIST_HEAD in alloc_init_session just prior to list_add
Date: Fri,  3 Apr 2009 01:38:38 +0300
Message-ID: <1238711918-22490-1-git-send-email-bhalevy@panasas.com>
References: <49D53D44.4030102@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:26850 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1764792AbZDBWin (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 18:38:43 -0400
In-Reply-To: <49D53D44.4030102@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As per Bruce's review comment.

squash into "nfsd41: create_session"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 53ed144..b04f1fa 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -522,8 +522,6 @@ alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp,
 
 	new->se_flags = cses->flags;
 	kref_init(&new->se_ref);
-	INIT_LIST_HEAD(&new->se_hash);
-	INIT_LIST_HEAD(&new->se_perclnt);
 	spin_lock(&sessionid_lock);
 	list_add(&new->se_hash, &sessionid_hashtbl[idx]);
 	list_add(&new->se_perclnt, &clp->cl_sessions);
-- 
1.6.2.1

