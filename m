Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36388 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751740AbdHRPMU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Aug 2017 11:12:20 -0400
Received: by mail-io0-f196.google.com with SMTP id j32so5827949iod.3
        for <linux-nfs@vger.kernel.org>; Fri, 18 Aug 2017 08:12:20 -0700 (PDT)
Subject: [PATCH v1 1/3] nfsd: Limit end of page list when decoding NFSv4
 WRITE
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Fri, 18 Aug 2017 11:12:19 -0400
Message-ID: <20170818151219.26571.31977.stgit@klimt.1015granger.net>
In-Reply-To: <20170818150957.26571.12169.stgit@klimt.1015granger.net>
References: <20170818150957.26571.12169.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When processing an NFSv4 WRITE operation, argp->end should never
point past the end of the data in the final page of the page list.
Otherwise, nfsd4_decode_compound can walk into uninitialized memory.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4xdr.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 51e729a..7c48d68 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -144,7 +144,7 @@ static void next_decode_page(struct nfsd4_compoundargs *argp)
 	argp->p = page_address(argp->pagelist[0]);
 	argp->pagelist++;
 	if (argp->pagelen < PAGE_SIZE) {
-		argp->end = argp->p + (argp->pagelen>>2);
+		argp->end = argp->p + XDR_QUADLEN(argp->pagelen);
 		argp->pagelen = 0;
 	} else {
 		argp->end = argp->p + (PAGE_SIZE>>2);
@@ -1279,9 +1279,7 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
 		argp->pagelen -= pages * PAGE_SIZE;
 		len -= pages * PAGE_SIZE;
 
-		argp->p = (__be32 *)page_address(argp->pagelist[0]);
-		argp->pagelist++;
-		argp->end = argp->p + XDR_QUADLEN(PAGE_SIZE);
+		next_decode_page(argp);
 	}
 	argp->p += XDR_QUADLEN(len);
 

