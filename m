Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35539 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754290Ab2KZOkD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 09:40:03 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/8] nfsd4: simplify reading of opnum
Date: Mon, 26 Nov 2012 09:39:54 -0500
Message-Id: <1353940799-11763-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1353940799-11763-1-git-send-email-bfields@redhat.com>
References: <1353940799-11763-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The comment here is totally bogus:
	- OP_WRITE + 1 is RELEASE_LOCKOWNER.  Maybe there was some older
	  version of the spec in which that served as a sort of
	  OP_ILLEGAL?  No idea, but it's clearly wrong now.
	- In any case, I can't see that the spec says anything about
	  what to do if the client sends us less ops than promised.
	  It's clearly nutty client behavior, and we should do
	  whatever's easiest: returning an xdr error (even though it
	  won't be consistent with the error on the last op returned)
	  seems fine to me.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |   34 ++--------------------------------
 1 file changed, 2 insertions(+), 32 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 9dfad58..cfebc9c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1624,38 +1624,8 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 		op = &argp->ops[i];
 		op->replay = NULL;
 
-		/*
-		 * We can't use READ_BUF() here because we need to handle
-		 * a missing opcode as an OP_WRITE + 1. So we need to check
-		 * to see if we're truly at the end of our buffer or if there
-		 * is another page we need to flip to.
-		 */
-
-		if (argp->p == argp->end) {
-			if (argp->pagelen < 4) {
-				/* There isn't an opcode still on the wire */
-				op->opnum = OP_WRITE + 1;
-				op->status = nfserr_bad_xdr;
-				argp->opcnt = i+1;
-				break;
-			}
-
-			/*
-			 * False alarm. We just hit a page boundary, but there
-			 * is still data available.  Move pointer across page
-			 * boundary.  *snip from READ_BUF*
-			 */
-			argp->p = page_address(argp->pagelist[0]);
-			argp->pagelist++;
-			if (argp->pagelen < PAGE_SIZE) {
-				argp->end = argp->p + (argp->pagelen>>2);
-				argp->pagelen = 0;
-			} else {
-				argp->end = argp->p + (PAGE_SIZE>>2);
-				argp->pagelen -= PAGE_SIZE;
-			}
-		}
-		op->opnum = ntohl(*argp->p++);
+		READ_BUF(4);
+		READ32(op->opnum);
 
 		if (op->opnum >= FIRST_NFS4_OP && op->opnum <= LAST_NFS4_OP)
 			op->status = ops->decoders[op->opnum](argp, &op->u);
-- 
1.7.9.5

