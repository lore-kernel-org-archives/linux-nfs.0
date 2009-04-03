From: andros@netapp.com
Subject: [PATCH 15/22] SQUASHME nfsd41: revert portion of nfsd4_set_cache_entry
Date: Thu,  2 Apr 2009 20:19:56 -0400
Message-ID: <1238718003-8764-15-git-send-email-andros@netapp.com>
References: <1238718003-8764-1-git-send-email-andros@netapp.com>
 <1238718003-8764-2-git-send-email-andros@netapp.com>
 <1238718003-8764-3-git-send-email-andros@netapp.com>
 <1238718003-8764-4-git-send-email-andros@netapp.com>
 <1238718003-8764-5-git-send-email-andros@netapp.com>
 <1238718003-8764-6-git-send-email-andros@netapp.com>
 <1238718003-8764-7-git-send-email-andros@netapp.com>
 <1238718003-8764-8-git-send-email-andros@netapp.com>
 <1238718003-8764-9-git-send-email-andros@netapp.com>
 <1238718003-8764-10-git-send-email-andros@netapp.com>
 <1238718003-8764-11-git-send-email-andros@netapp.com>
 <1238718003-8764-12-git-send-email-andros@netapp.com>
 <1238718003-8764-13-git-send-email-andros@netapp.com>
 <1238718003-8764-14-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>,
	Andy Adamson <andros-Kun280L+pZkAvxtiuMwx3w@public.gmane.org>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33624 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757423AbZDCAUg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2009 20:20:36 -0400
In-Reply-To: <1238718003-8764-14-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

March 31 review comments.
Squash into nfsd41: Add a create session replay cache

Signed-off-by: Andy Adamson <andros-Kun280L+pZkAvxtiuMwx3w@public.gmane.org>
---
 fs/nfsd/nfs4state.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 852b101..4d547fa 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1060,14 +1060,12 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 {
 	struct nfsd4_cache_entry *entry = &resp->cstate.slot->sl_cache_entry;
 	struct svc_rqst *rqstp = resp->rqstp;
-	struct nfsd4_compoundargs *args = rqstp->rq_argp;
-	struct nfsd4_op *op = &args->ops[resp->opcnt];
 	struct kvec *resv = &rqstp->rq_res.head[0];
 
 	dprintk("--> %s entry %p\n", __func__, entry);
 
-	/* Don't cache a failed OP_SEQUENCE. */
-	if (resp->opcnt == 1 && op->opnum == OP_SEQUENCE && resp->cstate.status)
+	/* Don't cache a failed OP_SEQUENCE */
+	if (resp->opcnt == 1 && resp->cstate.status)
 		return;
 
 	nfsd4_release_respages(entry->ce_respages, entry->ce_resused);
-- 
1.5.4.3

