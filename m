Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43324 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750870AbaEVTcc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:32:32 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 04/52] nfsd4: decoding errors can still be cached and require space
Date: Thu, 22 May 2014 15:31:39 -0400
Message-Id: <1400787148-25941-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-1-git-send-email-bfields@redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Currently a non-idempotent op reply may be cached if it fails in the
proc code but not if it fails at xdr decoding.  I doubt there are any
xdr-decoding-time errors that would make this a problem in practice, so
this probably isn't a serious bug.

The space estimates should also take into account space required for
encoding of error returns.  Again, not a practical problem, though it
would become one after future patches which will tighten the space
estimates.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |  2 ++
 fs/nfsd/nfs4xdr.c  | 10 +++++-----
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 2c1ee70..26995a5 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1215,6 +1215,8 @@ static inline struct nfsd4_operation *OPDESC(struct nfsd4_op *op)
 
 bool nfsd4_cache_this_op(struct nfsd4_op *op)
 {
+	if (op->opnum == OP_ILLEGAL)
+		return false;
 	return OPDESC(op)->op_flags & OP_CACHEME;
 }
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 18881f3..e866a06 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1677,11 +1677,6 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 			op->opnum = OP_ILLEGAL;
 			op->status = nfserr_op_illegal;
 		}
-
-		if (op->status) {
-			argp->opcnt = i+1;
-			break;
-		}
 		/*
 		 * We'll try to cache the result in the DRC if any one
 		 * op in the compound wants to be cached:
@@ -1689,6 +1684,11 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 		cachethis |= nfsd4_cache_this_op(op);
 
 		max_reply = max(max_reply, nfsd4_max_reply(op->opnum));
+
+		if (op->status) {
+			argp->opcnt = i+1;
+			break;
+		}
 	}
 	/* Sessions make the DRC unnecessary: */
 	if (argp->minorversion)
-- 
1.9.0

