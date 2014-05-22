Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43416 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752546AbaEVTck (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:32:40 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 27/52] nfsd4: convert 4.1 replay encoding
Date: Thu, 22 May 2014 15:32:02 -0400
Message-Id: <1400787148-25941-28-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-1-git-send-email-bfields@redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Limits on maxresp_sz mean that we only ever need to replay rpc's that
are contained entirely in the head.

The one exception is very small zero-copy reads.  That's an odd corner
case as clients wouldn't normally ask those to be cached.

in any case, this seems a little more robust.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 28 ++++++++++++++--------------
 fs/nfsd/nfs4xdr.c   |  2 +-
 fs/nfsd/xdr4.h      |  2 +-
 3 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 63bb9eb..e936d9f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1560,6 +1560,7 @@ out_err:
 void
 nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 {
+	struct xdr_buf *buf = resp->xdr.buf;
 	struct nfsd4_slot *slot = resp->cstate.slot;
 	unsigned int base;
 
@@ -1573,11 +1574,9 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 		slot->sl_datalen = 0;
 		return;
 	}
-	slot->sl_datalen = (char *)resp->xdr.p - (char *)resp->cstate.datap;
-	base = (char *)resp->cstate.datap -
-					(char *)resp->xdr.buf->head[0].iov_base;
-	if (read_bytes_from_xdr_buf(resp->xdr.buf, base, slot->sl_data,
-				    slot->sl_datalen))
+	base = resp->cstate.data_offset;
+	slot->sl_datalen = buf->len - base;
+	if (read_bytes_from_xdr_buf(buf, base, slot->sl_data, slot->sl_datalen))
 		WARN("%s: sessions DRC could not cache compound\n", __func__);
 	return;
 }
@@ -1618,7 +1617,8 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 			 struct nfsd4_sequence *seq)
 {
 	struct nfsd4_slot *slot = resp->cstate.slot;
-	struct kvec *head = resp->xdr.iov;
+	struct xdr_stream *xdr = &resp->xdr;
+	__be32 *p;
 	__be32 status;
 
 	dprintk("--> %s slot %p\n", __func__, slot);
@@ -1627,16 +1627,16 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 	if (status)
 		return status;
 
-	/* The sequence operation has been encoded, cstate->datap set. */
-	memcpy(resp->cstate.datap, slot->sl_data, slot->sl_datalen);
+	p = xdr_reserve_space(xdr, slot->sl_datalen);
+	if (!p) {
+		WARN_ON_ONCE(1);
+		return nfserr_serverfault;
+	}
+	xdr_encode_opaque_fixed(p, slot->sl_data, slot->sl_datalen);
+	xdr_commit_encode(xdr);
 
 	resp->opcnt = slot->sl_opcnt;
-	resp->xdr.p = resp->cstate.datap + XDR_QUADLEN(slot->sl_datalen);
-	head->iov_len = (void *)resp->xdr.p - head->iov_base;
-	resp->xdr.buf->len = head->iov_len;
-	status = slot->sl_status;
-
-	return status;
+	return slot->sl_status;
 }
 
 /*
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 1bac000..19df1c2 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3659,7 +3659,7 @@ nfsd4_encode_sequence(struct nfsd4_compoundres *resp, __be32 nfserr,
 	WRITE32(seq->maxslots - 1); /* sr_target_highest_slotid */
 	WRITE32(seq->status_flags);
 
-	resp->cstate.datap = p; /* DRC cache data pointer */
+	resp->cstate.data_offset = xdr->buf->len; /* DRC cache data pointer */
 	return 0;
 }
 
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index ea5ad5d..ee9ffdc 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -58,7 +58,7 @@ struct nfsd4_compound_state {
 	/* For sessions DRC */
 	struct nfsd4_session	*session;
 	struct nfsd4_slot	*slot;
-	__be32			*datap;
+	int			data_offset;
 	size_t			iovlen;
 	u32			minorversion;
 	__be32			status;
-- 
1.9.0

