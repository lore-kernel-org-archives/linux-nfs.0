From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 21/44] nfsd41: remove struct nfsd4_cache_entry
Date: Tue, 16 Jun 2009 04:20:12 +0300
Message-ID: <1245115212-7493-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2663
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752010AbZFPBUM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:20:12 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Replaced by fields in struct nfsd4_slot

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c        |   20 ++------------------
 include/linux/nfsd/state.h |   27 +++++++--------------------
 2 files changed, 9 insertions(+), 38 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0f740c1..954ccda 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1016,13 +1016,11 @@ void
 nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 {
 	struct nfsd4_slot *slot = resp->cstate.slot;
-	struct nfsd4_cache_entry *entry = &resp->cstate.slot->sl_cache_entry;
 	struct svc_rqst *rqstp = resp->rqstp;
 	struct nfsd4_compoundargs *args = rqstp->rq_argp;
 	struct nfsd4_op *op = &args->ops[resp->opcnt];
-	struct kvec *resv = &rqstp->rq_res.head[0];
 
-	dprintk("--> %s entry %p\n", __func__, entry);
+	dprintk("--> %s\n", __func__);
 
 	/* Don't cache a failed OP_SEQUENCE. */
 	if (resp->opcnt == 1 && op->opnum == OP_SEQUENCE && resp->cstate.status)
@@ -1037,8 +1035,6 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	 */
 
 	if (nfsd4_not_cached(resp)) {
-		entry->ce_resused = 0;
-		entry->ce_rpchdrlen = 0;
 		slot->sl_datalen = 0;
 		dprintk("%s Just cache SEQUENCE. cachethis %d\n", __func__,
 			resp->cstate.slot->sl_cachethis);
@@ -1046,16 +1042,6 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	}
 	slot->sl_datalen = (char *)resp->p - (char *)resp->cstate.datap;
 	memcpy(slot->sl_data, resp->cstate.datap, slot->sl_datalen);
-
-	entry->ce_resused = rqstp->rq_resused;
-	if (entry->ce_resused > NFSD_PAGES_PER_SLOT + 1)
-		entry->ce_resused = NFSD_PAGES_PER_SLOT + 1;
-	entry->ce_datav.iov_base = resp->cstate.statp;
-	entry->ce_datav.iov_len = resv->iov_len - ((char *)resp->cstate.statp -
-				(char *)page_address(rqstp->rq_respages[0]));
-	/* Current request rpc header length*/
-	entry->ce_rpchdrlen = (char *)resp->cstate.statp -
-				(char *)page_address(rqstp->rq_respages[0]);
 }
 
 /*
@@ -1067,10 +1053,9 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 			 struct nfsd4_sequence *seq)
 {
 	struct nfsd4_slot *slot = resp->cstate.slot;
-	struct nfsd4_cache_entry *entry = &resp->cstate.slot->sl_cache_entry;
 	__be32 status;
 
-	dprintk("--> %s entry %p\n", __func__, entry);
+	dprintk("--> %s datalen %d\n", __func__, slot->sl_datalen);
 
 	/*
 	 * If this is just the sequence operation, we did not keep
@@ -1090,7 +1075,6 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 	/* The sequence operation has been encoded, cstate->datap set. */
 	memcpy(resp->cstate.datap, slot->sl_data, slot->sl_datalen);
 
-	resp->rqstp->rq_resused = entry->ce_resused;
 	resp->opcnt = slot->sl_opcnt;
 	resp->p = resp->cstate.datap + XDR_QUADLEN(slot->sl_datalen);
 	status = slot->sl_status;
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 4003afc..644a54b 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -94,31 +94,18 @@ struct nfs4_cb_conn {
 
 /* Maximum number of slots per session. 128 is useful for long haul TCP */
 #define NFSD_MAX_SLOTS_PER_SESSION	128
-/* Maximum number of pages per slot cache entry */
-#define NFSD_PAGES_PER_SLOT	1
 #define NFSD_SLOT_CACHE_SIZE		512
 /* Maximum number of operations per session compound */
 #define NFSD_MAX_OPS_PER_COMPOUND	16
 
-struct nfsd4_cache_entry {
-	__be32		ce_status;
-	struct kvec	ce_datav; /* encoded NFSv4.1 data in rq_res.head[0] */
-	struct page	*ce_respages[NFSD_PAGES_PER_SLOT + 1];
-	int		ce_cachethis;
-	short		ce_resused;
-	int		ce_opcnt;
-	int		ce_rpchdrlen;
-};
-
 struct nfsd4_slot {
-	bool				sl_inuse;
-	u32				sl_seqid;
-	int				sl_cachethis;
-	int				sl_opcnt;
-	__be32				sl_status;
-	u32				sl_datalen;
-	char				sl_data[NFSD_SLOT_CACHE_SIZE];
-	struct nfsd4_cache_entry	sl_cache_entry;
+	bool	sl_inuse;
+	u32	sl_seqid;
+	int	sl_cachethis;
+	int	sl_opcnt;
+	__be32	sl_status;
+	u32	sl_datalen;
+	char	sl_data[NFSD_SLOT_CACHE_SIZE];
 };
 
 struct nfsd4_channel_attrs {
-- 
1.6.3

