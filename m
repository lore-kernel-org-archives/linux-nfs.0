Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55902 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752996AbaAGVFN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jan 2014 16:05:13 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/4] nfsd4: encode_rdattr_error cleanup
Date: Tue,  7 Jan 2014 16:04:34 -0500
Message-Id: <1389128674-16951-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1389128674-16951-1-git-send-email-bfields@redhat.com>
References: <1389128674-16951-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

There's a simpler way to write this.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 3bffba6..67b4496 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2620,17 +2620,14 @@ out_put:
 static __be32 *
 nfsd4_encode_rdattr_error(__be32 *p, int buflen, __be32 nfserr)
 {
-	__be32 *attrlenp;
-
 	if (buflen < 6)
 		return NULL;
 	*p++ = htonl(2);
 	*p++ = htonl(FATTR4_WORD0_RDATTR_ERROR); /* bmval0 */
 	*p++ = htonl(0);			 /* bmval1 */
 
-	attrlenp = p++;
+	*p++ = htonl(4);     /* attribute length */
 	*p++ = nfserr;       /* no htonl */
-	*attrlenp = htonl((char *)p - (char *)attrlenp - 4);
 	return p;
 }
 
-- 
1.7.9.5

