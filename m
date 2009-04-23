From: andros@netapp.com
Subject: [PATCH 12/29] nfsd41: allocate and use drc cache buffers
Date: Thu, 23 Apr 2009 12:42:51 -0400
Message-ID: <1240504988-9572-13-git-send-email-andros@netapp.com>
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
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46174 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756695AbZDWQnW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Apr 2009 12:43:22 -0400
In-Reply-To: <1240504988-9572-12-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Change from page based to memory based NFSv4.1 DRC.

Use the existing nfsd4_cache_entry ce_datav kvec to hold up to
NFSD_SLOT_CACH_SIZE of all encoded operation data past the encoded sequence
operation.  Allocate the buffer on demand, and keep it for the life of the
session.

Wnen we have dynamic slots negotiation we need to shutdown the slot upon
allocation error.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c        |   31 ++++++++++++++++++++++++-------
 fs/nfsd/nfs4xdr.c          |    2 ++
 include/linux/nfsd/state.h |    2 +-
 include/linux/nfsd/xdr4.h  |    3 ++-
 4 files changed, 29 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5666feb..9e79e0c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1048,20 +1048,19 @@ nfsd4_copy_pages(struct page **topages, struct page **frompages, short count)
  * Store the base and length of the rq_req.head[0] page
  * of the NFSv4.1 data, just past the rpc header.
  */
-void
+__be32
 nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 {
 	struct nfsd4_cache_entry *entry = &resp->cstate.slot->sl_cache_entry;
 	struct svc_rqst *rqstp = resp->rqstp;
 	struct nfsd4_compoundargs *args = rqstp->rq_argp;
 	struct nfsd4_op *op = &args->ops[resp->opcnt];
-	struct kvec *resv = &rqstp->rq_res.head[0];
 
 	dprintk("--> %s entry %p\n", __func__, entry);
 
 	/* Don't cache a failed OP_SEQUENCE. */
 	if (resp->opcnt == 1 && op->opnum == OP_SEQUENCE && resp->cstate.status)
-		return;
+		return 0;
 
 	nfsd4_release_respages(entry->ce_respages, entry->ce_resused);
 	entry->ce_opcnt = resp->opcnt;
@@ -1075,21 +1074,35 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	if (nfsd4_not_cached(resp)) {
 		entry->ce_resused = 0;
 		entry->ce_rpchdrlen = 0;
+		entry->ce_datav.iov_len = 0;
 		dprintk("%s Just cache SEQUENCE. ce_cachethis %d\n", __func__,
 			resp->cstate.slot->sl_cache_entry.ce_cachethis);
-		return;
+		return 0;
 	}
+
+	/* allocate the buffer on demand and keep it for the life of the slot */
+	if (entry->ce_datav.iov_base == NULL) {
+		entry->ce_datav.iov_base = kmalloc(NFSD_SLOT_CACHE_SIZE,
+						   GFP_KERNEL);
+		if (!entry->ce_datav.iov_base) {
+			/* FIXME: Should remove slot from session */
+			printk(KERN_WARNING "NFSD: No memory for DRC\n");
+			return -ENOMEM;
+		}
+	}
+	entry->ce_datav.iov_len = (char *)resp->p - (char *)resp->cstate.datap;
+	memcpy(entry->ce_datav.iov_base, resp->cstate.datap,
+	       entry->ce_datav.iov_len);
+
 	entry->ce_resused = rqstp->rq_resused;
 	if (entry->ce_resused > NFSD_PAGES_PER_SLOT + 1)
 		entry->ce_resused = NFSD_PAGES_PER_SLOT + 1;
 	nfsd4_copy_pages(entry->ce_respages, rqstp->rq_respages,
 			 entry->ce_resused);
-	entry->ce_datav.iov_base = resp->cstate.statp;
-	entry->ce_datav.iov_len = resv->iov_len - ((char *)resp->cstate.statp -
-				(char *)page_address(rqstp->rq_respages[0]));
 	/* Current request rpc header length*/
 	entry->ce_rpchdrlen = (char *)resp->cstate.statp -
 				(char *)page_address(rqstp->rq_respages[0]);
+	return 0;
 }
 
 /*
@@ -1146,6 +1159,10 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 		return nfs_ok;
 	}
 
+	/* The sequence operation has been encoded, cstate->datap set. */
+	memcpy(resp->cstate.datap, entry->ce_datav.iov_base,
+	       entry->ce_datav.iov_len);
+
 	if (!nfsd41_copy_replay_data(resp, entry)) {
 		/*
 		 * Not enough room to use the replay rpc header, send the
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 7459900..f4bba66 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3113,6 +3113,7 @@ nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
 	WRITE32(0);
 
 	ADJUST_ARGS();
+	resp->cstate.datap = p; /* DRC cache data pointer */
 	return 0;
 }
 
@@ -3362,6 +3363,7 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 				!nfsd4_not_cached(resp)) {
 			iov->iov_len = resp->cstate.iovlen;
 		} else {
+			/* FIXME: return ignored for now. Can have -ENOMEM */
 			nfsd4_store_cache_entry(resp);
 			dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
 			resp->cstate.slot->sl_inuse = 0;
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 473eb0d..b8aa47a 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -116,7 +116,7 @@ struct nfs4_callback {
 
 struct nfsd4_cache_entry {
 	__be32		ce_status;
-	struct kvec	ce_datav; /* encoded NFSv4.1 data in rq_res.head[0] */
+	struct kvec	ce_datav; /* encoded cached operations */
 	struct page	*ce_respages[NFSD_PAGES_PER_SLOT + 1];
 	int		ce_cachethis;
 	short		ce_resused;
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 8fd5eb1..5622e56 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -52,6 +52,7 @@ struct nfsd4_compound_state {
 	struct nfsd4_session	*session;
 	struct nfsd4_slot	*slot;
 	__be32			*statp;
+	__be32			*datap;
 	size_t			iovlen;
 	u32			minorversion;
 	u32			status;
@@ -514,7 +515,7 @@ extern __be32 nfsd4_setclientid(struct svc_rqst *rqstp,
 extern __be32 nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 		struct nfsd4_setclientid_confirm *setclientid_confirm);
-extern void nfsd4_store_cache_entry(struct nfsd4_compoundres *resp);
+extern __be32 nfsd4_store_cache_entry(struct nfsd4_compoundres *resp);
 extern __be32 nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 		struct nfsd4_sequence *seq);
 extern void nfsd4_cache_create_session(struct nfsd4_create_session *cr_ses,
-- 
1.5.4.3

