From: andros@netapp.com
Subject: [PATCH 16/22] SQUASHME nfsd41: add to nfsd4_set_cache_entry
Date: Thu,  2 Apr 2009 20:19:57 -0400
Message-ID: <1238718003-8764-16-git-send-email-andros@netapp.com>
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
 <1238718003-8764-15-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33624 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756614AbZDCAUh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2009 20:20:37 -0400
In-Reply-To: <1238718003-8764-15-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

March 31 review comments.
squash into nfsd41: DRC save, restore, and clear functions

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4d547fa..852b101 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1060,12 +1060,14 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 {
 	struct nfsd4_cache_entry *entry = &resp->cstate.slot->sl_cache_entry;
 	struct svc_rqst *rqstp = resp->rqstp;
+	struct nfsd4_compoundargs *args = rqstp->rq_argp;
+	struct nfsd4_op *op = &args->ops[resp->opcnt];
 	struct kvec *resv = &rqstp->rq_res.head[0];
 
 	dprintk("--> %s entry %p\n", __func__, entry);
 
-	/* Don't cache a failed OP_SEQUENCE */
-	if (resp->opcnt == 1 && resp->cstate.status)
+	/* Don't cache a failed OP_SEQUENCE. */
+	if (resp->opcnt == 1 && op->opnum == OP_SEQUENCE && resp->cstate.status)
 		return;
 
 	nfsd4_release_respages(entry->ce_respages, entry->ce_resused);
-- 
1.5.4.3

