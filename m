Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47916 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752233AbaCWBMb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 21:12:31 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 39/50] nfsd4: use session limits to release send buffer reservation
Date: Sat, 22 Mar 2014 21:12:10 -0400
Message-Id: <1395537141-10389-40-git-send-email-bfields@redhat.com>
In-Reply-To: <1395537141-10389-1-git-send-email-bfields@redhat.com>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
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
index 79f3b71..343324e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2277,6 +2277,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 				    nfserr_rep_too_big;
 	if (xdr_restrict_buflen(xdr, buflen - 2 * RPC_MAX_AUTH_SIZE))
 		goto out_put_session;
+	svc_reserve(rqstp, buflen);
 
 	status = nfs_ok;
 	/* Success! bump slot seqid */
-- 
1.8.5.3

