From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 06/21] SQUASHME: nfsd41: simplify match_clientid_establishment logic
Date: Fri,  3 Apr 2009 01:37:56 +0300
Message-ID: <1238711876-22209-1-git-send-email-bhalevy@panasas.com>
References: <49D53D44.4030102@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:25787 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1765308AbZDBWiI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 18:38:08 -0400
In-Reply-To: <49D53D44.4030102@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As per Bruce's review comment.

squash into "nfsd41: match clientid establishment method"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 445cf94..6ae12ff 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -876,12 +876,17 @@ find_unconfirmed_client(clientid_t *clid)
  * Return 1 iff clp's clientid establishment method matches the use_exchange_id
  * parameter. Matching is based on the fact the at least one of the
  * EXCHGID4_FLAG_USE_{NON_PNFS,PNFS_MDS,PNFS_DS} flags must be set for v4.1
+ *
+ * FIXME: we need to unify the clientid namespaces for nfsv4.x
+ * and correctly deal with client upgrade/downgrade in EXCHANGE_ID
+ * and SET_CLIENTID{,_CONFIRM}
  */
 static inline int
 match_clientid_establishment(struct nfs4_client *clp, bool use_exchange_id)
 {
 #if defined(CONFIG_NFSD_V4_1)
-	return (clp->cl_exchange_flags != 0) == (use_exchange_id != false);
+	bool has_exchange_flags = (clp->cl_exchange_flags != 0);
+	return use_exchange_id == has_exchange_flags;
 #else  /* CONFIG_NFSD_V4_1 */
 	return 1;
 #endif /* CONFIG_NFSD_V4_1 */
-- 
1.6.2.1

