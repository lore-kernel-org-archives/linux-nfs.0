From: andros@netapp.com
Subject: [PATCH 11/30] nfsd41: use static buffers for sessions DRC
Date: Mon,  8 Jun 2009 14:20:52 -0400
Message-ID: <1244485271-7461-12-git-send-email-andros@netapp.com>
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
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:65497 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753040AbZFHSVY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:21:24 -0400
In-Reply-To: <1244485271-7461-11-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Change from page based to memory based NFSv4.1 DRC.

We need to allocate memory for the session DRC in the CREATE_SESSION operation
because of the guarantee to the client that the memory resource is available
for caching responses.

In preparation to remove struct nfsd4_cache_entry, add static storage to
struct nfsd4_slot to hold up to NFSD_SLOT_CACH_SIZE of all encoded operation
data past the encoded sequence operation.

The encoded operation processing length is checked prior to the
nfsd4_store_cache_entry call by nfsd4_check_drc_limit. Note that
nfsd4_check_drc_limit() does this check after processing each operation which
is incorrect, it should be done prior to processing.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c        |   12 ++++++++++++
 fs/nfsd/nfs4xdr.c          |    1 +
 include/linux/nfsd/state.h |    2 ++
 include/linux/nfsd/xdr4.h  |    1 +
 4 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cdc2a5e..ab80a38 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1048,6 +1048,7 @@ nfsd4_copy_pages(struct page **topages, struct page **frompages, short count)
 void
 nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 {
+	struct nfsd4_slot *slot = resp->cstate.slot;
 	struct nfsd4_cache_entry *entry = &resp->cstate.slot->sl_cache_entry;
 	struct svc_rqst *rqstp = resp->rqstp;
 	struct nfsd4_compoundargs *args = rqstp->rq_argp;
@@ -1072,10 +1073,17 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	if (nfsd4_not_cached(resp)) {
 		entry->ce_resused = 0;
 		entry->ce_rpchdrlen = 0;
+		slot->sl_datalen = 0;
 		dprintk("%s Just cache SEQUENCE. ce_cachethis %d\n", __func__,
 			resp->cstate.slot->sl_cache_entry.ce_cachethis);
 		return;
 	}
+	/* Length is checked to be <= se_fmaxresp_cached in
+	 * nfsd4_check_drc_limit
+	 */
+	slot->sl_datalen = (char *)resp->p - (char *)resp->cstate.datap;
+	memcpy(slot->sl_data, resp->cstate.datap, slot->sl_datalen);
+
 	entry->ce_resused = rqstp->rq_resused;
 	if (entry->ce_resused > NFSD_PAGES_PER_SLOT + 1)
 		entry->ce_resused = NFSD_PAGES_PER_SLOT + 1;
@@ -1123,6 +1131,7 @@ __be32
 nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 			 struct nfsd4_sequence *seq)
 {
+	struct nfsd4_slot *slot = resp->cstate.slot;
 	struct nfsd4_cache_entry *entry = &resp->cstate.slot->sl_cache_entry;
 	__be32 status;
 
@@ -1143,6 +1152,9 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 		return nfs_ok;
 	}
 
+	/* The sequence operation has been encoded, cstate->datap set. */
+	memcpy(resp->cstate.datap, slot->sl_data, slot->sl_datalen);
+
 	if (!nfsd41_copy_replay_data(resp, entry)) {
 		/*
 		 * Not enough room to use the replay rpc header, send the
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 7e6b139..6f7e7b2 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3090,6 +3090,7 @@ nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
 	WRITE32(0);
 
 	ADJUST_ARGS();
+	resp->cstate.datap = p;	/* DRC cache data pointer */
 	return 0;
 }
 
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 28ddb32..5319be5 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -120,6 +120,8 @@ struct nfsd4_cache_entry {
 struct nfsd4_slot {
 	bool				sl_inuse;
 	u32				sl_seqid;
+	u32				sl_datalen;
+	char				sl_data[NFSD_SLOT_CACHE_SIZE];
 	struct nfsd4_cache_entry	sl_cache_entry;
 };
 
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 6e24dbb..9ab9ab6 100644
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
-- 
1.5.4.3

