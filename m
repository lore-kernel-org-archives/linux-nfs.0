Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43447 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752656AbaEVTcn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:32:43 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 35/52] nfsd4: use session limits to release send buffer reservation
Date: Thu, 22 May 2014 15:32:10 -0400
Message-Id: <1400787148-25941-36-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-1-git-send-email-bfields@redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Once we know the limits the session places on the size of the rpc, we
can also use that information to release any unnecessary reserved reply
buffer space.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 09be2e0..7a06246 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2290,6 +2290,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 				    nfserr_rep_too_big;
 	if (xdr_restrict_buflen(xdr, buflen - 2 * RPC_MAX_AUTH_SIZE))
 		goto out_put_session;
+	svc_reserve(rqstp, buflen);
 
 	status = nfs_ok;
 	/* Success! bump slot seqid */
-- 
1.9.0

