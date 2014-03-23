Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47862 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752102AbaCWBM0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 21:12:26 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 12/50] nfsd4: reserve head space for krb5 integ/priv info
Date: Sat, 22 Mar 2014 21:11:43 -0400
Message-Id: <1395537141-10389-13-git-send-email-bfields@redhat.com>
In-Reply-To: <1395537141-10389-1-git-send-email-bfields@redhat.com>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Currently if the nfs-level part of a reply would be too large, we'll
return an error to the client.  But if the nfs-level part fits and
leaves no room for krb5p or krb5i stuff, then we just drop the request
entirely.

That's no good.  Instead, reserve some slack space at the end of the
buffer and make sure we fail outright if we'd come close.

The slack space here is a massive overstimate of what's required, we
should probably try for a tighter limit at some point.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 80e5921..849b0eb 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1270,7 +1270,7 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp, struct nfsd4_compoundres
 
 	xdr->buf = buf;
 	xdr->p   = head->iov_base + head->iov_len;
-	xdr->end = head->iov_base + PAGE_SIZE;
+	xdr->end = head->iov_base + PAGE_SIZE - 2 * RPC_MAX_AUTH_SIZE;
 }
 
 /*
-- 
1.8.5.3

