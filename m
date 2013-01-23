Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:17879 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752421Ab3AWWzk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jan 2013 17:55:40 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r0NMteLq000600
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 23 Jan 2013 17:55:40 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/7] nfsd4: encode_rdattr_error cleanup
Date: Wed, 23 Jan 2013 17:55:35 -0500
Message-Id: <1358981738-5649-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1358981738-5649-1-git-send-email-bfields@redhat.com>
References: <1358981738-5649-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

There's a simpler way to write this.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index f1b6aac..a7876f7 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2514,17 +2514,14 @@ out_put:
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
1.7.11.7

