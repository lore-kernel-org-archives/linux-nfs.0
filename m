Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36417 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751740AbdHRPM3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Aug 2017 11:12:29 -0400
Received: by mail-io0-f193.google.com with SMTP id j32so5828188iod.3
        for <linux-nfs@vger.kernel.org>; Fri, 18 Aug 2017 08:12:28 -0700 (PDT)
Subject: [PATCH v1 2/3] nfsd: Incoming xdr_bufs may have content in tail
 buffer
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Fri, 18 Aug 2017 11:12:27 -0400
Message-ID: <20170818151227.26571.61022.stgit@klimt.1015granger.net>
In-Reply-To: <20170818150957.26571.12169.stgit@klimt.1015granger.net>
References: <20170818150957.26571.12169.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since the beginning, svcsock has built a received RPC Call message
by populating the xdr_buf's head, then placing the remaining
message bytes in the xdr_buf's page list. The xdr_buf's tail is
never populated.

This means that an NFSv4 COMPOUND containing an NFS WRITE operation
plus trailing operations has a page list that contains the WRITE
data payload followed by the trailing operations. NFSv4 XDR decoders
will not look in the xdr_buf's tail, ever, because svcsock never put
anything there.

To support transports that can pass the write payload in the
xdr_buf's pagelist and trailing content in the xdr_buf's tail,
introduce logic in READ_BUF that switches to the xdr_buf's tail vec
when the decoder runs out of content in rq_arg.pages.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4xdr.c |   20 ++++++++++++++++++++
 fs/nfsd/xdr4.h    |    1 +
 2 files changed, 21 insertions(+)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 7c48d68..a9f88cf 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -159,6 +159,25 @@ static __be32 *read_buf(struct nfsd4_compoundargs *argp, u32 nbytes)
 	 */
 	unsigned int avail = (char *)argp->end - (char *)argp->p;
 	__be32 *p;
+
+	if (argp->pagelen == 0) {
+		struct kvec *vec = &argp->rqstp->rq_arg.tail[0];
+
+		if (!argp->tail) {
+			argp->tail = true;
+			avail = vec->iov_len;
+			argp->p = vec->iov_base;
+			argp->end = vec->iov_base + avail;
+		}
+
+		if (avail < nbytes)
+			return NULL;
+
+		p = argp->p;
+		argp->p += XDR_QUADLEN(nbytes);
+		return p;
+	}
+
 	if (avail + argp->pagelen < nbytes)
 		return NULL;
 	if (avail + PAGE_SIZE < nbytes) /* need more than a page !! */
@@ -4573,6 +4592,7 @@ void nfsd4_release_compoundargs(struct svc_rqst *rqstp)
 	args->end = rqstp->rq_arg.head[0].iov_base + rqstp->rq_arg.head[0].iov_len;
 	args->pagelist = rqstp->rq_arg.pages;
 	args->pagelen = rqstp->rq_arg.page_len;
+	args->tail = false;
 	args->tmpp = NULL;
 	args->to_free = NULL;
 	args->ops = args->iops;
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 72c6ad1..bac91b1 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -614,6 +614,7 @@ struct nfsd4_compoundargs {
 	__be32 *			end;
 	struct page **			pagelist;
 	int				pagelen;
+	bool				tail;
 	__be32				tmp[8];
 	__be32 *			tmpp;
 	struct svcxdr_tmpbuf		*to_free;

