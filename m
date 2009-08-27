From: andros@netapp.com
Subject: [PATCH 1/5] nfsd41: expand solo sequence check
Date: Thu, 27 Aug 2009 12:07:40 -0400
Message-ID: <1251389264-3009-2-git-send-email-andros@netapp.com>
References: <1251389264-3009-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:11161 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752595AbZH0QH0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Aug 2009 12:07:26 -0400
In-Reply-To: <1251389264-3009-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Failed sequenece == solo sequence.
Remove redundant sequence operation cache checks.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c       |    9 ---------
 include/linux/nfsd/xdr4.h |    2 +-
 2 files changed, 1 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d2a0524..ddfd36f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -991,16 +991,10 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 {
 	struct nfsd4_cache_entry *entry = &resp->cstate.slot->sl_cache_entry;
 	struct svc_rqst *rqstp = resp->rqstp;
-	struct nfsd4_compoundargs *args = rqstp->rq_argp;
-	struct nfsd4_op *op = &args->ops[resp->opcnt];
 	struct kvec *resv = &rqstp->rq_res.head[0];
 
 	dprintk("--> %s entry %p\n", __func__, entry);
 
-	/* Don't cache a failed OP_SEQUENCE. */
-	if (resp->opcnt == 1 && op->opnum == OP_SEQUENCE && resp->cstate.status)
-		return;
-
 	nfsd4_release_respages(entry->ce_respages, entry->ce_resused);
 	entry->ce_opcnt = resp->opcnt;
 	entry->ce_status = resp->cstate.status;
@@ -1490,9 +1484,6 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	slot->sl_inuse = true;
 	slot->sl_seqid = seq->seqid;
 	slot->sl_cache_entry.ce_cachethis = seq->cachethis;
-	/* Always set the cache entry cachethis for solo sequence */
-	if (nfsd4_is_solo_sequence(resp))
-		slot->sl_cache_entry.ce_cachethis = 1;
 
 	cstate->slot = slot;
 	cstate->session = session;
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 5e4beb0..3f71660 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -467,7 +467,7 @@ struct nfsd4_compoundres {
 static inline bool nfsd4_is_solo_sequence(struct nfsd4_compoundres *resp)
 {
 	struct nfsd4_compoundargs *args = resp->rqstp->rq_argp;
-	return args->opcnt == 1;
+	return resp->opcnt == 1 && args->ops[0].opnum == OP_SEQUENCE;
 }
 
 static inline bool nfsd4_not_cached(struct nfsd4_compoundres *resp)
-- 
1.6.2.5

