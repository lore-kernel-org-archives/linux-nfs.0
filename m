Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37336 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753215Ab3KTBm3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Nov 2013 20:42:29 -0500
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1ViwoG-0008DY-V3
	for linux-nfs@vger.kernel.org; Tue, 19 Nov 2013 20:42:29 -0500
Date: Tue, 19 Nov 2013 20:42:28 -0500
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd4: fix xdr decoding of large non-write compounds
Message-ID: <20131120014228.GB27364@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This fixes a regression from 247500820ebd02ad87525db5d9b199e5b66f6636
"nfsd4: fix decoding of compounds across page boundaries".  The previous
code was correct: argp->pagelist is initialized in
nfs4svc_deocde_compoundargs to rqstp->rq_arg.pages, and is therefore a
pointer to the page *after* the page we are currently decoding.

The reason that patch nevertheless fixed a problem with decoding
compounds containing write was a bug in the write decoding introduced by
5a80a54d21c96590d013378d8c5f65f879451ab4 "nfsd4: reorganize write
decoding", after which write decoding no longer adhered to the rule that
argp->pagelist point to the next page.

Cc: stable@vger.kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

I'm queueing this up for 3.13.

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 088de13..ee7237f 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -141,8 +141,8 @@ xdr_error:					\
 
 static void next_decode_page(struct nfsd4_compoundargs *argp)
 {
-	argp->pagelist++;
 	argp->p = page_address(argp->pagelist[0]);
+	argp->pagelist++;
 	if (argp->pagelen < PAGE_SIZE) {
 		argp->end = argp->p + (argp->pagelen>>2);
 		argp->pagelen = 0;
@@ -1229,6 +1229,7 @@ nfsd4_decode_write(struct nfsd4_compoundargs *argp, struct nfsd4_write *write)
 		len -= pages * PAGE_SIZE;
 
 		argp->p = (__be32 *)page_address(argp->pagelist[0]);
+		argp->pagelist++;
 		argp->end = argp->p + XDR_QUADLEN(PAGE_SIZE);
 	}
 	argp->p += XDR_QUADLEN(len);
-- 
1.7.9.5

