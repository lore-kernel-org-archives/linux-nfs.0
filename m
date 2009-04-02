From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 05/21] SQUASHME: nfsd41: reverse use of EXCHGID4_INVAL_FLAG_MASK_A
Date: Fri,  3 Apr 2009 01:37:52 +0300
Message-ID: <1238711872-22178-1-git-send-email-bhalevy@panasas.com>
References: <49D53D44.4030102@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:26452 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1765308AbZDBWh6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 18:37:58 -0400
In-Reply-To: <49D53D44.4030102@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As per Bruce's review comment.

squash into "nfsd41: exchange_id operation"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b7c4ed0..445cf94 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1222,7 +1222,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 		__func__, rqstp, exid, clname.len, clname.data,
 		ip_addr, exid->flags, exid->spa_how);
 
-	if (!check_name(clname) || (exid->flags & EXCHGID4_INVAL_FLAG_MASK_A))
+	if (!check_name(clname) || (exid->flags & ~EXCHGID4_FLAG_MASK_A))
 		return nfserr_inval;
 
 	/* Currently only support SP4_NONE */
-- 
1.6.2.1

