From: andros@netapp.com
Subject: [PATCH 12/30] nfsd41: replace ce_cachethis with nfsd4_slot field
Date: Mon,  8 Jun 2009 14:20:53 -0400
Message-ID: <1244485271-7461-13-git-send-email-andros@netapp.com>
References: <>
 <1244485271-7461-1-git-send-email-andros@netapp.com>
 <1244485271-7461-2-git-send-email-andros@netapp.com>
 <1244485271-7461-3-git-send-email-andros@netapp.com>
 <1244485271-7461-4-git-send-email-andros@netapp.com>
 <1244485271-7461-5-git-send-email-andros@netapp.com>
 <1244485271-7461-6-git-send-email-andros@netapp.com>
 <1244485271-7461-7-git-send-email-andros@netapp.com>
 <1244485271-7461-8-git-send-email-andros@netapp.com>
 <1244485271-7461-9-git-send-email-andros@netapp.com>
 <1244485271-7461-10-git-send-email-andros@netapp.com>
 <1244485271-7461-11-git-send-email-andros@netapp.com>
 <1244485271-7461-12-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38770 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752994AbZFHSV0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:21:26 -0400
In-Reply-To: <1244485271-7461-12-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

In preparation to remove struct nfsd4_cache_entry

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4proc.c         |    6 +++---
 fs/nfsd/nfs4state.c        |   10 +++++-----
 fs/nfsd/nfs4xdr.c          |    2 +-
 include/linux/nfsd/state.h |    1 +
 include/linux/nfsd/xdr4.h  |    2 +-
 5 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 13a6c58..3a2b12f 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -870,8 +870,8 @@ nfsd4_enc_uncached_replay(struct nfsd4_compoundargs *args,
 {
 	struct nfsd4_op *op;
 
-	dprintk("--> %s resp->opcnt %d ce_cachethis %u \n", __func__,
-		resp->opcnt, resp->cstate.slot->sl_cache_entry.ce_cachethis);
+	dprintk("--> %s resp->opcnt %d cachethis %u \n", __func__,
+		resp->opcnt, resp->cstate.slot->sl_cachethis);
 
 	/* Encode the replayed sequence operation */
 	BUG_ON(resp->opcnt != 1);
@@ -879,7 +879,7 @@ nfsd4_enc_uncached_replay(struct nfsd4_compoundargs *args,
 	nfsd4_encode_operation(resp, op);
 
 	/*return nfserr_retry_uncached_rep in next operation. */
-	if (resp->cstate.slot->sl_cache_entry.ce_cachethis == 0) {
+	if (resp->cstate.slot->sl_cachethis == 0) {
 		op = &args->ops[resp->opcnt++];
 		op->status = nfserr_retry_uncached_rep;
 		nfsd4_encode_operation(resp, op);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ab80a38..837c9cf 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1074,8 +1074,8 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 		entry->ce_resused = 0;
 		entry->ce_rpchdrlen = 0;
 		slot->sl_datalen = 0;
-		dprintk("%s Just cache SEQUENCE. ce_cachethis %d\n", __func__,
-			resp->cstate.slot->sl_cache_entry.ce_cachethis);
+		dprintk("%s Just cache SEQUENCE. cachethis %d\n", __func__,
+			resp->cstate.slot->sl_cachethis);
 		return;
 	}
 	/* Length is checked to be <= se_fmaxresp_cached in
@@ -1532,10 +1532,10 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	/* Success! bump slot seqid */
 	slot->sl_inuse = true;
 	slot->sl_seqid = seq->seqid;
-	slot->sl_cache_entry.ce_cachethis = seq->cachethis;
-	/* Always set the cache entry cachethis for solo sequence */
+	slot->sl_cachethis = seq->cachethis;
+	/* Always set the slot cachethis for solo sequence */
 	if (nfsd4_is_solo_sequence(resp))
-		slot->sl_cache_entry.ce_cachethis = 1;
+		slot->sl_cachethis = 1;
 
 	cstate->slot = slot;
 	cstate->session = session;
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 6f7e7b2..0250214 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3191,7 +3191,7 @@ static int nfsd4_check_drc_limit(struct nfsd4_compoundres *resp)
 		return status;
 
 	session = resp->cstate.session;
-	if (session == NULL || slot->sl_cache_entry.ce_cachethis == 0)
+	if (session == NULL || slot->sl_cachethis == 0)
 		return status;
 
 	if (resp->opcnt >= args->opcnt)
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 5319be5..e818edc 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -120,6 +120,7 @@ struct nfsd4_cache_entry {
 struct nfsd4_slot {
 	bool				sl_inuse;
 	u32				sl_seqid;
+	int				sl_cachethis;
 	u32				sl_datalen;
 	char				sl_data[NFSD_SLOT_CACHE_SIZE];
 	struct nfsd4_cache_entry	sl_cache_entry;
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 9ab9ab6..49d5ec9 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -470,7 +470,7 @@ static inline bool nfsd4_is_solo_sequence(struct nfsd4_compoundres *resp)
 
 static inline bool nfsd4_not_cached(struct nfsd4_compoundres *resp)
 {
-	return !resp->cstate.slot->sl_cache_entry.ce_cachethis ||
+	return !resp->cstate.slot->sl_cachethis ||
 			nfsd4_is_solo_sequence(resp);
 }
 
-- 
1.5.4.3

