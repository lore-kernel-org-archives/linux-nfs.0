Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43434 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751039AbaEVTcm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:32:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 31/52] nfsd4: nfsd4_check_resp_size should check against whole buffer
Date: Thu, 22 May 2014 15:32:06 -0400
Message-Id: <1400787148-25941-32-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-1-git-send-email-bfields@redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 741aab2..91d0b9a 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3762,7 +3762,6 @@ __be32 nfsd4_check_resp_size(struct nfsd4_compoundres *resp, u32 respsize)
 {
 	struct xdr_buf *buf = &resp->rqstp->rq_res;
 	struct nfsd4_session *session = resp->cstate.session;
-	int slack_bytes = (char *)resp->xdr.end - (char *)resp->xdr.p;
 
 	if (nfsd4_has_session(&resp->cstate)) {
 		struct nfsd4_slot *slot = resp->cstate.slot;
@@ -3775,7 +3774,7 @@ __be32 nfsd4_check_resp_size(struct nfsd4_compoundres *resp, u32 respsize)
 			return nfserr_rep_too_big_to_cache;
 	}
 
-	if (respsize > slack_bytes) {
+	if (buf->len + respsize > buf->buflen) {
 		WARN_ON_ONCE(nfsd4_has_session(&resp->cstate));
 		return nfserr_resource;
 	}
-- 
1.9.0

