Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42982 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750863Ab3GXOOz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Jul 2013 10:14:55 -0400
Date: Wed, 24 Jul 2013 10:14:53 -0400
To: Trond Myklebust <trond@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Fix attribute length
Message-ID: <20130724141453.GG23378@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The calculation of attribute length fields is too high by four because
it incorrectly includes the length field itself.

This regression was introduced by
b4a2cf76ab7c08628c62b2062dacefa496b59dfd "NFSv4: Fix a regression
against the FreeBSD server" and causes OPENs to the Linux NFS server to
fail with BADXDR errors (translated by the client into EIO).

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/nfs4xdr.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

I thought you guys had automated testing against the Linux server?  How
did this slip through into upstream?

--b.

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c74d616..d6d6754 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1118,7 +1118,7 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
 				len, ((char *)p - (char *)q) + 4);
 		BUG();
 	}
-	len = (char *)p - (char *)q - (bmval_len << 2);
+	len = (char *)p - (char *)q - (bmval_len + 1 << 2);
 	*q++ = htonl(bmval0);
 	*q++ = htonl(bmval1);
 	if (bmval_len == 3)
-- 
1.7.9.5

