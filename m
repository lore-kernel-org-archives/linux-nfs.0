Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35122 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752027Ab3FZTVa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Jun 2013 15:21:30 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>, stable@vger.kernel.org
Subject: [PATCH 1/7] nfsd4: fix decoding across page boundaries
Date: Wed, 26 Jun 2013 15:21:21 -0400
Message-Id: <1372274488-4752-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1372274488-4752-1-git-send-email-bfields@redhat.com>
References: <1372274488-4752-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

nfsd4: fix decoding of compounds across page boundaries

A freebsd NFSv4.0 client was getting rare IO errors expanding a tarball.
A network trace showed the server returning BAD_XDR on the final getattr
of a getattr+write+getattr compound.  The final getattr started on a
page boundary.

I believe the Linux client ignores errors on the post-write getattr, and
that that's why we haven't seen this before.

Cc: stable@vger.kernel.org
Reported-by: Rick Macklem <rmacklem@uoguelph.ca>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 171fe5e4..e34f5eb 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -167,8 +167,8 @@ static __be32 *read_buf(struct nfsd4_compoundargs *argp, u32 nbytes)
 	 */
 	memcpy(p, argp->p, avail);
 	/* step to next page */
-	argp->p = page_address(argp->pagelist[0]);
 	argp->pagelist++;
+	argp->p = page_address(argp->pagelist[0]);
 	if (argp->pagelen < PAGE_SIZE) {
 		argp->end = argp->p + (argp->pagelen>>2);
 		argp->pagelen = 0;
-- 
1.8.1.4

