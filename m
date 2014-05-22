Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43348 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751967AbaEVTcd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:32:33 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 16/52] nfsd4: no need for encode_compoundres to adjust lengths
Date: Thu, 22 May 2014 15:31:51 -0400
Message-Id: <1400787148-25941-17-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-1-git-send-email-bfields@redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

xdr_reserve_space should now be calculating the length correctly as we
go, so there's no longer any need to fix it up here.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 3 +++
 fs/nfsd/nfs4xdr.c   | 8 +-------
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 56e8992..63bb9eb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1618,6 +1618,7 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 			 struct nfsd4_sequence *seq)
 {
 	struct nfsd4_slot *slot = resp->cstate.slot;
+	struct kvec *head = resp->xdr.iov;
 	__be32 status;
 
 	dprintk("--> %s slot %p\n", __func__, slot);
@@ -1631,6 +1632,8 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 
 	resp->opcnt = slot->sl_opcnt;
 	resp->xdr.p = resp->cstate.datap + XDR_QUADLEN(slot->sl_datalen);
+	head->iov_len = (void *)resp->xdr.p - head->iov_base;
+	resp->xdr.buf->len = head->iov_len;
 	status = slot->sl_status;
 
 	return status;
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 865a2c2..2fc4f9c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3789,19 +3789,13 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 	 * All that remains is to write the tag and operation count...
 	 */
 	struct nfsd4_compound_state *cs = &resp->cstate;
-	struct kvec *iov;
+
 	p = resp->tagp;
 	*p++ = htonl(resp->taglen);
 	memcpy(p, resp->tag, resp->taglen);
 	p += XDR_QUADLEN(resp->taglen);
 	*p++ = htonl(resp->opcnt);
 
-	if (rqstp->rq_res.page_len) 
-		iov = &rqstp->rq_res.tail[0];
-	else
-		iov = &rqstp->rq_res.head[0];
-	iov->iov_len = ((char *)resp->xdr.p) - (char *)iov->iov_base;
-	BUG_ON(iov->iov_len > PAGE_SIZE);
 	if (nfsd4_has_session(cs)) {
 		struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 		struct nfs4_client *clp = cs->session->se_client;
-- 
1.9.0

