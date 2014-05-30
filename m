Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:54201 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932205AbaE3NN4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 May 2014 09:13:56 -0400
Received: by mail-qg0-f51.google.com with SMTP id q107so5259698qgd.10
        for <linux-nfs@vger.kernel.org>; Fri, 30 May 2014 06:13:55 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: trond.myklebust@primarydata.com, bhalevy@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH 10/9] nfsd: remove initial assignment of "p" in nfsd4_encode_security_label
Date: Fri, 30 May 2014 09:13:47 -0400
Message-Id: <1401455627-18628-1-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1401455373-18207-1-git-send-email-jlayton@primarydata.com>
References: <1401455373-18207-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"pp" is no longer passed to this function, and "p" is clobbered just
afterward anyway.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 1bac00040706..d3a576dbd99b 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1981,7 +1981,7 @@ static inline __be32
 nfsd4_encode_security_label(struct xdr_stream *xdr, struct svc_rqst *rqstp,
 			    void *context, int len)
 {
-	__be32 *p = *pp;
+	__be32 *p;
 
 	p = xdr_reserve_space(xdr, len + 4 + 4 + 4);
 	if (!p)
-- 
1.9.3

