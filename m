Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48756 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933904AbcIFPMw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Sep 2016 11:12:52 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/9] nfs: the length argument to read_buf should be unsigned
Date: Tue,  6 Sep 2016 11:12:32 -0400
Message-Id: <1473174760-29859-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1473174760-29859-1-git-send-email-jlayton@redhat.com>
References: <1473174760-29859-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/callback_xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 656f68f7fe53..d6a40c06ec26 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -72,7 +72,7 @@ static int nfs4_encode_void(struct svc_rqst *rqstp, __be32 *p, void *dummy)
 	return xdr_ressize_check(rqstp, p);
 }
 
-static __be32 *read_buf(struct xdr_stream *xdr, int nbytes)
+static __be32 *read_buf(struct xdr_stream *xdr, unsigned int nbytes)
 {
 	__be32 *p;
 
-- 
2.7.4

