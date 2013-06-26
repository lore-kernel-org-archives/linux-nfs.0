Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35123 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752267Ab3FZTVb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Jun 2013 15:21:31 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/7] nfsd4: minor read_buf cleanup
Date: Wed, 26 Jun 2013 15:21:22 -0400
Message-Id: <1372274488-4752-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1372274488-4752-1-git-send-email-bfields@redhat.com>
References: <1372274488-4752-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The code to step to the next page seems reasonably self-contained.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index e34f5eb..c102d25 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -139,6 +139,19 @@ xdr_error:					\
 	}					\
 } while (0)
 
+static void next_decode_page(struct nfsd4_compoundargs *argp)
+{
+	argp->pagelist++;
+	argp->p = page_address(argp->pagelist[0]);
+	if (argp->pagelen < PAGE_SIZE) {
+		argp->end = argp->p + (argp->pagelen>>2);
+		argp->pagelen = 0;
+	} else {
+		argp->end = argp->p + (PAGE_SIZE>>2);
+		argp->pagelen -= PAGE_SIZE;
+	}
+}
+
 static __be32 *read_buf(struct nfsd4_compoundargs *argp, u32 nbytes)
 {
 	/* We want more bytes than seem to be available.
@@ -166,16 +179,7 @@ static __be32 *read_buf(struct nfsd4_compoundargs *argp, u32 nbytes)
 	 * guarantee p points to at least nbytes bytes.
 	 */
 	memcpy(p, argp->p, avail);
-	/* step to next page */
-	argp->pagelist++;
-	argp->p = page_address(argp->pagelist[0]);
-	if (argp->pagelen < PAGE_SIZE) {
-		argp->end = argp->p + (argp->pagelen>>2);
-		argp->pagelen = 0;
-	} else {
-		argp->end = argp->p + (PAGE_SIZE>>2);
-		argp->pagelen -= PAGE_SIZE;
-	}
+	next_decode_page(argp);
 	memcpy(((char*)p)+avail, argp->p, (nbytes - avail));
 	argp->p += XDR_QUADLEN(nbytes - avail);
 	return p;
-- 
1.8.1.4

