From: andros@netapp.com
Subject: [PATCH 20/31] nfsd41: remove struct nfsd4_cache_entry
Date: Tue, 28 Apr 2009 12:59:54 -0400
Message-ID: <1240938005-23778-20-git-send-email-andros@netapp.com>
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
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50815 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755703AbZD1RA3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2009 13:00:29 -0400
In-Reply-To: <1240938005-23778-19-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Replaced by fields in struct nfsd4_slot

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c        |   20 ++------------------
 include/linux/nfsd/state.h |   27 +++++++--------------------
 2 files changed, 9 insertions(+), 38 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 616ec0f..ff43793 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1030,13 +1030,11 @@ void
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
@@ -1051,8 +1049,6 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	 */
 
 	if (nfsd4_not_cached(resp)) {
-		entry->ce_resused = 0;
-		entry->ce_rpchdrlen = 0;
 		slot->sl_datalen = 0;
 		dprintk("%s Just cache SEQUENCE. cachethis %d\n", __func__,
 			resp->cstate.slot->sl_cachethis);
@@ -1060,16 +1056,6 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
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
@@ -1081,10 +1067,9 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 			 struct nfsd4_sequence *seq)
 {
 	struct nfsd4_slot *slot = resp->cstate.slot;
-	struct nfsd4_cache_entry *entry = &resp->cstate.slot->sl_cache_entry;
 	__be32 status;
 
-	dprintk("--> %s entry %p\n", __func__, entry);
+	dprintk("--> %s datalen %d\n", __func__, slot->sl_datalen);
 
 	/*
 	 * If this is just the sequence operation, we did not keep
@@ -1104,7 +1089,6 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 	/* The sequence operation has been encoded, cstate->datap set. */
 	memcpy(resp->cstate.datap, slot->sl_data, slot->sl_datalen);
 
-	resp->rqstp->rq_resused = entry->ce_resused;
 	resp->opcnt = slot->sl_opcnt;
 	resp->p = resp->cstate.datap + XDR_QUADLEN(slot->sl_datalen);
 	status = slot->sl_status;
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 8800e18..20d9958 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -107,31 +107,18 @@ struct nfs4_callback {
 
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
 
 /*
-- 
1.5.4.3

