Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38598 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757703AbaEKUxC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 16:53:02 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 26/43] nfsd4: nfsd4_check_resp_size should check against whole buffer
Date: Sun, 11 May 2014 16:52:31 -0400
Message-Id: <1399841568-19716-27-git-send-email-bfields@redhat.com>
In-Reply-To: <1399841568-19716-1-git-send-email-bfields@redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index eb1694d..4751fd4 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3760,7 +3760,6 @@ __be32 nfsd4_check_resp_size(struct nfsd4_compoundres *resp, u32 respsize)
 {
 	struct xdr_buf *buf = &resp->rqstp->rq_res;
 	struct nfsd4_session *session = resp->cstate.session;
-	int slack_bytes = (char *)resp->xdr.end - (char *)resp->xdr.p;
 
 	if (nfsd4_has_session(&resp->cstate)) {
 		struct nfsd4_slot *slot = resp->cstate.slot;
@@ -3773,7 +3772,7 @@ __be32 nfsd4_check_resp_size(struct nfsd4_compoundres *resp, u32 respsize)
 			return nfserr_rep_too_big_to_cache;
 	}
 
-	if (respsize > slack_bytes) {
+	if (buf->len + respsize > buf->buflen) {
 		WARN_ON_ONCE(nfsd4_has_session(&resp->cstate));
 		return nfserr_resource;
 	}
-- 
1.7.9.5

