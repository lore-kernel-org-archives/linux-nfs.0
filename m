Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38519 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754226AbaEKUwy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 16:52:54 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 04/43] nfsd4: reserve head space for krb5 integ/priv info
Date: Sun, 11 May 2014 16:52:09 -0400
Message-Id: <1399841568-19716-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1399841568-19716-1-git-send-email-bfields@redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
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
 fs/nfsd/nfs4proc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 6c049c4..3d4b044 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1259,7 +1259,7 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp, struct nfsd4_compoundres
 
 	xdr->buf = buf;
 	xdr->p   = head->iov_base + head->iov_len;
-	xdr->end = head->iov_base + PAGE_SIZE;
+	xdr->end = head->iov_base + PAGE_SIZE - 2 * RPC_MAX_AUTH_SIZE;
 }
 
 /*
-- 
1.7.9.5

