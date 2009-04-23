From: andros@netapp.com
Subject: [PATCH 28/29] nfsd41: remove redundant failed sequence check
Date: Thu, 23 Apr 2009 12:43:07 -0400
Message-ID: <1240504988-9572-29-git-send-email-andros@netapp.com>
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
 <1240504988-9572-27-git-send-email-andros@netapp.com>
 <1240504988-9572-28-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3269 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756832AbZDWQnh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Apr 2009 12:43:37 -0400
In-Reply-To: <1240504988-9572-28-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6be72ad..4d211ff 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1008,16 +1008,9 @@ __be32
 nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 {
 	struct nfsd4_cache_entry *entry = &resp->cstate.slot->sl_cache_entry;
-	struct svc_rqst *rqstp = resp->rqstp;
-	struct nfsd4_compoundargs *args = rqstp->rq_argp;
-	struct nfsd4_op *op = &args->ops[resp->opcnt];
 
 	dprintk("--> %s cachethis %d\n", __func__, entry->ce_cachethis);
 
-	/* Don't cache a failed OP_SEQUENCE. */
-	if (resp->opcnt == 1 && op->opnum == OP_SEQUENCE && resp->cstate.status)
-		return 0;
-
 	entry->ce_opcnt = resp->opcnt;
 	entry->ce_status = resp->cstate.status;
 
-- 
1.5.4.3

