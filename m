From: andros@netapp.com
Subject: [PATCH 14/14] nfsd41: remove redundant failed sequence check
Date: Wed, 24 Jun 2009 15:37:58 -0400
Message-ID: <1245872278-18743-15-git-send-email-andros@netapp.com>
References: <>
 <1245872278-18743-1-git-send-email-andros@netapp.com>
 <1245872278-18743-2-git-send-email-andros@netapp.com>
 <1245872278-18743-3-git-send-email-andros@netapp.com>
 <1245872278-18743-4-git-send-email-andros@netapp.com>
 <1245872278-18743-5-git-send-email-andros@netapp.com>
 <1245872278-18743-6-git-send-email-andros@netapp.com>
 <1245872278-18743-7-git-send-email-andros@netapp.com>
 <1245872278-18743-8-git-send-email-andros@netapp.com>
 <1245872278-18743-9-git-send-email-andros@netapp.com>
 <1245872278-18743-10-git-send-email-andros@netapp.com>
 <1245872278-18743-11-git-send-email-andros@netapp.com>
 <1245872278-18743-12-git-send-email-andros@netapp.com>
 <1245872278-18743-13-git-send-email-andros@netapp.com>
 <1245872278-18743-14-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:40120 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761090AbZFXTiI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Jun 2009 15:38:08 -0400
In-Reply-To: <1245872278-18743-14-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7662ca8..bb85d0d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1003,17 +1003,10 @@ void
 nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 {
 	struct nfsd4_slot *slot = resp->cstate.slot;
-	struct svc_rqst *rqstp = resp->rqstp;
-	struct nfsd4_compoundargs *args = rqstp->rq_argp;
-	struct nfsd4_op *op = &args->ops[resp->opcnt];
 	unsigned int base;
 
 	dprintk("--> %s slot %p\n", __func__, slot);
 
-	/* Don't cache a failed OP_SEQUENCE. */
-	if (resp->opcnt == 1 && op->opnum == OP_SEQUENCE && resp->cstate.status)
-		return;
-
 	slot->sl_opcnt = resp->opcnt;
 	slot->sl_status = resp->cstate.status;
 
-- 
1.5.4.3

