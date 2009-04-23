From: andros@netapp.com
Subject: [PATCH 26/29] nfsd41: fix nfsd4_store_cache_entry dprintk
Date: Thu, 23 Apr 2009 12:43:05 -0400
Message-ID: <1240504988-9572-27-git-send-email-andros@netapp.com>
References: <>
 <1240504988-9572-1-git-send-email-andros@netapp.com>
 <1240504988-9572-2-git-send-email-andros@netapp.com>
 <1240504988-9572-3-git-send-email-andros@netapp.com>
 <1240504988-9572-4-git-send-email-andros@netapp.com>
 <1240504988-9572-5-git-send-email-andros@netapp.com>
 <1240504988-9572-6-git-send-email-andros@netapp.com>
 <1240504988-9572-7-git-send-email-andros@netapp.com>
 <1240504988-9572-8-git-send-email-andros@netapp.com>
 <1240504988-9572-9-git-send-email-andros@netapp.com>
 <1240504988-9572-10-git-send-email-andros@netapp.com>
 <1240504988-9572-11-git-send-email-andros@netapp.com>
 <1240504988-9572-12-git-send-email-andros@netapp.com>
 <1240504988-9572-13-git-send-email-andros@netapp.com>
 <1240504988-9572-14-git-send-email-andros@netapp.com>
 <1240504988-9572-15-git-send-email-andros@netapp.com>
 <1240504988-9572-16-git-send-email-andros@netapp.com>
 <1240504988-9572-17-git-send-email-andros@netapp.com>
 <1240504988-9572-18-git-send-email-andros@netapp.com>
 <1240504988-9572-19-git-send-email-andros@netapp.com>
 <1240504988-9572-20-git-send-email-andros@netapp.com>
 <1240504988-9572-21-git-send-email-andros@netapp.com>
 <1240504988-9572-22-git-send-email-andros@netapp.com>
 <1240504988-9572-23-git-send-email-andros@netapp.com>
 <1240504988-9572-24-git-send-email-andros@netapp.com>
 <1240504988-9572-25-git-send-email-andros@netapp.com>
 <1240504988-9572-26-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46174 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757392AbZDWQnf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Apr 2009 12:43:35 -0400
In-Reply-To: <1240504988-9572-26-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1e995ec..6be72ad 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1012,7 +1012,7 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	struct nfsd4_compoundargs *args = rqstp->rq_argp;
 	struct nfsd4_op *op = &args->ops[resp->opcnt];
 
-	dprintk("--> %s entry %p\n", __func__, entry);
+	dprintk("--> %s cachethis %d\n", __func__, entry->ce_cachethis);
 
 	/* Don't cache a failed OP_SEQUENCE. */
 	if (resp->opcnt == 1 && op->opnum == OP_SEQUENCE && resp->cstate.status)
@@ -1024,8 +1024,6 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	/* Don't cache the sequence operation, use the slot values on replay. */
 	if (nfsd4_not_cached(resp)) {
 		entry->ce_datav.iov_len = 0;
-		dprintk("%s Just cache SEQUENCE. ce_cachethis %d\n", __func__,
-			resp->cstate.slot->sl_cache_entry.ce_cachethis);
 		return 0;
 	}
 
-- 
1.5.4.3

