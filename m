From: andros@netapp.com
Subject: [PATCH 30/31] nfsd41: remove redundant failed sequence check
Date: Tue, 28 Apr 2009 13:00:04 -0400
Message-ID: <1240938005-23778-30-git-send-email-andros@netapp.com>
References: <1240938005-23778-1-git-send-email-andros@netapp.com>
 <1240938005-23778-2-git-send-email-andros@netapp.com>
 <1240938005-23778-3-git-send-email-andros@netapp.com>
 <1240938005-23778-4-git-send-email-andros@netapp.com>
 <1240938005-23778-5-git-send-email-andros@netapp.com>
 <1240938005-23778-6-git-send-email-andros@netapp.com>
 <1240938005-23778-7-git-send-email-andros@netapp.com>
 <1240938005-23778-8-git-send-email-andros@netapp.com>
 <1240938005-23778-9-git-send-email-andros@netapp.com>
 <1240938005-23778-10-git-send-email-andros@netapp.com>
 <1240938005-23778-11-git-send-email-andros@netapp.com>
 <1240938005-23778-12-git-send-email-andros@netapp.com>
 <1240938005-23778-13-git-send-email-andros@netapp.com>
 <1240938005-23778-14-git-send-email-andros@netapp.com>
 <1240938005-23778-15-git-send-email-andros@netapp.com>
 <1240938005-23778-16-git-send-email-andros@netapp.com>
 <1240938005-23778-17-git-send-email-andros@netapp.com>
 <1240938005-23778-18-git-send-email-andros@netapp.com>
 <1240938005-23778-19-git-send-email-andros@netapp.com>
 <1240938005-23778-20-git-send-email-andros@netapp.com>
 <1240938005-23778-21-git-send-email-andros@netapp.com>
 <1240938005-23778-22-git-send-email-andros@netapp.com>
 <1240938005-23778-23-git-send-email-andros@netapp.com>
 <1240938005-23778-24-git-send-email-andros@netapp.com>
 <1240938005-23778-25-git-send-email-andros@netapp.com>
 <1240938005-23778-26-git-send-email-andros@netapp.com>
 <1240938005-23778-27-git-send-email-andros@netapp.com>
 <1240938005-23778-28-git-send-email-andros@netapp.com>
 <1240938005-23778-29-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50875 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759926AbZD1RAo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2009 13:00:44 -0400
In-Reply-To: <1240938005-23778-29-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c7a78e2..1ea62cd 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1016,16 +1016,9 @@ void
 nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 {
 	struct nfsd4_slot *slot = resp->cstate.slot;
-	struct svc_rqst *rqstp = resp->rqstp;
-	struct nfsd4_compoundargs *args = rqstp->rq_argp;
-	struct nfsd4_op *op = &args->ops[resp->opcnt];
 
 	dprintk("--> %s cachethis %d\n", __func__, slot->sl_cachethis);
 
-	/* Don't cache a failed OP_SEQUENCE. */
-	if (resp->opcnt == 1 && op->opnum == OP_SEQUENCE && resp->cstate.status)
-		return;
-
 	slot->sl_opcnt = resp->opcnt;
 	slot->sl_status = resp->cstate.status;
 
-- 
1.5.4.3

