From: andros@netapp.com
Subject: [PATCH 28/31] nfsd41: fix nfsd4_store_cache_entry dprintk
Date: Tue, 28 Apr 2009 13:00:02 -0400
Message-ID: <1240938005-23778-28-git-send-email-andros@netapp.com>
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
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7762 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760854AbZD1RBI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2009 13:01:08 -0400
In-Reply-To: <1240938005-23778-27-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 56114fd..c7a78e2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1020,7 +1020,7 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	struct nfsd4_compoundargs *args = rqstp->rq_argp;
 	struct nfsd4_op *op = &args->ops[resp->opcnt];
 
-	dprintk("--> %s\n", __func__);
+	dprintk("--> %s cachethis %d\n", __func__, slot->sl_cachethis);
 
 	/* Don't cache a failed OP_SEQUENCE. */
 	if (resp->opcnt == 1 && op->opnum == OP_SEQUENCE && resp->cstate.status)
@@ -1033,8 +1033,6 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	/* Don't cache the sequence operation, use the slot values on replay */
 	if (nfsd4_not_cached(resp)) {
 		slot->sl_datalen = 0;
-		dprintk("%s Just cache SEQUENCE. cachethis %d\n", __func__,
-			resp->cstate.slot->sl_cachethis);
 		return;
 	}
 	slot->sl_datalen = (char *)resp->p - (char *)resp->cstate.datap;
-- 
1.5.4.3

