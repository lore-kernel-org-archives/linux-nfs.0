Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38623 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757648AbaEKUxF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 16:53:05 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 35/43] nfsd4: turn off zero-copy-read in exotic cases
Date: Sun, 11 May 2014 16:52:40 -0400
Message-Id: <1399841568-19716-36-git-send-email-bfields@redhat.com>
In-Reply-To: <1399841568-19716-1-git-send-email-bfields@redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We currently allow only one read per compound, with operations before
and after whose responses will require no more than about a page to
encode.

While we don't expect clients to violate those limits any time soon,
this limitation isn't really condoned by the spec, so to future proof
the server we should lift the limitation.

At the same time we'd like to continue to support zero-copy reads.

Supporting multiple zero-copy-reads per compound would require a new
data structure to replace struct xdr_buf, which can represent only one
set of included pages.

So for now we plan to modify encode_read() to support either zero-copy
or non-zero-copy reads, and use some heuristics at the start of the
compound processing to decide whether a zero-copy read will work.

This will allow us to support more exotic compounds without introducing
a performance regression in the normal case.

Later patches handle those "exotic compounds", this one just makes sure
zero-copy is turned off in those cases.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |   13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 4dba311..f69906d 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1629,6 +1629,8 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 	struct nfsd4_op *op;
 	bool cachethis = false;
 	int max_reply = 2 * RPC_MAX_AUTH_SIZE; /* uh, kind of a guess */
+	int readcount = 0;
+	int readbytes = 0;
 	int i;
 
 	READ_BUF(4);
@@ -1679,14 +1681,21 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 		 */
 		cachethis |= nfsd4_cache_this_op(op);
 
-		max_reply += nfsd4_max_reply(argp->rqstp, op);
+		if (op->opnum == OP_READ) {
+			readcount++;
+			readbytes += nfsd4_max_reply(argp->rqstp, op);
+		} else
+			max_reply += nfsd4_max_reply(argp->rqstp, op);
 	}
 	/* Sessions make the DRC unnecessary: */
 	if (argp->minorversion)
 		cachethis = false;
-	svc_reserve(argp->rqstp, max_reply);
+	svc_reserve(argp->rqstp, max_reply + readbytes);
 	argp->rqstp->rq_cachetype = cachethis ? RC_REPLBUFF : RC_NOCACHE;
 
+	if (readcount > 1 || max_reply > PAGE_SIZE - 2*RPC_MAX_AUTH_SIZE)
+		argp->rqstp->rq_splice_ok = false;
+
 	DECODE_TAIL;
 }
 
-- 
1.7.9.5

