From: andros@netapp.com
Subject: [PATCH 12/31] nfsd41: use static buffers for sessions DRC
Date: Tue, 28 Apr 2009 12:59:46 -0400
Message-ID: <1240938005-23778-12-git-send-email-andros@netapp.com>
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
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50815 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757973AbZD1RAc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2009 13:00:32 -0400
In-Reply-To: <1240938005-23778-11-git-send-email-andros@netapp.com>
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

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c        |    9 +++++++++
 fs/nfsd/nfs4xdr.c          |    1 +
 include/linux/nfsd/state.h |    2 ++
 include/linux/nfsd/xdr4.h  |    1 +
 4 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 187e1da..fecee33 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1066,6 +1066,7 @@ nfsd4_copy_pages(struct page **topages, struct page **frompages, short count)
 void
 nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 {
+	struct nfsd4_slot *slot = resp->cstate.slot;
 	struct nfsd4_cache_entry *entry = &resp->cstate.slot->sl_cache_entry;
 	struct svc_rqst *rqstp = resp->rqstp;
 	struct nfsd4_compoundargs *args = rqstp->rq_argp;
@@ -1090,10 +1091,14 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	if (nfsd4_not_cached(resp)) {
 		entry->ce_resused = 0;
 		entry->ce_rpchdrlen = 0;
+		slot->sl_datalen = 0;
 		dprintk("%s Just cache SEQUENCE. ce_cachethis %d\n", __func__,
 			resp->cstate.slot->sl_cache_entry.ce_cachethis);
 		return;
 	}
+	slot->sl_datalen = (char *)resp->p - (char *)resp->cstate.datap;
+	memcpy(slot->sl_data, resp->cstate.datap, slot->sl_datalen);
+
 	entry->ce_resused = rqstp->rq_resused;
 	if (entry->ce_resused > NFSD_PAGES_PER_SLOT + 1)
 		entry->ce_resused = NFSD_PAGES_PER_SLOT + 1;
@@ -1141,6 +1146,7 @@ __be32
 nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 			 struct nfsd4_sequence *seq)
 {
+	struct nfsd4_slot *slot = resp->cstate.slot;
 	struct nfsd4_cache_entry *entry = &resp->cstate.slot->sl_cache_entry;
 	__be32 status;
 
@@ -1161,6 +1167,9 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 		return nfs_ok;
 	}
 
+	/* The sequence operation has been encoded, cstate->datap set. */
+	memcpy(resp->cstate.datap, slot->sl_data, slot->sl_datalen);
+
 	if (!nfsd41_copy_replay_data(resp, entry)) {
 		/*
 		 * Not enough room to use the replay rpc header, send the
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 238612e..41ac385 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3111,6 +3111,7 @@ nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
 	WRITE32(0);
 
 	ADJUST_ARGS();
+	resp->cstate.datap = p;	/* DRC cache data pointer */
 	return 0;
 }
 
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 3580d55..362c684 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -126,6 +126,8 @@ struct nfsd4_cache_entry {
 struct nfsd4_slot {
 	bool				sl_inuse;
 	u32				sl_seqid;
+	u32				sl_datalen;
+	char				sl_data[NFSD_SLOT_CACHE_SIZE];
 	struct nfsd4_cache_entry	sl_cache_entry;
 };
 
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index ac00985..52589ba 100644
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

