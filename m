Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40804 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754725AbcIQWRm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 17 Sep 2016 18:17:42 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: [PATCH v4 1/9] nfs: the length argument to read_buf should be unsigned
Date: Sat, 17 Sep 2016 18:17:31 -0400
Message-Id: <1474150659-23894-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1474150659-23894-1-git-send-email-jlayton@redhat.com>
References: <1474150659-23894-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since it gets passed through to xdr_inline_decode, we might as well
have read_buf expect what it expects -- a size_t.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/callback_xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 656f68f7fe53..a710825f3d61 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -72,7 +72,7 @@ static int nfs4_encode_void(struct svc_rqst *rqstp, __be32 *p, void *dummy)
 	return xdr_ressize_check(rqstp, p);
 }
 
-static __be32 *read_buf(struct xdr_stream *xdr, int nbytes)
+static __be32 *read_buf(struct xdr_stream *xdr, size_t nbytes)
 {
 	__be32 *p;
 
-- 
2.7.4

