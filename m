Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f49.google.com ([209.85.216.49]:44653 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754019AbaCJPfC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Mar 2014 11:35:02 -0400
Received: by mail-qa0-f49.google.com with SMTP id cm18so2819767qab.8
        for <linux-nfs@vger.kernel.org>; Mon, 10 Mar 2014 08:35:01 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] svcrpc: explicitly reject compounds that are not padded out to 4-byte multiple
Date: Mon, 10 Mar 2014 11:34:55 -0400
Message-Id: <1394465695-727-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We have a WARN_ON in the nfsd4_decode_write() that tells us when the
client has sent a request that is not padded out properly according to
RFC4506. A WARN_ON really isn't appropriate in this case though since
this indicates a client bug, not a server one.

Move this check out to the top-level compound decoder and have it just
explicitly return an error. Also add a dprintk() that shows the client
address and xid to help track down clients and frames that trigger it.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 63f2395c57ed..3a491dade169 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1222,7 +1222,6 @@ nfsd4_decode_write(struct nfsd4_compoundargs *argp, struct nfsd4_write *write)
 	}
 	write->wr_head.iov_base = p;
 	write->wr_head.iov_len = avail;
-	WARN_ON(avail != (XDR_QUADLEN(avail) << 2));
 	write->wr_pagelist = argp->pagelist;
 
 	len = XDR_QUADLEN(write->wr_buflen) << 2;
@@ -3691,6 +3690,12 @@ int nfsd4_release_compoundargs(void *rq, __be32 *p, void *resp)
 int
 nfs4svc_decode_compoundargs(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compoundargs *args)
 {
+	if (rqstp->rq_arg.head[0].iov_len % 4) {
+		/* client is nuts */
+		dprintk("%s: compound not properly padded! (peeraddr=%pISc xid=0x%x)",
+			__func__, svc_addr(rqstp), be32_to_cpu(rqstp->rq_xid));
+		return 0;
+	}
 	args->p = p;
 	args->end = rqstp->rq_arg.head[0].iov_base + rqstp->rq_arg.head[0].iov_len;
 	args->pagelist = rqstp->rq_arg.pages;
-- 
1.8.5.3

