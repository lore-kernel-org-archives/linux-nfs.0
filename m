Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43365 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751430AbaEVTce (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:32:34 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 10/52] nfsd4: reserve head space for krb5 integ/priv info
Date: Thu, 22 May 2014 15:31:45 -0400
Message-Id: <1400787148-25941-11-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-1-git-send-email-bfields@redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
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
index f809aa8..747d6a8 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1262,7 +1262,7 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
 
 	xdr->buf = buf;
 	xdr->p   = head->iov_base + head->iov_len;
-	xdr->end = head->iov_base + PAGE_SIZE;
+	xdr->end = head->iov_base + PAGE_SIZE - 2 * RPC_MAX_AUTH_SIZE;
 }
 
 /*
-- 
1.9.0

