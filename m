Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38609 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757743AbaEKUxD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 16:53:03 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 29/43] nfsd4: use session limits to release send buffer reservation
Date: Sun, 11 May 2014 16:52:34 -0400
Message-Id: <1399841568-19716-30-git-send-email-bfields@redhat.com>
In-Reply-To: <1399841568-19716-1-git-send-email-bfields@redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Once we know the limits the session places on the size of the rpc, we
can also use that information to release any unnecessary reserved reply
buffer space.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 620d240..2526426 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2286,6 +2286,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 				    nfserr_rep_too_big;
 	if (xdr_restrict_buflen(xdr, buflen - 2 * RPC_MAX_AUTH_SIZE))
 		goto out_put_session;
+	svc_reserve(rqstp, buflen);
 
 	status = nfs_ok;
 	/* Success! bump slot seqid */
-- 
1.7.9.5

